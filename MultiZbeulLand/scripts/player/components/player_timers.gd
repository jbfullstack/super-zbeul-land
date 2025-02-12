extends Node
class_name PlayerTimersComponenent

@onready var charger_jump_timer: Timer  = $ChargerJumpTimer

@onready var max_jump_timer: Timer = $MaxJumpTimer
var is_max_jump_active: bool = false

@onready var coyote_jump_timer: Timer = $CoyoteJumpTimer
var coyote_used: bool = false


func update_wait_time(timer: Timer, newTimeDuration: float):
	timer.wait_time = newTimeDuration

# --- Getters

func charger_jump() -> Timer:
	return charger_jump_timer
	
func coyote_jump() -> Timer:
	return coyote_jump_timer

func max_jump() -> Timer:
	return max_jump_timer

func get_jump_time_coefficient(timer : Timer) -> float:
	if max_jump().is_stopped():
		return 0.0
		
	# Get how much time has elapsed
	var total_duration: float = max_jump().wait_time
	var time_left: float = max_jump().time_left
	var elapsed_time: float = total_duration - time_left
	
	# Normalize it (0 = just started, 1 = finished)
	return elapsed_time / total_duration
	
# --- Utils

func coyote_timer_allows_jump() -> bool:
	return not ( coyote_jump().is_stopped() or coyote_used)

func start_coyote_jump() -> void:
	coyote_jump().start()
	coyote_used = false

func stop_coyote_jump() -> void:
	coyote_jump().stop()
	coyote_used = true
	
func start_max_jump() -> void:
	max_jump().start()
	is_max_jump_active = true

func stop_max_jump() -> void:
	max_jump().stop()
	is_max_jump_active = false
