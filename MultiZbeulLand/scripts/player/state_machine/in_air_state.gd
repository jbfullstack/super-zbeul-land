extends BasePlayerState
class_name InTheAirState

#--- Vertical
const INITIAL_JUMP_BOOST: float = 1.2  # Makes initial jump more snappy
const PEAK_GRAVITY_FACTOR: float = 0.5  # Slower at peak of jump
const FALL_GRAVITY_FACTOR: float = 2.5  # Faster falling
const MAX_FALL_SPEED: float = 800.0  # Maximum falling speed (positive value)

# --- Horizontal
const AIR_FRICTION: float = 0.92  # How quickly horizontal speed decays (0.92 = keep 92% of speed each frame)
const MIN_HORIZONTAL_SPEED: float = 5.0  # Speed below which we stop completely

func enter() -> void:
	#player.timers_component.update_wait_time(player.timers_component.max_jump(), PlayerStates.MEGAJUMP_MAX_JUMP_TIME)
	if player.is_on_floor() and player._input_state.should_jump:
		start_jump()
	else:
		set_animation(PlayerStates.ANIMATION_FALL)

func physics_update(delta: float) -> void:	
	# Check for coyote jump
	if player.timers_component.coyote_timer_allows_jump() and player._input_state.should_jump and player.velocity.y >= 0:
		print_d("Coyote jump triggered via Timer!")
		player.timers_component.stop_coyote_jump()
		start_jump()
	
	# Handle jump physics
	if player.velocity.y < 0:  # Moving upward (jumping)
		if player._input_state.jump_just_released or player.timers_component.max_jump().is_stopped():
			# Smooth transition when cutting jump short
			var peak_transition_speed: float = player.velocity.y * 0.6  # Preserve some upward momentum
			player.velocity.y = peak_transition_speed
			player.timers_component.stop_max_jump()
			# Apply reduced gravity near peak
			player.velocity.y += (PlayerStates.GRAVITY * PEAK_GRAVITY_FACTOR) * delta
		else:
			# During active jump
			var jump_time_coef: float = player.timers_component.get_jump_time_coefficient(player.timers_component.max_jump())
			
			# More power at start, gradually decrease
			var jump_power: float = lerp(INITIAL_JUMP_BOOST, 0.8, jump_time_coef)
			player.velocity.y = (PlayerStates.JUMP_VELOCITY * jump_power) + (PlayerStates.GRAVITY * 0.6 * delta)
	else:  # Falling
		# Apply fall gravity
		player.velocity.y += (PlayerStates.GRAVITY * FALL_GRAVITY_FACTOR) * delta
		# Clamp to maximum fall speed
		player.velocity.y = min(player.velocity.y, MAX_FALL_SPEED)
		player.timers_component.stop_max_jump()
	
	# Handle horizontal movement with inertia
	if player._input_state.direction != 0:
		# Player is actively moving - apply full speed
		player.velocity.x = player._input_state.direction * PlayerStates.SPEED
	else:
		# No input - gradually slow down
		player.velocity.x *= AIR_FRICTION
		
		# Stop completely if moving very slowly
		if abs(player.velocity.x) < MIN_HORIZONTAL_SPEED:
			player.velocity.x = 0.0
	
	if player.is_on_wall() and player.velocity.y >= 0 and (player.left_wall_is_colliding_with_raycast() or player.right_wall_is_colliding_with_raycast()):
		transition_to(PlayerStates.WALL_SLIDE)
		return
	
	if player.is_on_floor():
		if player._input_state.direction == 0:
			transition_to(PlayerStates.IDLE)
		else:
			transition_to(PlayerStates.RUN)
		return
	
	if player._input_state.should_down:
		transition_to(PlayerStates.DOWN_DASH)
			
	_update_animations()
	player.move_and_slide()


func start_jump() -> void:
	player.velocity.y = PlayerStates.JUMP_VELOCITY * INITIAL_JUMP_BOOST  # Snappier initial jump
	player.timers_component.start_max_jump()
	set_animation(PlayerStates.ANIMATION_JUMP)
	
func _update_animations() -> void:
	if player.velocity.y < 0:
		set_animation(PlayerStates.ANIMATION_JUMP)
	else:
		set_animation(PlayerStates.ANIMATION_FALL)
	
	if player.velocity.x != 0:
		set_flip_h(player.velocity.x < 0)
