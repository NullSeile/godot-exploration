extends CharacterBody3D
class_name Player

const SPEED = 300.0
const JUMP_VELOCITY = 4.5

var desired_angle: float = 0
var on_dialogue: bool = false

signal set_interactable(node: Node)
var current_interactable = null

@export var hair_color: Color = Color(0.569, 0.349, 0.796)
@export var skin_color: Color = Color(1, 0.753, 0.949)
@export var eye_color: Color = Color(0.784, 0.435, 0.71)
@export var shirt_color: Color = Color(0.835, 0.533, 0.878)
@export var sleeves_color: Color = Color(0.835, 0.533, 0.878)
@export var pants_color: Color = Color(0.573, 0.349, 0.8)


func _ready() -> void:
	DialogueManager.dialogue_started.connect(func(_a): on_dialogue = true)
	DialogueManager.dialogue_ended.connect(func(_a): on_dialogue = false)
	set_interactable.connect(
		func(body):
			current_interactable = body
			$UI/interact.visible = true if body else false
	)
	$UI/interact.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if current_interactable:
			current_interactable.interact()

	if event.is_action_pressed("test2"):
		get_tree().current_scene.launch_minigame()


func shaded(color: Color) -> Color:
	color.ok_hsl_l -= 0.06
	color.ok_hsl_s += 0.01
	return color


func _process(delta: float) -> void:
	if velocity.x > 0:
		desired_angle = 0
	elif velocity.x < 0:
		desired_angle = -PI

	(
		$Body/Hair
		. material_override
		. set_shader_parameter(
			"colors",
			[
				hair_color,
				shaded(hair_color),
			]
		)
	)
	(
		$Body/Body
		. material_override
		. set_shader_parameter(
			"colors",
			[
				skin_color,
				shaded(skin_color),
			]
		)
	)
	(
		$Body/Head
		. material_override
		. set_shader_parameter(
			"colors",
			[
				skin_color,
				shaded(skin_color),
			]
		)
	)
	var blush_color = skin_color
	blush_color.ok_hsl_l -= 0.05
	blush_color.ok_hsl_s += 0.00

	if blush_color.ok_hsl_h > 0.5:
		blush_color.ok_hsl_h += 0.02
	else:
		blush_color.ok_hsl_h -= 0.02

	(
		$Body/Eyes
		. material_override
		. set_shader_parameter(
			"colors",
			[
				blush_color,
				shaded(blush_color),
				eye_color,
			]
		)
	)
	(
		$Body/Cloths
		. material_override
		. set_shader_parameter(
			"colors",
			[
				shirt_color,
				shaded(shirt_color),
				sleeves_color,
				shaded(sleeves_color),
				pants_color,
				shaded(pants_color),
			]
		)
	)

	if absf(velocity.x) > 3.0:
		for part in $Body.get_children():
			var p: AnimatedSprite3D = part as AnimatedSprite3D
			p.play("walk")
	else:
		for part in $Body.get_children():
			var p: AnimatedSprite3D = part as AnimatedSprite3D
			p.play("idle")

	$Body.rotation.y = lerpf($Body.rotation.y, desired_angle, delta * 10)


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
