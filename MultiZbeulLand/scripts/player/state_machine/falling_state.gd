extends AirborneState
class_name FallingState

const FALL_GRAVITY_FACTOR: float = 2.5
const MAX_FALL_SPEED: float = 800.0

func enter() -> void:
	set_animation(PlayerStates.ANIMATION_FALL)

func physics_update(delta: float) -> void:
	# Check for coyote jump
	if player.timers_component.coyote_timer_allows_jump() and player._input_state.should_jump and player.velocity.y >= 0:
		print_d("Coyote jump triggered via Timer!")
		player.timers_component.stop_coyote_jump()
		transition_to(PlayerStates.JUMP)
		return
	
	# Apply fall gravity with speed limit
	player.velocity.y += (PlayerStates.GRAVITY * FALL_GRAVITY_FACTOR) * delta
	player.velocity.y = min(player.velocity.y, MAX_FALL_SPEED)
	
	handle_horizontal_movement()
	
	if handle_wall_detection() or handle_ground_detection():
		return
		
	if player._input_state.should_down:
		transition_to(PlayerStates.DOWN_DASH)
		return
			
	update_animations()
	player.move_and_slide()
