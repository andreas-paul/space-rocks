extends CanvasLayer

@export var label : Label


func show_wave(wave: int, total_waves: int, duration: float):
	label.text = "WAVE %d / %d" % [wave, total_waves]
	label.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_interval(duration * 0.5)
	tween.tween_property(label, "modulate:a", 0.0, duration * 0.5)
