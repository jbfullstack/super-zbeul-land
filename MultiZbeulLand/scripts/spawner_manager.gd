extends Node
#class_name SpawnerManager

@export var PlayerScene : PackedScene
@export var CoinScene : PackedScene

var respawn_point: Vector2

func _ready():
	var index = 0
	for player_id in GameManager.Players:
		spawnPlayer(index, player_id)
		index += 1
		
	respawn_point = get_tree().get_nodes_in_group("PlayerRespawnPoint")[0].global_position
	
	index = 0
	for coin in get_tree().get_nodes_in_group("CoinSpawnPoint"):
		#print("Spawn coin %s  [%s]" % [coin, multiplayer.get_unique_id()])
		var currentCoin = CoinScene.instantiate()
		currentCoin.position = coin.global_position
		currentCoin.id = index
		get_tree().root.get_node("Game").get_node("Coins").add_child(currentCoin)
		index += 1

@rpc("any_peer", "call_local")
func spawn_late_joiner(player_id):
	if !GameManager.Players.has(player_id):
		return
	
	# Avoid double-spawning if we already have a Node named after this player_id
	if has_node(str(player_id)):
		return
	
	var index = get_child_count()
	spawnPlayer(index, player_id)

func spawnPlayer(index_in_spawn_group: int, player_id):
	var currentPlayer = PlayerScene.instantiate()
	var found_player_in_list = GameManager.Players[player_id]
	#if found_player_in_list == null:
		#print("Player %s not found in player list  [%s]" % [player_id, multiplayer.get_unique_id()])
	#else:
		#print("Player %s found in player list  [%s]" % [player_id, multiplayer.get_unique_id()])
		#print("player_id.id = %s  [%s]" % [str(found_player_in_list.id), multiplayer.get_unique_id()])
		
	currentPlayer.name = str(found_player_in_list.id)
	currentPlayer.player_id = str(found_player_in_list.id)
	currentPlayer.pseudo = str(found_player_in_list.name)
	currentPlayer.modulate = GameManager.Players[player_id].color
	
	add_child(currentPlayer)
	for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoint"):
		if spawn.name == str(index_in_spawn_group):
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
