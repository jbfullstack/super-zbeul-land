extends BasePlayerState
class_name RunningState

func enter() -> void:
	_update_animations()

func physics_update(delta: float) -> void:
	if player._input_state.should_down and player.current_pipe != null:
		transition_to(PlayerStates.ENTER_PIPE)
		return
		
	player.velocity.x = player._input_state.direction * PlayerStates.SPEED
	player.velocity.y += player.gravity * delta
	
	# Check transitions
	if not player.is_on_floor():
		# Init coyote for player 
		player.timers_component.start_coyote_jump()
		transition_to(PlayerStates.IN_AIR)
	elif (player._input_state.should_jump ):
		transition_to(PlayerStates.IN_AIR)
	elif player._input_state.direction == 0:
		transition_to(PlayerStates.IDLE)
	else:
		_update_animations()  # Update sprite direction while running
	
	player.move_and_slide()

func _update_animations() -> void:
	player.animated_sprite.play(PlayerStates.ANIMATION_RUN)
	var effective_direction = player._input_state.direction
	if effective_direction == 0:
		effective_direction = sign(player.velocity.x)
	
	if effective_direction != 0:
		player.animated_sprite.flip_h = effective_direction < 0
