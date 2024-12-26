extends Node

const SERVER_PORT = 3311
#const SERVER_IP = "127.0.0.1"
#const SERVER_IP = "84.98.112.147"
var peer

var multiplayer_scene = preload("res://scenes/multiplayer/multiplayer_player.tscn")

var host_mode_enabled = false
var multiplayer_mode_enabled = false
var respawn_point = Vector2(30, 20)

#var _players_pseudos := {}

func _ready():
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)
	

func become_host(pseudo: String):
	#_players_pseudos[str(1)] = pseudo
	become_dedicated_host()
	_peer_connected(1)
	print("Waiting For Players! [%s]" % multiplayer.get_unique_id())

func become_dedicated_host():
	print("Starting host!")
	multiplayer_mode_enabled = true
	host_mode_enabled = true
	
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(SERVER_PORT, 10)
	if error != OK:
		printerr("Cannot HOST: %s" % error)
	
	# a bit of comrpession
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	
	_remove_single_player()
	#_spawn_coins()

func join_as_player(pseudo: String, server_ip: String):
	print("Player joining")
	
	multiplayer_mode_enabled = true
	
	peer = ENetMultiplayerPeer.new()
	peer.create_client(server_ip, SERVER_PORT)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	#_players_pseudos[str(client_peer.get_unique_id())] = pseudo
	#print("Player %s pseudo is %s" % [str(client_peer.get_unique_id()), pseudo])
	
	_remove_single_player()
	#_register_pseudo_on_server.rpc_id(1, pseudo)

func _peer_connected(id: int):
	print("Player joined the game! [%d]" % id)
	
	#var player_to_add = multiplayer_scene.instantiate()
	#player_to_add.player_id = id
	#player_to_add.name = str(id)
	#player_to_add.modulate = ColorsUtils.pick_random_hex_color_for_player()
	#
	#_players_spawn_node.add_child(player_to_add, true)



func _peer_disconnected(id: int):
	print("Player left the game! [%d]" % id)
	GameManager.Players.erase(id)
	var players = get_tree().get_nodes_in_group("Player")
	for i in players:
		if i.name == str(id):
			i.queue_free()

# called only from client
func _connected_to_server():
	print("Player connected to server! [%s]" % multiplayer.get_unique_id())
	SendPlayerInformation.rpc_id(1, "undefined", multiplayer.get_unique_id())

# called only from client
func _connection_failed():
	print("Couldn't connect.. [%s]"  % multiplayer.get_unique_id())

func _remove_single_player():
	print("Remove single player [%s]" % multiplayer.get_unique_id())
	var player_to_remove = get_tree().get_current_scene().get_node("Player")
	player_to_remove.queue_free()


func _spawn_coins():
	# Load the multiplayer coin scene (or pick whichever fits your project)
	var coin_scene = preload("res://scenes/multiplayer/multiplayer_coin.tscn")

	# The "Coins" node in your main scene must exist
	var coins_container = get_tree().get_current_scene().get_node("Coins")
	
	if coins_container == null:
		printerr("No 'Coins' node found! Check your scene.")
		return

	# Example: Find all your Markers that define coin positions
	for marker in coins_container.get_children():
		if marker is Marker2D and "CoinMarker" in marker.name:
			var coin = coin_scene.instantiate()
			coin.position = marker.position
			# The server is authority (often ID=1, but let's do it dynamically)
			coin.set_multiplayer_authority(multiplayer.get_unique_id())

			# Unique name so Godot replicates them properly
			coin.name = "Coin_%s" % marker.name

			coins_container.add_child(coin)
			marker.queue_free()  # remove marker if not needed

@rpc("any_peer")
func SendPlayerInformation(name, id):
	if !GameManager.Players.has(id):
		GameManager.Players[id] ={
			"name" : name,
			"id" : id,
			"score": 0
		}
	
	if multiplayer.is_server():
		for i in GameManager.Players:
			SendPlayerInformation.rpc(GameManager.Players[i].name, i)
