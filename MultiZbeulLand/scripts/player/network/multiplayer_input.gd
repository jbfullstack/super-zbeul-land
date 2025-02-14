extends MultiplayerSynchronizer

@onready var player = $".."

var input_direction = 0.0
var joystick_direction = Vector2.ZERO

func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)

func _physics_process(_delta):
	input_direction = Input.get_axis("move_left", "move_right")
	joystick_direction =Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
	
func _process(_delta):
	if Input.is_action_just_pressed("run"):
		start_run.rpc()
		
	if Input.is_action_just_released("run"):
		stop_run.rpc()
		
	if Input.is_action_just_pressed("jump"):
		jump.rpc()
		
	if Input.is_action_just_released("jump"):
		release_jump.rpc()
	
	if Input.is_action_just_pressed("down"):
		down.rpc()
		
	if Input.is_action_just_pressed("grapple"):
		grapple.rpc()
		
	
@rpc("call_local")
func start_run():
	if multiplayer.is_server():
		player._input_state.should_start_run = true
		player._input_state.is_run_action_activated = true
		
@rpc("call_local")
func stop_run():
	if multiplayer.is_server():
		player._input_state.should_stop_run = true
		player._input_state.is_run_action_activated = false
		
@rpc("call_local")
func jump():
	if multiplayer.is_server():
		player._input_state.should_jump = true
		
@rpc("call_local")
func release_jump():
	if multiplayer.is_server():
		player._input_state.jump_just_released = true

@rpc("call_local")
func down():
	if multiplayer.is_server():
		player._input_state.should_down = true

@rpc("call_local")
func grapple():
	if multiplayer.is_server():
		player._input_state.should_grapple_action = true
