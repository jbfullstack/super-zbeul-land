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
		#print_d("Spawning coin %s  [%s]" % [coin, multiplayer.get_unique_id()])
		#print_d("GameManager.CollectedCoins.has index %s? %s  [%s]" % [coin, str(GameManager.CollectedCoins.has(index)), multiplayer.get_unique_id()])
		#for i in GameManager.CollectedCoins:
			#print_d("Coin %s collected by %s  [%s]" % [i, GameManager.CollectedCoins[i].player_id,  multiplayer.get_unique_id()])
		#print_d("*****")
		if !GameManager.CollectedCoins.has(index):
			var currentCoin = CoinScene.instantiate()
			currentCoin.position = coin.global_position
			currentCoin.id = index
			get_tree().root.get_node("Game").get_node("Coins").add_child(currentCoin, true)
		index += 1

@rpc("any_peer", "call_local")
func spawn_late_joiner(player_id):
	print_d("Spawning late player %s  [%s]" % [player_id, multiplayer.get_unique_id()])
	if !GameManager.Players.has(player_id):
		print_d("GameManager.Players do not have it -> return  [%s]" % [multiplayer.get_unique_id()])
		return
	
	# Avoid double-spawning if we already have a Node named after this player_id
	var players_node = get_players_node()
	if players_node.has_node(str(player_id)):
		print_d("Players node already have it -> return  [%s]" % [multiplayer.get_unique_id()])
		return
	else:
		print_d("Players %s not already spawned -> continue  [%s]" % [player_id, multiplayer.get_unique_id()])
	
	var index = GameManager.Players.keys().find(player_id)
	if index == -1:
		index = players_node.get_child_count() - 1
	
	spawnPlayer(index, player_id)

func spawnPlayer(index_in_spawn_group: int, player_id):
	var currentPlayer = PlayerScene.instantiate()
	var found_player_in_list = GameManager.Players[player_id]
	#if found_player_in_list == null:
		#print_d("Player %s not found in player list  [%s]" % [player_id, multiplayer.get_unique_id()])
	#else:
		#print_d("Player %s found in player list  [%s]" % [player_id, multiplayer.get_unique_id()])
		#print_d("player_id.id = %s  [%s]" % [str(found_player_in_list.id), multiplayer.get_unique_id()])
		
	currentPlayer.name = str(found_player_in_list.id)
	currentPlayer.player_id = str(found_player_in_list.id)
	currentPlayer.pseudo = str(found_player_in_list.name)
	currentPlayer.modulate = GameManager.Players[player_id].color
	
	print_d("Will spawnPlayer %s at index %s  [%s]" % [currentPlayer.name, index_in_spawn_group, multiplayer.get_unique_id()])
	
	var spawn_points =  get_tree().get_nodes_in_group("PlayerSpawnPoint")
	#get_players_node().add_child(currentPlayer, true)
	add_child(currentPlayer, true)
	
	print_d("player added  [%s]" % [multiplayer.get_unique_id()])
	
	#for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoint"):
		#print_d("Spawn player spawn.name %s found, index = %s  [%s]" % [spawn.name,  str(index_in_spawn_group),  multiplayer.get_unique_id()])
	if index_in_spawn_group < spawn_points.size():
		currentPlayer.global_position = spawn_points[index_in_spawn_group].global_position
		print_d("player added global pos: %s  [%s]" % [currentPlayer.global_position, multiplayer.get_unique_id()])
	else:
		currentPlayer.global_position = respawn_point
		print_d("player spawned at respawn point  [%s]" % [multiplayer.get_unique_id()])
			
func get_players_node():
	return get_tree().root.get_node("Game").get_node("Players")
	
func get_coins_node():
	return get_tree().root.get_node("Game").get_node("Coins")

func print_d(msg: String):
	if DebugUtils.debug_spawner_manager:
		print(msg)
