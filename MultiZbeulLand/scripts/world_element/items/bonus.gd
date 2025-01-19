extends FreezableArea2D
class_name Bonus

@onready var horizontal_speed = 35
@onready var max_vertical_speed = 120
@onready var vertical_velocity_gain = .2
@onready var shape_cast_2d = $ShapeCast2D as ShapeCast2D

var allow_horizontal_movement = false
var is_eatable = false
var vertical_speed = 0


func _process(delta):
	if handle_game_freeze():
		return
		
	if allow_horizontal_movement:
		position.x += delta * horizontal_speed
		
	if shape_cast_2d!= null && !shape_cast_2d.is_colliding() && allow_horizontal_movement:
		vertical_speed = lerpf(vertical_speed, max_vertical_speed, vertical_velocity_gain)
		position.y += delta * vertical_speed
	elif vertical_speed != 0 :
		vertical_speed = 0
