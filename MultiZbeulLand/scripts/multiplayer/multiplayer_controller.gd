extends CharacterBody2D
class_name MultiplayerController

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
# WALL STUFF
const WALL_SLIDE_SPEED = 50.0  # Speed of wall sliding
const WALL_JUMP_VELOCITY = Vector2(300.0, -250.0)  # Wall jump force
const WALL_JUMP_TIME = 0.1  # Time in seconds before normal movement resumes

@onready var animated_sprite = $AnimatedSprite2D as AnimatedSprite2D
@onready var player_hud = %PlayerHUD
@onready var pseudo_lbl = %PseudoLbl as Label


@onready var visibility_manager: VisibilityManager



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var spawner_manager
var current_pipe = null

var direction = 1
var do_jump = false
var do_down = false
var do_invisible = false

var _is_on_floor = true
var alive = true
var is_invisible: bool:
	get:
		return visibility_manager.is_invisible if visibility_manager else false

var is_wall_sliding = false
var wall_normal = Vector2.ZERO  # Direction of the wall normal
var wall_jump_timer = 0.0


var nb_collected_coin = 0

@export var player_id := 1:
	set(id):
		player_id = id
		%InputSynchronizer.set_multiplayer_authority(id)

@export var pseudo := "undefined":
	set(name):
		pseudo = name
		%PseudoLbl.text = name

static func _name() -> String:
	return "MultiplayerController"

func getShape():
	return self.get_node("CollisionShape2D")
	
func _ready():
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
		push_error("No SpawnerManager found  [%]", % player_id)
		
	visibility_manager = VisibilityManager.new()
	add_child(visibility_manager)
	visibility_manager.setup(animated_sprite, pseudo_lbl)
		
	#$PseudoLbl.text = pseudo
	#print("pseudo: %s" % pseudo)
	
	

func _apply_animations(_delta):
	# Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Play animations
	if _is_on_floor:
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	elif is_wall_sliding:
		# TODO: Wall side animation
		print("wallslide animation")
		animated_sprite.play("idle")
	else:
		animated_sprite.play("jump")

func _apply_movement_from_input(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# Wall slide check
	is_wall_sliding = false
	if not is_on_floor() and is_on_wall():
		wall_normal = get_wall_normal()
		is_wall_sliding = true
		print("is_wall_sliding")
		velocity.y = min(velocity.y, WALL_SLIDE_SPEED)
		
	# Handle wall jump
	if wall_jump_timer > 0:
		wall_jump_timer -= delta

	# Handle jump.
	if do_jump:
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif is_wall_sliding:
			# Wall jump
			print("wall jump")
			velocity = Vector2(wall_normal.x * WALL_JUMP_VELOCITY.x, WALL_JUMP_VELOCITY.y)
			wall_jump_timer = WALL_JUMP_TIME
		do_jump = false
		
	if do_down:
		if current_pipe != null:
			print("Down with pipe  [%s]" % player_id)
			current_pipe.teleport_player(self)
		do_down = false
		
	#if do_invisible:
		## make semi visible locally
		#if !is_invisible:
			#if multiplayer.is_server():
				#_set_invisible(player_id)
		#else:
			#if multiplayer.is_server():
				#_reset_alpha(player_id)
		#do_invisible = false

	# Get the input direction: -1, 0, 1
	direction = %InputSynchronizer.input_direction
	
	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _physics_process(delta):
	if multiplayer.is_server():
		if not alive && is_on_floor():
			_set_alive()
		
		_is_on_floor = is_on_floor()
		_apply_movement_from_input(delta)
		
	if not multiplayer.is_server() || NetworkController.host_mode_enabled:
		_apply_animations(delta)

func mark_dead():
	print("Mark player dead!  [%s]" % player_id)
	alive = false
	
	$CollisionShape2D.set_deferred("disabled", true)
	$RespawnTimer.start()

func _respawn():
	print("Respawned!  [%s]" % player_id)
	position = spawner_manager.respawn_point
	$CollisionShape2D.set_deferred("disabled", false)

func _set_alive():
	print("Alive again!  [%s]" % player_id)
	GameManager.UpdateScoreInformation(player_id, -1)
	alive = true
	Engine.time_scale = 1.0

func update_score():
	player_hud.UpdateScoreHUD.rpc()

# ------------------------------------------
#                POWER
# ------------------------------------------
func _set_invisible(authority_id: int):
	visibility_manager.set_invisible(authority_id)

func _reset_alpha(authority_id: int):
	visibility_manager.reset_alpha(authority_id)

