extends Node
class_name PlayerStates

# State names
const IDLE = "Idle"
const RUNNING = "Running"
const IN_AIR = "InTheAir"
const WALL_SLIDE = "WallSlide"
const WALL_JUMP = "WallJump"
const ENTER_PIPE = "EnterPipe"
const DOWN_DASH = "DownDash"

# Movement constants
const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const GRAVITY = 4000.0  # À déplacer depuis ProjectSettings
const DOWN_ATTACK_SPEED = 450

# Wall mechanics
const WALL_SLIDE_SPEED = 50.0
const WALL_SLIDE_SUPER_SLOW = 5.0  # Vitesse très lente quand on pousse vers le mur
const WALL_SLIDE_MIN_TIME = 0.3  # Temps minimum de slow slide pour réinitialiser le wall jump !! REMETTRE
const WALL_JUMP_VELOCITY = Vector2(100.0, -250.0)  # Augmenté la force en X
const WALL_JUMP_OPPOSITE_FORCE = 1.5  # Multiplicateur de force dans la direction opposée
const WALL_JUMP_NO_CONTROL_TIME = 0.25  # Temps pendant lequel le joueur ne peut pas contrôler après un wall jump
const WALL_COYOTE_TIME = 0.5  # Temps pendant lequel le joueur encore jump wall apres avoir quitté le mur
const MIN_FLOOR_CONTACT_TIME = 0.3

# Animation names
const ANIMATION_IDLE = "idle"
const ANIMATION_JUMP = "jump"
const ANIMATION_FALL = "idle"
const ANIMATION_RUN = "run"
const ANIMATION_WALL_SLIDE = "jump"
const ANIMATION_ENTER_PIPE = "idle"
const ANIMATION_DOWN_ATTACK = "down_dash"

# Particules Fx constants
const DEFAULT_WALL_DUST_PARTICULES_OFFSET = 4.0
