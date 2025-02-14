extends BasePlayerController
class_name LocalPlayerController

static func _name() -> String:
	return "LocalPlayerController"

func _ready():
	super._ready()
	GameManager.current_player = self
	
	# Debug prints with correct variable reference
	if $StateMachine:
		print("LocalPlayer ready, StateMachine found")
		print("Initial state: ", $StateMachine.current_state)
	else:
		push_error("StateMachine node not found!")

func _physics_process(_delta):
	# Update input state
	_input_state.direction = Input.get_axis("move_left", "move_right")
	_input_state.joystick_direction =Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
	
	_input_state.should_start_run = Input.is_action_just_pressed("run")
	if (_input_state.should_start_run):
		_input_state.is_run_action_activated = true
	_input_state.should_stop_run = Input.is_action_just_released("run")
	if (_input_state.should_stop_run):
		_input_state.is_run_action_activated = false
	_input_state.should_jump = Input.is_action_just_pressed("jump")
	_input_state.jump_just_released = Input.is_action_just_released("jump")
	_input_state.should_down = Input.is_action_just_pressed("down")
	_input_state.should_grapple_action = Input.is_action_just_pressed("grapple")
	
	super._physics_process(_delta)
	
	# Ne pas reset les actions ici, ça sera fait APRÈS que la physique soit traitée
	# _input_state.reset_one_shot_actions()

# Nouveau: une fonction qui sera appelée après le physics_process pour reset les inputs
func post_physics_update():
	_input_state.reset_one_shot_actions()
