extends BasePlayerState
class_name InTheAirState

var coyote_timer: float = 0.0
var can_wall_jump: bool = false
var was_on_wall: bool = false

func enter() -> void:
	print("InTheAirState - enter()")
	print("is_on_floor:", player.is_on_floor())
	print("should_jump:", player._input_state.should_jump)
	print("Initial velocity:", player.velocity)
	
	# Init coyote time si on vient de quitter le sol ou un mur
	if player.is_on_floor() or was_on_wall:
		coyote_timer = PlayerStates.WALL_COYOTE_TIME
		can_wall_jump = true
	
	# Si on entre depuis un saut normal
	if player.is_on_floor() and player._input_state.should_jump:
		print("Initiating jump with velocity:", PlayerStates.JUMP_VELOCITY)
		player.velocity.y = PlayerStates.JUMP_VELOCITY
		player.animated_sprite.play(PlayerStates.ANIMATION_JUMP)
	else:
		print("Entering air state without jump")
		player.animated_sprite.play(PlayerStates.ANIMATION_FALL)

func physics_update(delta: float) -> void:
	print("InTheAirState - physics_update()")
	print("Current velocity:", player.velocity)
	
	# Mettre à jour le timer de coyote
	if coyote_timer > 0:
		coyote_timer -= delta
		if coyote_timer <= 0:
			can_wall_jump = false
	
	# Mise à jour du mouvement
	player.velocity.x = player._input_state.direction * PlayerStates.SPEED
	player.velocity.y += player.gravity * delta
	
	# Vérifier les transitions
	if player.is_on_wall():
		was_on_wall = true
		transition_to(PlayerStates.WALL_SLIDE)
		return
	else:
		was_on_wall = false
	
	if player.is_on_floor():
		if player._input_state.direction == 0:
			transition_to(PlayerStates.IDLE)
		else:
			transition_to(PlayerStates.RUNNING)
		return
	
	# Update animation based on vertical velocity
	_update_animations()
	player.move_and_slide()

func _update_animations() -> void:
	if player.velocity.y < 0:
		player.animated_sprite.play(PlayerStates.ANIMATION_JUMP)
	else:
		player.animated_sprite.play(PlayerStates.ANIMATION_FALL)
	
	if player.velocity.x != 0:
		player.animated_sprite.flip_h = player.velocity.x < 0
