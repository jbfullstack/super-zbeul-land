class_name CameraDebug
extends Node

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

func update_debug_lines(horizontal_state: int, vertical_active: bool, 
						pos_cam_1: float, pos_cam_2: float, 
						vertical_target: float, vertical_top_offset: float, 
						vertical_bottom_offset: float,
						dead_zone_size: float, zoom: Vector2) -> void:
	debug_lines.clear()
	
	var screen_size = camera.get_viewport_rect().size
	var scaled_w = screen_size.x / zoom.x
	var scaled_h = screen_size.y / zoom.y
	var half_w = scaled_w * 0.5
	var half_h = scaled_h * 0.5
	
	# Horizontal debug lines
	var dead_zone_width = scaled_w * dead_zone_size
	match horizontal_state:
		0: # TO_RIGHT
			var target_x = scaled_w * pos_cam_1
			var offset = target_x - half_w
			add_horizontal_debug_lines(offset, dead_zone_width, half_h, horizontal_state)
		1: # TO_LEFT
			var target_x = scaled_w * pos_cam_2
			var offset = target_x - half_w
			add_horizontal_debug_lines(offset, dead_zone_width, half_h, horizontal_state)
	
	# Vertical debug lines
	if vertical_active:
		add_vertical_debug_lines(vertical_target, vertical_top_offset, vertical_bottom_offset, scaled_h, half_w)

func add_horizontal_debug_lines(offset: float, dead_zone_width: float, half_h: float, side: int) -> void:
	# Dead zone lines
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
	
	# Center line
	var center_color = Color(1, 0, 0) if side == 0 else Color(0.8, 0, 0.6)
	debug_lines.append(DebugLine.new(
		Vector2(offset, -half_h),
		Vector2(offset, half_h),
		center_color,
		1.0
	))

func add_vertical_debug_lines(target: float, top_offset: float, 
							bottom_offset: float, scaled_h: float, half_w: float) -> void:
	var half_h = scaled_h * 0.5
	var center_offset = (target - 0.5) * scaled_h
	
	# Add boundary lines
	# Top boundary (red)
	debug_lines.append(DebugLine.new(
		Vector2(-half_w, center_offset - (top_offset * scaled_h)),
		Vector2(half_w, center_offset - (top_offset * scaled_h)),
		Color(1, 0.4, 0.4)  # Light red
	))
	
	# Bottom boundary (orange)
	debug_lines.append(DebugLine.new(
		Vector2(-half_w, center_offset + (bottom_offset * scaled_h)),
		Vector2(half_w, center_offset + (bottom_offset * scaled_h)),
		Color(1, 0.6, 0.2)  # Orange
	))
	
	# Target line (green)
	debug_lines.append(DebugLine.new(
		Vector2(-half_w, center_offset),
		Vector2(half_w, center_offset),
		Color(0, 0.8, 0),  # Green
		1.0
	))

func draw(target: Node2D) -> void:
	# Draw all debug lines
	for line in debug_lines:
		camera.draw_line(line.start, line.end, line.color, line.width)
	
	# Draw player position
	#if target:
		#var local_pos = target.global_position - camera.global_position
		#camera.draw_circle(local_pos, 3.0, Color.GREEN)
