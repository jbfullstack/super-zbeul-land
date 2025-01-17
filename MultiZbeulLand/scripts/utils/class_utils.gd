extends Node


static func is_instance_of_class(obj: Object, className: String) -> bool:
	if obj == null:
		return false

	if ClassDB.class_exists(className):
		# Built-in class
		return obj.is_class(className)
	else:
		# Custom script class
		var class_script: Script

		# Check if it's a script path and load it
		if ResourceLoader.exists(className):
			class_script = load(className) as Script
		else:
			# Otherwise, assume it's a custom class name and find it
			for x in ProjectSettings.get_global_class_list():
				if str(x["class"]) == className:
					class_script = load(str(x["path"]))
					break

		if class_script == null:
			return false  # Unknown class

		# Check if the object's script matches the class
		var check_script = obj.get_script()
		while check_script != null:
			if check_script == class_script:
				return true
			check_script = check_script.get_base_script()

	return false


static func is_player_type(body) -> bool :
	if body is Player or body is MultiplayerController:
		return true
	else:
		return false
