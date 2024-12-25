extends CanvasLayer


@onready var select_solo_multi_container = $Main/CenterContainer/PanelContainer/GameModeContainer
@onready var select_host_join_container = $Main/CenterContainer/PanelContainer/MultiplayerContainer
@onready var host_container = $Main/CenterContainer/PanelContainer/HostContainer
@onready var join_container = $Main/CenterContainer/PanelContainer/JoinContainer
@onready var in_game_container = $Main/CenterContainer/PanelContainer/InGameContainer


enum WINDOW { SELECT_SOLO_MULTI_MENU, SELECT_HOST_JOIN_MENU, HOST_MENU, JOIN_MENU, SETTINGS_MENU, IN_GAME_MENU, NO_MENU}

var is_local_mode: bool
var is_host: bool
var current_window: WINDOW

func _ready():
	get_tree().paused = true
	display(WINDOW.SELECT_SOLO_MULTI_MENU)
	
func display(window: WINDOW):
	current_window = window
	hide_all()
	match window:
		WINDOW.SELECT_SOLO_MULTI_MENU:
			select_solo_multi_container.visible = true
		WINDOW.SELECT_HOST_JOIN_MENU:
			select_host_join_container.visible = true
		WINDOW.HOST_MENU:
			host_container.visible = true
		WINDOW.JOIN_MENU:
			join_container.visible = true
		WINDOW.IN_GAME_MENU:
			in_game_container.visible = true
			
func hide_all():
	select_solo_multi_container.visible = false
	select_host_join_container.visible = false
	host_container.visible = false
	join_container.visible = false
	in_game_container.visible = false
	


func _on_solo_btn_pressed():
	# Start the game SOLO
	pass

func _on_multi_btn_pressed():
	display(WINDOW.SELECT_HOST_JOIN_MENU)

func _on_host_btn_pressed():
	display(WINDOW.HOST_MENU)

func _on_join_btn_pressed():
	display(WINDOW.JOIN_MENU)

func _on_return_btn_pressed():
	display(WINDOW.SELECT_SOLO_MULTI_MENU)

func _on_back_from_host_button_pressed():
	display(WINDOW.SELECT_HOST_JOIN_MENU)

func _on_back_from_join_button_pressed():
	display(WINDOW.SELECT_HOST_JOIN_MENU)
