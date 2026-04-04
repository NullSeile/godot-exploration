extends Node3D
class_name MainScene

var current_world_path = null
var current_world = null

@onready var player: Player = $World/Player


func save_appearance() -> void:
	var appearance_data = {
		"player_styles":
		{
			"hair_style": player.hair_style,
			"head_style": player.head_style,
			"eye_style": player.eye_style,
			"bottom_style": player.bottom_style,
		},
		"player_colors":
		{
			"hair_color": player.hair_color.to_html(),
			"skin_color": player.skin_color.to_html(),
			"eye_color": player.eye_color.to_html(),
			"eye_white_color": player.eye_white_color.to_html(),
			"shirt_color": player.shirt_color.to_html(),
			"pants_color": player.pants_color.to_html(),
			"snout_color": player.snout_color.to_html(),
		}
	}
	var file = FileAccess.open("user://appearance.json", FileAccess.WRITE)
	file.store_line(JSON.stringify(appearance_data))
	file.close()


func load_appearance() -> void:
	if not FileAccess.file_exists("user://appearance.json"):
		return

	var appearance_file = FileAccess.open("user://appearance.json", FileAccess.READ)
	var json_str = appearance_file.get_line()
	var data = JSON.parse_string(json_str)

	for style in data["player_styles"]:
		player.set(style, data["player_styles"][style])

	for color in data["player_colors"]:
		player.set(color, Color(data["player_colors"][color]))


func save_game() -> void:
	var save_data = {
		"current_world": current_world_path,
		"player_position":
		{
			"x": player.position.x,
			"y": player.position.y,
			"z": player.position.z,
		},
	}
	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	file.store_line(JSON.stringify(save_data))
	file.close()


func load_game() -> void:
	if not FileAccess.file_exists("user://savegame.json"):
		return

	var save_file = FileAccess.open("user://savegame.json", FileAccess.READ)
	var json_str = save_file.get_line()
	var data = JSON.parse_string(json_str)

	change_world(data["current_world"], null)
	player.position.x = data["player_position"]["x"]
	player.position.y = data["player_position"]["y"]
	player.position.z = data["player_position"]["z"]


func _minigame_finished() -> void:
	$World.visible = true
	$World/Player/Camera3D.make_current()
	$World.process_mode = Node.PROCESS_MODE_ALWAYS


func change_world(scene: String, spawn):
	if current_world:
		current_world.queue_free()

	current_world = (load(scene) as PackedScene).instantiate()
	current_world_path = scene

	if spawn:
		player.position = current_world.find_child(spawn).position
	$World.add_child(current_world)


func launch_minigame() -> void:
	var scene = load("res://minigames/test1/minigame.tscn").instantiate()
	$World.hide()
	$World.process_mode = Node.PROCESS_MODE_DISABLED
	scene.finished.connect(_minigame_finished)

	$Minigame.add_child(scene)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_appearance()
	change_world("res://levels/overworld1/overworld1.tscn", "Spawn")
	# current_world = load("res://levels/overworld1/overworld1.tscn").instantiate()
	# $World.add_child(current_world)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
