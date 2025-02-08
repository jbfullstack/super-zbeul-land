# visibility_manager.gd
extends Node
class_name MultiplayerVisibilityManager

# The sprite we're managing visibility for
var sprite_node: AnimatedSprite2D = null
var pseudo_lbl_node: Label = null
# State tracking
var is_invisible: bool = false

# Initialize with the sprite to manage
func setup(player_animatedsprite_node: AnimatedSprite2D, player_pseudo_lbl_node: Label) -> void:
	sprite_node = player_animatedsprite_node
	pseudo_lbl_node = player_pseudo_lbl_node

# Called by the controller when player wants to toggle invisibility
func set_invisible(authority_id: int) -> void:
	if multiplayer.is_server():
		# Set is_invisible flag first
		is_invisible = true
		
		# Apply local visibility on server
		if multiplayer.get_unique_id() == authority_id:
			make_invisible_self()
		else:
			make_invisible_others()
			
		# Propagate to all clients with the authority_id of who triggered it
		sync_invisible.rpc(authority_id)

# Called on all clients to sync visibility state
@rpc
func sync_invisible(authority_id: int) -> void:
	is_invisible = true
	
	# If this client is the one who triggered invisibility
	if multiplayer.get_unique_id() == authority_id:
		make_invisible_self()  # Show half-visible
	else:
		make_invisible_others()  # Show fully invisible

# Called by the controller to reset visibility
func reset_alpha(_authority_id: int) -> void:
	if multiplayer.is_server():
		is_invisible = false
		make_visible()
		sync_reset_alpha.rpc()

# Called on all clients to sync visibility reset
@rpc
func sync_reset_alpha() -> void:
	is_invisible = false
	make_visible()

# Makes the sprite fully visible
func make_visible() -> void:
	if sprite_node:
		sprite_node.modulate.a = 1.0  # Fully visible
	if pseudo_lbl_node && !pseudo_lbl_node.visible:
		pseudo_lbl_node.visible = true

# Makes the sprite semi-transparent (for the player using invisibility)
func make_invisible_self() -> void:
	if sprite_node:
		sprite_node.modulate.a = 0.5  # Semi-invisible

# Makes the sprite fully invisible (for other players)
func make_invisible_others() -> void:
	if sprite_node:
		sprite_node.modulate.a = 0.0  # Fully invisible
	if pseudo_lbl_node && pseudo_lbl_node.visible:
		pseudo_lbl_node.visible = false
