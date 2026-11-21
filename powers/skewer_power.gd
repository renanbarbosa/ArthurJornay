extends "res://powers/power.gd"
## Super Espetinho: Arthur come o espetinho e solta fogo pela boca,
## acabando com todos os inimigos e ferindo a bruxa.

## Momento da animação (em segundos) em que o fogo sai da boca.
const FIRE_START := 0.6
## Boca do Arthur em relação aos pés, já na escala do jogo.
const MOUTH := Vector2(4.0, -90.0)

var fired := false


func _init() -> void:
	id = "skewer"
	display_name = "Super Espetinho"
	hud_label = "espetinho"
	keycode = KEY_E
	cooldown = 18.0
	effect_duration = 1.35
	hud_color = Color("#a14c68")
	player_anim = "arthur_fogo"
	locks_movement = true


func _on_activate(game) -> void:
	fired = false
	game.stun_enemies(effect_duration)
	game.stun_boss(effect_duration)


func _on_update(game, _delta: float) -> void:
	if is_active() and not fired and elapsed() >= FIRE_START:
		fired = true
		game.clear_enemies()
		game.damage_boss(2, 1.1)


func reset() -> void:
	super()
	fired = false


func draw(game, player_screen: Vector2) -> void:
	if elapsed() < FIRE_START:
		return
	# Jato de fogo saindo da boca na direção em que o Arthur olha.
	var f: float = game.facing
	var mouth := player_screen + Vector2(MOUTH.x * f, MOUTH.y)
	var grow := clampf((elapsed() - FIRE_START) / 0.2, 0.0, 1.0)
	var fade := clampf(effect_left / 0.25, 0.0, 1.0)
	var length := 520.0 * grow
	var time := Time.get_ticks_msec() * 0.001
	var flicker := sin(time * 50.0) * 8.0
	var outer := Color(1.0, 0.36, 0.08, 0.85 * fade)
	var inner := Color(1.0, 0.86, 0.3, 0.9 * fade)
	game.draw_colored_polygon(PackedVector2Array([
		mouth + Vector2(0.0, -6.0),
		mouth + Vector2(length * 0.45 * f, -34.0 - flicker),
		mouth + Vector2(length * 0.85 * f, -40.0 + flicker),
		mouth + Vector2(length * f, 0.0),
		mouth + Vector2(length * 0.85 * f, 38.0 - flicker),
		mouth + Vector2(length * 0.45 * f, 30.0 + flicker),
		mouth + Vector2(0.0, 6.0),
	]), outer)
	game.draw_colored_polygon(PackedVector2Array([
		mouth + Vector2(0.0, -3.0),
		mouth + Vector2(length * 0.5 * f, -14.0 + flicker * 0.5),
		mouth + Vector2(length * 0.8 * f, 0.0),
		mouth + Vector2(length * 0.5 * f, 14.0 - flicker * 0.5),
		mouth + Vector2(0.0, 3.0),
	]), inner)
	# Bolas de fogo correndo pelo jato.
	for ball in range(6):
		var along := fposmod(time * 1.6 + ball / 6.0, 1.0)
		var wobble := sin(time * 23.0 + ball * 2.1) * 18.0 * along
		var radius := (10.0 + 22.0 * along) * (1.0 - along * 0.35)
		var center := mouth + Vector2(length * along * f, wobble)
		game.draw_circle(center, radius, Color(1.0, 0.45 + 0.4 * (1.0 - along), 0.1, 0.75 * fade))
