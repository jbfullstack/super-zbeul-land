extends Node

var Players = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func print_players():
	if multiplayer.is_server():
		print("-----------------------------")
		print("List of players: ")		
		for i in GameManager.Players:
			print("%s [%s]" % [Players[i].name, Players[i].id])
		print("-----------------------------")
