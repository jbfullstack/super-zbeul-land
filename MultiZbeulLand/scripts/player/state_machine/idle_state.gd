extends BasePlayerState
class_name IdleState

func enter() -> void:
	player.velocity.x = 0.0
	_update_animations()

func physics_update(delta: float) -> void:
	if player._input_state.should_down and player.current_pipe != null:
		transition_to(PlayerStates.ENTER_PIPE)
		return
	
	player.velocity.y += player.gravity * delta
	
	#player.check_edge_correction()
	
	# Vérifier les transitions
	if (player._input_state.should_jump ) and player.is_on_floor():
		print_d("Initiating jump transition")
		transition_to(PlayerStates.JUMP)
	elif player.grapple.is_griping:
		transition_to(PlayerStates.GRAPPLE)
		return
	elif not player.is_on_floor():
		print_d("Falling transition")
		transition_to(PlayerStates.FALL)
	elif player.is_on_edge() and abs(player._input_state.direction) < 0.9:		
		set_animation(PlayerStates.ANIMATION_ON_EDGE_OF_FALLING)
		pass
	elif player._input_state.direction != 0:
		print_d("Running transition")
		transition_to(PlayerStates.RUN)
	
	player.move_and_slide()

func _update_animations() -> void:
	set_animation(PlayerStates.ANIMATION_IDLE)
	
	var effective_direction = player._input_state.direction
	if effective_direction == 0:
		effective_direction = sign(player.velocity.x)
	
	if effective_direction != 0:
		set_flip_h(effective_direction < 0)
