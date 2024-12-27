extends Area2D

@onready var game_manager
@onready var animation_player = $AnimationPlayer

func init(gm):
	game_manager = gm

func _on_body_entered(_body):
	#game_manager.add_point(body)
	animation_player.play("pickup")
