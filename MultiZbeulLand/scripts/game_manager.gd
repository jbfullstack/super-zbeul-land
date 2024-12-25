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
	print( str(body.player_id) + " collected " + str(body.nb_collected_coin) + " coins.")

func become_host():
	print("Become host pressed")
	%MultiplayerHUD.hide()
	MultiplayerManager.become_host()
	
func join_as_player():
	print("Join as player")
	%MultiplayerHUD.hide()
	MultiplayerManager.join_as_player()
