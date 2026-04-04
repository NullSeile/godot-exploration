extends Node3D

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var main_scene: MainScene = get_tree().current_scene

var customization_scene: PackedScene = preload("res://utils/character_customization_ui.tscn")
var customization_ui: CharacterCustomization


func show_customization() -> void:
	if customization_ui:
		return

	customization_ui = customization_scene.instantiate() as CharacterCustomization
	customization_ui.accept_pressed.connect(_on_ui_accept_pressed)
	customization_ui.cancel_pressed.connect(_on_ui_cancel_pressed)

	$PhantomCamera3D.set_priority(10)
	$PhantomCamera3D.tween_completed.connect(func(): self.add_child(customization_ui))


func hide_customization() -> void:
	if not customization_ui:
		return

	$PhantomCamera3D.set_priority(0)
	self.remove_child(customization_ui)
	customization_ui.queue_free()
	customization_ui = null


func interact() -> void:
	show_customization()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Customize.body_entered.connect(
		func(body: Node3D):
			if body.is_in_group("player"):
				player.set_interactable(self)
	)

	$Customize.body_exited.connect(
		func(body: Node3D):
			if body.is_in_group("player"):
				player.set_interactable(null)
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_ui_accept_pressed() -> void:
	main_scene.save_appearance()
	hide_customization()


func _on_ui_cancel_pressed() -> void:
	main_scene.load_appearance()
	hide_customization()
