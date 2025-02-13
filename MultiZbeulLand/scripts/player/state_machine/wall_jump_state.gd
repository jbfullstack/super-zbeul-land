extends BasePlayerState
class_name WallJumpState

var initial_force: float = 0.0
const FORCE_DECAY_RATE: float = 3.0
const MIN_FORCE: float = 50.0

func enter() -> void:
	print("Entering WallJump state")
	
	var jump_force = PlayerStates.WALL_JUMP_VELOCITY
	jump_force.x *= PlayerStates.WALL_JUMP_OPPOSITE_FORCE
	
	initial_force = abs(jump_force.x)
	player.velocity = Vector2(player.wall_normal.x * jump_force.x, jump_force.y)
	player.last_jump_side = sign(player.wall_normal.x)
	_update_animations()

func physics_update(delta: float) -> void:
	player.velocity.y += player.gravity * delta
	
	var current_force = abs(player.velocity.x)
	
	# Decay the force
	if current_force > MIN_FORCE:
		var decay = FORCE_DECAY_RATE * initial_force * delta
		var new_velocity = move_toward(abs(player.velocity.x), MIN_FORCE, decay)
		player.velocity.x = new_velocity * sign(player.velocity.x)
	
	# Handle player input with force-based control
	if player._input_state.direction != 0:
		var target_speed = player._input_state.direction * PlayerStates.SPEED
		# Base influence inversement proportionnelle à la force actuelle
		var force_ratio = current_force / initial_force
		var input_influence = 1.0 - force_ratio  # Plus la force est grande, moins l'input a d'effet
		
		# Si on va contre le wall jump, l'influence est encore plus réduite par la force
		if sign(player._input_state.direction) == sign(player.wall_normal.x * -1):
			input_influence *= (1.0 - force_ratio)  # Force au carré pour effet plus marqué
		
		player.velocity.x = lerp(
			player.velocity.x,
			target_speed,
			input_influence
		)
		
	elif player._input_state.should_down:
		transition_to(PlayerStates.DOWN_DASH)
		
	if player._input_state.direction == 0:
		set_flip_h(player.velocity.x < 0)
	else:
		set_flip_h(player._input_state.direction < 0)
	player.move_and_slide()
	
	# Standard transitions
	if player.is_on_wall() and not player.is_on_floor():
		transition_to(PlayerStates.WALL_SLIDE)
	elif player.is_on_floor():
		if player._input_state.direction == 0:
			transition_to(PlayerStates.IDLE)
		else:
			transition_to(PlayerStates.RUN)
