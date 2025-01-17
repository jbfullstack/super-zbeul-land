extends Node
class_name GameState

var is_frozen = false

func freeze():
	print("freeze")
	is_frozen = true
	
func unfreeze():
	print("unfreeze")
	is_frozen = false
