# VisualGrappleTarget.gd
extends Node2D
class_name VisualGrappleTarget

var circle_radius = 3.5
var corner_size = 2.0
var corner_offset = 8.0
var line_width = 1.0
var target_color = Color.RED

@onready var corners: Node2D = $Corners
var corner_scale_max = 0.3
var corner_scale_min = 0.08

var appear_tween: Tween
var pulse_tween: Tween
var blink_tween: Tween

func _ready():
	# Create nodes if they don't exist
	if not has_node("Corners"):
		corners = Node2D.new()
		corners.name = "Corners"
		add_child(corners)
	
	# Don't set script for child nodes anymore
	scale = Vector2.ZERO
	corners.scale = Vector2.ZERO
	
func appear():
	stop_animations()
	
	appear_tween = create_tween()
	appear_tween.set_parallel(true)
	
	# Make main target visible
	scale = Vector2.ONE
	
	# Scale corners from 0 to 1
	appear_tween.tween_property(corners, "scale",
		Vector2.ONE * corner_scale_max, 0.5).from(Vector2.ONE * corner_scale_min).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Rotate corners 180 degrees
	appear_tween.tween_property(corners, "rotation_degrees",
		180, 0.5).from(0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# When appear animation finished, start pulse and blink
	appear_tween.chain().tween_callback(start_pulse_animation)
	#appear_tween.chain().tween_callback(start_blink_animation)

func start_pulse_animation():
	if pulse_tween and pulse_tween.is_valid():
		return
		
	pulse_tween = create_tween()
	pulse_tween.set_loops()
	
	# Scale only corners between 0.8 and 1.2
	pulse_tween.tween_property(corners, "scale",
		Vector2.ONE * corner_scale_min, 0.5).from(Vector2.ONE * corner_scale_max).set_trans(Tween.TRANS_SINE)
	pulse_tween.tween_property(corners, "scale",
		Vector2.ONE * corner_scale_max, 0.3).set_trans(Tween.TRANS_SINE)

#func start_blink_animation():
	#blink_tween = create_tween()
	#blink_tween.set_loops()
	#
	## Blink only the circle using modulate
	#blink_tween.tween_property(circle, "modulate:a",
		#0.0, 0.4).from(1.0).set_trans(Tween.TRANS_SINE)
	#blink_tween.tween_property(circle, "modulate:a",
		#1.0, 0.5).set_trans(Tween.TRANS_SINE)

func stop_animations():
	if appear_tween and appear_tween.is_valid():
		appear_tween.kill()
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()
	if blink_tween and blink_tween.is_valid():
		blink_tween.kill()
	scale = Vector2.ZERO
	corners.scale = Vector2.ZERO

func hide_target():
	stop_animations()

func update_target():
	queue_redraw()
	corners.queue_redraw()
