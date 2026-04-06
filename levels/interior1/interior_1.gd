extends Node3D

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var main_scene: MainScene = get_tree().current_scene
@onready var fps_camera: PhantomCamera3D = $IntroSpawn/FPSCamera
@onready var customization_camera: PhantomCamera3D = $CustomizationCamera

var customization_scene: PackedScene = preload("res://utils/character_customization_ui.tscn")
var customization_ui: CharacterCustomization


func exit_intro() -> void:
	fps_camera.set_priority(0)
	main_scene.intro_done = true
	main_scene.save_game()
	regular_start()


func show_customization() -> void:
	if customization_ui:
		return

	if not main_scene.intro_done:
		create_tween().tween_property(player, "rotation:y", 0, 0.5)

	player.can_move = false

	player.move_to($IntroSpawn.global_position)

	customization_ui = customization_scene.instantiate() as CharacterCustomization
	customization_ui.show_cancel = main_scene.intro_done
	customization_ui.accept_pressed.connect(_on_ui_accept_pressed)
	customization_ui.cancel_pressed.connect(_on_ui_cancel_pressed)

	exit_intro()
	customization_camera.set_priority(10)
	customization_camera.tween_completed.connect(
		func(): self.add_child(customization_ui),
		ConnectFlags.CONNECT_ONE_SHOT,
	)


func hide_customization() -> void:
	if not customization_ui:
		return

	player.can_move = true

	customization_camera.set_priority(0)
	self.remove_child(customization_ui)
	customization_ui.queue_free()
	customization_ui = null


func interact() -> void:
	show_customization()


func regular_start() -> void:
	$Customize.body_entered.connect(
		func(body: Node3D):
			if body.is_in_group("player") and not customization_ui:
				player.set_interactable(self)
	)

	$Customize.body_exited.connect(
		func(body: Node3D):
			if body.is_in_group("player"):
				player.set_interactable(null)
	)


func launch_intro() -> void:
	player.can_move = false
	player.hide()
	$IntroCamera.set_priority(5)

	$AnimationPlayer.play(&"intro_camera")
	await $AnimationPlayer.animation_finished
	player.show()

	$IntroCamera.set_priority(0)
	fps_camera.set_priority(10)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if main_scene.intro_done:
		regular_start()
	else:
		launch_intro()


func _physics_process(delta: float) -> void:
	if not main_scene.intro_done:
		var input := Input.get_axis(&"left", &"right")
		fps_camera.rotation.y -= input * delta * 1.5
		player.rotation.y = fps_camera.rotation.y

		if fposmod(absf(fps_camera.rotation.y), TAU) < 0.3:
			player.set_interactable(self)
		else:
			player.set_interactable(null)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_ui_accept_pressed() -> void:
	main_scene.save_appearance()
	hide_customization()
	exit_intro()


func _on_ui_cancel_pressed() -> void:
	main_scene.load_appearance()
	hide_customization()
	exit_intro()
