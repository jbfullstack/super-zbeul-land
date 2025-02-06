extends Camera2D
class_name StateBasedCamera2D

# Horizontal camera parameters
@export_category("general")
@export var target: Node2D
@export var zoom_factor := Vector2(4, 4)
@export var debug_display := false

@export_category("horizontal")
@export_range(0.0, 1.0) var pos_cam_1 := 0.2
@export_range(0.0, 1.0) var pos_cam_2 := 0.8
@export var dead_zone_size := 0.30
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

func _ready() -> void:
	zoom = zoom_factor
	target_camera_x = global_position.x
	target_camera_y = global_position.y
	debug = CameraDebug.new(self)

func _physics_process(delta: float) -> void:
	if not target:
		return
		
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

func process_horizontal_movement(delta: float) -> void:
	var screen_size = get_viewport_rect().size
	var half_screen_width = screen_size.x * 0.5
	var offset_in_pixels = (target.global_position.x - global_position.x) * zoom.x
	var player_screen_x = half_screen_width + offset_in_pixels
	var player_screen_fraction = player_screen_x / screen_size.x
	
	var state_changed := false
	var prev_pos := global_position.x
	
	match current_side:
		CAMERA_STATE.TO_RIGHT:
			var left_bound = pos_cam_1 - dead_zone_size * 0.5
			var right_bound = pos_cam_1 + dead_zone_size * 0.5
			if player_screen_fraction < left_bound:
				current_side = CAMERA_STATE.TO_LEFT
				target_camera_x = get_desired_camera_x(pos_cam_2)
				start_transition(prev_pos)
				state_changed = true
			elif player_screen_fraction > right_bound:
				target_camera_x = get_desired_camera_x(pos_cam_1)
				
		CAMERA_STATE.TO_LEFT:
			var left_bound = pos_cam_2 - dead_zone_size * 0.5
			var right_bound = pos_cam_2 + dead_zone_size * 0.5
			if player_screen_fraction > right_bound:
				current_side = CAMERA_STATE.TO_RIGHT
				target_camera_x = get_desired_camera_x(pos_cam_1)
				start_transition(prev_pos)
				state_changed = true
			elif player_screen_fraction < left_bound:
				target_camera_x = get_desired_camera_x(pos_cam_2)
	
	# Apply movement
	if is_transitioning and curve:
		apply_curve_movement(delta)
	else:
		# Regular lerp movement for small adjustments
		var new_x = lerp(global_position.x, target_camera_x, camera_speed * delta)
		global_position.x = new_x

func start_transition(from_pos: float) -> void:
	if curve:
		transition_time = 0
		transition_dir = 1
		is_transitioning = true
		transition_start_pos = from_pos

func apply_curve_movement(delta: float) -> void:
	transition_time += delta * transition_dir
	
	if transition_time >= transition_duration:
		is_transitioning = false
		global_position.x = target_camera_x
		return
	
	# Sample the curve
	var t = transition_time / transition_duration
	var curve_value = curve.sample(t)
	
	# Interpolate position
	global_position.x = lerp(transition_start_pos, target_camera_x, curve_value)

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
	
	# Smooth vertical movement
	var new_y = lerp(global_position.y, target_camera_y, vertical_speed * delta)
	global_position.y = new_y

func get_desired_camera_x(target_fraction: float) -> float:
	var screen_width = get_viewport_rect().size.x
	var half_screen_width = screen_width * 0.5
	var desired_screen_x = target_fraction * screen_width
	var offset = (desired_screen_x - half_screen_width) / zoom.x
	return target.global_position.x - offset

func get_desired_camera_y(target_fraction: float) -> float:
	var screen_height = get_viewport_rect().size.y
	var half_screen_height = screen_height * 0.5
	var desired_screen_y = target_fraction * screen_height
	var offset = (desired_screen_y - half_screen_height) / zoom.y
	return target.global_position.y - offset

func _draw() -> void:
	if debug_display:
		debug.draw(target)
