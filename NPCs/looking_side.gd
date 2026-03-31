extends Node3D

var desired_angle: float = 0
var can_interact: bool = false

@export var interact_area: Area3D
@export var sprites: AnimatedSprite3D
@onready var player: Player = get_tree().get_first_node_in_group("player")

var look_at: Node3D


func _ready() -> void:
	look_at = Node3D.new()
	self.add_child(look_at)

	interact_area.body_entered.connect(
		func(body: Node):
			if body.is_in_group("player"):
				can_interact = true
	)

	interact_area.body_exited.connect(
		func(body: Node):
			if body.is_in_group("player"):
				can_interact = false
	)


func _process(delta: float) -> void:
	look_at.look_at(player.global_position)

	var target_dir = Vector3(0, 0, 0)

	if player.global_position.x > global_position.x:
		target_dir.y = TAU + look_at.rotation.y
	else:
		target_dir.y = look_at.rotation.y

	target_dir.y = (target_dir.y + PI) / 2

	if player.global_position.x < global_position.x:
		target_dir.y -= (PI)

	delta *= 5

	sprites.rotation.x = lerpf(sprites.rotation.x, target_dir.x, delta)
	sprites.rotation.y = lerpf(sprites.rotation.y, target_dir.y, delta)
	sprites.rotation.z = lerpf(sprites.rotation.z, target_dir.z, delta)
