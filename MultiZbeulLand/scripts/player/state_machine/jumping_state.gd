extends AirborneState
class_name JumpingState

const INITIAL_JUMP_BOOST: float = 1.2
const PEAK_GRAVITY_FACTOR: float = 0.5

func enter() -> void:
	start_jump()

func physics_update(delta: float) -> void:
	# Handle early jump cancellation
	if player._input_state.jump_just_released or player.timers_component.max_jump().is_stopped():
		# Transition to falling with reduced upward momentum
		var peak_transition_speed: float = player.velocity.y * 0.6
		player.velocity.y = peak_transition_speed
		player.timers_component.stop_max_jump()
		transition_to(PlayerStates.FALL)
		return
	
	# Normal jump physics
	var jump_time_coef: float = player.timers_component.get_jump_time_coefficient(player.timers_component.max_jump())
	var jump_power: float = lerp(INITIAL_JUMP_BOOST, 0.8, jump_time_coef)
	player.velocity.y = (PlayerStates.JUMP_VELOCITY * jump_power) + (PlayerStates.GRAVITY * 0.6 * delta)
	
	# Handle state transitions - CHECK VELOCITY AFTER APPLYING PHYSICS
	if player.velocity.y >= 0:
		player.timers_component.start_coyote_jump()
		transition_to(PlayerStates.FALL)
		return
		
	handle_horizontal_movement()
	
	if handle_wall_detection() or handle_ground_detection():
		return
		
	if player._input_state.should_down:
		transition_to(PlayerStates.DOWN_DASH)
		return
			
	update_animations()
	player.move_and_slide()

func start_jump() -> void:
	player.velocity.y = PlayerStates.JUMP_VELOCITY * INITIAL_JUMP_BOOST
	player.timers_component.start_max_jump()
	set_animation(PlayerStates.ANIMATION_JUMP)
