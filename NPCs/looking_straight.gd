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

	var target_dir = Vector3(0, PI, 0)
	if can_interact:
		target_dir = look_at.rotation

	delta *= 10

	sprites.rotation.x = lerp_angle(sprites.rotation.x, target_dir.x, delta)
	sprites.rotation.y = lerp_angle(sprites.rotation.y, target_dir.y, delta)
	sprites.rotation.z = lerp_angle(sprites.rotation.z, target_dir.z, delta)
