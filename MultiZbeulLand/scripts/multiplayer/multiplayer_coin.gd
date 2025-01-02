extends Area2D
class_name  MultiplayerCoin

@onready var animation_player = $AnimationPlayer
@onready var audio_player = $AudioPlayer

@export var sfx_pickup_loud: AudioStream
@export var sfx_pickup_soft: AudioStream

var id:= -1

func _on_body_entered(body):
	#game_manager.add_point(body)
	animation_player.play("pickup")
	if NetworkController.multiplayer_mode_enabled:
		if multiplayer.is_server():
			GameManager.SendCollectedCoinInformation(id, body.player_id)
			
		if body.player_id == multiplayer.get_unique_id():
			audio_player.stream = sfx_pickup_loud
	else:
		#game_manager.add_point(body)
		pass
		
	
	#else:
		#audio_player.stream = sfx_pickup_soft
