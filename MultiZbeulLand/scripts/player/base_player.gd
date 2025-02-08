extends CharacterBody2D
class_name BasePlayerController

# Movement constants
const SPEED = 130.0
const JUMP_VELOCITY = -300.0

# Wall mechanics constants
const WALL_SLIDE_SPEED = 50.0
const WALL_JUMP_VELOCITY = Vector2(100.0, -250.0)
const WALL_JUMP_TIME = 0.1
const WALL_SLIDE_SUPER_SLOW = 5.0
const WALL_SLIDE_SUPER_FAST = 100.0
const WALL_JUMP_OPPOSITE_FORCE = 1.5
const WALL_SLIDE_MIN_TIME = 0.3
const WALL_JUMP_NO_CONTROL_TIME = 0.25
const WALL_COYOTE_TIME = 0.1

# Timers
var wall_coyote_timer = 0.0
var has_wall_coyote = false

# State variables
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_pipe = null
var nb_collected_coin = 0
var _is_on_floor = false
var is_wall_sliding = false
var wall_normal = Vector2.ZERO
var last_wall_normal = Vector2.ZERO
var wall_jump_timer = 0.0
var was_on_wall = false
var last_jump_side = 0
var slow_slide_timer = 0.0
var no_control_timer = 0.0
var alive = true
var _input_state: PlayerInputState
var collision_rayon

var is_invisible: bool:
	get:
		return visibility_manager.is_invisible if visibility_manager else false

@onready var animated_sprite = $AnimatedSprite2D as AnimatedSprite2D
@onready var visibility_manager = %Invisibility

static func _name() -> String:
	return "BasePlayerController"

func getShape():
	return self.get_node("CollisionShape2D")

func _ready():
	_input_state = PlayerInputState.new()
	var collision = $CollisionShape2D as CollisionShape2D
	collision_rayon = collision.get_shape().radius

func _physics_process(delta):
	if not alive && is_on_floor():
		_set_alive()

	_update_state()
	_handle_movement(delta)
	_handle_animations(delta)

func _update_state():
	_is_on_floor = is_on_floor()
	was_on_wall = is_on_wall()

func _handle_movement(delta):
	_apply_gravity(delta)
	_handle_wall_mechanics(delta)
	_handle_wall_coyote_time(delta)
	_update_no_control_timer(delta)
	_handle_jump()
	_handle_pipe_teleport()
	_apply_horizontal_movement()
	move_and_slide()

func _apply_gravity(delta):
	if not _is_on_floor:
		velocity.y += gravity * delta

func _handle_wall_mechanics(delta):
	is_wall_sliding = false
	if not _is_on_floor and is_on_wall():
		_handle_wall_slide(delta)
	else:
		slow_slide_timer = 0.0

func _handle_wall_slide(delta):
	wall_normal = get_wall_normal()
	is_wall_sliding = true
	
	_check_new_wall()
	_update_wall_slide_speed(delta)
	_reset_wall_coyote()

func _check_new_wall():
	if wall_normal != last_wall_normal:
		last_wall_normal = wall_normal
		last_jump_side = 0

func _update_wall_slide_speed(delta):
	var pushing_into_wall = sign(_input_state.direction) == -sign(wall_normal.x)
	if pushing_into_wall:
		velocity.y = min(velocity.y, WALL_SLIDE_SUPER_SLOW)
		slow_slide_timer += delta
		if slow_slide_timer >= WALL_SLIDE_MIN_TIME:
			last_jump_side = 0
	else:
		velocity.y = min(velocity.y, WALL_SLIDE_SPEED)
		slow_slide_timer = 0.0

func _reset_wall_coyote():
	wall_coyote_timer = 0.0
	has_wall_coyote = false

func _handle_wall_coyote_time(delta):
	if was_on_wall and !is_on_wall():
		wall_coyote_timer = WALL_COYOTE_TIME
		has_wall_coyote = true
	
	if wall_coyote_timer > 0:
		wall_coyote_timer -= delta
		if wall_coyote_timer <= 0:
			has_wall_coyote = false

func _update_no_control_timer(delta):
	if no_control_timer > 0:
		no_control_timer -= delta

func _handle_jump():
	if not _input_state.should_jump:
		return
		
	if _is_on_floor:
		_perform_normal_jump()
	elif (is_wall_sliding or has_wall_coyote) and not _is_on_floor:
		_perform_wall_jump()

func _perform_normal_jump():
	velocity.y = JUMP_VELOCITY
	last_jump_side = 0
	
	if not has_node("JumpDustParticles"):
		return
		
	var particles = $JumpDustParticles as GPUParticles2D
	particles.emitting = true

func _perform_wall_jump():
	var current_side = sign(wall_normal.x)
	if current_side != last_jump_side:
		var jump_force = WALL_JUMP_VELOCITY
		jump_force.x *= WALL_JUMP_OPPOSITE_FORCE
		
		velocity = Vector2(wall_normal.x * jump_force.x, jump_force.y)
		last_jump_side = current_side
		no_control_timer = WALL_JUMP_NO_CONTROL_TIME

func _handle_pipe_teleport():
	if _input_state.should_down and current_pipe != null:
		current_pipe.teleport_player(self)

func _apply_horizontal_movement():
	if no_control_timer <= 0:
		if _input_state.direction:
			velocity.x = _input_state.direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

func _handle_animations(_delta):
	_update_sprite_flip()
	_update_animation()
	_handle_wall_particles()

func _update_sprite_flip():
	if velocity.x > 0:
		animated_sprite.flip_h = false
	elif velocity.x < 0:
		animated_sprite.flip_h = true

func _update_animation():
	if is_wall_sliding:
		animated_sprite.play("wall_slide")
	else:
		if is_on_floor:
			if velocity.x == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		else:
			animated_sprite.play("jump")

func _handle_wall_particles():
	if not has_node("WallDustParticles"):
		return
		
	var particles = $WallDustParticles as GPUParticles2D
	
	#TODO: manage particle position fct of collision_radius
	
	if is_wall_sliding:
		_update_wall_particles(particles)
	else:
		particles.emitting = false

func _update_wall_particles(particles: GPUParticles2D):
	particles.emitting = true
	
	var speed_ratio = (abs(velocity.y) - WALL_SLIDE_SUPER_SLOW) / (WALL_SLIDE_SPEED - WALL_SLIDE_SUPER_SLOW)
	speed_ratio = clamp(speed_ratio, 0.0, 1.0)	
	
	var process_material = particles.process_material as ParticleProcessMaterial
	if process_material:
		process_material.emission_box_extents.y = lerp(1.0, 3.0, speed_ratio)
		process_material.initial_velocity_min = lerp(5.0, 20.0, speed_ratio)
		process_material.initial_velocity_max = lerp(10.0, 30.0, speed_ratio)
		particles.scale.x = _input_state.direction		
		particles.amount = int(lerp(4, 12, speed_ratio))

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

func _set_invisible(authority_id: int):
	if visibility_manager:
		visibility_manager.set_invisible(authority_id)

func _reset_alpha(authority_id: int):
	if visibility_manager:
		visibility_manager.reset_alpha(authority_id)
