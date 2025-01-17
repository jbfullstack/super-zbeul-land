extends DefaultBrick
class_name  MysteryBlock

enum BonusType {
	COIN,
	SHROOM,
	FLOWER
}

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var bump_area = $BumpArea2D
@onready var block_collision_shape = $BumpArea2D/BumpCollisionShape2D
@export var bonus_type: BonusType = BonusType.SHROOM
@export var invisible: bool = false


var is_empty: bool = false

func _ready():
	animated_sprite_2d.visible = !invisible
	if invisible:
		_disable_collisions()
	else:
		_enable_collisions()
	# Ensure the bump_area is set to monitoring in the editor

func make_visible():
	invisible = false
	animated_sprite_2d.visible = true
	_enable_collisions()
	
func _set_visible():	
	if multiplayer.is_server():
		make_visible()
		sync_visibility.rpc()
	
@rpc
func sync_visibility():
	print("sync visibility  [%s]" % multiplayer.multiplayer_peer)
	make_visible()
	
func bump():
	if is_empty:
		return

	super.bump()
	_set_empty()

	match bonus_type:
		BonusType.COIN:
			spawn_coin()
		BonusType.SHROOM:
			spawn_shroom()
		BonusType.FLOWER:
			spawn_flower()

func make_empty():
	is_empty = true
	animated_sprite_2d.play("empty")

func _set_empty():
	if multiplayer.is_server():
		make_empty()
		sync_empty.rpc()

@rpc
func sync_empty():
	print("sync empty [%s]" % multiplayer.multiplayer_peer)
	make_empty()

func spawn_coin():
	#var coin = COIN_SCENE.instantiate()
	#coin.global_position = global_position + Vector2(0, -16)
	#get_tree().root.add_child(coin)
	#get_tree().get_first_node_in_group("level_manager").on_coin_collected()
	pass

func spawn_shroom():
	#var shroom = SHROOM_SCENE.instantiate()
	#shroom.global_position = global_position
	#get_tree().root.call_deferred("add_child", shroom)
	pass

func spawn_flower():
	#var flower = SHOOTING_FLOWER_SCENE.instantiate()
	#flower.global_position = global_position
	#get_tree().root.call_deferred("add_child", flower)
	pass

func _disable_collisions():
	collision_layer = 0
	collision_mask = 0

func _enable_collisions():
	# Adjust these to match your layers/masks setup
	set_collision_layer_value(1, true)
	set_collision_mask_value(2, true)
	#set_collision_mask_value(3, true)

func _prevent_player_stuck(player):
	# Get the block's collision shape and compute its rect
	var block_rect = _get_collision_rect(block_collision_shape, global_position)

	# Get player's collision shape node; adjust the path if needed
	var player_collision_shape = player.getShape()
	var player_rect = _get_collision_rect(player_collision_shape, player.global_position)

	# Check overlap
	if block_rect.intersects(player_rect):
		# Move player just below the block
		# We assume the block and player rect are properly sized.
		player.global_position.y = block_rect.position.y + block_rect.size.y + (player_rect.size.y * 0.5) + 1

func _get_collision_rect(collision_shape: CollisionShape2D, entity_pos: Vector2) -> Rect2:
	var shape = collision_shape.get_shape()
	if shape is RectangleShape2D:
		# RectangleShape2D is centered on the entity_pos by default
		var half_size = shape.size * 0.5
		return Rect2(entity_pos - half_size, shape.size)
	# If you have other shape types, handle them here or convert your shapes to RectangleShape2D.
	return Rect2(entity_pos, Vector2.ZERO)


func _on_bump_area_2d_body_entered(body):
	if !is_empty:
		if ClassUtils.is_player_type(body):
			var player_below = body.global_position.y > global_position.y
			var player_moving_up = body.velocity.y < 0
			if invisible:
				if player_below and player_moving_up:
					_set_visible()
					bump()
					# Ensure player doesn't get stuck inside now-solid block
					_prevent_player_stuck(body)
			else:
				bump()


