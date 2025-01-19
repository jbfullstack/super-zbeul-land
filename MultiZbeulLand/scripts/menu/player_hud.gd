extends CanvasLayer

@onready var name_lbl = %NameLbl
@onready var score_value_lbl = %ScoreValueLbl

func init(player_id):
	var player_data = GameManager.Players[player_id]
	if player_data:
		name_lbl.text = player_data.name
		score_value_lbl.text = str(player_data.score)
	
func update_score():
	# Get the player_id from our parent MultiplayerController
	var controller = get_parent()
	if not controller:
		return
		
	var player_id = controller.player_id
	var player_data = GameManager.Players[player_id]
	if player_data == null:
		print("cannot update score, player data not found in Players List... [%s]" % player_id)
		return
		
	score_value_lbl.text = str(player_data.score)
	

@rpc("call_local")
func UpdateScoreHUD():
	update_score()
