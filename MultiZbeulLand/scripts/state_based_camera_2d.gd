extends Camera2D
class_name StateBasedCamera2D

# Horizontal camera parameters
@export_category("general")
@export var target: Node2D
@export var zoom_factor := Vector2(4, 4)
@export var debug_display := false
@export var movement_threshold := 50.0  # Speed threshold to consider player "moving"
@export var direction_change_threshold := 0.1  # Time window to detect direction changes

# Movement tracking
var _previous_position := Vector2.ZERO
var _current_velocity := Vector2.ZERO
var _last_direction := Vector2.ZERO
var _direction_change_timer := 0.0
var _is_moving := false

@export_category("horizontal")
@export_range(0.0, 1.0) var pos_cam_1 := 0.2
@export_range(0.0, 1.0) var pos_cam_2 := 0.8
@export var dead_zone_size := 0.90
@export var camera_speed := 2.0
# bézieene curve
var transition_start_pos := 0.0
var transition_start_time := 0.0
var is_transitioning := false
var transition_duration := 1.5  # Duration in seconds
@export var use_bezier_transition := true
@export var curve: Curve
var transition_time: float = 0
var transition_dir := 1  # 1 for forward, -1 for reverse

# Vertical camera parameters
@export_category("vertical")
@export var vertical_enabled := true
@export_range(0.0, 1.0) var vertical_target := 0.5  # Where camera settles (green line)
@export_range(0.0, 1.0) var vertical_top_offset := 0.3  # Distance to top boundary
@export_range(0.0, 1.0) var vertical_bottom_offset := 0.15  # Distance to bottom boundary
@export var vertical_speed := 2.0

enum CAMERA_STATE {
	TO_RIGHT,
	TO_LEFT
}

var current_side: CAMERA_STATE = CAMERA_STATE.TO_RIGHT
var target_camera_x: float
var target_camera_y: float
var debug: CameraDebug
var previous_target_pos := Vector2.ZERO

func _ready() -> void:
	zoom = zoom_factor
	if target:
		target_camera_x = target.global_position.x
		target_camera_y = target.global_position.y
		previous_target_pos = target.global_position
		_previous_position = target.global_position
	debug = CameraDebug.new(self)
	
	# Set Camera2D built-in smoothing
	position_smoothing_enabled = true
	position_smoothing_speed = 5.0

func _physics_process(delta: float) -> void:
	if not target:
		return
		
	# Update movement detection
	update_movement_state(delta)
		
	# Check for sudden target position changes
	var target_movement = target.global_position - previous_target_pos
	if target_movement.length() > 100:  # Threshold for sudden movements
		is_transitioning = false  # Cancel any ongoing transition
		target_camera_x = global_position.x  # Keep current position
		target_camera_y = global_position.y
	
	previous_target_pos = target.global_position
		
	# Horizontal movement logic
	process_horizontal_movement(delta)
	
	# Vertical movement logic
	if vertical_enabled:
		process_vertical_movement(delta)
	
	# Update debug visualization
	if debug_display:
		debug.update_debug_lines(
			current_side, vertical_enabled,
			pos_cam_1, pos_cam_2,
			vertical_target, vertical_top_offset, vertical_bottom_offset,
			dead_zone_size, zoom)
		queue_redraw()

func update_movement_state(delta: float) -> void:
	# Calculate velocity
	_current_velocity = (target.global_position - _previous_position) / delta
	_previous_position = target.global_position
	
	# Check if player is moving
	_is_moving = _current_velocity.length() > movement_threshold
	
	# Detect direction changes
	if _current_velocity.length() > movement_threshold:
		var normalized_velocity = _current_velocity.normalized()
		if _last_direction.dot(normalized_velocity) < 0:  # Direction changed
			_direction_change_timer = direction_change_threshold
		_last_direction = normalized_velocity
	
	# Update direction change timer
	if _direction_change_timer > 0:
		_direction_change_timer -= delta

func process_horizontal_movement(delta: float) -> void:
	var screen_size = get_viewport_rect().size
	var half_screen_width = screen_size.x * 0.5
	var offset_in_pixels = (target.global_position.x - global_position.x) * zoom.x
	var player_screen_x = half_screen_width + offset_in_pixels
	var player_screen_fraction = player_screen_x / screen_size.x
	
	# Adjust dead zone based on movement state
	var effective_dead_zone = dead_zone_size
	if _is_moving and _direction_change_timer <= 0:
		effective_dead_zone = 0.0  # Disable dead zone during continuous movement
	
	var state_changed := false
	var prev_pos := global_position.x
	
	# Store previous target position
	var previous_target = target_camera_x
	
	match current_side:
		CAMERA_STATE.TO_RIGHT:
			var left_bound = pos_cam_1 - effective_dead_zone * 0.5
			var right_bound = pos_cam_1 + effective_dead_zone * 0.5
			if player_screen_fraction < left_bound:
				if not is_transitioning:  # Only change state if not already transitioning
					current_side = CAMERA_STATE.TO_LEFT
					target_camera_x = get_desired_camera_x(pos_cam_2)
					start_transition(prev_pos)
					state_changed = true
			elif player_screen_fraction > right_bound:
				target_camera_x = get_desired_camera_x(pos_cam_1)
				
		CAMERA_STATE.TO_LEFT:
			var left_bound = pos_cam_2 - effective_dead_zone * 0.5
			var right_bound = pos_cam_2 + effective_dead_zone * 0.5
			if player_screen_fraction > right_bound:
				if not is_transitioning:  # Only change state if not already transitioning
					current_side = CAMERA_STATE.TO_RIGHT
					target_camera_x = get_desired_camera_x(pos_cam_1)
					start_transition(prev_pos)
					state_changed = true
			elif player_screen_fraction < left_bound:
				target_camera_x = get_desired_camera_x(pos_cam_2)
	
	# Prevent sudden target changes if not transitioning
	if not state_changed and not is_transitioning:
		var target_change = abs(target_camera_x - previous_target)
		if target_change > 100:  # Threshold for sudden changes
			target_camera_x = previous_target
	
	# Apply movement with smoothing
	if is_transitioning and curve and use_bezier_transition:
		apply_curve_movement(delta)
	else:
		# Enhanced lerp movement with smoothing
		var new_x = global_position.x
		if position_smoothing_enabled:
			new_x = lerp(global_position.x, target_camera_x, min(1.0, camera_speed * position_smoothing_speed * delta))
		else:
			new_x = lerp(global_position.x, target_camera_x, camera_speed * delta)
		global_position.x = new_x

func start_transition(from_pos: float) -> void:
	if curve and use_bezier_transition:
		transition_time = 0
		transition_dir = 1
		is_transitioning = true
		transition_start_pos = from_pos

func apply_curve_movement(delta: float) -> void:
	transition_time += delta * transition_dir
	
	if transition_time >= transition_duration:
		is_transitioning = false
		return
	
	# Sample the curve
	var t = transition_time / transition_duration
	var curve_value = curve.sample(t)
	
	# Interpolate position with smoothing
	var interpolated_pos = lerp(transition_start_pos, target_camera_x, curve_value)
	if position_smoothing_enabled:
		global_position.x = lerp(global_position.x, interpolated_pos, min(1.0, position_smoothing_speed * delta))
	else:
		global_position.x = interpolated_pos

func process_vertical_movement(delta: float) -> void:
	var screen_size = get_viewport_rect().size
	var half_screen_height = screen_size.y * 0.5
	var vertical_offset = (target.global_position.y - global_position.y) * zoom.y
	var player_screen_y = half_screen_height + vertical_offset
	var player_screen_fraction = player_screen_y / screen_size.y
	
	# Calculate asymmetric bounds
	var upper_bound = vertical_target - vertical_top_offset
	var lower_bound = vertical_target + vertical_bottom_offset
	
	# Update target Y position if player is outside bounds
	if player_screen_fraction < upper_bound or player_screen_fraction > lower_bound:
		target_camera_y = get_desired_camera_y(vertical_target)  # Always return to target line
	
	# Smooth vertical movement with enhanced smoothing
	var new_y = global_position.y
	if position_smoothing_enabled:
		new_y = lerp(global_position.y, target_camera_y, min(1.0, vertical_speed * position_smoothing_speed * delta))
	else:
		new_y = lerp(global_position.y, target_camera_y, vertical_speed * delta)
	global_position.y = new_y

func get_desired_camera_x(target_fraction: float) -> float:
	var screen_width = get_viewport_rect().size.x
	var half_screen_width = screen_width * 0.5
	var desired_screen_x = target_fraction * screen_width
	var _offset = (desired_screen_x - half_screen_width) / zoom.x
	return target.global_position.x - _offset

func get_desired_camera_y(target_fraction: float) -> float:
	var screen_height = get_viewport_rect().size.y
	var half_screen_height = screen_height * 0.5
	var desired_screen_y = target_fraction * screen_height
	var _offset = (desired_screen_y - half_screen_height) / zoom.y
	return target.global_position.y - _offset

func _draw() -> void:
	if debug_display:
		debug.draw(target)
