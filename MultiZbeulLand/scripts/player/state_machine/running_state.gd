extends BasePlayerState
class_name RunningState

const WALK_SPEED: float = 100.0
const RUN_SPEED: float = 195.0
const SPRINT_SPEED: float = 225.0
const WALK_ACCEL: float = 800.0
const STOP_DECEL: float = 500.0
const DIRECTION_CHANGE_DECEL: float = 400.0  # Higher deceleration for direction changes
const P_METER_START_SPEED: float = 131.25
const MAX_P_METER: float = 1.867
const EDGE_CHECK_THRESHOLD: float = 0.8
const SLIDE_SPEED_THRESHOLD: float = WALK_SPEED  # Using WALK_SPEED as threshold

var p_meter: float = 0.0
var current_max_speed: float = WALK_SPEED
var current_velocity: float = 0.0
var is_sliding: bool = false
var is_change_direction_sliding: bool = false
var last_direction: float = 0.0  # Track last direction for direction changes

var is_started_to_change_direction_sliding: bool = false
var change_direction_sliding_initial_direction: float = 0.0

func enter() -> void:
	# If coming from IDLE, reset velocity
	if player.get_node("StateMachine").previous_state.name == PlayerStates.IDLE:
		current_velocity = 0.0
		
	update_animations()
	last_direction = sign(current_velocity) if current_velocity != 0 else 0.0

func physics_update(delta: float) -> void:
	if player._input_state.should_down and player.current_pipe != null:
		transition_to(PlayerStates.ENTER_PIPE)
		return
	elif player._input_state.should_grapple_action:
		transition_to(PlayerStates.GRAPPLE)
		return

	# Update running mechanics before movement
	update_run_mechanics(delta)
		
	# Prevent user from falling if joystick not heavily pressed
	if player.is_on_edge() and abs(player._input_state.direction) < EDGE_CHECK_THRESHOLD:
		print("Prevent player falling - Running")
		set_animation(PlayerStates.ANIMATION_ON_EDGE_OF_FALLING)
	else:
		# Calculate target speed based on input
		var target_speed = player._input_state.direction * current_max_speed
		
		# Update sliding states
		update_sliding_states()
		
		# Apply movement with appropriate acceleration/deceleration
		var accel = get_current_acceleration()
		current_velocity = move_toward(current_velocity, target_speed, accel * delta)
		player.velocity.x = current_velocity
		
		# Update last direction for next frame
		if not is_change_direction_sliding and current_velocity != 0:
			last_direction = sign(current_velocity)

	player.velocity.y += player.gravity * delta
	
	# Check transitions
	if not player.is_on_floor():
		player.timers_component.start_coyote_jump()
		transition_to(PlayerStates.FALL)
	elif player._input_state.should_jump:
		transition_to(PlayerStates.JUMP)
	elif player._input_state.direction == 0 and abs(current_velocity) < WALK_SPEED:
		transition_to(PlayerStates.IDLE)
	else:
		update_animations()
	
	player.move_and_slide()

func update_sliding_states() -> void:
	var current_direction = sign(current_velocity)
	var input_direction = sign(player._input_state.direction)
	
	
	# Check for direction change sliding
	is_change_direction_sliding = (
		abs(current_velocity) > SLIDE_SPEED_THRESHOLD and 
		input_direction != 0 and 
		input_direction != current_direction
	)
	if is_change_direction_sliding:
		is_started_to_change_direction_sliding = true
		change_direction_sliding_initial_direction = current_direction
	
	# Check for regular sliding (stopping or releasing run)
	is_sliding = (
		abs(current_velocity) > SLIDE_SPEED_THRESHOLD and 
		(player._input_state.direction == 0 or not player._input_state.is_run_action_activated) and 
		not is_change_direction_sliding
	)

const FRICTION_FACTOR: float = 0.8  # Plus la valeur est basse, plus le slide dure longtemps

func get_current_acceleration() -> float:
	var speed_ratio = abs(current_velocity) / max(current_max_speed, 0.01)  # Prevent division by 0
	var friction_multiplier = lerp(1.0, FRICTION_FACTOR, speed_ratio)
	
	if is_change_direction_sliding:
		return DIRECTION_CHANGE_DECEL * friction_multiplier
	elif is_sliding:
		return STOP_DECEL * friction_multiplier
	return WALK_ACCEL

func update_animations() -> void:	
	if is_started_to_change_direction_sliding:
		if player.velocity.x == 0 or sign(player.velocity.x) != change_direction_sliding_initial_direction:
			is_started_to_change_direction_sliding = false
			change_direction_sliding_initial_direction = 0.0
		else:
			set_animation(PlayerStates.ANIMATION_SLIDE)
			return
	if p_meter >= MAX_P_METER:
		set_animation(PlayerStates.ANIMATION_SPRINT)
	elif player._input_state.is_run_action_activated:
		set_animation(PlayerStates.ANIMATION_RUN)
	else:
		set_animation(PlayerStates.ANIMATION_WALK)

	# Update character direction
	var effective_direction = player._input_state.direction
	if is_sliding:
		# During normal slide, keep facing the movement direction
		effective_direction = sign(current_velocity)
	elif is_change_direction_sliding:
		# During direction change slide, face the input direction
		effective_direction = sign(player._input_state.direction)
	elif effective_direction == 0:
		effective_direction = sign(current_velocity)
	
	if effective_direction != 0:
		set_flip_h(effective_direction < 0)

# The rest of the methods remain unchanged
func update_max_speed(delta: float) -> void:
	var target_max_speed: float = WALK_SPEED
	if player._input_state.is_run_action_activated:
		if p_meter >= MAX_P_METER:
			target_max_speed = SPRINT_SPEED
		else:
			target_max_speed = RUN_SPEED

	current_max_speed = move_toward(current_max_speed, target_max_speed, WALK_ACCEL * delta)

func update_p_meter(delta: float) -> void:
	if player.is_on_floor() and abs(current_velocity) >= P_METER_START_SPEED and player._input_state.is_run_action_activated:
		p_meter = min(p_meter + delta, MAX_P_METER)
		print("[RunningState] Increasing P-meter to ", p_meter)
	else:
		p_meter = max(p_meter - delta, 0)

func update_run_mechanics(delta: float) -> void:
	update_p_meter(delta)
	update_max_speed(delta)
