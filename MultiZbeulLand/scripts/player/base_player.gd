extends CharacterBody2D
class_name BasePlayerController

@onready var coyote_timer: Timer = $CoyoteJumpTimer
var coyote_used: bool = false

# State variables
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_pipe = null
var nb_collected_coin = 0
var alive = true
var wall_normal = Vector2.ZERO
var last_wall_normal = Vector2.ZERO
var is_wall_sliding = false
var last_jump_side = 0

# Protected variables for child classes
var _input_state: PlayerInputState
var is_invisible: bool:
	get:
		return visibility_manager.is_invisible if visibility_manager else false

@onready var animated_sprite = $AnimatedSprite2D as AnimatedSprite2D
@onready var visibility_manager = %Invisibility
@onready var state_machine = $StateMachine as BasePlayerStateMachine

func _ready() -> void:
	_input_state = PlayerInputState.new()
	# Ensure that all states have access to the player
	for state in state_machine.get_children():
		if state is BasePlayerState:
			state.player = self
	# Ensure that particles are disabled on start
	if has_node("WallDustParticles"):
		$WallDustParticles.emitting = false

func getShape():
	return self.get_node("CollisionShape2D")

func _physics_process(delta):
	if not alive && is_on_floor():
		_set_alive()
	
	# When on the floor, stop the coyote timer and reset the flag.
	if is_on_floor():
		coyote_timer.stop()
		coyote_used = false
	else:
		# Only start the coyote timer if it's not running and we haven't used it yet.
		if not coyote_used and coyote_timer.is_stopped():
			coyote_timer.start(PlayerStates.WALL_COYOTE_TIME)
				
	# Execute normal physics logic via the state machine.
	$StateMachine._physics_process(delta)
	
	# Then reset one-shot actions.
	post_physics_update()

# Function to be overridden by children
func post_physics_update():
	pass
	
func mark_dead():
	print("Mark player dead!")
	alive = false
	$CollisionShape2D.set_deferred("disabled", true)
	$RespawnTimer.start()

func _respawn():
	print("Respawned!")
	$CollisionShape2D.set_deferred("disabled", false)

func _set_alive():
	print("Alive again!")
	alive = true
	Engine.time_scale = 1.0

func _set_invisible(authority_id: int):
	if visibility_manager:
		visibility_manager.set_invisible(authority_id)

func _reset_alpha(authority_id: int):
	if visibility_manager:
		visibility_manager.reset_alpha(authority_id)
