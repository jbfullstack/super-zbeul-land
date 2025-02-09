extends Node
class_name BasePlayerStateMachine

@export var initial_state: NodePath
var current_state: BasePlayerState
var states: Dictionary = {}

func _ready() -> void:
	# Attendre que le owner soit prêt
	await owner.ready
	print("StateMachine ready, setting up states...")
	
	set_physics_process(false)
	
	# Configurer la référence au player pour tous les états
	for child in get_children():
		if child is BasePlayerState:
			states[child.name] = child
			child.player = owner as BasePlayerController
			child.state_finished.connect(_change_state)
			print("Added state: ", child.name)
	
	# Initialiser l'état initial
	if initial_state:
		var initial_state_node = get_node(initial_state)
		if initial_state_node is BasePlayerState:
			print("Setting initial state: ", initial_state_node.name)
			_change_state(initial_state_node.name)
	else:
		var first_state = states.values()[0] if not states.is_empty() else null
		if first_state:
			print("Setting first state as initial: ", first_state.name)
			_change_state(first_state.name)
		else:
			push_warning("No states found in state machine!")

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		var player = owner as BasePlayerController
		
		# Si c'est un NetworkPlayerController
		if player is NetworkPlayerController:
			# Seul le serveur traite la physique
			if multiplayer.is_server():
				if player.get_multiplayer_authority() == multiplayer.get_unique_id():
					current_state.physics_update(delta)
			# Les clients ne traitent que les animations
			elif !multiplayer.is_server() or NetworkController.host_mode_enabled:
				current_state.animation_update(delta)
		# Si c'est un LocalPlayerController, tout est traité normalement
		else:
			current_state.physics_update(delta)

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

func _change_state(new_state_name: String) -> void:
	print("Trying to change state from ", current_state.name if current_state else "null", " to ", new_state_name)
	
	if new_state_name in states:
		if current_state:
			print("Exiting state: ", current_state.name)
			current_state.exit()
			
		var new_state = states[new_state_name]
		print("Found new state: ", new_state.name)
		current_state = new_state
		print("Current state set to: ", current_state.name)
		current_state.enter()
		print("State entered successfully")
	else:
		push_error("State " + new_state_name + " not found in state machine! Available states: " + str(states.keys()))
