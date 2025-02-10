extends CharacterBody2D
class_name BasePlayerController

@onready var coyote_timer: Timer = $CoyoteJumpTimer
var coyote_used: bool = false

# State variables
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_pipe = null
var nb_collected_coin = 0
var alive = true
var wall_normal = Vector2.ZERO
var last_wall_normal = Vector2.ZERO
var is_wall_sliding = false
var last_jump_side = 0

# Protected variables for child classes
var _input_state: PlayerInputState
var is_invisible: bool:
	get:
		return visibility_manager.is_invisible if visibility_manager else false

@onready var animated_sprite = $AnimatedSprite2D as AnimatedSprite2D
@onready var visibility_manager = %Invisibility
@onready var state_machine = $StateMachine as BasePlayerStateMachine

func _ready() -> void:
	_input_state = PlayerInputState.new()
	# Ensure that all states have access to the player
	for state in state_machine.get_children():
		if state is BasePlayerState:
			state.player = self
	# Ensure that particles are disabled on start
	if has_node("WallDustParticles"):
		$WallDustParticles.emitting = false

func getShape():
	return self.get_node("CollisionShape2D")

func _physics_process(delta):
	if not alive && is_on_floor():
		_set_alive()
	
	# When on the floor, stop the coyote timer and reset the flag.
	if is_on_floor():
		coyote_timer.stop()
		coyote_used = false
	else:
		# Only start the coyote timer if it's not running and we haven't used it yet.
		if not coyote_used and coyote_timer.is_stopped():
			coyote_timer.start(PlayerStates.WALL_COYOTE_TIME)
				
	# Execute normal physics logic via the state machine.
	$StateMachine._physics_process(delta)
	
	# Then reset one-shot actions.
	post_physics_update()

# Function to be overridden by children
func post_physics_update():
	pass

func floor_is_colliding_with_raycast() -> bool:
	for ray in get_node("RayCastNode/FloorRayCasts").get_children():
		if ray is RayCast2D and ray.is_enabled() and ray.is_colliding():
			return true
	return false
	
func left_wall_is_colliding_with_raycast() -> bool:
	for ray in get_node("RayCastNode/LeftWallRayCasts").get_children():
		if ray is RayCast2D and ray.is_enabled() and ray.is_colliding():
			return true
	return false
	
func right_wall_is_colliding_with_raycast() -> bool:
	for ray in get_node("RayCastNode/RightWallRayCasts").get_children():
		if ray is RayCast2D and ray.is_enabled() and ray.is_colliding():
			return true
	return false
	
func check_edge_correction():
	var right_floor_ray = get_node("RayCastNode/FloorRayCasts/RightFloorRayCast2D")
	var left_floor_ray = get_node("RayCastNode/FloorRayCasts/LeftFloorRayCast2D")
	var right_correction_floor_ray = get_node("RayCastNode/EdgeCorrectionCasts/RightCorrectionFloorRayCast2D")
	var left_correction_floor_ray = get_node("RayCastNode/EdgeCorrectionCasts/LeftCorrectionFloorRayCast2D")
	
	var right_foot_ray = get_node("RayCastNode/RightWallRayCasts/RightFootRayCast2D")
	var left_foot_ray = get_node("RayCastNode/LeftWallRayCasts/LeftFootRayCast2D")
	if right_floor_ray.is_colliding() and not right_foot_ray.is_colliding() and not right_correction_floor_ray.is_colliding():
		position.x += 2  # Nudge player left
		position.y -= 1  # Small vertical adjustment
	elif left_floor_ray.is_colliding() and not left_foot_ray.is_colliding() and not left_correction_floor_ray.is_colliding():
		position.x -= 2  # Nudge player right
		position.y -= 1  # Small vertical adjustment
	
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
