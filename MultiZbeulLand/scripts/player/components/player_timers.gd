extends Node
class_name PlayerTimersComponenent

@onready var charger_jump_timer: Timer  = $ChargerJumpTimer

@onready var coyote_jump_timer: Timer = $CoyoteJumpTimer
var coyote_used: bool = false


# --- Getters

func charger_jump() -> Timer:
	return charger_jump_timer
	
func coyote_jump() -> Timer:
	return coyote_jump_timer

# --- Utils

func coyote_timer_allows_jump() -> bool:
	return not ( coyote_jump().is_stopped() or coyote_used)

func start_coyote_jump() -> void:
	coyote_jump().start()
	coyote_used = false

func stop_coyote_jump() -> void:
	coyote_jump().stop()
	coyote_used = true
