extends Control

#@export var Address = "84.98.112.147"
@export var port = 3311
var peer
var game_scene = "res://scenes/game.tscn"

@onready var pseudoInput = %Pseudo
@onready var nb_player_lbl = %NbPlayerLbl
@onready var nb_player_joining_menu_lbl = %NbPlayerJoinWaitingLbl

@onready var canvas_layer = $CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	#if "--server" in OS.get_cmdline_args():
		#hostGame()
	#pass # Replace with function body.


# this get called on the server and clients
func peer_connected(id):
	print("Player Connected  [%s]" % id)
	
# this get called on the server and clients
func peer_disconnected(id):
	print("Player Disconnected  [%s]" % id)
	GameManager.Players.erase(id)
	var players = get_tree().get_nodes_in_group("Player")
	for i in players:
		if i.name == str(id):
			i.queue_free()
# called only from clients
func connected_to_server():
	print("connected To Sever!  [%s]" % multiplayer.get_unique_id())
	SendPlayerInformation.rpc_id(1, pseudoInput.text, multiplayer.get_unique_id())

# called only from clients
func connection_failed():
	print("Couldnt Connect  [%s]" % multiplayer.get_unique_id())

@rpc("any_peer")
func SendPlayerInformation(pseudo, id):
	if !GameManager.Players.has(id):
		GameManager.Players[id] ={
			"name" : pseudo,
			"id" : id,
			"score": 0,
			"color":  ColorsUtils.pick_random_hex_color_for_player()
		}
	
	nb_player_lbl.text = "%s players" % GameManager.Players.size()
	nb_player_joining_menu_lbl.text = "%s players" % GameManager.Players.size()
	
	if multiplayer.is_server():		
		print("updated number player %s " % nb_player_lbl.text)
		for i in GameManager.Players:
			SendPlayerInformation.rpc(GameManager.Players[i].name, i)
	
	GameManager.print_players()

@rpc("any_peer","call_local")
func StartGame():
	var scene = load(game_scene).instantiate()
	get_tree().root.add_child(scene)
	canvas_layer.hide()
	_remove_single_player()
	get_tree().paused = false
	
func hostGame():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 2)
	if error != OK:
		print("cannot host: " + error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting For Players!  [%s]" % multiplayer.get_unique_id())
	NetworkController.multiplayer_mode_enabled = true
	NetworkController.host_mode_enabled = true
	
	
func _on_host_button_down():
	hostGame()
	SendPlayerInformation(pseudoInput.text, multiplayer.get_unique_id())
	pass


func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(canvas_layer.get_server_ip(), port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	
	NetworkController.multiplayer_mode_enabled = true
	pass


func _on_start_game_button_down():
	StartGame.rpc()
	pass

func _remove_single_player():
	print("Remove single player [%s]" % multiplayer.get_unique_id())
	var player_to_remove = get_tree().root.get_node("Game").get_node("Player")
	player_to_remove.queue_free()


func _on_solo_btn_pressed():
	var scene = load(game_scene).instantiate()
	get_tree().root.add_child(scene)
	canvas_layer.hide()
	get_tree().paused = false