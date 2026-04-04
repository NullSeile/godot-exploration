extends Node3D

var dialogue: DialogueResource = preload("res://utils/transition.dialogue")

@export var area: Area3D
@export_file("*.tscn") var scene_path: String
@export var spawn_name: String

@onready var player: Player = get_tree().get_first_node_in_group("player")


func interact() -> void:
	if scene_path.is_empty():
		push_error("Transition has no scene_path set: %s" % get_path())
		return

	DialogueManager.show_dialogue_balloon(dialogue, "start", [self])


func transition() -> void:
	get_tree().current_scene.change_world(scene_path, spawn_name)


func _ready() -> void:
	area.body_entered.connect(
		func(body: Node):
			if body.is_in_group("player"):
				player.set_interactable(self)
	)
	area.body_exited.connect(
		func(body: Node):
			if body.is_in_group("player"):
				player.set_interactable(null)
	)
