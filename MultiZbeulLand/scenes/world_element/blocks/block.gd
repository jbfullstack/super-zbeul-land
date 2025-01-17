extends StaticBody2D
class_name Block

@onready var ray_cast_2d = $RayCast2D as RayCast2D

#func bump(_player_mode: Player.PlayerMode):
func bump():
	#GlobalAudioPlayer.play_sound(GlobalAudioPlayer.Sounds.BLOCK_HIT)
	var bump_tween = get_tree().create_tween()
	bump_tween.tween_property(self, "position", position + Vector2(0, -5), .12)
	bump_tween.chain().tween_property(self, "position", position, .12)
	check_for_upper_collisions()

func check_for_upper_collisions():
	if ray_cast_2d.is_colliding():
		print("block collision with %s" % ray_cast_2d.get_collider())
		
	#if ray_cast_2d.is_colliding() && ray_cast_2d.get_collider() is Enemy:
		#var enemy = ray_cast_2d.get_collider() as Enemy
		#enemy.die_from_hit()
	
	if ray_cast_2d.is_colliding() && ray_cast_2d.get_collider() is Player:
		var player = ray_cast_2d.get_collider() as Player
		#player.die()
		print("player %s hit by block (TODO)" % player.player_id)
