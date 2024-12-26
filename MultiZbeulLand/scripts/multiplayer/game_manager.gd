extends Node

var Players = {}

func print_players():
	if multiplayer.is_server():	
		print("\nList of players: ")
		print("-----------------------------")
		for i in GameManager.Players:
			print("%s [%s]" % [Players[i].name, Players[i].id])
		print("-----------------------------\n")
