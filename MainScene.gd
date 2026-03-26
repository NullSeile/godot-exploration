extends Node3D

@onready var minigame_container = $Minigame
var current_minigame = null


func _minigame_finished() -> void:
	$World.visible = true
	$World/Player/Camera3D.make_current()
	$World.process_mode = Node.PROCESS_MODE_ALWAYS


func launch_minigame() -> void:
	var scene = load("res://minigames/test1/minigame.tscn").instantiate()
	current_minigame = scene
	$World.visible = false
	$World.process_mode = Node.PROCESS_MODE_DISABLED
	scene.finished.connect(_minigame_finished)

	minigame_container.add_child(scene)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
