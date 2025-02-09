extends RefCounted
class_name PlayerInputState

var direction: float = 0.0
var should_jump: bool = false
var should_down: bool = false

func reset_one_shot_actions() -> void:
	should_jump = false
	should_down = false

