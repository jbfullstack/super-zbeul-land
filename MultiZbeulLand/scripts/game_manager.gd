extends Node

var nb_collected_coin = 0

@onready var score_label = $ScoreLabel

func _ready():
	if OS.has_feature("dedicated_server"):
		print("Starting dedicated server...")
		MultiplayerManager.become_dedicated_host()

func add_point(body):
	nb_collected_coin += 1
	#score_label.text = str(body.player_id) + " collected " + str(score) + " coins."
	body.nb_collected_coin += 1
	if MultiplayerManager.host_mode_enabled:
		print( str(body.player_id) + " collected " + str(body.nb_collected_coin) + " coins.")
	else:
		print("Player collected " + str(body.nb_collected_coin) + " coins")

func become_host():
	print("Become host pressed")
	get_tree().paused = false
	%CanvasLayer.visible = false
	MultiplayerManager.become_host()
	
func join_as_player():
	print("Join as player")
	get_tree().paused = false
	%CanvasLayer.hide()
	MultiplayerManager.join_as_player()

func _on_solo_btn_pressed():
	print("Solo game")
	get_tree().paused = false
	%CanvasLayer.hide()
