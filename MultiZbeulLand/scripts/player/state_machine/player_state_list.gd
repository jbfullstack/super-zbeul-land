extends Node
class_name PlayerStates

# State names
const IDLE = "Idle"
const RUN = "Run"
#const IN_AIR = "InTheAir"
const JUMP = "Jump"
const FALL = "Fall"
const WALL_SLIDE = "WallSlide"
const WALL_JUMP = "WallJump"
const ENTER_PIPE = "EnterPipe"
const DOWN_DASH = "DownDash"
const GRAPPLE = "Grapple"

# Movement constants
const SPEED = 130.0
const JUMP_VELOCITY = -225.0
const GRAVITY = 400.0 
const DOWN_ATTACK_SPEED = 450

# Jump mechanism
const DEFAULT_MAX_JUMP_TIME = 0.2
const MEGAJUMP_MAX_JUMP_TIME = 0.3

# Wall mechanics
const WALL_SLIDE_SPEED = 50.0
const WALL_SLIDE_SUPER_SLOW = 5.0  # Vitesse très lente quand on pousse vers le mur
const WALL_SLIDE_MIN_TIME = 0.3  # Temps minimum de slow slide pour réinitialiser le wall jump !! REMETTRE
const WALL_JUMP_VELOCITY = Vector2(100.0, -250.0)  # Augmenté la force en X
const WALL_JUMP_OPPOSITE_FORCE = 1.5  # Multiplicateur de force dans la direction opposée
const WALL_JUMP_NO_CONTROL_TIME = 0.25  # Temps pendant lequel le joueur ne peut pas contrôler après un wall jump
#const WALL_COYOTE_TIME = 0.5  # Temps pendant lequel le joueur encore jump wall apres avoir quitté le mur
const MIN_FLOOR_CONTACT_TIME = 0.3


# Animation names
const ANIMATION_IDLE = "idle"
const ANIMATION_JUMP = "jump"
const ANIMATION_FALL = "fall"
const ANIMATION_WALK = "walk"
const ANIMATION_RUN = "run"
const ANIMATION_SLIDE = "glide"
const ANIMATION_SPRINT = "sprint"
const ANIMATION_WALL_SLIDE = "wall_glide"
const ANIMATION_WALL_SLIDE_SLOW = "wall_glide_slow"
const ANIMATION_WALL_JUMP = "wall_jump"
const ANIMATION_ENTER_PIPE = "idle"
const ANIMATION_DOWN_ATTACK = "down_dash"
const ANIMATION_ON_EDGE_OF_FALLING = "on_edge"
const ANIMATION_GRAPPLING = "jump"

# Particules Fx constants
const DEFAULT_WALL_DUST_PARTICULES_OFFSET = 4.0
