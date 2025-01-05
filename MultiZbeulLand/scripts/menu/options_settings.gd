extends VBoxContainer

@onready var resolution_option_button = $resolution_OptionButton
@onready var fullscreen_check_box = $fullscreen_CheckBox
@onready var screen_selector_option_button: OptionButton = $screen_selector_OptionButton


var Resolutions: Dictionary = {"3840x2160":Vector2i(3840,2160),
								"2560x1440":Vector2i(2560,1080),
								"1920x1080":Vector2i(1920,1080),
								"1366x768":Vector2i(1366,768),
								"1536x864":Vector2i(1536,864),
								"1280x720":Vector2i(1280,720),
								"1440x900":Vector2i(1440,900),
								"1600x900":Vector2i(1600,900),
								"1024x600":Vector2i(1024,600),
								"800x600": Vector2i(800,600)}


func _ready():
	add_resolutions()
	get_screens()
	check_variables()
	
func check_variables():
	var _window = get_window()
	var mode = _window.get_mode()
	
	
	if mode == Window.MODE_FULLSCREEN:
		fullscreen_check_box.set_pressed_no_signal(true)
		resolution_option_button.set_disabled(true)
		
	var current_screen = _window.get_current_screen()
	screen_selector_option_button.select(current_screen)
		

func set_resolution_text():
	var resolution_text = str(get_window().get_size().x) + "X" + str(get_window().get_size().y)
	resolution_option_button.set_text(resolution_text)

func add_resolutions():
	var current_resolution = get_window().get_size()
	print("screen size ", current_resolution)
	var ID = 0
	for r in Resolutions:
		resolution_option_button.add_item(r, ID)
		if Resolutions[r] == current_resolution:
			resolution_option_button.select(ID)
		ID += 1


func _on_option_button_item_selected(index):
	var ID = resolution_option_button.get_item_text(index)
	get_window().set_size(Resolutions[ID])
	centre_windows()

func centre_windows():
	var center_screen = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
	var windows_size = get_window().get_size_with_decorations()
	get_window().set_position(center_screen - windows_size / 2)


func _on_fullscreen_check_box_toggled(toggled_on):
	if toggled_on:
		get_window().set_mode(Window.MODE_FULLSCREEN)
		resolution_option_button.set_disabled(true)
	else:
		get_window().set_mode(Window.MODE_WINDOWED)
		resolution_option_button.set_disabled(false)
		centre_windows()
	# wait for new  resolution to be applied
	get_tree().create_timer(0.05).timeout.connect(set_resolution_text)

func get_screens():
	var screens = DisplayServer.get_screen_count()
	
	for s in screens:
		screen_selector_option_button.add_item("Screen: " + str(s))


func _on_screen_selector_option_button_item_selected(index):
	var _window = get_window()
	var mode = _window.get_mode()
	
	_window.set_mode(Window.MODE_WINDOWED)
	_window.set_current_screen(index)
	if mode == Window.MODE_FULLSCREEN:
		_window.set_mode(Window.MODE_FULLSCREEN)
