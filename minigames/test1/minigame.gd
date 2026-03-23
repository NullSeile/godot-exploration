extends Node2D

signal finished


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Camera2D.make_current()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		finished.emit()
		queue_free()
