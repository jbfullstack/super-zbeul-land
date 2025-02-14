extends BasePlayerController
class_name NetworkPlayerController

@onready var player_hud = %PlayerHUD
@onready var pseudo_lbl = %PseudoLbl as Label
var spawner_manager

@export var player_id := 1:
	set(id):
		player_id = id
		%InputSynchronizer.set_multiplayer_authority(id)

@export var pseudo := "undefined":
	set(name):
		pseudo = name
		%PseudoLbl.text = name

static func _name() -> String:
	return "NetworkPlayerController"

func _ready():
	super._ready()
	
	if multiplayer.get_unique_id() == player_id:
		$Camera2D.make_current()
		GameManager.current_player = self
		player_hud.init(player_id)
	else:
		$Camera2D.enabled = false
		player_hud.queue_free()
	
	var game_node = get_tree().root.get_node("Game")
	if game_node and game_node.has_node("SpawnerManager"):
		spawner_manager = game_node.get_node("SpawnerManager")
	else:
		push_error("No SpawnerManager found [%s]" % player_id)
	
	visibility_manager.setup($AnimatedSprite2D, $PseudoLbl)


func _physics_process(_delta):
	# Serveur gère l'input
	if multiplayer.is_server():
		if get_multiplayer_authority() == multiplayer.get_unique_id():
			_input_state.direction = %InputSynchronizer.input_direction
			_input_state.joystick_direction = %InputSynchronizer.joystick_direction

	super._physics_process(_delta)
	
func post_physics_update():
	_input_state.reset_one_shot_actions()
	
func _respawn():
	super._respawn()
	position = spawner_manager.respawn_point

func _set_alive():
	super._set_alive()
	GameManager.UpdateScoreInformation(player_id, -1)

func update_score():
	player_hud.UpdateScoreHUD.rpc()
