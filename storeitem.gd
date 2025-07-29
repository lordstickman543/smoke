extends VBoxContainer

@export var title : String
@export var icon : Texture
@export var url : String
@export var extension : String

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	$Label.text = title
	$TextureRect.texture = icon


func _on_button_pressed() -> void:
	$Window.title = title
	$Window.show()


func _on_window_close_requested() -> void:
	$Window.hide()


func _on_download_pressed() -> void:
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("games"):
		dir.make_dir("games")
	$download.download_file = "user://games/" + title + extension
	$download.request(url)


func _on_download_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	$Window.hide()
	Games.get_game_list()
