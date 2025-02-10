extends BasePlayerState
class_name DownDashState

var down_attack_speed: float = PlayerStates.DOWN_ATTACK_SPEED
var down_dash_inertia: float = 0.0

func enter() -> void:
	print_d("Entering DownDash state")
	# Lancer l'animation spécifique au dash vers le bas
	player.animated_sprite.play(PlayerStates.ANIMATION_DOWN_ATTACK)	
	## Stocker l'inertie horizontale actuelle dès l'entrée dans l'état
	#down_dash_inertia = player.velocity.x
	player.velocity.x = 0
	# Imposer la vitesse verticale de dash
	player.velocity.y = down_attack_speed

func physics_update(delta: float) -> void:
	# Conserver l'inertie horizontale sans tenir compte des inputs
	player.velocity.x = down_dash_inertia
	# Conserver la vitesse verticale constante (dash vers le bas)
	player.velocity.y = down_attack_speed
	
	# Appliquer le mouvement
	player.move_and_slide()
	
	# Condition de transition :
	# Par exemple, dès que le joueur touche le sol, il passe en Idle (ou Running selon le cas)
	if player.is_on_floor():
		transition_to(PlayerStates.IDLE)
		return
	
	# Vous pouvez ajouter ici d'autres conditions (collision avec un ennemi, par exemple) pour quitter cet état.
	# Notez qu'on ignore ici tout input (direction ou jump) afin de conserver l'inertie pendant tout le dash.

func exit() -> void:
	print_d("Exiting DownDash state")
	# Optionnel : réinitialiser des variables spécifiques à cet état
