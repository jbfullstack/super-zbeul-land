extends CanvasLayer

@onready var name_lbl = %NameLbl
@onready var score_value_lbl = %ScoreValueLbl


# Called when the node enters the scene tree for the first time.
func init(player_id):
	var player_data = GameManager.Players[player_id]
	name_lbl.text = player_data.name
	score_value_lbl.text = str(player_data.score)
	#else:
		#print("player data not found in Players List...  [%s]" % multiplayer.get_unique_id())
		#return
		
	


func update_score():
	var player_data = GameManager.Players[multiplayer.get_unique_id()]
	if player_data == null:
		print("cannot pdate score, player data not found in Players List...  [%s]" % multiplayer.get_unique_id())
		return
	score_value_lbl.text = str(player_data.score)
	

@rpc("call_local")
func UpdateScoreHUD():
	update_score()
