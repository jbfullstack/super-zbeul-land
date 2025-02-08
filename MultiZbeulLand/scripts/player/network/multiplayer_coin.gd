extends Area2D
class_name  MultiplayerCoin

@onready var animation_player = $AnimationPlayer
@onready var audio_player = $AudioPlayer

@export var sfx_pickup_loud: AudioStream
@export var sfx_pickup_soft: AudioStream

var id:= -1

func _on_body_entered(body):
	#game_manager.add_point(body)
	#animation_player.play("pickup")
	var spawn_tween = get_tree().create_tween()
	spawn_tween.tween_property(self, "position", position + Vector2(0, -10), 0.4)
	spawn_tween.tween_callback(queue_free)
	
	if NetworkController.multiplayer_mode_enabled:
		if multiplayer.is_server():
			GameManager.SendCollectedCoinInformation(id, body.player_id)
			GameManager.UpdateScoreInformation(body.player_id, 1)
			
		if body.player_id == multiplayer.get_unique_id():
			audio_player.stream = sfx_pickup_loud
			
		
	else:
		#game_manager.add_point(body)
		pass
	
	
		
		#GlobalAudioPlayer.play_sound(GlobalAudioPlayer.Sounds.COIN)
		
	
	
	#else:
		#audio_player.stream = sfx_pickup_soft

#func _ready():
	#var spawn_tween = get_tree().create_tween()
	#
	##GlobalAudioPlayer.play_sound(GlobalAudioPlayer.Sounds.COIN)
	#
	#spawn_tween.tween_property(self, "position", position + Vector2(0, -40), .3)
	#spawn_tween.chain().tween_property(self, "position", position, .3)
	#spawn_tween.tween_callback(queue_free)
