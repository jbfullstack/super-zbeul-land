extends Resource
class_name CollectedCoinData

var id: int
var player_id: String
var player_name: String

func _init(_id: int = 0, _player_id: String = "", _player_name: String = "",):
	player_id = _player_id
	id = _id
	player_name = _player_name
