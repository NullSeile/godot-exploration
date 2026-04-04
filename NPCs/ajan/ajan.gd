extends Node3D

var desired_angle: float = 0
var dialogue: DialogueResource = preload("res:///NPCs/ajan/ajan.dialogue")

@onready var player: Player = get_tree().get_first_node_in_group("player")


func interact() -> void:
	DialogueManager.show_dialogue_balloon(dialogue, "start")
	$AnimatedSprite3D.play("talk")


func _ready() -> void:
	$InteractArea.body_entered.connect(
		func(body: Node):
			if body.is_in_group("player"):
				player.set_interactable(self)
	)

	$InteractArea.body_exited.connect(
		func(body: Node):
			if body.is_in_group("player"):
				player.set_interactable(null)
	)

	DialogueManager.dialogue_ended.connect(
		func(resource: DialogueResource):
			if resource == dialogue:
				$AnimatedSprite3D.play("default")
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
