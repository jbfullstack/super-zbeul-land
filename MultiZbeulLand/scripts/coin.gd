extends Area2D

@onready var game_manager = %GameManager
@onready var animation_player = $AnimationPlayer

func _on_body_entered(body):
	animation_player.play("pickup")
	
	if multiplayer.is_server():
		game_manager.add_point(body)
