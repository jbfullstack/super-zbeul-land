extends MultiplayerSynchronizer

@onready var player = $".."

var input_direction = 0.0

func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)

func _physics_process(_delta):
	input_direction = Input.get_axis("move_left", "move_right")

func _process(_delta):
	if Input.is_action_just_pressed("jump"):
		jump.rpc()
	
	if Input.is_action_just_pressed("down"):
		down.rpc()

@rpc("call_local")
func jump():
	if multiplayer.is_server():
		player._input_state.should_jump = true

@rpc("call_local")
func down():
	if multiplayer.is_server():
		player._input_state.should_down = true
