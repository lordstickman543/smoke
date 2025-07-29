extends Node

const GITHUB_USER := "lordstickman543"
const REPO_NAME := "smoke-games"
const BRANCH := "main"
const EXTENSION := ".exe"  # Change this to ".exe", ".zip", etc.

var file_data := []  # This will hold the list of file info dictionaries

func _ready():
	get_file_list_with_names_and_sizes(EXTENSION)


func get_file_list_with_names_and_sizes(extension: String):
	var api_url := "https://api.github.com/repos/%s/%s/git/trees/%s?recursive=1" % [GITHUB_USER, REPO_NAME, BRANCH]
	var raw_base := "https://raw.githubusercontent.com/%s/%s/%s/" % [GITHUB_USER, REPO_NAME, BRANCH]

	var http := HTTPRequest.new()
	add_child(http)

	http.request_completed.connect(func(result, response_code, headers, body):
		if response_code == 200:
			var json = JSON.parse_string(body.get_string_from_utf8())
			if json and json.has("tree"):
				for item in json["tree"]:
					if item.get("type") == "blob" and item.get("path", "").to_lower().ends_with(extension.to_lower()):
						var path = item["path"]
						var name = path.get_file().get_basename()
						var url = raw_base + path
						var size = item.get("size", 0)
						file_data.append({
							"name": name,
							"url": url,
							"size": size
						})
				print("File list loaded into memory:")
				if file_data.size() > 0:
					for f in file_data:
						var child_node = load("res://storeitem.tscn")
						var child = child_node.instantiate()
						child.name = str(f.name)
						child.title = str(f.name)
						child.url = f.url
						child.extension = EXTENSION
						$GridContainer.add_child(child)
						
						print("Name: %s, URL: %s, Size: %s bytes" % [f.name, f.url, f.size])
				else:
					var noitemslabel = Label.new()
					noitemslabel.text = "Nothing here right now"
					add_child(noitemslabel)
					
			else:
				push_error("Invalid JSON structure or no tree.")
		else:
			push_error("HTTP request failed with code: %s" % response_code)
	)

	var err = http.request(api_url)
	if err != OK:
		push_error("Failed to send request to GitHub API: %s" % err)
