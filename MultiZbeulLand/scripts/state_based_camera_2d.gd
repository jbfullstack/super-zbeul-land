extends Camera2D
class_name StateBasedCamera2D

# Original camera parameters
@export var target: Node2D
@export_range(0.0, 1.0) var pos_cam_1 := 0.2
@export_range(0.0, 1.0) var pos_cam_2 := 0.8
@export var dead_zone_size := 0.30
@export var camera_speed := 2.0
@export var zoom_factor := Vector2(4, 4)
@export var debug_display := true

enum CAMERA_STATE {
	TO_RIGHT,
	TO_LEFT
}

var current_side: CAMERA_STATE = CAMERA_STATE.TO_RIGHT
var target_camera_x: float
var debug: CameraDebug

func _ready() -> void:
	zoom = zoom_factor
	target_camera_x = global_position.x
	debug = CameraDebug.new(self)

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
		debug.update_debug_lines(current_side, pos_cam_1, pos_cam_2, dead_zone_size, zoom)
		queue_redraw()

func get_desired_camera_x(target_fraction: float) -> float:
	var screen_width = get_viewport_rect().size.x
	var half_screen_width = screen_width * 0.5
	var desired_screen_x = target_fraction * screen_width
	var offset = (desired_screen_x - half_screen_width) / zoom.x
	return target.global_position.x - offset

func _draw() -> void:
	if debug_display:
		debug.draw(target)
