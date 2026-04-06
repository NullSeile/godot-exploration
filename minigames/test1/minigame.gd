extends Node2D

@onready var main_scene: MainScene = get_tree().current_scene


func create_static_body(pos: Vector2, gradient: Gradient, size: Vector2) -> void:
	# Create the GradientTexture2D with the desired size
	var gradient_tex := GradientTexture2D.new()
	gradient_tex.gradient = gradient
	gradient_tex.width = int(size.x)
	gradient_tex.height = int(size.y)

	# Create the StaticBody2D
	var static_body := StaticBody2D.new()
	static_body.position = pos

	# Add Sprite2D with the generated texture (no scaling needed)
	var sprite := Sprite2D.new()
	sprite.texture = gradient_tex
	static_body.add_child(sprite)

	# Add CollisionShape2D
	var collision_shape := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision_shape.shape = shape
	static_body.add_child(collision_shape)

	self.add_child(static_body)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CharacterBody2D/Camera2D.make_current()

	# Crear plataformes
	var gradient := Gradient.new()
	gradient.colors = [Color.BLACK, Color.WHITE]
	gradient.offsets = [0.0, 0.5]

	for i in range(10):
		if i % 2 == 0:
			create_static_body(Vector2(600, 200 - i * 100), gradient, Vector2(200, 40))
		else:
			create_static_body(Vector2(300, 200 - i * 100), gradient, Vector2(200, 40))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		main_scene.minigame_finished()


func _on_button_pressed() -> void:
	main_scene.minigame_finished()
