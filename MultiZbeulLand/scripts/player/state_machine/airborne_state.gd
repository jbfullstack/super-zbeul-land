extends BasePlayerState
class_name AirborneState

# --- Horizontal (shared between both states)
const AIR_FRICTION: float = 0.92
const MIN_HORIZONTAL_SPEED: float = 5.0

func handle_horizontal_movement() -> void:
	if player._input_state.direction != 0:
		player.velocity.x = player._input_state.direction * PlayerStates.SPEED
	else:
		player.velocity.x *= AIR_FRICTION
		if abs(player.velocity.x) < MIN_HORIZONTAL_SPEED:
			player.velocity.x = 0.0

func handle_wall_detection() -> bool:
	if player.is_on_wall() and player.velocity.y >= 0 and (player.left_wall_is_colliding_with_raycast() or player.right_wall_is_colliding_with_raycast()):
		transition_to(PlayerStates.WALL_SLIDE)
		return true
	return false

func handle_ground_detection() -> bool:
	if player.is_on_floor():
		if player._input_state.direction == 0:
			transition_to(PlayerStates.IDLE)
		else:
			transition_to(PlayerStates.RUN)
		return true
	return false

func update_animations() -> void:
	if player.velocity.y < 0:
		set_animation(PlayerStates.ANIMATION_JUMP)
	else:
		set_animation(PlayerStates.ANIMATION_FALL)
	
	if player.velocity.x != 0:
		set_flip_h(player.velocity.x < 0)
