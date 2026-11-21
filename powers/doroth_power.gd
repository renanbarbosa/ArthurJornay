extends "res://powers/power.gd"
## Doroth: passeia correndo pelo cenário o tempo todo. Quando a energia do
## Arthur acaba, ela corre até ele (a tela pisca com raios) e solta o super
## poder: recupera toda a energia, some com os inimigos e fere a bruxa.

enum State { WANDER, RUSH, POWER }

const WANDER_SPEED := 200.0
const CATCH_UP_SPEED := 430.0
const RUSH_SPEED := 600.0
const RUSH_MAX_TIME := 1.6
const POWER_TIME := 1.92
const LANE_PIXELS := 78.0
const SPRITE_SCALE := 0.42
const TEXT_COLOR := Color("#263550")

var state := State.WANDER
var x := 60.0
var lane := 0.55
var target_x := 60.0
var target_lane := 0.55
var wait := 0.0
var facing := 1.0
var moving := false
var state_time := 0.0
var rng := RandomNumberGenerator.new()


func _init() -> void:
	id = "doroth"
	display_name = "Doroth"
	hud_label = "doroth"
	keycode = KEY_NONE
	cooldown = 0.0
	effect_duration = 0.0
	hud_color = Color("#477c5d")
	rng.randomize()


## "Ativo" = em ação de resgate (correndo até o Arthur ou soltando o poder).
func is_active() -> bool:
	return state != State.WANDER


func is_ready() -> bool:
	return state == State.WANDER


func reset() -> void:
	super()
	state = State.WANDER
	x = 60.0
	lane = 0.55
	target_x = x
	target_lane = lane
	wait = 0.5
	facing = 1.0
	moving = false
	state_time = 0.0


func _on_activate(game) -> void:
	state = State.RUSH
	state_time = 0.0
	game.set_invulnerable(RUSH_MAX_TIME + POWER_TIME + 0.5)
	game.stun_enemies(RUSH_MAX_TIME + POWER_TIME)
	game.stun_boss(RUSH_MAX_TIME + POWER_TIME)


func _on_update(game, delta: float) -> void:
	state_time += delta
	match state:
		State.WANDER:
			_wander(game, delta)
		State.RUSH:
			target_x = game.player_x + 80.0 * game.facing
			target_lane = game.player_lane + 0.05
			var arrived := _move_toward_target(RUSH_SPEED, delta)
			if arrived or state_time >= RUSH_MAX_TIME:
				x = target_x
				lane = target_lane
				_start_power(game)
		State.POWER:
			moving = false
			facing = 1.0 if game.player_x >= x else -1.0
			if state_time >= POWER_TIME:
				state = State.WANDER
				state_time = 0.0
				wait = 0.8


func _start_power(game) -> void:
	state = State.POWER
	state_time = 0.0
	moving = false
	game.restore_energy()
	game.clear_enemies()
	game.damage_boss(2, 2.2)
	game.set_invulnerable(POWER_TIME + 1.0)


func _wander(game, delta: float) -> void:
	var camera: float = game.get_camera_x()
	var off_screen := x < camera - 40.0 or x > camera + 1000.0
	if target_x < camera + 40.0 or target_x > camera + 920.0:
		_pick_wander_target(camera)
		wait = 0.0
	if wait > 0.0 and not off_screen:
		wait -= delta
		moving = false
		return
	if _move_toward_target(CATCH_UP_SPEED if off_screen else WANDER_SPEED, delta):
		wait = rng.randf_range(0.5, 2.2)
		_pick_wander_target(camera)


func _pick_wander_target(camera: float) -> void:
	target_x = rng.randf_range(camera + 80.0, camera + 880.0)
	target_lane = rng.randf_range(-0.75, 0.8)


## Anda em direção ao alvo. Retorna true quando chega.
func _move_toward_target(speed: float, delta: float) -> bool:
	var offset := Vector2(target_x - x, (target_lane - lane) * LANE_PIXELS)
	if offset.length() <= speed * delta or offset.length() < 2.0:
		x = target_x
		lane = target_lane
		moving = false
		return true
	var step := offset.normalized() * speed * delta
	x += step.x
	lane += step.y / LANE_PIXELS
	moving = true
	if absf(offset.x) > 4.0:
		facing = signf(offset.x)
	return false


func draw_world(game, camera_x: float, behind_player: bool) -> void:
	if (lane < game.player_lane) != behind_player:
		return
	var feet := Vector2(x - camera_x, game.lane_y(lane))
	if feet.x < -120.0 or feet.x > game.get_viewport_rect().size.x + 120.0:
		return
	game.draw_oval(feet + Vector2(0.0, 3.0), Vector2(34.0, 8.0), Color(0.22, 0.27, 0.31, 0.2))

	var anim = game.get_anim("dorothy_poder" if state == State.POWER else "dorothy_correndo")
	if anim == null:
		_draw_fallback(game, feet)
	elif state == State.POWER:
		anim.draw(game, anim.frame_at(state_time), feet, SPRITE_SCALE, facing)
	elif moving:
		var run_time := state_time * (1.6 if state == State.RUSH else 1.0)
		anim.draw(game, anim.frame_at(run_time, true, 1, 5), feet, SPRITE_SCALE, facing)
	else:
		anim.draw(game, 0, feet, SPRITE_SCALE, facing)

	if state == State.POWER:
		game.draw_string(ThemeDB.fallback_font, feet + Vector2(-40.0, -100.0), "DOROTH!", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 20, Color("#fff36b"))


func _draw_fallback(game, position: Vector2) -> void:
	game.draw_circle(position + Vector2(0.0, -28.0), 24.0, Color("#d9a46e"))
	game.draw_circle(position + Vector2(20.0 * facing, -39.0), 17.0, Color("#e6bc8b"))
	game.draw_oval(position + Vector2(-15.0 * facing, -48.0), Vector2(9.0, 18.0), Color("#76513f"))
	game.draw_circle(position + Vector2(30.0 * facing, -42.0), 3.0, TEXT_COLOR)


func draw_hud(game, viewport: Vector2) -> void:
	_draw_lightning(game, viewport)
	if state == State.POWER:
		game.draw_rect(Rect2(viewport.x * 0.5 - 190.0, 165.0, 380.0, 44.0), Color(1.0, 1.0, 1.0, 0.9))
		game.draw_string(ThemeDB.fallback_font, Vector2(viewport.x * 0.5 - 168.0, 193.0), "Doroth salvou o Arthur! A aventura continua!", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, hud_color)


## Tela piscando com raios durante todo o resgate.
func _draw_lightning(game, viewport: Vector2) -> void:
	var tick := int(state_time * 14.0)
	var strength := 1.0 if state == State.POWER else 0.6
	if tick % 2 == 0:
		game.draw_rect(Rect2(Vector2.ZERO, viewport), Color(1.0, 0.98, 0.7, 0.32 * strength))
	var bolt_rng := RandomNumberGenerator.new()
	bolt_rng.seed = tick * 7919 + int(state) * 104729 + 17
	for bolt in range(2 if state == State.RUSH else 4):
		var point := Vector2(bolt_rng.randf_range(40.0, viewport.x - 40.0), 0.0)
		var points := PackedVector2Array([point])
		var ground := bolt_rng.randf_range(300.0, 470.0)
		while point.y < ground:
			point += Vector2(bolt_rng.randf_range(-40.0, 40.0), bolt_rng.randf_range(28.0, 55.0))
			points.append(point)
		game.draw_polyline(points, Color(1.0, 0.93, 0.3, 0.9 * strength), 8.0)
		game.draw_polyline(points, Color(1.0, 1.0, 1.0, strength), 3.0)
