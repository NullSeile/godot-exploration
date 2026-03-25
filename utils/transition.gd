extends Node3D

@export var area: Area3D
@export_file("*.tscn") var scene_path: String
@export var spawn_name: String

@onready var player: Player = get_tree().get_first_node_in_group("player")


func interact() -> void:
	if scene_path.is_empty():
		push_error("Transition has no scene_path set: %s" % get_path())
		return

	get_tree().current_scene.change_world(scene_path, spawn_name)


func _ready() -> void:
	area.body_entered.connect(
		func(body: Node):
			if body.is_in_group("player"):
				player.set_interactable.emit(self)
	)
	area.body_exited.connect(
		func(body: Node):
			if body.is_in_group("player"):
				player.set_interactable.emit(null)
	)
