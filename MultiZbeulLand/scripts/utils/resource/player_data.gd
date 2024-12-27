extends Resource
class_name PlayerData

var name: String
var player_id: int
var color: Color
var score: int

func _init(_name: String = "", _id: int = 0):
	name = _name
	player_id = _id
	color = ColorsUtils.pick_random_hex_color_for_player()
	score = 0
