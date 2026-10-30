extends Area2D

@export var speed = -800
@onready var screen_size = get_viewport_rect().size

func _ready() -> void:
	$Sprite2D.modulate = Color(2.0, 2.0, 2.0)  # values > 1 make it glow
	Utils.add_fake_glow(self, Color(1, 1, 1, 0.5), 50)

func _physics_process(delta):
	position += transform.y * speed * delta
	
	# Wrap around screen
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)


func _on_body_entered(body:Node2D) -> void:
	if body.is_in_group("Asteroids") or body.is_in_group("Player") or body.is_in_group("Mothership"):
		body.hit()
	queue_free() 


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Asteroids") or area.is_in_group("Player") or area.is_in_group("Mothership"):
		area.hit()
	queue_free() 
	
	
func _on_timer_timeout() -> void:
	$AnimationPlayer.play("fade_out")
	await $AnimationPlayer.animation_finished
	queue_free()
