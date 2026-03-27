extends Node3D

var current_world = null


func _minigame_finished() -> void:
	$World.visible = true
	$World/Player/Camera3D.make_current()
	$World.process_mode = Node.PROCESS_MODE_ALWAYS


func change_world(scene: String, spawn: String):
	# $World.remove_child()
	if current_world:
		current_world.queue_free()
	current_world = (load(scene) as PackedScene).instantiate()

	$World/Player.position = current_world.find_child(spawn).position
	$World.add_child(current_world)


func launch_minigame() -> void:
	var scene = load("res://minigames/test1/minigame.tscn").instantiate()
	$World.hide()
	$World.process_mode = Node.PROCESS_MODE_DISABLED
	scene.finished.connect(_minigame_finished)

	$Minigame.add_child(scene)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_world("res://levels/overworld1/overworld1.tscn", "Spawn")
	# current_world = load("res://levels/overworld1/overworld1.tscn").instantiate()
	# $World.add_child(current_world)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
