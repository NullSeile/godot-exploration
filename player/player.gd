extends CharacterBody3D
class_name Player

const SPEED = 300.0
const JUMP_VELOCITY = 4.5

var desired_angle: float = 0
var on_dialogue: bool = false

var current_interactable = null

signal set_interactable(node: Node)


func _ready() -> void:
	DialogueManager.dialogue_started.connect(func(_a): on_dialogue = true)
	DialogueManager.dialogue_ended.connect(func(_a): on_dialogue = false)
	set_interactable.connect(
		func(body):
			current_interactable = body
			$UI/interact.visible = true if body else false
	)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if current_interactable:
			current_interactable.interact()

	if event.is_action_pressed("test2"):
		get_tree().current_scene.launch_minigame()


func _process(delta: float) -> void:
	if velocity.x > 0:
		desired_angle = 0
	elif velocity.x < 0:
		desired_angle = -PI

	$Sprite3D.rotation.y = lerpf($Sprite3D.rotation.y, desired_angle, delta * 10)


func _physics_process(delta: float) -> void:
	if on_dialogue:
		return

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input := Input.get_axis("left", "right")
	var target := input * SPEED * delta

	if input:
		velocity.x = lerpf(velocity.x, target, delta * 20)
	else:
		velocity.x = lerpf(velocity.x, target, delta * 10)

	move_and_slide()
