extends Node


func spawn_asteroid(asteroid: PackedScene, asteroid_color, min_x, min_y, max_x, max_y, asteroid_scale):
	var asteroid_position = randomize_position(min_x, min_y, max_x, max_y)
	var a = asteroid.instantiate() as Asteroid
	a.global_position = asteroid_position
	a.modulate = asteroid_color
	a.hit_allowed = true
	a.scale = Vector2.ONE * asteroid_scale
	return a


func randomize_position(min_x, min_y, max_x, max_y) -> Vector2:
	var pos_x : int
	var pos_y : int
	var choice = [1, 2, 3, 4].pick_random()
	if choice == 1:
		# Spawn on right side of screen
		pos_x = randi_range(max_x, 2500)
		pos_y = randi_range(min_y, max_y)
	elif choice == 2:
		# Spawn on left side of screen
		pos_x = randi_range(min_x, 0)
		pos_y = randi_range(min_y, max_y)
	elif choice == 3:
		# Spawn on top of screen
		pos_x = randi_range(min_x, max_x)
		pos_y = randi_range(min_y, 0)
	else:
		# Spawn on bottom of screen
		pos_x = randi_range(min_x, max_x)
		pos_y = randi_range(1080, max_y)

	return Vector2(pos_x, pos_y)
