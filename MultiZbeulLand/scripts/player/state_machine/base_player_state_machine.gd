extends Node
class_name BasePlayerStateMachine

@export var initial_state: NodePath
var current_state: BasePlayerState
var previous_state: BasePlayerState
var states: Dictionary = {}

var preserve_momentum: bool = false

func _ready() -> void:
	# Wait for owner to be ready
	await owner.ready
	print_d("StateMachine ready, setting up states...")
	
	set_physics_process(false)
	
	# Configure player reference for all states recursively
	_setup_states(self)
	print_d("Available states after setup: ", states.keys())
	
	# Initialize initial state
	if initial_state:
		var initial_state_node = get_node(initial_state)
		if initial_state_node is BasePlayerState:
			print_d("Setting initial state: ", initial_state_node.name)
			_change_state(initial_state_node.name)
	else:
		var first_state = states.values()[0] if not states.is_empty() else null
		if first_state:
			print_d("Setting first state as initial: ", first_state.name)
			_change_state(first_state.name)
		else:
			push_warning("No states found in state machine!")

func _setup_states(node: Node) -> void:
	print_d("Checking node: ", node.name)
	for child in node.get_children():
		print_d("Examining child: ", child.name, " of type: ", child.get_class())
		# First check if it's a group node (like Landborne or Airborne)
		if child.get_class() == "Node":
			print_d("Found group node: ", child.name, ", checking its children...")
			_setup_states(child)
		
		if child is BasePlayerState:
			# Add state to dictionary
			states[child.name] = child
			child.player = owner as BasePlayerController
			child.state_finished.connect(_change_state)
			print_d("  Added state: ", child.name)
			
			# Also check this state's children
			_setup_states(child)

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		var player = owner as BasePlayerController
		
		# If it's a NetworkPlayerController
		if player is NetworkPlayerController:
			# Only server processes physics
			if multiplayer.is_server():
				if player.get_multiplayer_authority() == multiplayer.get_unique_id():
					current_state.physics_update(delta)
			# Clients only process animations
			elif !multiplayer.is_server() or NetworkController.host_mode_enabled:
				current_state.animation_update(delta)
		# If it's a LocalPlayerController, everything is processed normally
		else:
			current_state.physics_update(delta)

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

func _change_state(new_state_name: String) -> void:
	print_d("Trying to change state from ", current_state.name if current_state else "null", " to ", new_state_name)
	
	if new_state_name in states:
		if current_state:
			print_d("Exiting state: ", current_state.name)
			current_state.exit()
			
		var new_state = states[new_state_name]
		print_d("Found new state: ", new_state.name)
		if current_state != null:
			previous_state = current_state
		else:
			previous_state = new_state
			
		current_state = new_state
		print_d("Current state set to: ", current_state.name)
		current_state.enter()
		print_d("State entered successfully")
	else:
		push_error("State " + new_state_name + " not found in state machine! Available states: " + str(states.keys()))

func print_d(arg1, arg2 = "", arg3 = "", arg4 = "", arg5 = "", arg6 = ""):
	if DebugUtils.debug_player_state_machine:
		# Filter out empty default arguments and convert to strings
		var args = Array([arg1, arg2, arg3, arg4, arg5, arg6])
		args = args.filter(func(arg): return arg != "")
		var final_msg = " ".join(args.map(func(arg): return str(arg)))
		
		if NetworkController.multiplayer_mode_enabled:
			print("%s  [%s]" % [final_msg, multiplayer.get_unique_id()])
		else:
			print(final_msg)
