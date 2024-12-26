extends Node

var available_player_colors = [
	Color.hex(0x049CD8ff),
	Color.hex(0xFBD000ff),
	Color.hex(0xE52521ff),
	Color.hex(0x740063ff),
	Color.hex(0x329d9eaff),
	Color.hex(0xe9f344ff),
	Color.hex(0x569199ff),
	Color.hex(0x98583cff),
	Color.hex(0x292929ff),
	Color.hex(0x1c1c1cff),
	Color(0,0,1,1),
	Color(0,1,0,1),
	Color(0,1,1,1),
	Color(1,0,0,1),
	Color(1,0,1,1),
	Color(1,1,0,1),
	Color(1,1,1,1),
]

func pick_random_hex_color_for_player() -> Color:
	# Handle empty case
	if available_player_colors.size() == 0:
		return Color(1, 1, 1, 1) # white as fallback	
	# Get a random index
	var random_index = randi() % available_player_colors.size()
	# Retrieve color at that index
	var chosen_color = available_player_colors[random_index]	
	# Remove it so it won't be chosen again
	available_player_colors.remove_at(random_index)
	# Return the chosen color
	return chosen_color
