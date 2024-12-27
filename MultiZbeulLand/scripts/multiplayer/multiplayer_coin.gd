extends Area2D
class_name  MultiplayerCoin

@onready var animation_player = $AnimationPlayer

var id

func _on_body_entered(_body):
	#game_manager.add_point(body)
	animation_player.play("pickup")
	if multiplayer.is_server():
		GameManager.SendCollectedCoinInformation(id)
	else:
		GameManager.SendCollectedCoinInformation.rpc_id(1, id)
