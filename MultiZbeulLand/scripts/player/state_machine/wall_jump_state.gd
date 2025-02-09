extends BasePlayerState
class_name WallJumpState

var no_control_timer: float

func enter() -> void:
	# Initialiser le timer au début du wall jump
	no_control_timer = PlayerStates.WALL_JUMP_NO_CONTROL_TIME
	var jump_force = PlayerStates.WALL_JUMP_VELOCITY
	jump_force.x *= PlayerStates.WALL_JUMP_OPPOSITE_FORCE
	
	# Appliquer la velocité du wall jump
	player.velocity = Vector2(player.wall_normal.x * jump_force.x, jump_force.y)
	player.last_jump_side = sign(player.wall_normal.x)
	
	# Update animation
	_update_animations()

func physics_update(delta: float) -> void:
	no_control_timer -= delta
	player.velocity.y += player.gravity * delta
	
	# Le mouvement horizontal ne doit être appliqué qu'après la période de non-contrôle
	if no_control_timer <= 0:
		player.velocity.x = player._input_state.direction * PlayerStates.SPEED
	
	player.move_and_slide()
	
	# Check transitions dans l'ordre de priorité
	if player.is_on_wall() and not player.is_on_floor():
		# Permettre de re-wall slide uniquement sur un mur différent
		var current_wall_normal = player.get_wall_normal()
		if current_wall_normal != player.wall_normal:
			transition_to(PlayerStates.WALL_SLIDE)
	# Ne pas vérifier is_on_floor pendant la période de non-contrôle
	elif player.is_on_floor() and no_control_timer <= 0:
		if player._input_state.direction == 0:
			transition_to(PlayerStates.IDLE)
		else:
			transition_to(PlayerStates.RUNNING)
	# Passer en état aérien seulement si le timer est écoulé
	elif no_control_timer <= 0:
		transition_to(PlayerStates.IN_AIR)

func _update_animations() -> void:
	player.animated_sprite.play(PlayerStates.ANIMATION_JUMP)
	player.animated_sprite.flip_h = player.velocity.x < 0

func exit() -> void:
	print("Exiting WallJump state")
