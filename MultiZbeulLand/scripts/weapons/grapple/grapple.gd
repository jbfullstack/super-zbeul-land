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

var is_equiped: bool = false
var state: int = GrappleState.IDLE
var is_griping: bool:
	get:
		return state == GrappleState.FIRING or state == GrappleState.ATTACHED

var grapple_target: Vector2
var rest_length = 2.0
var stiffness = 10.0
var damping = 2.0
var raycast: RayCast2D

# for visual target
var appear_tween: Tween
var pulse_tween: Tween
var was_colliding: bool = false
@onready var visual_target: VisualGrappleTarget = $VisualTarget


func _ready():
	print("Grapple ready")
	await owner.ready
	player = owner as BasePlayerController
	raycast = owner.get_node("Weapons/RayCasts/GrappleRayCast2D") as RayCast2D
	
	visual_target.scale = Vector2.ZERO
	
	set_physics_process(false)

func _physics_process(delta):
	if !is_equiped:
		return
		
	if player._input_state.joystick_direction.length_squared() > 0.1:
		raycast.target_position = player._input_state.joystick_direction * 100
		raycast.force_raycast_update()

	# Hide target if grapple is attached
	#if state == GrappleState.ATTACHED:
		#visual_target.scale = Vector2.ZERO
		#was_colliding = false
		#return

	if state != GrappleState.ATTACHED:
		if raycast.is_colliding():
			var collision_point = raycast.get_collision_point()
			visual_target.global_position = collision_point
				
			if not was_colliding:
				visual_target.appear()
			#elif not appear_tween or not appear_tween.is_running():
				#play_target_pulse_animation()
		else:
			if was_colliding:
				visual_target.hide_target()
	else:
		visual_target.hide_target()
		
	was_colliding = raycast.is_colliding()
	
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
