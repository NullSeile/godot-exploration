extends Node3D

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var main_scene: MainScene = get_tree().current_scene

@onready var tab_container: TabContainer = $UI/VBoxContainer/TabContainer

@onready var example_button = %ExampleButton
@onready var example_param = %ExampleParam
@onready var example_tab = %ExampleTab

var eye_previews: Array[TextureRect]
var hair_previews: Array[TextureRect]
var head_previews: Array[TextureRect]
var pants_previews: Array[TextureRect]
var shirt_previews: Array[TextureRect]


func create_button(atlas: Texture2D, rect: Rect2, function: Callable) -> Control:
	var button := example_button.duplicate()
	var texture: TextureRect = button.get_child(1)
	var tex = AtlasTexture.new()
	tex.atlas = atlas
	tex.region = rect
	texture.texture = tex
	texture.material = texture.material.duplicate()
	texture.material.set_shader_parameter("current_atlas", atlas)

	button.get_child(0).pressed.connect(function)

	return button


func create_param(
	title: String,
	initial: Color,
	function: Callable,
	initialy_folded: bool = true,
) -> Control:
	var param = example_param.duplicate()
	param.title = title
	param.folded = initialy_folded
	var picker: ColorPicker = param.get_child(0)
	picker.color = initial
	picker.color_changed.connect(function)

	return param


func create_tab(title: String, params: Array[Control], styles: Array) -> Control:
	var tab = example_tab.duplicate()
	tab.name = title

	var prop_container = tab.find_child("ParamContainer", true, false)
	for p in params:
		prop_container.add_child(p)

	var button_container = tab.find_child("ButtonsContainer", true, false)
	for s in styles:
		button_container.add_child(s)

	return tab


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%ButtonsContainer.remove_child(example_button)
	%ParamContainer.remove_child(example_param)

	tab_container.remove_child(example_tab)

	var body_tab = create_tab(
		"Body",
		[
			create_param(
				"Body Color",
				player.skin_color,
				func(c: Color): player.skin_color = c,
				false,
			),
		],
		[]
	)
	tab_container.add_child(body_tab)

	var eye_styles = player.eye_styles.keys().map(
		func(style):
			var button = create_button(
				player.eye_styles[style],
				Rect2(37, 6, 16, 16),
				func(): player.eye_style = style,
			)
			eye_previews.append(button.get_child(1))
			return button
	)
	var eyes_tab = create_tab(
		"Eyes",
		[
			create_param(
				"Pupile Color",
				player.eye_color,
				func(c: Color): player.eye_color = c,
			),
			create_param(
				"White Color",
				player.eye_white_color,
				func(c: Color): player.eye_white_color = c,
			)
		],
		eye_styles
	)
	tab_container.add_child(eyes_tab)

	var hair_styles = player.hair_styles.keys().map(
		func(style):
			var button = create_button(
				player.hair_styles[style],
				Rect2(8, 5, 16, 16),
				func(): player.hair_style = style,
			)
			hair_previews.append(button.get_child(1))
			return button
	)
	var hair_tab = create_tab(
		"Hair",
		[
			create_param(
				"Hair Color",
				player.hair_color,
				func(c: Color): player.hair_color = c,
				false,
			),
		],
		hair_styles
	)
	tab_container.add_child(hair_tab)

	var head_styles = player.head_styles.keys().map(
		func(style):
			var button = create_button(
				player.head_styles[style],
				Rect2(8, 5, 16, 16),
				func():
					player.head_style = style
					var hair_idx = tab_container.get_tab_idx_from_control(hair_tab)
					tab_container.set_tab_disabled(hair_idx, style == player.HeadStyle.CANINE)
			)
			head_previews.append(button.get_child(1))
			return button
	)
	var head_tab = create_tab(
		"Head",
		[
			create_param(
				"Snout Color",
				player.snout_color,
				func(c: Color): player.snout_color = c,
				false,
			),
		],
		head_styles,
	)
	tab_container.add_child(head_tab)

	var pants_styles = player.bottom_styles.keys().map(
		func(style):
			var button = create_button(
				player.bottom_styles[style],
				Rect2(12, 16, 9, 9),
				func(): player.bottom_style = style,
			)
			pants_previews.append(button.get_child(1))
			return button
	)
	var pants_tab = create_tab(
		"Pants",
		[
			create_param(
				"Pants Color",
				player.pants_color,
				func(c: Color): player.pants_color = c,
				false,
			),
		],
		pants_styles
	)
	tab_container.add_child(pants_tab)

	var shirt_tab = create_tab(
		"Shirt",
		[
			create_param(
				"Shirt Color",
				player.shirt_color,
				func(c: Color): player.shirt_color = c,
				false,
			),
		],
		[]
	)
	tab_container.add_child(shirt_tab)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var colors: Array = (
		player.find_child("Eyes").material_override.get_shader_parameter("colors").duplicate()
	)
	colors[0] = Color.TRANSPARENT
	colors[1] = Color.TRANSPARENT
	for prev in eye_previews:
		prev.material.set_shader_parameter("colors", colors)

	var hair_colors: Array = player.find_child("Hair").material_override.get_shader_parameter(
		"colors"
	)
	for prev in hair_previews:
		prev.material.set_shader_parameter("colors", hair_colors)

	var head_colors: Array = player.find_child("Head").material_override.get_shader_parameter(
		"colors"
	)
	for prev in head_previews:
		prev.material.set_shader_parameter("colors", head_colors)

	var pants_colors: Array = player.find_child("Bottom").material_override.get_shader_parameter(
		"colors"
	)
	for prev in pants_previews:
		prev.material.set_shader_parameter("colors", pants_colors)

	var shirt_colors: Array = player.find_child("Shirt").material_override.get_shader_parameter(
		"colors"
	)
	for prev in shirt_previews:
		prev.material.set_shader_parameter("colors", shirt_colors)


func _on_cancel_pressed() -> void:
	main_scene.load_appearance()
	main_scene.load_game()


func _on_accept_pressed() -> void:
	main_scene.save_appearance()
	main_scene.load_game()
