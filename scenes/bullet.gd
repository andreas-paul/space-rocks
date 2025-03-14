extends Area2D

@export var speed = -800
@onready var screen_size = get_viewport_rect().size


func _physics_process(delta):
	position += transform.y * speed * delta
	
	# Wrap around screen
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)


func _on_body_entered(body:Node2D) -> void:
	if body.is_in_group("Asteroids") or body.is_in_group("Player"):
		body.hit()
	queue_free() 


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Asteroids") or area.is_in_group("Player"):
		area.hit()
	queue_free() 
	
	
func _on_timer_timeout() -> void:
	$AnimationPlayer.play("fade_out")
	await $AnimationPlayer.animation_finished
	queue_free()
