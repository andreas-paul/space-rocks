extends Node

signal score(value: int)
signal score_updated(score: int)
signal player_health_changed(hitpoints: int)
signal screen_shake(strength: float)
signal hit_stop(duration: float)
signal won
signal lost
signal new_game
signal quit
signal pause
signal open_main_menu
signal restart
signal options
signal toggle_fullscreen
