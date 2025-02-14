extends RefCounted
class_name PlayerInputState

var direction: float = 0.0
var should_start_run: bool = false
var should_stop_run: bool = false
var is_run_action_activated: bool = false
var should_jump: bool = false
var jump_just_released: bool = false
var should_down: bool = false
var should_grapple_action: bool = false
var joystick_direction: Vector2 = Vector2.ZERO


func reset_one_shot_actions() -> void:	
	should_start_run = false
	should_stop_run = false
	should_jump = false
	should_down = false
	jump_just_released = false
	should_grapple_action = false

