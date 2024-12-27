extends Node

var Players = {}
var CollectedCoins = {}

func print_players():
	if multiplayer.is_server():	
		print("\nList of players: ")
		print("-----------------------------")
		for i in Players:
			print("%s [%s]" % [Players[i].name, Players[i].id])
		print("-----------------------------\n")
		
func print_collected_coins():
	if multiplayer.is_server():	
		print("\nList of collected coins: ")
		print("-----------------------------")
		for i in CollectedCoins:
			print("Coin %s collected by %s [%s]" % [CollectedCoins[i].id, CollectedCoins[i]._playder_name, CollectedCoins[i]._player_id])
		print("-----------------------------\n")

@rpc("any_peer")
func SendCollectedCoinInformation(collected_id: int, collector_id: int):
	if CollectedCoins.has(collected_id):
		print("Cannot add coin %s from CollectedCoins dict.. Coin already exists  [%d]" % [collected_id, multiplayer.get_unique_id()])
	else:
		CollectedCoins[collected_id] = {
			"player_id": collector_id
		}
		print("Coin %s added to CollectedCoins dict!  [%d]" % [collected_id, multiplayer.get_unique_id()])
	
	if multiplayer.is_server():
		SendCollectedCoinInformation.rpc(collected_id, collector_id)
	
