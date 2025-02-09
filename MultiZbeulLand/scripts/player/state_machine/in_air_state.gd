extends BasePlayerState
class_name InTheAirState

var coyote_timer: float = 0.0
var can_wall_jump: bool = false
var was_on_wall: bool = false

func enter() -> void:
	# Initialize coyote time if coming off the floor or a wall.
	if player.is_on_floor() or was_on_wall:
		coyote_timer = PlayerStates.WALL_COYOTE_TIME
		can_wall_jump = true
	
	# If entering from a normal jump, mark coyote as used.
	if player.is_on_floor() and player._input_state.should_jump:
		player.velocity.y = PlayerStates.JUMP_VELOCITY
		player.coyote_used = true
		player.animated_sprite.play(PlayerStates.ANIMATION_JUMP)
	else:
		player.animated_sprite.play(PlayerStates.ANIMATION_FALL)

func physics_update(delta: float) -> void:	
	# Check for a coyote jump:
	# Only trigger if:
	#   - The coyote timer is still running,
	#   - The player presses jump,
	#   - The player's vertical velocity is not already negative,
	#   - And a coyote jump hasn't already been used.
	if not player.coyote_timer.is_stopped() and player._input_state.should_jump and player.velocity.y >= 0 and not player.coyote_used:
		print("Coyote jump triggered via Timer!")
		player.coyote_timer.stop()       # Stop the timer so it only triggers once.
		player.coyote_used = true        # Mark that the coyote jump has been used.
		player.velocity.y = PlayerStates.JUMP_VELOCITY
		player.animated_sprite.play(PlayerStates.ANIMATION_JUMP)
	
	# Update horizontal movement based on input.
	player.velocity.x = player._input_state.direction * PlayerStates.SPEED
	
	# Apply gravity.
	player.velocity.y += player.gravity * delta
	
	# Trigger wall slide only if on a wall and falling (not moving upward).
	if player.is_on_wall() and player.velocity.y >= 0:
		transition_to(PlayerStates.WALL_SLIDE)
		return
	
	# If the player lands, transition to Idle or Running.
	if player.is_on_floor():
		if player._input_state.direction == 0:
			transition_to(PlayerStates.IDLE)
		else:
			transition_to(PlayerStates.RUNNING)
		return
	
	if player._input_state.should_down:
			transition_to(PlayerStates.DOWN_DASH)
			
	_update_animations()
	player.move_and_slide()

func _update_animations() -> void:
	if player.velocity.y < 0:
		player.animated_sprite.play(PlayerStates.ANIMATION_JUMP)
	else:
		player.animated_sprite.play(PlayerStates.ANIMATION_FALL)
	
	if player.velocity.x != 0:
		player.animated_sprite.flip_h = player.velocity.x < 0
