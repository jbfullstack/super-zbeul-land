extends Shroom
class_name ShroomMisteryBlock

# Animation constants
const delta_speed: float = 115
const fallin_scale: Vector2 = Vector2(0.6, 1.4)
const default_scale: Vector2 = Vector2(1, 1)
const squish_scale: Vector2 = Vector2(1.2, 0.8)

# Power-up settings
@export var invisibility_duration: float = 1.0

# Node references
@onready var collision_shape = $CollisionShape2D

# Animation variables
var current_scale_tween: Tween = null
var was_falling: bool = false

func _ready():
	if collision_shape:
		collision_shape.disabled = true
	
	var spawn_tween = get_tree().create_tween()
	spawn_tween.tween_property(self, "position", position + Vector2(0, -15), .4)
	spawn_tween.tween_callback(func(): 
		allow_horizontal_movement = true
		if collision_shape:
			collision_shape.disabled = false
		is_eatable = true
	)

# ... (keep your existing animation functions)

func _on_body_entered(body):
	print("Body entered: " + body.to_string())
	if is_eatable:
		if ClassUtils.is_network_player_type(body):
			print("Player detected: ", body.player_id)
			if multiplayer.is_server():
				handle_invisibility(body)
			else:
				request_invisibility.rpc_id(1, body.player_id)
			queue_free()
		elif ClassUtils.is_local_player_type(body):
			print("TODO: Player eat mushroom")
			

@rpc("any_peer")
func request_invisibility(player_id: int):
	if multiplayer.is_server():
		print_d("Server received invisibility request for player:  %d"  %player_id)
		var player = find_player_in_tree(get_tree().root, player_id)
		if player:
			handle_invisibility(player)

func handle_invisibility(player):
	if multiplayer.is_server():
		print_d("Server applying invisibility for player:  %d"  % player.player_id)
		if not player.is_invisible:
			player._set_invisible(player.player_id)
			# Start timer on server
			PowerUpManager.start_invisibility_timer(player.player_id, invisibility_duration)
			# Tell clients to sync their timers
			start_timer_on_clients.rpc(player.player_id)

@rpc
func start_timer_on_clients(player_id: int):
	print_d("Starting client timer for player: %d"  %player_id)
	if not multiplayer.is_server():
		PowerUpManager.start_invisibility_timer(player_id, invisibility_duration)

func find_player_in_tree(node: Node, target_id: int) -> Node:
	if node.has_method("_set_invisible") and node.get("player_id") == target_id:
		return node
		
	for child in node.get_children():
		var result = find_player_in_tree(child, target_id)
		if result:
			return result
	
	return null


func print_d(msg: String):
	if DebugUtils.debug_item_shroom_mistery_block || DebugUtils.debug_all_item:
		if NetworkController.multiplayer_mode_enabled:
			print("%s  [%s]" % [msg,multiplayer.get_unique_id() ])
		else:
			print(msg)
