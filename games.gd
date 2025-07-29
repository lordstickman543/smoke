extends MarginContainer

var items = {}

func _ready() -> void:
	get_game_list()




func _process(delta: float) -> void:
	pass


func get_game_list():
	$ItemList.clear()
	var files := []
	var dir := DirAccess.open("user://games")
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				files.append(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()

		# Now use a for loop
		for file in files:
			var gamename = file.get_basename()
			var full_path = "user://games/" + file
			print("File found: ", full_path)
			$ItemList.add_item(gamename)
			items[gamename] = full_path
	else:
		print("Directory not found!")


func _on_item_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	var item_name = $ItemList.get_item_text(index)
	OS.shell_open(ProjectSettings.globalize_path(items[item_name]))
