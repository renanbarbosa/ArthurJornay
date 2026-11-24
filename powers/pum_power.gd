extends "res://powers/power.gd"
## Pum Poderoso: desmaia todos os inimigos por 2 segundos.
## Uma gosma verde escorre do alto da tela e manchas verdes aparecem.

## 9 quadros de arthur_pum a 0.11 s.
const POSE_TIME := 0.99
const GOO_DRIPS := 16
const GOO_SPOTS := 11
const GOO_FADE := 0.6
const GOO_DARK := Color("#2f9e1f")
const GOO_MAIN := Color("#6cf03a")
const GOO_SHINE := Color("#d6ff9e")

var goo_seed := 0


func _init() -> void:
	id = "pum"
	display_name = "Pum Poderoso"
	hud_label = "pum"
	keycode = KEY_Q
	cooldown = 7.0
	effect_duration = 2.8
	pose_duration = POSE_TIME
	hud_color = Color("#558348")
	player_anim = "arthur_pum"
	locks_movement = true


func _on_activate(game) -> void:
	goo_seed = randi()
	game.stun_enemies(2.0, true)
	game.stun_boss(1.4, true)


func draw(game, player_screen: Vector2) -> void:
	if elapsed() > POSE_TIME:
		return
	# Onda de fedor saindo por trás do Arthur.
	var progress := elapsed() / POSE_TIME
	var center := player_screen + Vector2(-30.0 * game.facing, -40.0)
	game.draw_circle(center, 60.0 + 260.0 * progress, Color(0.55, 0.92, 0.42, 0.28 * (1.0 - progress)))


func draw_hud(game, viewport: Vector2) -> void:
	var t := elapsed()
	var alpha := clampf(effect_left / GOO_FADE, 0.0, 1.0)
	var rng := RandomNumberGenerator.new()
	rng.seed = goo_seed
	_draw_spots(game, viewport, t, alpha, rng)
	_draw_drips(game, viewport, t, alpha, rng)


## Gosma escorrendo do topo da tela.
func _draw_drips(game, viewport: Vector2, t: float, alpha: float, rng: RandomNumberGenerator) -> void:
	# Faixa ondulada de gosma no topo.
	var top := PackedVector2Array([Vector2(0.0, 0.0)])
	var wave_height := minf(t * 90.0, 30.0)
	for i in range(25):
		var px := viewport.x * i / 24.0
		top.append(Vector2(px, wave_height + sin(i * 1.7 + goo_seed % 7) * 9.0))
	top.append(Vector2(viewport.x, 0.0))
	game.draw_colored_polygon(top, _with_alpha(GOO_MAIN, alpha * 0.92))

	for drip in range(GOO_DRIPS):
		var x := rng.randf_range(10.0, viewport.x - 10.0)
		var width := rng.randf_range(10.0, 26.0)
		var speed := rng.randf_range(160.0, 420.0)
		var delay := rng.randf_range(0.0, 0.5)
		var max_length := rng.randf_range(120.0, viewport.y * 0.95)
		var length := clampf((t - delay) * speed, 0.0, max_length)
		if length <= 0.0:
			continue
		var bottom := Vector2(x, wave_height + length)
		# Fio de gosma: grosso no alto, afinando e ondulando até a gota.
		var left := PackedVector2Array()
		var right := PackedVector2Array()
		var segments := 10
		for i in range(segments + 1):
			var k := float(i) / segments
			var y := bottom.y * k
			var half := width * 0.5 * (1.15 - 0.6 * k)
			var sway := sin(k * 5.0 + drip + t * 3.0) * width * 0.15
			left.append(Vector2(x - half + sway, y))
			right.append(Vector2(x + half + sway, y))
		right.reverse()
		var body := left + right
		game.draw_colored_polygon(body, _with_alpha(GOO_MAIN, alpha * 0.92))
		game.draw_polyline(left, _with_alpha(GOO_DARK, alpha * 0.6), 2.0)
		var tip := left[segments] + Vector2(width * 0.5 * 0.55, 0.0)
		game.draw_circle(tip, width * 0.62, _with_alpha(GOO_MAIN, alpha * 0.95))
		game.draw_circle(tip + Vector2(-width * 0.18, -width * 0.18), width * 0.2, _with_alpha(GOO_SHINE, alpha))


## Manchas verdes que vão aparecendo pela tela.
func _draw_spots(game, viewport: Vector2, t: float, alpha: float, rng: RandomNumberGenerator) -> void:
	for spot in range(GOO_SPOTS):
		var center := Vector2(rng.randf_range(40.0, viewport.x - 40.0), rng.randf_range(90.0, viewport.y - 30.0))
		var size := rng.randf_range(22.0, 48.0)
		var appear := rng.randf_range(0.1, 0.9)
		var pop := clampf((t - appear) / 0.15, 0.0, 1.0)
		var blobs := rng.randi_range(4, 7)
		var offsets: Array[Vector2] = []
		for blob in range(blobs):
			offsets.append(Vector2.from_angle(rng.randf() * TAU) * size * rng.randf_range(0.5, 1.0))
		if pop <= 0.0:
			continue
		var radius := size * pop
		game.draw_circle(center, radius, _with_alpha(GOO_DARK, alpha * 0.75))
		game.draw_circle(center, radius * 0.85, _with_alpha(GOO_MAIN, alpha * 0.85))
		for offset in offsets:
			game.draw_circle(center + offset * pop, radius * 0.42, _with_alpha(GOO_MAIN, alpha * 0.85))
		game.draw_circle(center + Vector2(-radius * 0.3, -radius * 0.3), radius * 0.22, _with_alpha(GOO_SHINE, alpha * 0.9))


func _with_alpha(color: Color, alpha: float) -> Color:
	return Color(color.r, color.g, color.b, color.a * alpha)
