extends Label

const prefix: String = "FPS: "

func _process(_delta):
	set_text(prefix + str(Engine.get_frames_per_second()))
