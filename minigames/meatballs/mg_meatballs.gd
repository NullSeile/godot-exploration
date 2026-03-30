extends Node2D

var meatballs_object: PackedScene = preload("res://minigames/meatballs/meatball.tscn")
var meatball: RigidBody2D = null

var dragging: bool = false
var cum_velocity: Vector2 = Vector2.ZERO
var counter: int = 0
var counting_down: bool = false
var num_meatballs: int = 2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UI/MeatballCounter.text = "Count: " + str(counter)
	new_meatball()

	$Plate/Area2D.body_entered.connect(
		func(body: Node):
			if body.is_in_group("meatball"):
				counter += 1
			if counter >= num_meatballs && !counting_down:
				$Countdown.start(10)
				counting_down = true
	)

	$Plate/Area2D.body_exited.connect(
		func(body: Node):
			if body.is_in_group("meatball"):
				counter -= 1
	)

	$Countdown.timeout.connect(
		func():
			counting_down = false
			$UI/Countdown.text = "YAY"
	)


func new_meatball() -> void:
	cum_velocity = Vector2.ZERO
	meatball = meatballs_object.instantiate()
	meatball.add_to_group("meatball")
	$SpawnMeatball.add_child(meatball)

	dragging = true
	# while dragging:
	meatball.freeze = true


func trajectory() -> void:
	var meatball_pos: Vector2 = meatball.global_position
	var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
	var drag: float = ProjectSettings.get_setting("physics/2d/default_linear_damp")
	var timestep := 0.02
	var velocity := -cum_velocity * 1500
	var line_start: Vector2 = meatball_pos
	var line_end: Vector2 = Vector2.ZERO
	var iters: int = 30
	var min_line: int = iters + 1

	for i: int in iters:
		velocity.y += gravity * timestep
		line_end = line_start + (velocity * timestep)
		velocity = velocity * clampf(1.0 - drag * timestep, 0, 1)

		if (
			(meatball_pos - $SpawnMeatball.position).length() != 0
			&& (
				(
					(meatball_pos - line_start).length()
					> (meatball_pos - $SpawnMeatball.position).length()
				)
				|| i > min_line
			)
		):
			var colour = Color(0.945, 0.306, 0.354, 1.0)
			min_line = i
			if i % 2 == 0:
				colour.a = 1 - (float(i) / iters)
			else:
				colour.a = 0
			draw_line(line_start, line_end, colour, 3)

		line_start = line_end


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if dragging:
			dragging = false
			meatball.freeze = false
			meatball.linear_velocity = -cum_velocity * 1500
			# new_meatball()
			get_tree().create_timer(0.5).timeout.connect(new_meatball)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# if meatball.linear_velocity.length() <= 0.1:
	if dragging:
		var direction := Input.get_vector("left", "right", "up", "down")
		cum_velocity += delta * direction
		cum_velocity = cum_velocity.normalized() * clamp(cum_velocity.length(), 0, 1)
		meatball.position = cum_velocity.normalized() * (1 - exp(-cum_velocity.length() * 3)) * 100

		queue_redraw()

	$UI/MeatballCounter.text = "Count: " + str(counter)

	if counting_down:
		$UI/Countdown.text = str(ceilf($Countdown.time_left))

		if counter < num_meatballs:
			$Countdown.stop()
			counting_down = false
			$UI/Countdown.text = ""

	# meatball.linear_velocity = -direction


func _draw() -> void:
	trajectory()
