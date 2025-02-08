extends StaticBody2D
class_name DefaultBrick

@onready var top_left_ray_cast = $TopLeftAngleRayCast2D as RayCast2D
@onready var centered_ray_cast = $CenteredRayCast2D as RayCast2D
@onready var top_right_ray_cast = $TopRightAngleRayCast2D as RayCast2D


var ray_cast_list = [top_left_ray_cast, centered_ray_cast, top_right_ray_cast]

#func bump(_player_mode: Player.PlayerMode):
func bump():
	#GlobalAudioPlayer.play_sound(GlobalAudioPlayer.Sounds.BLOCK_HIT)
	var bump_tween = get_tree().create_tween()
	bump_tween.tween_property(self, "position", position + Vector2(0, -5), .12)
	bump_tween.chain().tween_property(self, "position", position, .12)
	check_for_upper_collisions()

func check_for_upper_collisions():
	if !NetworkController.multiplayer_mode_enabled:
		var collider = is_brick_colliding_with(LocalPlayerController._name())
		if collider != null:
				var _player = collider as LocalPlayerController
				#player.die()
				print("player  hit by block (TODO)")
				return
	else:
		if multiplayer.is_server():
			var collider = is_brick_colliding_with(NetworkPlayerController._name())
			if collider != null:
				var player =collider as NetworkPlayerController
				#player.die()
				print("player %s hit by block (TODO)" % player.player_id)


func _on_bump_area_2d_body_entered(_body):
	bump()

func is_brick_colliding_with(className: String) -> Object:
	for ray_cast in  [top_left_ray_cast, centered_ray_cast, top_right_ray_cast]:
		if ray_cast.is_colliding():
			var collider = ray_cast.get_collider()
			if ClassUtils.is_instance_of_class(collider, className):
				print(ray_cast.name, " raycast collided with ", className)
				return collider
	return null
