extends Node
#class_name SpawnerManager
#
#var _coins_spawn_node
#
#func instanciate_coins(game_manager):
	#var coin_scene = preload("res://scenes/multiplayer/multiplayer_coin.tscn") if MultiplayerManager.multiplayer_mode_enabled else preload("res://scenes/coin.tscn")
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
