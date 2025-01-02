extends Node

var Players = {}
var current_player
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
		#print("Coin %s added to CollectedCoins dict!  [%d]" % [collected_id, multiplayer.get_unique_id()])
	
	if multiplayer.is_server():
		SendCollectedCoinInformation.rpc(collected_id, collector_id)
		
@rpc("any_peer")
func UpdateScoreInformation(player_id: int, score_delta: int):
	if! Players.has(player_id):
		print("Cannot update score for player %s, Player not in the Players List  [%d]" % [player_id, multiplayer.get_unique_id()])
		return
	else:
		Players[player_id]["score"] += score_delta
		current_player.player_hud.UpdateScoreHUD.rpc()
		#UpdateScoreHUD.rpc_id(multiplayer.get_unique_id())
		#print("Coin %s added to CollectedCoins dict!  [%d]" % [collected_id, multiplayer.get_unique_id()])
	
	if multiplayer.is_server():
		UpdateScoreInformation.rpc(player_id, score_delta)
	
