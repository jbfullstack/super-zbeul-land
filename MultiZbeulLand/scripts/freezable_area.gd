extends Area2D
class_name FreezableArea2D

@onready var animated_sprite_2d = $AnimatedSprite2D as AnimatedSprite2D

var is_animation_paused = false

func _physics_process(_delta):
	if handle_game_freeze():
		return
			
func _process(_delta):
	if handle_game_freeze():
		return
		
func handle_game_freeze():
	if GlobalGameState.is_frozen:
		# Only pause once
		if animated_sprite_2d != null:
			if not is_animation_paused:
				animated_sprite_2d.pause()
				is_animation_paused = true
		return true
	else:
		# Only resume if the animation was paused
		if animated_sprite_2d != null:
			if is_animation_paused:
				animated_sprite_2d.play()
				is_animation_paused = false
		return false
