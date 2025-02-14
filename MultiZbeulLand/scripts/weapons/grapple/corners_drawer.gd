# CornersDrawer.gd
extends Node2D

func _draw():
	var parent = get_parent() as VisualGrappleTarget
	if parent:
		var size = parent.corner_size * 2.5  # Smaller overall size
		var width = size * 0.4               # Thicker points relative to size
		
		# Three small, thick triangular points aimed inward
		
		# Top point (pointing down)
		var top_points = PackedVector2Array([
			Vector2(-width/2, -size),        # Top left
			Vector2(width/2, -size),         # Top right
			Vector2(0, -size * 0.4)          # Bottom point
		])
		draw_colored_polygon(top_points, parent.target_color)
		
		# Bottom right point (pointing top left)
		var br_points = PackedVector2Array([
			Vector2(size * 0.7, size * 0.4),      # Bottom right
			Vector2(size * 0.7, -width/2 + size * 0.4),  # Top right
			Vector2(size * 0.2, size * 0.1)       # Left point
		])
		draw_colored_polygon(br_points, parent.target_color)
		
		# Bottom left point (pointing top right)
		var bl_points = PackedVector2Array([
			Vector2(-size * 0.7, size * 0.4),     # Bottom left
			Vector2(-size * 0.7, -width/2 + size * 0.4), # Top left
			Vector2(-size * 0.2, size * 0.1)      # Right point
		])
		draw_colored_polygon(bl_points, parent.target_color)
