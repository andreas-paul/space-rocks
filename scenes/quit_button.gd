extends TextureRect

var mouse_is_entered : bool
var hover_speed = 0.3

signal quit_game

func _process(delta: float) -> void:
	if mouse_is_entered:
		if Input.is_action_just_released("left_click"):
			quit_game.emit()
		
func _on_mouse_entered() -> void:
	mouse_is_entered = true
	hover_animation()
	
func _on_mouse_exited() -> void:
	mouse_is_entered = false
	unhover_animation()
	
func hover_animation():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), hover_speed)
	
func unhover_animation():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), hover_speed)
	
