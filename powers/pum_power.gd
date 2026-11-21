extends "res://powers/power.gd"
## Pum Poderoso: desmaia todos os inimigos por 2 segundos.


func _init() -> void:
	id = "pum"
	display_name = "Pum Poderoso"
	hud_label = "pum"
	keycode = KEY_Q
	cooldown = 7.0
	effect_duration = 0.96
	hud_color = Color("#558348")
	player_anim = "arthur_pum"
	locks_movement = true


func _on_activate(game) -> void:
	game.stun_enemies(2.0)
	game.stun_boss(1.4)


func draw(game, player_screen: Vector2) -> void:
	# Onda de fedor saindo por trás do Arthur.
	var progress := elapsed() / effect_duration
	var center := player_screen + Vector2(-30.0 * game.facing, -40.0)
	game.draw_circle(center, 60.0 + 260.0 * progress, Color(0.55, 0.92, 0.42, 0.28 * (1.0 - progress)))
