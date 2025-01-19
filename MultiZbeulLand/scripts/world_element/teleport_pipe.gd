extends StaticBody2D
class_name TeleportPipe

@export var destination: TeleportPipe

@onready var collision_shape_2d = $CollisionShape2D
@onready var pipe_body_sprite = $pipeBodySprite as Sprite2D
@onready var pipe_top_sprite = $pipeTopSprite

@onready var ray_cast_2d = $RayCast2D

var TOP_PIPE_HEIGHT
var BODY_PIPE_WIDTH

var is_lenght_computed = false



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
	#if !is_lenght_computed:
		#_calculate_height_and_adjust_pipe()

func _calculate_height_and_adjust_pipe():
	if is_lenght_computed:
		return
		
	TOP_PIPE_HEIGHT = pipe_top_sprite.texture.get_size().y
	BODY_PIPE_WIDTH = pipe_body_sprite.texture.get_size().x

	if ray_cast_2d.is_colliding():
		# Ensure the sprite's origin is at the top-left
		pipe_body_sprite.offset = Vector2(0, 0)
		
		var collision_point = ray_cast_2d.get_collision_point()
		#print("Collision point: ", collision_point)

		var height = collision_point.y - global_position.y + 16
		#print("Calculated height: ", height)

		adjust_pipe(height)
		is_lenght_computed = true
	#else:
		#print("Raycast did not collide. Defaulting height to 64.")
		#adjust_pipe(64)

	#is_lenght_computed = true

func adjust_pipe(height):
	var computed_size_x: float = BODY_PIPE_WIDTH 
	var computed_size_y: float = height - TOP_PIPE_HEIGHT  # Subtract top pipe height
	var computed_x: float = BODY_PIPE_WIDTH + (computed_size_y / 2 - (TOP_PIPE_HEIGHT / 2))
	#var computed_y: float = TOP_PIPE_HEIGHT  # Start below the top pipe

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
	if body is Player or body is MultiplayerController:
		print("pipe setted")
		body.current_pipe = self


func _on_pipe_area_2d_body_exited(body):
	if body is Player or body is MultiplayerController:
		print("pipe removed")
		body.current_pipe = null

func teleport_player(player):
	if not destination:
		return

	player.set_physics_process(false)
	player.position.x = position.x
	# Start entering animation
	var enter_pipe_tween = get_tree().create_tween()
	enter_pipe_tween.tween_property(player, "position", player.position + Vector2(0, TOP_PIPE_HEIGHT), 1)
	await enter_pipe_tween.finished

	# Teleport to destination pipe
	player.global_position = destination.global_position + Vector2(0, destination.TOP_PIPE_HEIGHT / 2)

	# Start exiting animation
	var exit_pipe_tween = get_tree().create_tween()
	exit_pipe_tween.tween_property(player, "position", player.position - Vector2(0, destination.TOP_PIPE_HEIGHT), 1)
	await exit_pipe_tween.finished
	
	# Position player on top of the destination pipe
	#player.global_position = destination.global_position - Vector2(0, destination.TOP_PIPE_HEIGHT)
	player.set_physics_process(true)


func _on_timer_timeout():
	_calculate_height_and_adjust_pipe()
