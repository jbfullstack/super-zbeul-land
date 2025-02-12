class_name BasePlayerState extends Node

signal state_finished(next_state_name: String)

var player: BasePlayerController

func enter() -> void:
	pass

func exit() -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

# La logique physique qui ne doit être exécutée que par le serveur pour les NetworkPlayers
func physics_update(_delta: float) -> void:
	pass

# Les animations qui peuvent être exécutées par les clients
func animation_update(_delta: float) -> void:
	_update_animations()

# Fonction utilitaire pour les animations
func _update_animations() -> void:
	pass

# Fonction utilitaire pour les transitions
func transition_to(new_state: String) -> void:
	state_finished.emit(new_state)

func print_d(msg: String):
	if DebugUtils.debug_player_state_machine:
		if NetworkController.multiplayer_mode_enabled:
			print("%s  [%s]" % [msg,multiplayer.get_unique_id() ])
		else:
			print(msg)

func set_animation(animation_name: String) -> bool:
	if player.animated_sprite.animation !=animation_name:
		player.animated_sprite.play(animation_name)
		return true
	else:
		return false
