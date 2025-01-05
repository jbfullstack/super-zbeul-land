extends Control

#@export var Address = "84.98.112.147"
var port = 3311
var peer
var game_scene = preload("res://scenes/game.tscn")

@onready var pseudoInput = %Pseudo
@onready var nb_player_lbl = %NbPlayerLbl
@onready var nb_player_joining_menu_lbl = %NbPlayerJoinWaitingLbl

@onready var canvas_layer = $CanvasLayer

var is_game_started = false
var is_local_game = false



# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	if "--server" in OS.get_cmdline_args():
		hostGame()
	#pass # Replace with function body.

func _process(_delta):
	manage_settings_display()

# this get called on the server and clients
func peer_connected(id):
	print_d("Player Connected  [%s]" % id)
	
	# If the game is already running and we're the server,
	if multiplayer.is_server() and is_game_started:
		# Instead of sending info + then StartGame, do it in one step:
		LateJoinStartGame.rpc_id(id, GameManager.Players, GameManager.CollectedCoins)
		
# this get called on the server and clients
func peer_disconnected(id):
	print_d("Player Disconnected  [%s]" % id)
	GameManager.Players.erase(id)
	var players = get_tree().get_nodes_in_group("Players")
	for i in players:
		if i.player_id == id:
			i.queue_free()

# called only from clients
func connected_to_server():
	print_d("connected To Sever!  [%s]" % multiplayer.get_unique_id())
	SendPlayerInformation.rpc_id(1, pseudoInput.text, multiplayer.get_unique_id())

# called only from clients
func connection_failed():
	print_d("Couldnt Connect  [%s]" % multiplayer.get_unique_id())

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
		print_d("updated number player %s " % nb_player_lbl.text)
		for i in GameManager.Players:
			SendPlayerInformation.rpc(GameManager.Players[i].name, i)
	
	# If the server is already in-game, spawn this new player on all peers
	if multiplayer.is_server() and is_game_started:
		var spawner_manager = getSpawnerManager()
		if spawner_manager != null:
			spawner_manager.spawn_late_joiner.rpc(id)
	
	GameManager.print_players()

@rpc("any_peer", "call_local")
func LateJoinStartGame(players_dict: Dictionary, collected_coins_dict: Dictionary):
	# 1) Update our local dictionary
	GameManager.Players = players_dict.duplicate()
	GameManager.CollectedCoins = collected_coins_dict.duplicate()
	
	# 2) Instantiate the game scene (if it's not already)
	if !is_game_started:
		var scene = game_scene.instantiate()
		get_tree().root.add_child(scene)
		canvas_layer.hide()
		_remove_single_player()
		get_tree().paused = false
		is_game_started = true
	else:
		# If we already loaded the scene, just get it
		if !get_tree().root.has_node("Game"):
			var scene2 = game_scene.instantiate()
			get_tree().root.add_child(scene2)
			canvas_layer.hide()
			_remove_single_player()
	
	# 3) Spawn every known player via SpawnerManager
	#var spawner_manager = getSpawnerManager()
	#if spawner_manager != null:
		#for player_id in GameManager.Players:
			#spawner_manager.spawn_late_joiner(player_id)

@rpc("any_peer","call_local")
func StartGame():
	var scene = game_scene.instantiate()
	get_tree().root.add_child(scene)
	canvas_layer.hide()
	_remove_single_player()
	get_tree().paused = false
	is_game_started = true

	# The new client now has the full dictionary, so let's spawn them all:
	#var spawner_manager = scene.get_node("SpawnerManager")
	#if spawner_manager:
		#for player_id in GameManager.Players:
			#spawner_manager.spawn_late_joiner(player_id)
	
func hostGame():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 10)
	if error != OK:
		print_d("cannot host: " +str( error))
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	print_d("Waiting For Players!  [%s]" % multiplayer.get_unique_id())
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


func _on_start_game_button_down():
	StartGame.rpc()
	pass

func _remove_single_player():
	print_d("Remove single player [%s]" % multiplayer.get_unique_id())
	var player_to_remove = get_tree().root.get_node("Game").get_node("Player")
	player_to_remove.queue_free()


func _on_solo_btn_pressed():
	var scene = game_scene.instantiate()
	get_tree().root.add_child(scene)
	is_game_started = true
	canvas_layer.hide()
	is_local_game = true
	get_tree().paused = false

func getSpawnerManager():
	var game_node = get_tree().root.get_node("Game")
	if game_node and game_node.has_node("SpawnerManager"):
		var spawner_manager = game_node.get_node("SpawnerManager")
		return spawner_manager
	
	printerr("spawner_manager not found  [%s]" % multiplayer.get_unique_id())
	return null
	
func print_d(msg: String):
	if DebugUtils.debug_network_setup:
		print(msg)
		
		
func manage_settings_display():
	if Input.is_action_just_pressed("settings"):
		if is_game_started:
			if is_local_game:
				if get_tree().paused == false:
					get_tree().paused = true
					canvas_layer.display(EnumsUtils.WINDOW.SETTINGS_MENU)
					canvas_layer.visible = true
				else:
					canvas_layer.hide()
					get_tree().paused = false
			else:
				if canvas_layer.visible == false:
					canvas_layer.display(EnumsUtils.WINDOW.SETTINGS_MENU)
					canvas_layer.visible = true
				else:
					canvas_layer.visible = false
					
	
