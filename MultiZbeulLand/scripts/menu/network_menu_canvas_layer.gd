extends CanvasLayer


@onready var select_solo_multi_container = $Main/CenterContainer/PanelContainer/GameModeContainer
@onready var select_host_join_container = $Main/CenterContainer/PanelContainer/MultiplayerContainer
@onready var host_container = $Main/CenterContainer/PanelContainer/HostContainer
@onready var join_container = $Main/CenterContainer/PanelContainer/JoinContainer
@onready var in_game_container = $Main/CenterContainer/PanelContainer/InGameContainer
@onready var join_waiting_container = $Main/CenterContainer/PanelContainer/JoinWaitingContainer

@onready var ip_addr = $Main/CenterContainer/PanelContainer/JoinContainer/VBoxContainer/IpAddr

@onready var host_btn = $Main/CenterContainer/PanelContainer/MultiplayerContainer/VBoxContainer/HBoxContainer2/HostBtn
@onready var join_btn = $Main/CenterContainer/PanelContainer/MultiplayerContainer/VBoxContainer/HBoxContainer2/JoinBtn


var is_local_mode: bool
var is_host: bool
var current_window: EnumsUtils.WINDOW

func _ready():
	get_tree().paused = true
	display(EnumsUtils.WINDOW.SELECT_SOLO_MULTI_MENU)
	
func display(window: EnumsUtils.WINDOW):
	current_window = window
	hide_all()
	match window:
		EnumsUtils.WINDOW.SELECT_SOLO_MULTI_MENU:
			select_solo_multi_container.visible = true
		EnumsUtils.WINDOW.SELECT_HOST_JOIN_MENU:
			select_host_join_container.visible = true
		EnumsUtils.WINDOW.HOST_MENU:
			host_container.visible = true
		EnumsUtils.WINDOW.JOIN_MENU:
			join_container.visible = true
		EnumsUtils.WINDOW.IN_GAME_MENU:
			in_game_container.visible = true
		EnumsUtils.WINDOW.JOIN_WAITING_MENU:
			join_waiting_container.visible = true
			
func hide_all():
	select_solo_multi_container.visible = false
	select_host_join_container.visible = false
	host_container.visible = false
	join_container.visible = false
	in_game_container.visible = false
	join_waiting_container.visible = false
	


func _on_solo_btn_pressed():
	# Start the game SOLO
	pass

func _on_multi_btn_pressed():
	display(EnumsUtils.WINDOW.SELECT_HOST_JOIN_MENU)

func _on_host_btn_pressed():
	display(EnumsUtils.WINDOW.HOST_MENU)

func _on_join_btn_pressed():
	display(EnumsUtils.WINDOW.JOIN_MENU)

func _on_return_btn_pressed():
	display(EnumsUtils.WINDOW.SELECT_SOLO_MULTI_MENU)

func _on_back_from_host_button_pressed():
	display(EnumsUtils.WINDOW.SELECT_HOST_JOIN_MENU)

func _on_back_from_join_button_pressed():
	display(EnumsUtils.WINDOW.SELECT_HOST_JOIN_MENU)

func get_server_ip():
	return ip_addr.text

func _on_launch_button_pressed():
	display(EnumsUtils.WINDOW.JOIN_WAITING_MENU)


func _on_pseudo_text_changed(new_text):
	if new_text != "":
		host_btn.disabled = false
		join_btn.disabled = false
	else:
		host_btn.disabled = true
		join_btn.disabled = true
