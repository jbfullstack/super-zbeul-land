# power_up_manager.gd
extends Node

# Dictionary to store active timers
var active_timers = {}

func start_invisibility_timer(player_id: int, duration: float = 1.0):
	print("PowerUpManager: Starting invisibility timer for player ", player_id)
	
	# Only server should manage timers
	if not multiplayer.is_server():
		return
		
	# Cancel existing timer if there is one
	if active_timers.has(player_id):
		active_timers[player_id].queue_free()
		active_timers.erase(player_id)
	
	# Create new timer
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = duration
	timer.one_shot = true
	
	# Store timer reference
	active_timers[player_id] = timer
	
	# Connect timeout signal
	timer.timeout.connect(func():
		print("PowerUpManager: Timer completed for player ", player_id)
		if multiplayer.is_server():
			# Find player and reset visibility using the same method as the input system
			var player = find_player(get_tree().root, player_id)
			if player:
				player._reset_alpha(player_id)
		# Clean up timer
		timer.queue_free()
		active_timers.erase(player_id)
	)
	
	timer.start()
	print("PowerUpManager: Timer started for player ", player_id)

func find_player(node: Node, player_id: int) -> Node:
	if node.has_method("_set_invisible") and node.get("player_id") == player_id:
		return node
		
	for child in node.get_children():
		var result = find_player(child, player_id)
		if result:
			return result
	
	return null
