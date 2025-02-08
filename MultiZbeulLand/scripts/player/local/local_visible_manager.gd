# visibility_manager.gd
extends Node
class_name LocalVisibilityManager

# The sprite we're managing visibility for
var sprite_node: AnimatedSprite2D = null
# State tracking
var is_invisible: bool = false

# Initialize with the sprite to manage
func setup(player_animatedsprite_node: AnimatedSprite2D) -> void:
	sprite_node = player_animatedsprite_node

# Called by the controller when player wants to toggle invisibility
func set_invisible() -> void:
	make_invisible()


# Called by the controller to reset visibility
func reset_alpha(_authority_id: int) -> void:
	is_invisible = false
	make_visible()

# Makes the sprite semi-transparent (for the player using invisibility)
func make_visible() -> void:
	if sprite_node:
		is_invisible = false
		sprite_node.modulate.a = 0.5
		
func make_invisible() -> void:
	if sprite_node:
		is_invisible = true
		sprite_node.modulate.a = 1.0

