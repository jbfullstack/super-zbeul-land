extends StaticBody2D
class_name Pipe



@export var is_traversable = false
@export var destination: Pipe

@onready var collision_shape_2d = $CollisionShape2D
@onready var pipe_body_sprite = $pipeBodySprite as Sprite2D
@onready var pipe_top_sprite = $pipeTopSprite

@onready var ray_cast_2d = $RayCast2D

var TOP_PIPE_HEIGHT
var BODY_PIPE_WIDTH

var is_computed = false



func _process(_delta):
	_calculate_height_and_adjust_pipe()

func _calculate_height_and_adjust_pipe():
	if is_computed:
		return
		
	TOP_PIPE_HEIGHT = pipe_top_sprite.texture.get_size().y
	BODY_PIPE_WIDTH = pipe_body_sprite.texture.get_size().x

	if ray_cast_2d.is_colliding():
		# Ensure the sprite's origin is at the top-left
		pipe_body_sprite.offset = Vector2(0, 0)
		
		var collision_point = ray_cast_2d.get_collision_point()
		print("Collision point: ", collision_point)

		var height = collision_point.y - global_position.y + 16
		print("Calculated height: ", height)

		adjust_pipe(height)
	else:
		print("Raycast did not collide. Defaulting height to 64.")
		adjust_pipe(64)

	is_computed = true

func adjust_pipe(height):
	var computed_size_x: float = BODY_PIPE_WIDTH 
	var computed_size_y: float = height - TOP_PIPE_HEIGHT  # Subtract top pipe height
	var computed_x: float = BODY_PIPE_WIDTH + (computed_size_y / 2 - (TOP_PIPE_HEIGHT / 2))
	var computed_y: float = TOP_PIPE_HEIGHT  # Start below the top pipe

	# Adjust the pipe body sprite
	var region_rect = Rect2(pipe_body_sprite.region_rect)
	region_rect.size = Vector2(computed_size_x, computed_size_y)
	pipe_body_sprite.region_rect = region_rect

	# Position the pipe body sprite
	pipe_body_sprite.position = Vector2(0, computed_x)

	# Adjust the collision shape
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(computed_size_x / 2, (computed_size_y + TOP_PIPE_HEIGHT) / 2)
	collision_shape_2d.shape = shape

	# Correct the collision shape position
	collision_shape_2d.position = Vector2(0, (height / 2) - (TOP_PIPE_HEIGHT / 2))


func _on_pipe_area_2d_body_entered(body):
	#if is_traversable && ( body is Player or  body is MultiplayerController):
		#body.on_top_of_pipe(self, true)
		pass


func _on_pipe_area_2d_body_exited(body):
	#if is_traversable && ( body is Player or body is MultiplayerController):
		#body.on_top_of_pipe(self, false)
		pass
