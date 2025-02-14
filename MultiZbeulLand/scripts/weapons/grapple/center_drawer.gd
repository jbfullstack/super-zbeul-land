# CircleDrawer.gd
extends Node2D

func _draw():
	var parent = get_parent() as VisualGrappleTarget
	if parent:
		draw_arc(Vector2.ZERO, parent.circle_radius, 0, TAU, 32, parent.target_color, parent.line_width)
