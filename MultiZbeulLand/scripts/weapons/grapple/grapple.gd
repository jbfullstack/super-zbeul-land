# Grapple.gd - Keeps original physics and state management
extends Node
class_name Grapple

@onready var rope: GrappleRope = $Rope
var player: BasePlayerController

enum GrappleState {
	IDLE,
	FIRING,
	FIRING_NO_TARGET,
	ATTACHED,
	RETRACTING
}

var state: int = GrappleState.IDLE
var is_griping: bool:
	get:
		return state == GrappleState.FIRING or state == GrappleState.ATTACHED

var grapple_target: Vector2
var rest_length = 2.0
var stiffness = 10.0
var damping = 2.0
var raycast: RayCast2D

func _ready():
	print("Grapple ready")
	await owner.ready
	player = owner as BasePlayerController
	raycast = owner.get_node("Weapons/RayCasts/GrappleRayCast2D") as RayCast2D
	set_physics_process(false)

func _physics_process(delta):
	if player._input_state.joystick_direction.length_squared() > 0.1:
		raycast.target_position = player._input_state.joystick_direction * 100
		raycast.force_raycast_update()
	
	if player._input_state.should_grapple_action:
		if state == GrappleState.IDLE:
			launch()
		elif state != GrappleState.RETRACTING:
			retract()

func launch():
	if raycast.is_colliding():
		state = GrappleState.FIRING
		grapple_target = raycast.get_collision_point()
		rope.start_grapple()
	else:
		state = GrappleState.FIRING_NO_TARGET
		grapple_target = player.global_position + raycast.target_position
		rope.start_grapple()
		await get_tree().create_timer(0.2).timeout
		if state == GrappleState.FIRING_NO_TARGET:
			retract()

func retract():
	state = GrappleState.IDLE
	rope.stop_grapple()

func on_rope_reached_target():
	if state == GrappleState.FIRING:
		state = GrappleState.ATTACHED

func compute_velocity(delta) -> Vector2:
	if state != GrappleState.ATTACHED:
		return Vector2.ZERO
		
	var target_direction = player.global_position.direction_to(grapple_target)
	var target_distance = player.global_position.distance_to(grapple_target)
	
	var displacement = target_distance - rest_length
	var force = Vector2.ZERO
	
	if displacement > 0:
		var spring_force_magnitude = stiffness * displacement
		var spring_force = target_direction * spring_force_magnitude
		
		var velocity_dot = player.velocity.dot(target_direction)
		var damping_force = -damping * velocity_dot * target_direction
		
		force = spring_force + damping_force
		
	return force * delta

