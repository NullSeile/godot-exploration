extends Node3D

var desired_angle: float = 0

var dialogue: DialogueResource = load("res://ajan/ajan.dialogue")

@onready var ui: Control = get_tree().get_first_node_in_group("ui")
@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	# DialogueManager.show_dialogue_balloon(dialogue, "start")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$DirectionNode.look_at(player.global_position)
	# var dir = global_position.direction_to(player.global_position)
	# var target: Basis = Basis.looking_at(dir)
	# if player.position.x < position.x:
	# 	desired_angle = -180
	# else:
	# 	desired_angle = 0

	delta *= 10

	if Input.is_action_just_pressed("ui_down"):
		DialogueManager.show_dialogue_balloon(dialogue, "start")

	if Input.is_action_pressed("ui_down"):
		$AnimatedSprite3D.rotation.x = lerp_angle(
			$AnimatedSprite3D.rotation.x, $DirectionNode.rotation.x, delta
		)
		$AnimatedSprite3D.rotation.y = lerp_angle(
			$AnimatedSprite3D.rotation.y, $DirectionNode.rotation.y, delta
		)
		$AnimatedSprite3D.rotation.z = lerp_angle(
			$AnimatedSprite3D.rotation.z, $DirectionNode.rotation.z, delta
		)
		# $AnimatedSprite3D.basis = $AnimatedSprite3D.basis.slerp(target, delta)

	# $AnimatedSprite3D.rotation_degrees.y = lerpf(
	#     $AnimatedSprite3D.rotation_degrees.y, desired_angle, delta * 10
	# )
