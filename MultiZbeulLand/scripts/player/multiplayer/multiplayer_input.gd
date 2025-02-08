extends MultiplayerSynchronizer

@onready var player = $".."

var input_direction 

func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
	
	input_direction = Input.get_axis("move_left", "move_right")

func _physics_process(_delta):
	input_direction = Input.get_axis("move_left", "move_right")

func _process(_delta):
	if Input.is_action_just_pressed("jump"):
		jump.rpc()
	
	if Input.is_action_just_pressed("down"):
		down.rpc()
		
	if Input.is_action_just_pressed("invisible"):
		invisible.rpc()

@rpc("call_local")
func jump():
	if multiplayer.is_server():
		player.do_jump = true
		
@rpc("call_local")
func down():
	if multiplayer.is_server():
		player.do_down = true
		
@rpc("any_peer", "call_local")
func invisible():
	if multiplayer.is_server():
		# Toggle visibility state
		if player.is_invisible:
			player._reset_alpha(get_multiplayer_authority())
		else:
			player._set_invisible(get_multiplayer_authority())
