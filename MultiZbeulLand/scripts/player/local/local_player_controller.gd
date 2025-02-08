extends BasePlayerController
class_name LocalPlayerController

static func _name() -> String:
	return "LocalPlayerController"

func _ready():
	super._ready()  # This initializes input_state in base controller
	#$Camera2D.make_current()
	GameManager.current_player = self

func _physics_process(delta):
	# Update input state before physics processing
	_input_state.direction = Input.get_axis("move_left", "move_right")
	_input_state.should_jump = Input.is_action_just_pressed("jump")
	_input_state.should_down = Input.is_action_just_pressed("down")
	
	# Call parent physics process which will use the updated input state
	super._physics_process(delta)
	
	# Reset one-shot actions after physics processing
	_input_state.reset_one_shot_actions()
