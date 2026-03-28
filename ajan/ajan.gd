extends Node3D

var desired_angle: float = 0
var dialogue: DialogueResource = preload("res://ajan/ajan.dialogue")
var can_interact: bool = false

@onready var player: Player = get_tree().get_first_node_in_group("player")


func interact() -> void:
	DialogueManager.show_dialogue_balloon(dialogue, "start")
	$AnimatedSprite3D.play("talk")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$InteractArea.body_entered.connect(
		func(body: Node):
			if body.is_in_group("player"):
				player.set_interactable.emit(self)
				can_interact = true
	)

	$InteractArea.body_exited.connect(
		func(body: Node):
			if body.is_in_group("player"):
				player.set_interactable.emit(null)
				can_interact = false
	)
	
	DialogueManager.dialogue_ended.connect(
		func(resource: DialogueResource):
			if resource == dialogue:
				$AnimatedSprite3D.play("default")
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$DirectionNode.look_at(player.global_position)

	var target_dir = Vector3(0, PI, 0)
	if can_interact:
		target_dir = $DirectionNode.rotation

	delta *= 10

	$AnimatedSprite3D.rotation.x = lerp_angle($AnimatedSprite3D.rotation.x, target_dir.x, delta)
	$AnimatedSprite3D.rotation.y = lerp_angle($AnimatedSprite3D.rotation.y, target_dir.y, delta)
	$AnimatedSprite3D.rotation.z = lerp_angle($AnimatedSprite3D.rotation.z, target_dir.z, delta)
