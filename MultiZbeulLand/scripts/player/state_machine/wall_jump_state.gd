extends BasePlayerState
class_name WallJumpState

var no_control_timer: float = 0.0

func enter() -> void:
	print("Entering WallJump state")
	# Initialiser le timer de non-contrôle pour le wall jump
	no_control_timer = PlayerStates.WALL_JUMP_NO_CONTROL_TIME
	# Calculer la force du wall jump et appliquer la direction opposée du mur
	var jump_force = PlayerStates.WALL_JUMP_VELOCITY
	jump_force.x *= PlayerStates.WALL_JUMP_OPPOSITE_FORCE
	# Appliquer la vélocité initiale du wall jump
	player.velocity = Vector2(player.wall_normal.x * jump_force.x, jump_force.y)
	# Enregistrer le côté du saut (pour d'éventuelles restrictions ultérieures)
	player.last_jump_side = sign(player.wall_normal.x)
	_update_animations()

func physics_update(delta: float) -> void:
	# Décrémenter le timer de non-contrôle
	no_control_timer -= delta
	# Appliquer la gravité
	player.velocity.y += player.gravity * delta
	
	# Si le timer de non-contrôle est expiré, alors on autorise le joueur à changer la direction.
	# Sinon, on conserve l'inertie (la vitesse x initiale du wall jump) tant que l'input horizontal reste nul.
	if no_control_timer <= 0:
		if player._input_state.direction != 0:
			# Si le joueur fournit une commande, on applique la nouvelle vitesse en x
			player.velocity.x = player._input_state.direction * PlayerStates.SPEED
			player.animated_sprite.flip_h = player._input_state.direction < 0
		elif player._input_state.should_down:
			transition_to(PlayerStates.DOWN_DASH)
		# Sinon, on conserve la vélocité x actuelle (inertie)

	player.move_and_slide()
	
	# Transition vers d'autres états (exemple) :
	if player.is_on_wall() and not player.is_on_floor():
		transition_to(PlayerStates.WALL_SLIDE)
	elif player.is_on_floor():
		if player._input_state.direction == 0:
			transition_to(PlayerStates.IDLE)
		else:
			transition_to(PlayerStates.RUNNING)
	# Vous pouvez compléter avec d'autres conditions de transition si nécessaire.

func _update_animations() -> void:
	player.animated_sprite.play(PlayerStates.ANIMATION_JUMP)
	# Inverser l'orientation du sprite si besoin (par exemple, en fonction de la vélocité x)
	if player.velocity.x != 0:
		player.animated_sprite.flip_h = player.velocity.x < 0
