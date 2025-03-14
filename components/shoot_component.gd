extends Node2D

@onready var bullet = preload("res://scenes/bullet.tscn")


func shoot():
	if can_shoot:

		var b = bullet.instantiate()
		b.transform = $LeftMuzzle.global_transform
		var c = bullet.instantiate()
		c.transform = $RightMuzzle.global_transform
		owner.add_child(b)
		owner.add_child(c)
		
		AudioManager.get_node("Sounds").play_cannon_sound.emit()
