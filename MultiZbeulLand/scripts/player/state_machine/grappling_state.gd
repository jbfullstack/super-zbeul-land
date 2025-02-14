extends BasePlayerState
class_name GrapplingState

const ACCELERATION = 0.1
const DECELERATION = 0.1

func enter() -> void:
	set_animation(PlayerStates.ANIMATION_GRAPPLING)

func physics_update(delta: float) -> void:
	
	if player._input_state.should_jump:
		transition_to(PlayerStates.JUMP)
		player.grapple.retract()
		return
	
	if not player.grapple.is_griping:
		transition_to(PlayerStates.FALL)
		return
		
	else:
		var force = player.grapple.compute_velocity(delta)
		player.velocity += force
	
	if player._input_state.direction != 0:
		player.velocity.x = lerp(player.velocity.x, PlayerStates.SPEED * player._input_state.direction, ACCELERATION)
	else:
		player.velocity.x = lerp(player.velocity.x, 0.0, DECELERATION)
	
	player.velocity.y += (PlayerStates.GRAVITY) * delta
	player.move_and_slide()
