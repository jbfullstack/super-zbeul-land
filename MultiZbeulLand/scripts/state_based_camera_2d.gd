extends Camera2D
class_name StateBasedCamera2D

# Original camera parameters
@export var target: Node2D
@export_range(0.0, 1.0) var pos_cam_1 := 0.2
@export_range(0.0, 1.0) var pos_cam_2 := 0.8
@export var dead_zone_size := 0.30
@export var camera_speed := 1.0
@export var zoom_factor := Vector2(4, 4)
@export var debug_display := true

enum CAMERA_STATE {
	TO_RIGHT,
	TO_LEFT
}

var current_side: CAMERA_STATE = CAMERA_STATE.TO_RIGHT
var target_camera_x: float

# Debug visualization data structure
class DebugLine:
	var start: Vector2
	var end: Vector2
	var color: Color
	var width: float
	
	func _init(s: Vector2, e: Vector2, c: Color, w: float = 2.0):
		start = s
		end = e
		color = c
		width = w

# Arrays to store debug visualization elements
var debug_lines: Array[DebugLine] = []

func _ready() -> void:
	zoom = zoom_factor
	target_camera_x = global_position.x

func _physics_process(delta: float) -> void:
	if not target:
		return
		
	# Original camera movement logic
	var screen_size = get_viewport_rect().size
	var half_screen_width = screen_size.x * 0.5
	var offset_in_pixels = (target.global_position.x - global_position.x) * zoom.x
	var player_screen_x = half_screen_width + offset_in_pixels
	var player_screen_fraction = player_screen_x / screen_size.x
	
	match current_side:
		CAMERA_STATE.TO_RIGHT:
			var left_bound = pos_cam_1 - dead_zone_size * 0.5
			var right_bound = pos_cam_1 + dead_zone_size * 0.5
			if player_screen_fraction < left_bound:
				current_side = CAMERA_STATE.TO_LEFT
				target_camera_x = get_desired_camera_x(pos_cam_2)
			elif player_screen_fraction > right_bound:
				target_camera_x = get_desired_camera_x(pos_cam_1)
				
		CAMERA_STATE.TO_LEFT:
			var left_bound = pos_cam_2 - dead_zone_size * 0.5
			var right_bound = pos_cam_2 + dead_zone_size * 0.5
			if player_screen_fraction > right_bound:
				current_side = CAMERA_STATE.TO_RIGHT
				target_camera_x = get_desired_camera_x(pos_cam_1)
			elif player_screen_fraction < left_bound:
				target_camera_x = get_desired_camera_x(pos_cam_2)
	
	# Smooth camera movement
	var new_x = lerp(global_position.x, target_camera_x, camera_speed * delta)
	global_position = Vector2(new_x, global_position.y)
	
	# Update debug visualization
	if debug_display:
		update_debug_lines()
		queue_redraw()

func get_desired_camera_x(target_fraction: float) -> float:
	var screen_width = get_viewport_rect().size.x
	var half_screen_width = screen_width * 0.5
	var desired_screen_x = target_fraction * screen_width
	var offset = (desired_screen_x - half_screen_width) / zoom.x
	return target.global_position.x - offset

func update_debug_lines() -> void:
	debug_lines.clear()
	
	var screen_size = get_viewport_rect().size
	var scaled_w = screen_size.x / zoom.x
	var scaled_h = screen_size.y / zoom.y
	var half_w = scaled_w * 0.5
	var half_h = scaled_h * 0.5
	
	# Calculate positions
	var dead_zone_width = scaled_w * dead_zone_size
	
	match current_side:
		CAMERA_STATE.TO_RIGHT:
			var target_x = scaled_w * pos_cam_1
			var offset = target_x - half_w
			if debug_display:
				add_camera_debug_lines(offset, dead_zone_width, half_h, current_side)
			
		CAMERA_STATE.TO_LEFT:
			var target_x = scaled_w * pos_cam_2
			var offset = target_x - half_w
			if debug_display:
				add_camera_debug_lines(offset, dead_zone_width, half_h, current_side)

func add_camera_debug_lines(offset: float, dead_zone_width: float, half_h: float, side: CAMERA_STATE) -> void:
	# Add dead zone lines
	debug_lines.append(DebugLine.new(
		Vector2(offset - dead_zone_width/2, -half_h),
		Vector2(offset - dead_zone_width/2, half_h),
		Color(0, 0.6, 1)
	))
	debug_lines.append(DebugLine.new(
		Vector2(offset + dead_zone_width/2, -half_h),
		Vector2(offset + dead_zone_width/2, half_h),
		Color(0, 0.6, 1)
	))
	
	# Add center line with correct color based on side
	var center_color = Color(1, 0, 0) if side == CAMERA_STATE.TO_RIGHT else Color(0.8, 0, 0.6)
	debug_lines.append(DebugLine.new(
		Vector2(offset, -half_h),
		Vector2(offset, half_h),
		center_color,
		1.0
	))

func _draw() -> void:
	if not debug_display:
		return
	
	# Draw all debug lines
	for line in debug_lines:
		draw_line(line.start, line.end, line.color, line.width)
	
	# Draw player position
	if target:
		var local_pos = target.global_position - global_position
		draw_circle(local_pos, 3.0, Color.GREEN)
