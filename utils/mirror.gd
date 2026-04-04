extends Marker3D
class_name Mirror

@export var nodes: Array[Node3D] = []

@onready var player: Player = get_tree().get_first_node_in_group("player")
var player_body: Node3D

var body_dup: Node3D


# A --> B --> C
# C = B - A + B = 2B - A
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_body = player.get_node("Body") as Node3D
	body_dup = player_body.duplicate()
	self.add_child(body_dup)

	for node in nodes:
		var dup = node.duplicate()
		self.add_child(dup)
		dup.global_position.x = 2 * self.global_position.x - node.global_position.x
		dup.global_rotation.y *= -1
		dup.global_rotation.z *= -1
		# dup.rotation.y += PI


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	body_dup.global_position.x = 2 * self.global_position.x - player_body.global_position.x
	body_dup.global_position.y = player_body.global_position.y
	body_dup.global_position.z = player_body.global_position.z

	body_dup.global_rotation = player_body.global_rotation
	body_dup.rotation.y = -body_dup.rotation.y + PI

	for part in body_dup.get_children():
		var p: AnimatedSprite3D = part as AnimatedSprite3D
		p.play(player_body.get_child(0).animation)
		p.frame = player_body.get_child(0).frame
