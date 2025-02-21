extends BasePlayerState
class_name WallSlideState

var slow_slide_timer: float = 0.0
var floor_contact_timer: float = 0.0 	# Timer pour les contacts sol via raycasts
var wall_lost_timer: float = 0.0 		# Timer pour la perte de contact mural

func enter() -> void:
	print("Entering WallSlide state")
	player.is_wall_sliding = true
	player.wall_normal = player.get_wall_normal()
	slow_slide_timer = 0.0
	floor_contact_timer = 0.0
	wall_lost_timer = 0.0
	_update_animations()
	
	# Reset les timers de wall jump
	player.last_jump_side = 0
	
	# Initialiser les particules
	if player.has_node("WallDustParticles"):
		player.get_node("WallDustParticles").emitting = true

func physics_update(delta: float) -> void:
	player.velocity.y += player.gravity * delta
	
	# Gérer le timer de contact sol
	if player.is_on_floor():
		floor_contact_timer += delta
	else:
		floor_contact_timer = 0.0
	
	# Vérifier via les raycasts si le joueur touche le sol.
	var floor_detected: bool = player.floor_is_colliding_with_raycast()
	var left_wall_detected: bool = player.left_wall_is_colliding_with_raycast()
	var right_wall_detected: bool = player.right_wall_is_colliding_with_raycast()
	
	# Mise à jour du timer de perte de contact mural
	if (not left_wall_detected and not right_wall_detected):
		wall_lost_timer += delta
	else:
		wall_lost_timer = 0.0
	
	# Condition de sortie du WallSlide :
	# On quitte si le joueur a perdu le contact mural pendant un temps minimal OU si un contact sol persiste.
	var WALL_LOST_THRESHOLD: float = 0.15		# durée minimale de perte de contact mural
	var FLOOR_CONTACT_THRESHOLD: float = 0.15	# durée minimale de contact sol
	if (wall_lost_timer > WALL_LOST_THRESHOLD) or (floor_detected and floor_contact_timer > FLOOR_CONTACT_THRESHOLD):
		if floor_detected:
			if player._input_state.direction == 0:
				transition_to(PlayerStates.IDLE)
			else:
				transition_to(PlayerStates.RUN)
		else:
			transition_to(PlayerStates.FALL)
		return
		
	#if player.only_hand_is_colliding_with_raycast():
		#transition_to(PlayerStates.IN_AIR)
		#return
	
	# Mettre à jour la normale du mur
	player.wall_normal = player.get_wall_normal()
	
	# Ajuster la vitesse de glisse selon l'input
	var pushing_into_wall = sign(player._input_state.direction) == -sign(player.wall_normal.x)
	var pushing_away_from_wall = sign(player._input_state.direction) == sign(player.wall_normal.x)
	if pushing_into_wall:
		player.velocity.y = min(player.velocity.y, PlayerStates.WALL_SLIDE_SUPER_SLOW)
		slow_slide_timer += delta
	elif pushing_away_from_wall:
		player.velocity.x += 2 * sign(player.wall_normal.x)
		player.timers_component.start_coyote_jump()
		transition_to(PlayerStates.FALL)
	else:
		player.velocity.y = min(player.velocity.y, PlayerStates.WALL_SLIDE_SPEED)
		slow_slide_timer = 0.0
	
	# Gérer le wall jump
	if player._input_state.should_jump:
		transition_to(PlayerStates.WALL_JUMP)
	
	player.move_and_slide()
	_update_wall_particles()
	_update_animations()


func _update_animations() -> void:
	if player.velocity.y <= PlayerStates.WALL_SLIDE_SUPER_SLOW:
		set_animation(PlayerStates.ANIMATION_WALL_SLIDE_SLOW)
	else:
		set_animation(PlayerStates.ANIMATION_WALL_SLIDE)
	set_flip_h(player.wall_normal.x > 0)

func _stop_wall_particles() -> void:
	if player.has_node("WallDustParticles"):
		player.get_node("WallDustParticles").emitting = false

func _update_wall_particles() -> void:
	
	if not player.has_node("WallDustParticles"):
		return
		
	var wallDustParticles = player.get_node("WallDustParticles")
	
	if player.velocity.y < PlayerStates.WALL_SLIDE_SUPER_SLOW:
		if wallDustParticles.emitting:
			wallDustParticles.emitting = false
		return 
		
	# Calculer l'offset horizontal de base à partir de la collision shape
	var offset_distance: float = PlayerStates.DEFAULT_WALL_DUST_PARTICULES_OFFSET
	if player.get_node("CollisionShape2D") == null:
		push_error("player.collision is null, preventing error")
		return 
		
	var shape = player.get_node("CollisionShape2D").shape
	var new_position: Vector2
	if shape is CircleShape2D:
		# Pour un cercle, l'offset horizontal est basé sur le rayon (ajusté)
		offset_distance = (shape.radius / 3)
		
	new_position = -player.wall_normal * offset_distance
	wallDustParticles.position = new_position
	
	if player.is_wall_sliding:
		var speed_ratio = (abs(player.velocity.y) - PlayerStates.WALL_SLIDE_SUPER_SLOW) / (PlayerStates.WALL_SLIDE_SPEED - PlayerStates.WALL_SLIDE_SUPER_SLOW)
		speed_ratio = clamp(speed_ratio, 0.0, 1.0)
		
		var process_material = wallDustParticles.process_material
		if process_material:
			process_material.emission_box_extents.y = lerp(1.0, 3.0, speed_ratio)
			process_material.initial_velocity_min = lerp(5.0, 20.0, speed_ratio)
			process_material.initial_velocity_max = lerp(10.0, 30.0, speed_ratio)
			wallDustParticles.amount = int(lerp(4, 12, speed_ratio))
			
	wallDustParticles.emitting = player.is_wall_sliding



func exit() -> void:
	print("Exiting WallSlide state")
	player.is_wall_sliding = false
	_stop_wall_particles()
