extends "res://powers/power.gd"
## Doroth: passeia pelo cenário o tempo todo (correndo ou parada abanando o
## rabo). Quando a energia do Arthur acaba, ele cai derrotado no chão; ela corre
## até ele (a tela pisca com raios), lambe o rosto dele enquanto corações enchem
## a tela e a barra de energia vai enchendo, e então solta o super latido, que
## derruba todos os inimigos e fere a bruxa. Arthur levanta e a aventura continua.

enum State { WANDER, RUSH, LICK, BARK }

const WANDER_SPEED := 200.0
const CATCH_UP_SPEED := 430.0
const RUSH_SPEED := 600.0
## A corrida dura pelo menos o tempo da queda do Arthur.
const RUSH_MIN_TIME := 0.6
const RUSH_MAX_TIME := 1.6
## Arthur derrotado (arthur_derrotado, 0.15 s por quadro): 0-2 caindo,
## 3-4 tonto no chão, 5 sentando para levantar.
const FALL_TIME := 0.45
## Lambida (dorothy_lambida, 0.14 s por quadro): 0-2 chegando, 3-4 lambendo
## em loop. A energia enche de LICK_FILL_START até o fim.
const LICK_TIME := 2.0
const LICK_FILL_START := 0.42
## Super latido (dorothy_latido, 9 quadros de 0.12 s): o anel sai em BARK_BLAST.
const BARK_TIME := 1.2
const BARK_BLAST := 0.6
## Arthur fica sentado (quadro 5) no começo do latido e depois levanta.
const GET_UP_TIME := 0.6
## Distância da Doroth até os pés do Arthur, do lado da cabeça dele.
const LICK_OFFSET := 105.0
const LANE_PIXELS := 78.0
const TEXT_COLOR := Color("#263550")
const HEART_COUNT := 22

var state := State.WANDER
var x := 60.0
var lane := 0.55
var target_x := 60.0
var target_lane := 0.55
var wait := 0.0
var facing := 1.0
var moving := false
var state_time := 0.0
var idle_time := 0.0
var blasted := false
var heart_seed := 0
var rng := RandomNumberGenerator.new()


func _init() -> void:
	id = "doroth"
	display_name = "Doroth"
	hud_label = "doroth"
	keycode = KEY_NONE
	cooldown = 0.0
	effect_duration = 0.0
	hud_color = Color("#477c5d")
	locks_movement = true
	rng.randomize()


## "Ativo" = em ação de resgate (correndo, lambendo ou latindo).
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
	blasted = false


func _on_activate(game) -> void:
	_set_state(State.RUSH)
	heart_seed = randi()
	var total := RUSH_MAX_TIME + LICK_TIME + BARK_TIME
	game.set_invulnerable(total + 1.0)
	game.stun_enemies(total)
	game.stun_boss(total)


func _set_state(new_state: State) -> void:
	state = new_state
	state_time = 0.0
	moving = false


func _on_update(game, delta: float) -> void:
	state_time += delta
	match state:
		State.WANDER:
			_wander(game, delta)
		State.RUSH:
			target_x = game.player_x - LICK_OFFSET * game.facing
			target_lane = game.player_lane + 0.02
			var arrived := _move_toward_target(RUSH_SPEED, delta)
			if (arrived and state_time >= RUSH_MIN_TIME) or state_time >= RUSH_MAX_TIME:
				x = target_x
				lane = target_lane
				_set_state(State.LICK)
		State.LICK:
			facing = 1.0 if game.player_x >= x else -1.0
			var fill := clampf((state_time - LICK_FILL_START) / (LICK_TIME - LICK_FILL_START), 0.0, 1.0)
			game.set_energy(100.0 * fill)
			if state_time >= LICK_TIME:
				game.restore_energy()
				blasted = false
				_set_state(State.BARK)
		State.BARK:
			facing = 1.0 if game.player_x >= x else -1.0
			if not blasted and state_time >= BARK_BLAST:
				blasted = true
				game.clear_enemies()
				game.damage_boss(2, 2.2)
			if state_time >= BARK_TIME:
				_set_state(State.WANDER)
				wait = 0.8
				game.set_invulnerable(1.0)


## Arthur derrotado no chão enquanto a Doroth chega e lambe; sentado no latido.
func player_frame(game) -> Array:
	var anim = game.get_anim("arthur_derrotado")
	if anim == null:
		return []
	match state:
		State.RUSH:
			if state_time < FALL_TIME:
				return ["arthur_derrotado", anim.frame_at(state_time, false, 0, 2)]
			return ["arthur_derrotado", anim.frame_at((state_time - FALL_TIME) * 0.5, true, 3, 4)]
		State.LICK:
			return ["arthur_derrotado", anim.frame_at(state_time * 0.5, true, 3, 4)]
		State.BARK:
			if state_time < GET_UP_TIME:
				return ["arthur_derrotado", 5]
	return []


func _wander(game, delta: float) -> void:
	var camera: float = game.get_camera_x()
	var off_screen := x < camera - 40.0 or x > camera + 1000.0
	if target_x < camera + 40.0 or target_x > camera + 920.0:
		_pick_wander_target(game, camera)
		wait = 0.0
	if wait > 0.0 and not off_screen:
		wait -= delta
		moving = false
		idle_time += delta
		return
	idle_time = 0.0
	if _move_toward_target(CATCH_UP_SPEED if off_screen else WANDER_SPEED, delta):
		wait = rng.randf_range(0.5, 2.2)
		_pick_wander_target(game, camera)


func _pick_wander_target(game, camera: float) -> void:
	var limits: Vector2 = game.lane_limits()
	target_x = rng.randf_range(camera + 80.0, camera + 880.0)
	target_lane = rng.randf_range(limits.x, limits.y)


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


func world_depth(game) -> float:
	return game.lane_y(lane)


func draw_world(game, camera_x: float) -> void:
	var feet := Vector2(x - camera_x, game.lane_y(lane))
	if feet.x < -120.0 or feet.x > game.get_viewport_rect().size.x + 120.0:
		return
	game.draw_oval(feet + Vector2(0.0, 3.0), Vector2(34.0, 8.0), Color(0.22, 0.27, 0.31, 0.2))
	var current := current_frame(game)
	var anim = game.get_anim(current[0])
	if anim == null:
		_draw_fallback(game, feet)
	else:
		anim.draw(game, current[1], feet, game.SPRITE_SCALE, facing)
	if state == State.BARK:
		game.draw_string(ThemeDB.fallback_font, feet + Vector2(-40.0, -110.0), "AU AU!", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 22, Color("#fff36b"))


## Animação e quadro da Doroth agora: [nome, quadro].
func current_frame(game) -> Array:
	var anim_name := "dorothy_parada"
	var time := idle_time
	var first := 0
	var last := -1
	var loop := true
	match state:
		State.LICK:
			anim_name = "dorothy_lambida"
			time = state_time
			if state_time < LICK_FILL_START:
				loop = false
				last = 2
			else:
				time = state_time - LICK_FILL_START
				first = 3
				last = 4
		State.BARK:
			anim_name = "dorothy_latido"
			time = state_time
			loop = false
		_:
			if moving:
				anim_name = "dorothy_correndo"
				time = state_time * (1.6 if state == State.RUSH else 1.0)
	var anim = game.get_anim(anim_name)
	var frame := 0
	if anim != null:
		frame = anim.frame_at(time, loop, first, last)
	return [anim_name, frame]


func _draw_fallback(game, position: Vector2) -> void:
	game.draw_circle(position + Vector2(0.0, -28.0), 24.0, Color("#d9a46e"))
	game.draw_circle(position + Vector2(20.0 * facing, -39.0), 17.0, Color("#e6bc8b"))
	game.draw_oval(position + Vector2(-15.0 * facing, -48.0), Vector2(9.0, 18.0), Color("#76513f"))
	game.draw_circle(position + Vector2(30.0 * facing, -42.0), 3.0, TEXT_COLOR)


func draw_hud(game, viewport: Vector2) -> void:
	match state:
		State.RUSH:
			_draw_lightning(game, viewport, 0.6)
		State.LICK:
			_draw_hearts(game, viewport)
		State.BARK:
			_draw_lightning(game, viewport, 1.0)
			game.draw_rect(Rect2(viewport.x * 0.5 - 190.0, 165.0, 380.0, 44.0), Color(1.0, 1.0, 1.0, 0.9))
			game.draw_string(ThemeDB.fallback_font, Vector2(viewport.x * 0.5 - 168.0, 193.0), "Doroth salvou o Arthur! A aventura continua!", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, hud_color)


## Corações subindo pela tela enquanto a Doroth lambe o Arthur.
func _draw_hearts(game, viewport: Vector2) -> void:
	var heart_rng := RandomNumberGenerator.new()
	heart_rng.seed = heart_seed
	var fade := clampf(state_time / 0.25, 0.0, 1.0) * clampf((LICK_TIME - state_time) / 0.3, 0.0, 1.0)
	game.draw_rect(Rect2(Vector2.ZERO, viewport), Color(1.0, 0.55, 0.75, 0.12 * fade))
	for heart in range(HEART_COUNT):
		var start_x := heart_rng.randf_range(20.0, viewport.x - 20.0)
		var speed := heart_rng.randf_range(110.0, 230.0)
		var size := heart_rng.randf_range(10.0, 26.0)
		var delay := heart_rng.randf_range(0.0, 1.2)
		var sway := heart_rng.randf_range(0.0, TAU)
		var color := Color("#ff4f8b") if heart % 3 else Color("#ff8fb8")
		var t := state_time - delay
		if t < 0.0:
			continue
		var y := viewport.y + size - fposmod(t * speed, viewport.y + size * 3.0)
		var center := Vector2(start_x + sin(t * 3.0 + sway) * 18.0, y)
		var pulse := 1.0 + sin(t * 9.0 + sway) * 0.08
		_draw_heart(game, center, size * pulse, Color(color.r, color.g, color.b, 0.9 * fade))


func _draw_heart(game, center: Vector2, size: float, color: Color) -> void:
	var r := size * 0.32
	game.draw_circle(center + Vector2(-r, -r * 0.4), r, color)
	game.draw_circle(center + Vector2(r, -r * 0.4), r, color)
	game.draw_colored_polygon(PackedVector2Array([
		center + Vector2(-r * 1.95, -r * 0.1),
		center + Vector2(r * 1.95, -r * 0.1),
		center + Vector2(0.0, size * 0.62),
	]), color)
	game.draw_circle(center + Vector2(-r * 1.1, -r * 0.8), r * 0.3, Color(1.0, 1.0, 1.0, color.a * 0.7))


## Tela piscando com raios.
func _draw_lightning(game, viewport: Vector2, strength: float) -> void:
	var tick := int(state_time * 14.0)
	if tick % 2 == 0:
		game.draw_rect(Rect2(Vector2.ZERO, viewport), Color(1.0, 0.98, 0.7, 0.32 * strength))
	var bolt_rng := RandomNumberGenerator.new()
	bolt_rng.seed = tick * 7919 + int(state) * 104729 + 17
	for bolt in range(2 if strength < 1.0 else 4):
		var point := Vector2(bolt_rng.randf_range(40.0, viewport.x - 40.0), 0.0)
		var points := PackedVector2Array([point])
		var ground := bolt_rng.randf_range(300.0, 470.0)
		while point.y < ground:
			point += Vector2(bolt_rng.randf_range(-40.0, 40.0), bolt_rng.randf_range(28.0, 55.0))
			points.append(point)
		game.draw_polyline(points, Color(1.0, 0.93, 0.3, 0.9 * strength), 8.0)
		game.draw_polyline(points, Color(1.0, 1.0, 1.0, strength), 3.0)
