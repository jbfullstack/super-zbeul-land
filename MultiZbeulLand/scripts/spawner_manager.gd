extends Node
#class_name SpawnerManager

@export var PlayerScene : PackedScene


func _ready():
	var index = 0
	for i in GameManager.Players:
		var currentPlayer = PlayerScene.instantiate()
		currentPlayer.name = str(GameManager.Players[i].id)
		currentPlayer.player_id = str(GameManager.Players[i].id)
		currentPlayer.pseudo = str(GameManager.Players[i].name)
		currentPlayer.modulate = ColorsUtils.pick_random_hex_color_for_player()
		
		add_child(currentPlayer)
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoint"):
			if spawn.name == str(index):
				currentPlayer.global_position = spawn.global_position
		index += 1

@rpc("any_peer", "call_local")
func spawn_late_joiner(player_id):
	if !GameManager.Players.has(player_id):
		return
	
	# Avoid double-spawning if we already have a Node named after this player_id
	if has_node(str(player_id)):
		return
	
	var currentPlayer = PlayerScene.instantiate()
	currentPlayer.name = str(GameManager.Players[player_id].id)
	currentPlayer.player_id = str(GameManager.Players[player_id].id)
	currentPlayer.pseudo = str(GameManager.Players[player_id].name)
	currentPlayer.modulate = ColorsUtils.pick_random_hex_color_for_player()
	
	# Example approach: place them in the next available spawn slot
	var index = get_child_count()
	add_child(currentPlayer)
	for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoint"):
		if spawn.name == str(index):
			currentPlayer.global_position = spawn.global_position


#var _coins_spawn_node
#
#func instanciate_coins(game_manager):
	#var coin_scene = preload("res://scenes/multiplayer/multiplayer_coin.tscn") if NetworkController..multiplayer_mode_enabled else preload("res://scenes/coin.tscn")
	#var coins_container = $"../Coins"
	#
	#_coins_spawn_node = get_tree().get_current_scene().get_node("Coins")
#
	#
	#for marker in coins_container.get_children():
		#if marker is CoinMarker:
			#var coin_to_add = coin_scene.instantiate()
			#coin_to_add.position = marker.position
			#coin_to_add.init(game_manager)
			#
			## IMPORTANT: The server should be the authority
			## so that new clients see this node. 
			## If the server has unique_id == 1, you can do:			coin_instance.set_multiplayer_authority(multiplayer.get_unique_id())
#
			#
			#coin_to_add.name = "Coin_%s" % marker.name
#
			##coins_container.add_child(coin_instance)
			#_coins_spawn_node.add_child(coin_to_add, true)
#
			## Optional: Remove the original Marker2D if it's no longer needed
			#marker.queue_free()
