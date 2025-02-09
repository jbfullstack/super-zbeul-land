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
	_input_state.should_jump = Input.is_action_just_pressed("jump")
	_input_state.should_down = Input.is_action_just_pressed("down")
	
	super._physics_process(_delta)
	
	# Ne pas reset les actions ici, ça sera fait APRÈS que la physique soit traitée
	# _input_state.reset_one_shot_actions()

# Nouveau: une fonction qui sera appelée après le physics_process pour reset les inputs
func post_physics_update():
	_input_state.reset_one_shot_actions()
