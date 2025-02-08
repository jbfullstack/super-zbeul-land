extends Node

var Players = {}
var current_player
var CollectedCoins = {}

func print_players():
	if multiplayer.is_server():	
		print("\nList of players: ")
		print("-----------------------------")
		for i in Players:
			print("%s  [%s]" % [Players[i].name, Players[i].id])
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
	if not Players.has(player_id):
		print("Cannot update score for player %s, Player not in the Players List  [%d]" % [player_id, multiplayer.get_unique_id()])
		return
	
	# Update score in Players dictionary
	Players[player_id]["score"] += score_delta
	
	# Propagate update to all clients if we're the server
	if multiplayer.is_server():
		UpdateScoreInformation.rpc(player_id, score_delta)
		# Tell all clients to update their HUDs
		NotifyScoreUpdate.rpc(player_id)

@rpc
func NotifyScoreUpdate(player_id: int):
	# Find the player node and update its HUD if it exists
	var root = get_tree().root
	if root.has_node("Game"):
		var game = root.get_node("Game")
		# Use get_node_or_null to avoid errors if node doesn't exist
		var player = game.get_node_or_null(str(player_id))
		if player and player.has_node("%PlayerHUD"):
			player.get_node("%PlayerHUD").update_score()
