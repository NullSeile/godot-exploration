extends Node

func create_rigid_body(
	position: Vector2,
	gradient: Gradient,         # Your gradient (colors, offsets)
	size: Vector2,              # Size of the static body (and texture)
	parent: Node
) -> RigidBody2D:
	# Create the GradientTexture2D with the desired size
	var gradient_tex := GradientTexture2D.new()
	gradient_tex.gradient = gradient
	gradient_tex.width = int(size.x)
	gradient_tex.height = int(size.y)

	# Create the StaticBody2D
	var rigid_body := RigidBody2D.new()
	rigid_body.position = position

	# Add Sprite2D with the generated texture (no scaling needed)
	var sprite := Sprite2D.new()
	sprite.texture = gradient_tex
	rigid_body.add_child(sprite)

	# Add CollisionShape2D
	var collision_shape := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision_shape.shape = shape
	rigid_body.add_child(collision_shape)

	parent.add_child(rigid_body)
	print("rigid_body with gradient created at ", position, " with size ", size)
	
	return rigid_body

func crear_paper() -> void:
	var rng = RandomNumberGenerator.new()

	var gradient := Gradient.new()
	gradient.colors = [Color.BLUE, Color.CADET_BLUE]
	gradient.offsets = [0.0, 0.5]

	var game_world = self
	var body = create_rigid_body(Vector2(600,350), gradient, Vector2(400,500), game_world)
	
	body.collision_layer = 2      # assign all papers to layer 2
	body.collision_mask = 1       # only collide with layer 1 (e.g., world)

	body.freeze = true
	
	var button = Button.new()
	button.text = "Accept"
	button.position = Vector2(100, 200)
	add_child(button)   # Add it to the current node

	await button.pressed
	button.queue_free()
	
	body.freeze = false
	#var vert_forces = [0,0,0,0,0,100000]
	# -1 * vert_forces[rng.randi_range(0, vert_forces.size()-1)]
	body.apply_force(
		Vector2(5000 * rng.randf_range(-50,1),
				5000 * rng.randf_range(-50,1)),
		body.global_position + Vector2(rng.randf_range(-200,0), rng.randf_range(-250,250))
	)
	
	await get_tree().create_timer(2.0).timeout
	
	body.queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#while(true):
		#crear_paper()
		#await get_tree().create_timer(3.0).timeout
	for i in range(100):
		crear_paper()
	
	
	
	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	print("Yay")
