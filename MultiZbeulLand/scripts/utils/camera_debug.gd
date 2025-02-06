class_name CameraDebug
extends Node

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

var debug_lines: Array[DebugLine] = []
var camera: Camera2D

func _init(camera_node: Camera2D) -> void:
	camera = camera_node

func update_debug_lines(current_side, pos_cam_1: float, pos_cam_2: float, dead_zone_size: float, zoom: Vector2) -> void:
	debug_lines.clear()
	
	var screen_size = camera.get_viewport_rect().size
	var scaled_w = screen_size.x / zoom.x
	var scaled_h = screen_size.y / zoom.y
	var half_w = scaled_w * 0.5
	var half_h = scaled_h * 0.5
	
	# Calculate positions
	var dead_zone_width = scaled_w * dead_zone_size
	
	match current_side:
		0: # TO_RIGHT
			var target_x = scaled_w * pos_cam_1
			var offset = target_x - half_w
			add_camera_debug_lines(offset, dead_zone_width, half_h, current_side)
			
		1: # TO_LEFT
			var target_x = scaled_w * pos_cam_2
			var offset = target_x - half_w
			add_camera_debug_lines(offset, dead_zone_width, half_h, current_side)

func add_camera_debug_lines(offset: float, dead_zone_width: float, half_h: float, side: int) -> void:
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
	var center_color = Color(1, 0, 0) if side == 0 else Color(0.8, 0, 0.6)
	debug_lines.append(DebugLine.new(
		Vector2(offset, -half_h),
		Vector2(offset, half_h),
		center_color,
		1.0
	))

func draw(target: Node2D) -> void:
	# Draw all debug lines
	for line in debug_lines:
		camera.draw_line(line.start, line.end, line.color, line.width)
	
	# Draw player position
	if target:
		var local_pos = target.global_position - camera.global_position
		camera.draw_circle(local_pos, 3.0, Color.GREEN)
