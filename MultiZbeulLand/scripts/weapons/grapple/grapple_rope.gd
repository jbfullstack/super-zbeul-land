# GrappleRope.gd - Just handles the visual animation
extends Line2D
class_name GrappleRope

## Number of points used to draw the rope. Higher values make the rope smoother but more performance intensive
@export var precision: int = 100
## How quickly the rope straightens when reaching its target. Higher values make it snap to straight line faster
@export var straighten_speed: float = 5.0
## Animation curve defining the rope's wave shape. Used to create the characteristic wave pattern during firing
@export var wave_animation_curve: Curve
## Animation curve controlling how fast the rope extends. Useful for tweaking the "feel" of the rope's deployment
@export var progression_curve: Curve
## Maximum size of the wave effect. Higher values create more dramatic waves during firing
@export var start_wave_size: float = 10.0
## Speed of the rope's extension animation. Higher values make the rope reach its target faster
@export var progression_speed: float = 4.0

var wave_size: float = 0.0
var move_time: float = 0.0
var straight_line: bool = false
var grapple: Grapple

func _ready():
	grapple = get_parent() as Grapple
	hide()

func start_grapple():
	move_time = 0.0
	points = PackedVector2Array()
	clear_points()
	var local_start = to_local(grapple.player.global_position)
	for i in precision:
		add_point(local_start)
	wave_size = start_wave_size
	straight_line = false
	show()

func stop_grapple():
	hide()
	straight_line = false
	move_time = 0.0

func _process(delta: float):
	if not visible:
		return
		
	move_time += delta
	draw_rope(delta)

func draw_rope_waves():
	var start_pos = to_local(get_player_center())
	var end_pos = to_local(grapple.grapple_target)
	var grapple_vector = end_pos - start_pos
	var perpendicular = Vector2(-grapple_vector.y, grapple_vector.x).normalized()
	
	clear_points()
	for i in precision:
		var delta_point = float(i) / (precision - 1.0)
		
		# Adjust wave amplitude based on distance to endpoint
		# Wave is strongest in middle, zero at start and end
		var wave_amplitude = wave_size * sin(delta_point * PI)
		var offset = perpendicular * wave_animation_curve.sample(delta_point) * wave_amplitude
		
		var target_pos = start_pos.lerp(end_pos, delta_point) + offset
		var current_pos = start_pos.lerp(target_pos, progression_curve.sample(move_time * progression_speed))
		add_point(current_pos)

func draw_rope(delta: float):
	if not straight_line:
		draw_rope_waves()
		if move_time * progression_speed >= 1.0:
			straight_line = true
			grapple.on_rope_reached_target()
	else:
		# Use center position for straight line too
		clear_points()
		add_point(to_local(get_player_center()))
		add_point(to_local(grapple.grapple_target))

func get_player_center() -> Vector2:
	# Assuming the player has a CollisionShape2D that defines its size
	var player_center = grapple.player.global_position
	
	# Get the center offset, could be from collision shape or sprite
	if grapple.player.has_node("CollisionShape2D"):
		var collision = grapple.player.get_node("CollisionShape2D")
		player_center += collision.position  # This adds the local offset of the collision shape
	
	return player_center
