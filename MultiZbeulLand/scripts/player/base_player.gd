extends CharacterBody2D
class_name BasePlayerController

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const WALL_SLIDE_SPEED = 50.0
const WALL_JUMP_VELOCITY = Vector2(300.0, -250.0)
const WALL_JUMP_TIME = 0.1

@onready var animated_sprite = $AnimatedSprite2D as AnimatedSprite2D
@onready var visibility_manager = %Invisibility

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_pipe = null
var nb_collected_coin = 0

# Movement state
var _is_on_floor = true
var is_wall_sliding = false
var wall_normal = Vector2.ZERO
var wall_jump_timer = 0.0
var alive = true

# Input state - protected variable for child classes to access
var _input_state: PlayerInputState  # This is the important change

var is_invisible: bool:
	get:
		return visibility_manager.is_invisible if visibility_manager else false

static func _name() -> String:
	return "BasePlayerController"

func _ready():
	_input_state = PlayerInputState.new()  # Initialize the input state

func getShape():
	return self.get_node("CollisionShape2D")

func _physics_process(delta):
	if not alive && is_on_floor():
		_set_alive()
	
	_is_on_floor = is_on_floor()
	_handle_movement(delta)
	_handle_animations(delta)

func _handle_movement(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Wall slide logic
	is_wall_sliding = false
	if not is_on_floor() and is_on_wall():
		wall_normal = get_wall_normal()
		is_wall_sliding = true
		velocity.y = min(velocity.y, WALL_SLIDE_SPEED)
	
	# Wall jump timer
	if wall_jump_timer > 0:
		wall_jump_timer -= delta
	
	# Handle jump
	if _input_state.should_jump:
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif is_wall_sliding:
			velocity = Vector2(wall_normal.x * WALL_JUMP_VELOCITY.x, WALL_JUMP_VELOCITY.y)
			wall_jump_timer = WALL_JUMP_TIME
	
	# Handle down action
	if _input_state.should_down and current_pipe != null:
		current_pipe.teleport_player(self)
	
	# Apply horizontal movement
	if _input_state.direction:
		velocity.x = _input_state.direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()

func _handle_animations(_delta):
	# Handle sprite flipping
	if velocity.x > 0:
		animated_sprite.flip_h = false
	elif velocity.x < 0:
		animated_sprite.flip_h = true
	
	# Play appropriate animation
	if _is_on_floor:
		if velocity.x == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	elif is_wall_sliding:
		# TODO: Implement wall slide animation
		animated_sprite.play("idle")
	else:
		animated_sprite.play("jump")

func mark_dead():
	print("Mark player dead!")
	alive = false
	$CollisionShape2D.set_deferred("disabled", true)
	$RespawnTimer.start()

func _respawn():
	print("Respawned!")
	$CollisionShape2D.set_deferred("disabled", false)

func _set_alive():
	print("Alive again!")
	alive = true
	Engine.time_scale = 1.0

# Visibility methods
func _set_invisible(authority_id: int):
	if visibility_manager:
		visibility_manager.set_invisible(authority_id)

func _reset_alpha(authority_id: int):
	if visibility_manager:
		visibility_manager.reset_alpha(authority_id)
