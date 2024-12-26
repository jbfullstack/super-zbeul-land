extends Area2D

@onready var animation_player = $AnimationPlayer
@onready var audio_player = $AudioPlayer

@export var sfx_pickup_loud: AudioStream
@export var sfx_pickup_soft: AudioStream

var coin_collected: bool = false

func _ready() -> void:
	if animation_player:
		animation_player.animation_finished.connect(_on_coin_anim_finished)

func _on_body_entered(body: Node) -> void:
	if coin_collected:
		return

	# Must be your MultiplayerController or whatever your player class is
	if not (body is MultiplayerController):
		return

	if multiplayer.is_server():
		# Server handles logic: marks coin as collected, increments player count, etc.
		coin_collected = true
		body.nb_collected_coin += 1
		print("Server: Player %d has now %d coins" % [body.player_id, body.nb_collected_coin])
		
		# Remove coin from server scene (so late joiners never see it)
		queue_free()

		# Let all peers do a local 'pickup' effect
		rpc("rpc_pickup_coin_effect", body.player_id)
	else:
		# If it's a client (not server), ask the server to handle pickup
		rpc_id(1, "server_request_pickup", body.get_instance_id())

@rpc("authority")
func server_request_pickup(body_id: int) -> void:
	# Clients call this so the server does the actual pickup logic
	if coin_collected:
		return

	var body = get_node_or_null(str(body_id))
	if body and body is MultiplayerController:
		coin_collected = true
		body.nb_collected_coin += 1
		print("Server: Player %d has now %d coins" % [body.player_id, body.nb_collected_coin])
		
		queue_free()
		
		rpc_pickup_coin_effect.rpc(body.player_id)

@rpc
func rpc_pickup_coin_effect(collector_id: int) -> void:
	print("rpc_pickup_coin_effect")
	# Everyone (including server, if it has visuals) plays the pickup animation/sound
	if !is_inside_tree():
		return

	# Decide loud or soft
	if multiplayer.get_unique_id() == collector_id:
		audio_player.stream = sfx_pickup_loud
	else:
		audio_player.stream = sfx_pickup_soft

	audio_player.play()
	if animation_player:
		animation_player.play("pickup")
	else:
		# If there's no animation (e.g. headless), just free
		queue_free()

func _on_coin_anim_finished(anim_name: String) -> void:
	if anim_name == "pickup":
		queue_free()
