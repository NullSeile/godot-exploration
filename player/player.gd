extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var desired_angle: float = 0

var on_dialogue: bool = false


func _ready() -> void:
	DialogueManager.dialogue_started.connect(func(_a): on_dialogue = true)
	DialogueManager.dialogue_ended.connect(func(_a): on_dialogue = true)


func _physics_process(delta: float) -> void:
	if on_dialogue:
		return

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("ui_up"):
		get_tree().current_scene.launch_minigame()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, 0)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if velocity.x > 0:
		desired_angle = 0
	elif velocity.x < 0:
		desired_angle = PI

	$Sprite3D.rotation.y = lerp_angle($Sprite3D.rotation.y, desired_angle, delta * 10)

	move_and_slide()
