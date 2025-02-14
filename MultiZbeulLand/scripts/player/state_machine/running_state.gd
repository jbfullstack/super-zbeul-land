extends BasePlayerState
class_name RunningState

const WALK_SPEED: float = 100.0
const RUN_SPEED: float = 195.0
const SPRINT_SPEED: float = 225.0
const WALK_ACCEL: float = 800.0
const STOP_DECEL: float = 500.0
const P_METER_START_SPEED: float = 131.25
const MAX_P_METER: float = 1.867
const EDGE_CHECK_THRESHOLD: float = 0.8
const SLIDE_SPEED_THRESHOLD: float = 50.0  # Min speed needed to trigger slide

var p_meter: float = 0.0
var current_max_speed: float = WALK_SPEED
var current_velocity: float = 0.0
var is_sliding: bool = false

func enter() -> void:
	update_animations()

func physics_update(delta: float) -> void:
	if player._input_state.should_down and player.current_pipe != null:
		transition_to(PlayerStates.ENTER_PIPE)
		return
	elif player._input_state.should_grapple_action:
		transition_to(PlayerStates.GRAPPLE)
		return

	# Update running mechanics before movement
	update_run_mechanics(delta)
		
	# Detect slide state - when moving fast and trying to go opposite direction
	is_sliding = abs(current_velocity) > SLIDE_SPEED_THRESHOLD and sign(current_velocity) != sign(player._input_state.direction) and player._input_state.direction != 0
		
	# prevent user to fall if joystick not heavily pressed
	if player.is_on_edge() and abs(player._input_state.direction) < 0.8:
		print("Prevent player falling - Running")
		set_animation(PlayerStates.ANIMATION_ON_EDGE_OF_FALLING)
	else:
		# Apply inertia
		var target_speed = player._input_state.direction * current_max_speed
		
		# During slide, use higher deceleration
		var accel = WALK_ACCEL
		if is_sliding:
			accel = STOP_DECEL
			
		current_velocity = move_toward(current_velocity, target_speed, accel * delta)
		player.velocity.x = current_velocity

	player.velocity.y += player.gravity * delta
	
	# Check transitions
	if not player.is_on_floor():
		# Init coyote for player 
		player.timers_component.start_coyote_jump()
		transition_to(PlayerStates.FALL)
	elif player._input_state.should_jump:
		transition_to(PlayerStates.JUMP)
	elif player._input_state.direction == 0:
		transition_to(PlayerStates.IDLE)
	else:
		update_animations()
	
	player.move_and_slide()

func update_animations() -> void:
	# Handle slide animation first
	if is_sliding:
		set_animation(PlayerStates.ANIMATION_SLIDE)
	# Otherwise use normal speed-based animations
	elif p_meter >= MAX_P_METER:
		set_animation(PlayerStates.ANIMATION_SPRINT)
	elif player._input_state.is_run_action_activated:
		set_animation(PlayerStates.ANIMATION_RUN)
	else:
		set_animation(PlayerStates.ANIMATION_WALK)

	var effective_direction = player._input_state.direction
	if effective_direction == 0:
		effective_direction = sign(player.velocity.x)
	
	if effective_direction != 0:
		set_flip_h(effective_direction < 0)

# Update movement speed based on state
func update_max_speed(delta: float) -> void:
	# First determine target speed based on run state
	var target_max_speed: float = WALK_SPEED
	if player._input_state.is_run_action_activated:
		if p_meter >= MAX_P_METER:
			target_max_speed = SPRINT_SPEED
		else:
			target_max_speed = RUN_SPEED

	# Then smoothly move current speed toward target
	current_max_speed = move_toward(current_max_speed, target_max_speed, WALK_ACCEL * delta)

# Update P-meter based on conditions
func update_p_meter(delta: float) -> void:
	if player.is_on_floor() and abs(current_velocity) >= P_METER_START_SPEED and player._input_state.is_run_action_activated:
		p_meter = min(p_meter + delta, MAX_P_METER)  # Slower p-meter increase
		print("[RunningState] Increasing P-meter to ", p_meter)
	else:
		p_meter = max(p_meter - delta, 0)

# Main entry point for all run mechanics
func update_run_mechanics(delta: float) -> void:
	update_p_meter(delta)
	update_max_speed(delta)
