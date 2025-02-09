extends BasePlayerState
class_name EnterPipeState

func enter() -> void:
	# Arrête tout mouvement pour cette transition
	player.velocity = Vector2.ZERO
	print("Entering EnterPipe state")
	# Joue l'animation dédiée, si elle existe
	player.animated_sprite.play(PlayerStates.ANIMATION_ENTER_PIPE)
	# Optionnel : désactiver temporairement les inputs ou autres éléments visuels

func physics_update(delta: float) -> void:
	# Si un tuyau est présent, téléporte le joueur
	if player.current_pipe:
		player.current_pipe.teleport_player(player)
		# Réinitialise la référence au tuyau pour éviter de retéléporter
		player.current_pipe = null
	else:
		print("Aucun tuyau détecté en EnterPipe state")
	
	# Après la téléportation, retourne à l'état Idle
	transition_to(PlayerStates.IDLE)

func exit() -> void:
	print("Exiting EnterPipe state")
