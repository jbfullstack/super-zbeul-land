extends Area2D

@onready var timer = $Timer

func _on_body_entered(body):
	print("kill zone: ", body)
	if !body is TileMap:
		if not NetworkController.multiplayer_mode_enabled:
			print("You died!")
			Engine.time_scale = 0.5
			var collShape = body.get_node("CollisionShape2D")
			if collShape != null:
				collShape.queue_free()
			timer.start()
		else:
			_multiplayer_dead(body)

func _multiplayer_dead(body):
	if multiplayer.is_server() && body.alive:
		#Engine.time_scale = 0.5
		body.mark_dead()

func _on_timer_timeout():
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
