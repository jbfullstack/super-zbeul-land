extends BasePlayerState
class_name WallSlideState

var slow_slide_timer: float = 0.0

func enter() -> void:
	print("Entering WallSlide state")
	player.is_wall_sliding = true
	player.wall_normal = player.get_wall_normal()
	slow_slide_timer = 0.0
	_update_animations()
	
	# Reset les timers de wall jump
	player.last_jump_side = 0
	
	# Initialiser les particules
	if player.has_node("WallDustParticles"):
		player.get_node("WallDustParticles").emitting = true

func physics_update(delta: float) -> void:
	player.velocity.y += player.gravity * delta
	
	# Vérifier si on est toujours en condition de wall slide
	if not player.is_on_wall() or player.is_on_floor():
		if player.is_on_floor():
			if player._input_state.direction == 0:
				transition_to(PlayerStates.IDLE)
			else:
				transition_to(PlayerStates.RUNNING)
		else:
			transition_to(PlayerStates.IN_AIR)
		return
	
	# Mettre à jour la normale du mur
	player.wall_normal = player.get_wall_normal()
	
	# Ajuster la vitesse de glisse selon la direction
	var pushing_into_wall = sign(player._input_state.direction) == -sign(player.wall_normal.x)
	if pushing_into_wall:
		player.velocity.y = min(player.velocity.y, PlayerStates.WALL_SLIDE_SUPER_SLOW)
		slow_slide_timer += delta
	else:
		player.velocity.y = min(player.velocity.y, PlayerStates.WALL_SLIDE_SPEED)
		slow_slide_timer = 0.0
	
	# Gérer le wall jump
	if player._input_state.should_jump:
		transition_to(PlayerStates.WALL_JUMP)
	
	player.move_and_slide()
	_update_wall_particles()

func _update_animations() -> void:
	player.animated_sprite.play(PlayerStates.ANIMATION_WALL_SLIDE)
	player.animated_sprite.flip_h = player.wall_normal.x > 0

func _stop_wall_particles() -> void:
	if player.has_node("WallDustParticles"):
		player.get_node("WallDustParticles").emitting = false

func _update_wall_particles() -> void:
	if not player.has_node("WallDustParticles"):
		return
	
	var particles = player.get_node("WallDustParticles")
	particles.emitting = player.is_wall_sliding
	
	# Calculer l'offset horizontal de base à partir de la collision shape
	var offset_distance: float = PlayerStates.DEFAULT_WALL_DUST_PARTICULES_OFFSET
	var shape = player.get_node("CollisionShape2D").shape
	var new_position: Vector2
	if shape is CircleShape2D:
		# Pour un cercle, l'offset horizontal est basé sur le rayon (ajusté)
		offset_distance = shape.radius - 4.0
		# On ajoute un offset vertical pour placer les particules au milieu du joueur (par exemple, -shape.radius/2)
		new_position = -player.wall_normal * offset_distance + Vector2(0, -shape.radius / 2)
	elif shape is RectangleShape2D:
		# Pour un rectangle, l'offset horizontal est basé sur l'extents.x (ajusté)
		offset_distance = shape.extents.x - 4.0
		# On positionne verticalement au centre du joueur, supposant que l'origine est en bas
		new_position = -player.wall_normal * offset_distance + Vector2(0, -shape.extents.y)
	else:
		new_position = -player.wall_normal * offset_distance  # ou un Vector2(0,0) par défaut

	particles.position = new_position
	
	if player.is_wall_sliding:
		var speed_ratio = (abs(player.velocity.y) - PlayerStates.WALL_SLIDE_SUPER_SLOW) / (PlayerStates.WALL_SLIDE_SPEED - PlayerStates.WALL_SLIDE_SUPER_SLOW)
		speed_ratio = clamp(speed_ratio, 0.0, 1.0)
		
		var process_material = particles.process_material
		if process_material:
			process_material.emission_box_extents.y = lerp(1.0, 3.0, speed_ratio)
			process_material.initial_velocity_min = lerp(5.0, 20.0, speed_ratio)
			process_material.initial_velocity_max = lerp(10.0, 30.0, speed_ratio)
			particles.amount = int(lerp(4, 12, speed_ratio))



func exit() -> void:
	print("Exiting WallSlide state")
	player.is_wall_sliding = false
	if player.has_node("WallDustParticles"):
		player.get_node("WallDustParticles").emitting = false
