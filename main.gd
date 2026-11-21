extends Node2D

const PLAYER_SPEED := 250.0
const LANE_SPEED := 190.0
const PLAYER_SCREEN_X := 245.0
const BOSS_START := 1740.0
const BOSS_MAX_HEALTH := 8

# Defesa: segurar L ou Shift no chão.
const BLOCK_SPEED_FACTOR := 0.35
const BLOCK_DAMAGE_FACTOR := 0.2
const BLOCK_PUSHBACK := 70.0

# Obstáculos da fase. Para outro tipo, adicione um "kind" novo e trate-o em
# _obstacle_speed_factor e _draw_obstacle.
const OBSTACLES := [
	{"kind": "poca", "x": 330.0, "lane": 0.45},
	{"kind": "poca", "x": 640.0, "lane": -0.4},
	{"kind": "poca", "x": 1010.0, "lane": 0.1},
	{"kind": "poca", "x": 1390.0, "lane": -0.5},
]
const PUDDLE_HALF_WIDTH := 46.0
const PUDDLE_HALF_LANE := 0.28
const PUDDLE_SPEED_FACTOR := 0.4

# Poderes do Arthur. Para criar um novo, veja res://powers/power.gd.
const POWER_SCRIPTS := [
	preload("res://powers/pum_power.gd"),
	preload("res://powers/skewer_power.gd"),
	preload("res://powers/doroth_power.gd"),
]

# Animações em folhas de sprites (art/*.png, geradas por tools/gif_to_sheet.py
# a partir de images/*.gif). Se um arquivo faltar, o jogo usa o desenho com formas.
const SpriteAnim := preload("res://sprite_anim.gd")
const ARTHUR_FEET := Vector2(120.5, 251.0)
const DOROTHY_FEET := Vector2(124.0, 234.0)
const ARTHUR_SCALE := 0.55
# Quadros da folha arthur_caminhando: 0 = parado, 1..8 = andando.
const ARTHUR_WALK_FIRST := 1
const ARTHUR_WALK_LAST := 8
const ARTHUR_JUMP_FRAME := 3

const WAVE_MARKERS := [430.0, 850.0, 1270.0]
const FONT_COLOR := Color("#263550")

var player_x := 120.0
var player_lane := 0.0
var jump_height := 0.0
var jump_velocity := 0.0
var energy := 100.0
var invulnerability := 0.0
var attack_cooldown := 0.0
var attack_flash := 0.0
var blocking := false
var block_flash := 0.0
var mud_timer := 0.0
var wave_index := 0
var enemies: Array[Dictionary] = []
var boss_active := false
var boss_x := BOSS_START
var boss_lane := 0.0
var boss_health := BOSS_MAX_HEALTH
var boss_stun := 0.0
var game_won := false
var powers: Array = []
var facing := 1.0
var walking := false
var walk_time := 0.0
var anims := {}


func _ready() -> void:
	get_window().title = "Arthur: Caminho de Volta — Protótipo"
	# nome: SpriteAnim.new(arquivo, quadros, segundos por quadro, pés, imagem virada p/ esquerda?)
	anims = {
		"arthur_caminhando": SpriteAnim.new("res://art/arthur_caminhando.png", 9, 0.13, ARTHUR_FEET),
		"arthur_pum": SpriteAnim.new("res://art/arthur_pum.png", 8, 0.12, ARTHUR_FEET, true),
		"arthur_fogo": SpriteAnim.new("res://art/arthur_fogo.png", 8, 0.12, ARTHUR_FEET, true),
		"dorothy_correndo": SpriteAnim.new("res://art/dorothy_correndo.png", 9, 0.13, DOROTHY_FEET),
		"dorothy_poder": SpriteAnim.new("res://art/dorothy_poder.png", 8, 0.12, DOROTHY_FEET),
	}
	for script in POWER_SCRIPTS:
		powers.append(script.new())
	_power("doroth").reset()


func _input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	if key_event.keycode == KEY_ENTER and game_won:
		_restart()
	elif game_won:
		return
	elif _movement_locked():
		return
	elif key_event.keycode == KEY_SPACE and jump_height <= 0.0:
		jump_velocity = 480.0
	elif key_event.keycode == KEY_J or key_event.keycode == KEY_K:
		_attack()
	else:
		for power in powers:
			if power.keycode != KEY_NONE and key_event.keycode == power.keycode:
				power.try_activate(self)
				return


func _process(delta: float) -> void:
	if game_won:
		queue_redraw()
		return

	for power in powers:
		power.update(self, delta)
	invulnerability = maxf(0.0, invulnerability - delta)
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	attack_flash = maxf(0.0, attack_flash - delta)
	block_flash = maxf(0.0, block_flash - delta)
	mud_timer = maxf(0.0, mud_timer - delta)
	boss_stun = maxf(0.0, boss_stun - delta)

	blocking = (Input.is_key_pressed(KEY_L) or Input.is_key_pressed(KEY_SHIFT)) and jump_height <= 0.0

	var horizontal := 0.0
	var vertical := 0.0
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		horizontal += 1.0
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		horizontal -= 1.0
	if Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S):
		vertical += 1.0
	if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W):
		vertical -= 1.0
	if _movement_locked():
		horizontal = 0.0
		vertical = 0.0
		blocking = false

	if horizontal != 0.0 and not blocking:
		facing = horizontal
	walking = (horizontal != 0.0 or vertical != 0.0) and jump_height <= 0.0
	walk_time = walk_time + delta if walking else 0.0

	var speed_factor := _obstacle_speed_factor()
	if blocking:
		speed_factor *= BLOCK_SPEED_FACTOR
	player_x = maxf(0.0, player_x + horizontal * PLAYER_SPEED * speed_factor * delta)
	player_lane = clampf(player_lane + vertical * LANE_SPEED * speed_factor * delta / 100.0, -0.8, 0.8)

	if jump_height > 0.0 or jump_velocity > 0.0:
		jump_height += jump_velocity * delta
		jump_velocity -= 1100.0 * delta
		if jump_height <= 0.0:
			jump_height = 0.0
			jump_velocity = 0.0

	_spawn_progress()
	if boss_is_fighting():
		player_x = minf(player_x, BOSS_START - 250.0)
	_update_enemies(delta)
	_update_boss(delta)
	queue_redraw()


func _spawn_progress() -> void:
	while wave_index < WAVE_MARKERS.size() and player_x >= WAVE_MARKERS[wave_index]:
		var spawn_x: float = WAVE_MARKERS[wave_index] + 290.0
		enemies.append({"pos": Vector2(spawn_x, -0.25), "health": 2, "stun": 0.0, "kind": wave_index % 2})
		enemies.append({"pos": Vector2(spawn_x + 105.0, 0.35), "health": 2, "stun": 0.0, "kind": (wave_index + 1) % 2})
		wave_index += 1

	if player_x >= BOSS_START - 300.0:
		boss_active = true


func _update_enemies(delta: float) -> void:
	for index in range(enemies.size() - 1, -1, -1):
		var enemy: Dictionary = enemies[index]
		enemy["stun"] = maxf(0.0, float(enemy["stun"]) - delta)
		var position: Vector2 = enemy["pos"]
		var distance := player_x - position.x
		if float(enemy["stun"]) <= 0.0 and absf(distance) < 430.0:
			position.x += signf(distance) * 92.0 * delta
			if absf(distance) < 48.0 and absf(player_lane - position.y) < 0.5 and invulnerability <= 0.0:
				if blocking:
					position.x += _away_from_player(position.x) * BLOCK_PUSHBACK
					enemy["stun"] = 0.3
				enemy["pos"] = position
				enemies[index] = enemy
				_take_hit(12.0)
				if enemies.is_empty():
					return
				continue
		enemy["pos"] = position
		enemies[index] = enemy


func _update_boss(delta: float) -> void:
	if not boss_is_fighting():
		return
	if boss_stun <= 0.0:
		boss_x = move_toward(boss_x, player_x + 65.0, 52.0 * delta)
		if absf(boss_x - player_x) < 80.0 and absf(player_lane - boss_lane) < 0.55 and invulnerability <= 0.0:
			if blocking:
				boss_x += _away_from_player(boss_x) * BLOCK_PUSHBACK * 0.7
			_take_hit(18.0)


func _attack() -> void:
	if attack_cooldown > 0.0 or blocking or game_won:
		return
	attack_cooldown = 0.36
	attack_flash = 0.18
	for index in range(enemies.size() - 1, -1, -1):
		var enemy: Dictionary = enemies[index]
		var position: Vector2 = enemy["pos"]
		if absf(position.x - player_x) < 100.0 and absf(position.y - player_lane) < 0.65:
			enemy["health"] = int(enemy["health"]) - 1
			enemy["stun"] = 0.45
			position.x += 28.0
			enemy["pos"] = position
			if int(enemy["health"]) <= 0:
				enemies.remove_at(index)
			else:
				enemies[index] = enemy
			return

	if boss_is_fighting() and absf(boss_x - player_x) < 125.0 and absf(boss_lane - player_lane) < 0.7:
		damage_boss(1, 0.35)


func _take_hit(amount: float) -> void:
	if invulnerability > 0.0:
		return
	if blocking:
		amount *= BLOCK_DAMAGE_FACTOR
		block_flash = 0.35
	energy = maxf(0.0, energy - amount)
	invulnerability = 0.85
	if energy <= 0.0:
		_power("doroth").try_activate(self)


func _away_from_player(x: float) -> float:
	return 1.0 if x >= player_x else -1.0


func _obstacle_speed_factor() -> float:
	if jump_height > 0.0:
		return 1.0
	for obstacle in OBSTACLES:
		match obstacle["kind"]:
			"poca":
				if absf(player_x - float(obstacle["x"])) < PUDDLE_HALF_WIDTH and absf(player_lane - float(obstacle["lane"])) < PUDDLE_HALF_LANE:
					mud_timer = 0.45
					return PUDDLE_SPEED_FACTOR
	return 1.0


func _power(power_id: String):
	for power in powers:
		if power.id == power_id:
			return power
	return null


## Poder ativo que tem uma animação própria do Arthur (ou null).
func _posing_power():
	for power in powers:
		if power.is_active() and power.player_anim != "":
			return power
	return null


func _movement_locked() -> bool:
	for power in powers:
		if power.is_active() and power.locks_movement:
			return true
	return false


func _restart() -> void:
	player_x = 120.0
	player_lane = 0.0
	jump_height = 0.0
	jump_velocity = 0.0
	energy = 100.0
	invulnerability = 0.0
	attack_cooldown = 0.0
	attack_flash = 0.0
	blocking = false
	block_flash = 0.0
	mud_timer = 0.0
	facing = 1.0
	walking = false
	walk_time = 0.0
	wave_index = 0
	enemies.clear()
	boss_active = false
	boss_x = BOSS_START
	boss_health = BOSS_MAX_HEALTH
	boss_stun = 0.0
	game_won = false
	for power in powers:
		power.reset()


# --- API pública usada pelos poderes (res://powers/) ---

func boss_is_fighting() -> bool:
	return boss_active and boss_health > 0


func stun_enemies(seconds: float) -> void:
	for index in range(enemies.size()):
		var enemy: Dictionary = enemies[index]
		enemy["stun"] = seconds
		enemies[index] = enemy


func clear_enemies() -> void:
	enemies.clear()


func stun_boss(seconds: float) -> void:
	if boss_is_fighting():
		boss_stun = seconds


func damage_boss(amount: int, stun_seconds: float) -> void:
	if not boss_is_fighting():
		return
	boss_health = maxi(0, boss_health - amount)
	boss_stun = stun_seconds
	if boss_health == 0:
		game_won = true


func restore_energy() -> void:
	energy = 100.0


func set_invulnerable(seconds: float) -> void:
	invulnerability = seconds


func get_camera_x() -> float:
	return maxf(0.0, player_x - PLAYER_SCREEN_X)


## Animação carregada pelo nome (veja _ready), ou null se o arquivo não existe.
func get_anim(anim_name: String):
	var anim = anims.get(anim_name)
	if anim != null and anim.is_loaded():
		return anim
	return null


func lane_y(lane: float) -> float:
	return 408.0 + lane * 78.0


func draw_oval(center: Vector2, radii: Vector2, color: Color) -> void:
	draw_set_transform(center, 0.0, radii / 10.0)
	draw_circle(Vector2.ZERO, 10.0, color)
	draw_set_transform(Vector2.ZERO)


# --- Desenho ---

func _draw() -> void:
	var viewport := get_viewport_rect().size
	var camera_x := get_camera_x()
	_draw_background(viewport, camera_x)

	for obstacle in OBSTACLES:
		var obstacle_screen := Vector2(float(obstacle["x"]) - camera_x, lane_y(float(obstacle["lane"])))
		if obstacle_screen.x > -80.0 and obstacle_screen.x < viewport.x + 80.0:
			_draw_obstacle(obstacle_screen, obstacle["kind"])

	for enemy in enemies:
		var position: Vector2 = enemy["pos"]
		_draw_enemy(Vector2(position.x - camera_x, lane_y(position.y)), int(enemy["kind"]), float(enemy["stun"]) > 0.0)

	if boss_is_fighting():
		_draw_boss(Vector2(boss_x - camera_x, lane_y(boss_lane)), boss_stun > 0.0)

	for power in powers:
		power.draw_world(self, camera_x, true)
	var player_screen := Vector2(player_x - camera_x, lane_y(player_lane) - jump_height)
	_draw_player(player_screen)
	for power in powers:
		power.draw_world(self, camera_x, false)
	if mud_timer > 0.0:
		_draw_mud_splash(Vector2(player_screen.x, lane_y(player_lane)))
	if attack_flash > 0.0:
		var arc_start := -1.0 if facing > 0.0 else PI - 1.0
		draw_arc(player_screen + Vector2(35.0 * facing, -7.0), 42.0, arc_start, arc_start + 2.0, 20, Color("#fff3a1"), 8.0)
	if blocking:
		_draw_shield(player_screen)
	for power in powers:
		if power.is_active():
			power.draw(self, player_screen)

	_draw_hud(viewport)
	for power in powers:
		if power.is_active():
			power.draw_hud(self, viewport)
	if game_won:
		_draw_win_overlay(viewport)


func _draw_background(viewport: Vector2, camera_x: float) -> void:
	draw_rect(Rect2(Vector2.ZERO, viewport), Color("#8be0ff"))
	draw_circle(Vector2(825.0, 82.0), 42.0, Color("#ffe577"))
	draw_rect(Rect2(0.0, 220.0, viewport.x, 100.0), Color("#7dca79"))
	draw_rect(Rect2(0.0, 315.0, viewport.x, viewport.y - 315.0), Color("#f6d590"))
	draw_rect(Rect2(0.0, 465.0, viewport.x, 75.0), Color("#72c65e"))

	for building_index in range(5):
		var building_x := fposmod(float(building_index) * 310.0 - camera_x * 0.22, viewport.x + 180.0) - 90.0
		draw_rect(Rect2(building_x, 145.0, 155.0, 115.0), Color("#ff9d85") if building_index % 2 == 0 else Color("#f3b9e8"))
		draw_colored_polygon(PackedVector2Array([
			Vector2(building_x - 12.0, 147.0),
			Vector2(building_x + 78.0, 92.0),
			Vector2(building_x + 167.0, 147.0)
		]), Color("#d96d83"))
		for window_index in range(3):
			draw_rect(Rect2(building_x + 18.0 + window_index * 42.0, 174.0, 23.0, 30.0), Color("#b4efff"))

	for landmark in range(-1, 5):
		var tree_x := fposmod(float(landmark) * 280.0 - camera_x * 0.75, viewport.x + 300.0) - 120.0
		draw_rect(Rect2(tree_x - 8.0, 237.0, 16.0, 74.0), Color("#926348"))
		draw_circle(Vector2(tree_x, 222.0), 35.0, Color("#35b875"))
		draw_circle(Vector2(tree_x - 20.0, 237.0), 22.0, Color("#66cf77"))
		draw_circle(Vector2(tree_x + 22.0, 238.0), 21.0, Color("#42bd68"))

	for bench_index in range(4):
		var bench_x := fposmod(float(bench_index) * 390.0 - camera_x * 0.9, viewport.x + 150.0) - 60.0
		draw_rect(Rect2(bench_x, 305.0, 72.0, 9.0), Color("#b97745"))
		draw_rect(Rect2(bench_x + 8.0, 314.0, 7.0, 22.0), Color("#79594c"))
		draw_rect(Rect2(bench_x + 57.0, 314.0, 7.0, 22.0), Color("#79594c"))

	draw_rect(Rect2(0.0, 308.0, viewport.x, 7.0), Color("#ffe9a8"))
	draw_string(ThemeDB.fallback_font, Vector2(18.0, 294.0), "PRACA DA BRUXA", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, Color("#477c5d"))


func _draw_obstacle(position: Vector2, kind: String) -> void:
	match kind:
		"poca":
			draw_oval(position, Vector2(PUDDLE_HALF_WIDTH + 8.0, 18.0), Color("#7a4a2e"))
			draw_oval(position + Vector2(-3.0, -1.0), Vector2(PUDDLE_HALF_WIDTH - 4.0, 12.0), Color("#9c6440"))
			draw_oval(position + Vector2(-16.0, -5.0), Vector2(11.0, 3.0), Color(1.0, 1.0, 1.0, 0.45))
			draw_oval(position + Vector2(14.0, 3.0), Vector2(6.0, 2.0), Color(1.0, 1.0, 1.0, 0.35))


func _draw_mud_splash(feet: Vector2) -> void:
	var wobble := sin(Time.get_ticks_msec() * 0.02) * 4.0
	draw_circle(feet + Vector2(-22.0, -10.0 - wobble), 4.0, Color("#7a4a2e"))
	draw_circle(feet + Vector2(20.0, -14.0 + wobble), 5.0, Color("#9c6440"))
	draw_circle(feet + Vector2(-8.0, -20.0 + wobble), 3.0, Color("#7a4a2e"))
	draw_circle(feet + Vector2(10.0, -6.0 - wobble), 3.0, Color("#9c6440"))


func _draw_shield(player_screen: Vector2) -> void:
	var center := player_screen + Vector2(6.0 * facing, -60.0)
	var start := -1.25 if facing > 0.0 else PI - 1.25
	draw_arc(center, 54.0, start, start + 2.5, 24, Color("#4fc3ff"), 9.0)
	draw_arc(center, 54.0, start, start + 2.5, 24, Color("#fff3a1"), 3.0)
	if block_flash > 0.0:
		draw_circle(center + Vector2(52.0 * facing, 0.0), 16.0 * (1.0 + block_flash), Color(1.0, 0.95, 0.5, block_flash * 2.0))
		draw_string(ThemeDB.fallback_font, player_screen + Vector2(-30.0, -128.0), "DEFESA!", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 18, Color("#2c7fd6"))


func _draw_player(position: Vector2) -> void:
	if invulnerability > 0.0 and int(Time.get_ticks_msec() / 100) % 2 == 0:
		return
	if get_anim("arthur_caminhando") != null:
		_draw_player_sprite(position)
		return
	draw_oval(position + Vector2(0.0, 5.0), Vector2(25.0, 8.0), Color(0.22, 0.27, 0.31, 0.2))
	draw_rect(Rect2(position.x - 16.0, position.y - 42.0, 13.0, 31.0), Color("#ed785b"))
	draw_rect(Rect2(position.x + 3.0, position.y - 42.0, 13.0, 31.0), Color("#ed785b"))
	draw_rect(Rect2(position.x - 22.0, position.y - 73.0, 44.0, 39.0), Color("#4c91e8"))
	draw_circle(position + Vector2(0.0, -87.0), 22.0, Color("#f7bf8d"))
	draw_colored_polygon(PackedVector2Array([
		position + Vector2(-21.0, -94.0),
		position + Vector2(-13.0, -115.0),
		position + Vector2(8.0, -110.0),
		position + Vector2(22.0, -95.0),
		position + Vector2(14.0, -91.0),
		position + Vector2(-12.0, -96.0)
	]), Color("#493a39"))
	draw_circle(position + Vector2(8.0, -88.0), 2.5, Color("#263550"))
	draw_arc(position + Vector2(7.0, -80.0), 7.0, 0.2, 1.5, 12, Color("#a4484e"), 2.0)
	var hand := position + (Vector2(24.0, -58.0) if blocking else Vector2(-19.0, -55.0))
	draw_circle(hand, 7.0, Color("#f7bf8d"))


## Desenha o Arthur com as animações das folhas de sprites. Poderes com
## `player_anim` (pum, espetinho) têm prioridade; depois andar, pular e parado.
func _draw_player_sprite(position: Vector2) -> void:
	var t := Time.get_ticks_msec() / 1000.0
	var ground := Vector2(position.x, position.y + jump_height)
	var shadow_size := clampf(1.0 - jump_height / 220.0, 0.5, 1.0)
	draw_oval(ground + Vector2(0.0, 4.0), Vector2(28.0, 8.0) * shadow_size, Color(0.22, 0.27, 0.31, 0.22))

	var pose = _posing_power()
	if pose != null and get_anim(pose.player_anim) != null:
		var pose_anim = get_anim(pose.player_anim)
		pose_anim.draw(self, pose_anim.frame_at(pose.elapsed(), false), position, ARTHUR_SCALE, facing)
		return

	var anim = get_anim("arthur_caminhando")
	var frame := 0
	var stretch := Vector2.ONE
	var tilt := 0.0
	if jump_height > 0.0:
		frame = ARTHUR_JUMP_FRAME
		stretch = Vector2(0.93, 1.08) if jump_velocity > 0.0 else Vector2.ONE
	elif walking:
		frame = anim.frame_at(walk_time, true, ARTHUR_WALK_FIRST, ARTHUR_WALK_LAST)
	else:
		stretch = Vector2(1.0, 1.0 + sin(t * 3.0) * 0.015)
	if blocking:
		tilt = -0.12 * facing
	if attack_flash > 0.0:
		frame = ARTHUR_JUMP_FRAME
		tilt = 0.18 * facing
	anim.draw(self, frame, position, ARTHUR_SCALE, facing, tilt, stretch)


func _draw_enemy(position: Vector2, kind: int, stunned: bool) -> void:
	draw_oval(position + Vector2(0.0, 5.0), Vector2(24.0, 7.0), Color(0.22, 0.27, 0.31, 0.18))
	var body_color := Color("#a769d5") if kind == 0 else Color("#63bd67")
	draw_circle(position + Vector2(0.0, -25.0), 22.0, body_color)
	draw_colored_polygon(PackedVector2Array([
		position + Vector2(-18.0, -37.0),
		position + Vector2(-25.0, -54.0),
		position + Vector2(-8.0, -44.0),
		position + Vector2(1.0, -48.0),
		position + Vector2(15.0, -56.0),
		position + Vector2(14.0, -38.0)
	]), body_color)
	draw_circle(position + Vector2(-7.0, -28.0), 4.0, Color.WHITE)
	draw_circle(position + Vector2(8.0, -28.0), 4.0, Color.WHITE)
	draw_circle(position + Vector2(-6.0, -28.0), 2.0, FONT_COLOR)
	draw_circle(position + Vector2(9.0, -28.0), 2.0, FONT_COLOR)
	if stunned:
		draw_string(ThemeDB.fallback_font, position + Vector2(-18.0, -58.0), "Z z", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, Color("#fff5a8"))


func _draw_boss(position: Vector2, stunned: bool) -> void:
	draw_oval(position + Vector2(0.0, 5.0), Vector2(54.0, 12.0), Color(0.22, 0.27, 0.31, 0.22))
	draw_colored_polygon(PackedVector2Array([
		position + Vector2(-42.0, -32.0),
		position + Vector2(-37.0, -105.0),
		position + Vector2(-22.0, -133.0),
		position + Vector2(0.0, -111.0),
		position + Vector2(24.0, -137.0),
		position + Vector2(42.0, -94.0),
		position + Vector2(48.0, -32.0)
	]), Color("#a14c9a"))
	draw_circle(position + Vector2(0.0, -116.0), 31.0, Color("#f4bd86"))
	draw_colored_polygon(PackedVector2Array([
		position + Vector2(-30.0, -118.0),
		position + Vector2(-36.0, -151.0),
		position + Vector2(-17.0, -137.0),
		position + Vector2(0.0, -157.0),
		position + Vector2(13.0, -137.0),
		position + Vector2(36.0, -152.0),
		position + Vector2(28.0, -114.0)
	]), Color("#45364b"))
	draw_circle(position + Vector2(-10.0, -116.0), 4.0, Color("#fff1ac"))
	draw_circle(position + Vector2(11.0, -116.0), 4.0, Color("#fff1ac"))
	if stunned:
		draw_string(ThemeDB.fallback_font, position + Vector2(-24.0, -162.0), "Z z", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 20, Color("#fff5a8"))


func _draw_hud(viewport: Vector2) -> void:
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(20.0, 18.0, 305.0, 67.0), Color(1.0, 1.0, 1.0, 0.88))
	draw_string(font, Vector2(34.0, 43.0), "ARTHUR", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 17, FONT_COLOR)
	draw_rect(Rect2(34.0, 53.0, 220.0, 17.0), Color("#e8d8d6"))
	draw_rect(Rect2(34.0, 53.0, 220.0 * energy / 100.0, 17.0), Color("#fa6872"))
	draw_string(font, Vector2(34.0, 81.0), "Doroth: %d resgates" % _power("doroth").uses, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12, Color("#477c5d"))

	var power_parts: PackedStringArray = []
	for power in powers:
		if power.keycode != KEY_NONE:
			power_parts.append("%s %s (%s)" % [OS.get_keycode_string(power.keycode), power.hud_label, _cooldown_text(power.cooldown_left)])
	draw_rect(Rect2(viewport.x - 394.0, 18.0, 374.0, 84.0), Color(1.0, 1.0, 1.0, 0.88))
	draw_string(font, Vector2(viewport.x - 376.0, 41.0), "← → andar   ↑ ↓ faixa   ESPAÇO pular", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, FONT_COLOR)
	draw_string(font, Vector2(viewport.x - 376.0, 62.0), "J atacar   L ou SHIFT defender", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, FONT_COLOR)
	draw_string(font, Vector2(viewport.x - 376.0, 84.0), "   ".join(power_parts), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, Color("#a14c68"))

	if boss_is_fighting():
		draw_rect(Rect2(viewport.x * 0.5 - 155.0, 110.0, 310.0, 47.0), Color(1.0, 1.0, 1.0, 0.9))
		draw_string(font, Vector2(viewport.x * 0.5 - 139.0, 130.0), "BRUXA DA PRAÇA", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, FONT_COLOR)
		draw_rect(Rect2(viewport.x * 0.5 - 139.0, 137.0, 278.0, 11.0), Color("#ead8e9"))
		draw_rect(Rect2(viewport.x * 0.5 - 139.0, 137.0, 278.0 * float(boss_health) / float(BOSS_MAX_HEALTH), 11.0), Color("#bf5daf"))

	var ready_x := 24.0
	for power in powers:
		if power.keycode != KEY_NONE and power.is_ready():
			var ready_text: String = "%s PRONTO!" % power.display_name.to_upper()
			draw_string(font, Vector2(ready_x, viewport.y - 18.0), ready_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, power.hud_color)
			ready_x += font.get_string_size(ready_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13).x + 30.0


func _draw_win_overlay(viewport: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, viewport), Color(0.13, 0.17, 0.28, 0.7))
	draw_rect(Rect2(viewport.x * 0.5 - 235.0, viewport.y * 0.5 - 105.0, 470.0, 210.0), Color("#fff4d6"))
	draw_string(ThemeDB.fallback_font, Vector2(viewport.x * 0.5 - 160.0, viewport.y * 0.5 - 32.0), "FASE COMPLETA!", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 34, Color("#a14c68"))
	draw_string(ThemeDB.fallback_font, Vector2(viewport.x * 0.5 - 170.0, viewport.y * 0.5 + 13.0), "Arthur e Doroth venceram a Bruxa da Praça!", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, FONT_COLOR)
	draw_string(ThemeDB.fallback_font, Vector2(viewport.x * 0.5 - 100.0, viewport.y * 0.5 + 57.0), "ENTER para jogar de novo", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, Color("#477c5d"))
	draw_circle(Vector2(viewport.x - 103.0, 85.0), 38.0, Color("#151321"))
	draw_circle(Vector2(viewport.x - 116.0, 82.0), 4.0, Color("#fff1ac"))
	draw_circle(Vector2(viewport.x - 91.0, 82.0), 4.0, Color("#fff1ac"))


func _cooldown_text(value: float) -> String:
	return "OK" if value <= 0.0 else "%.0fs" % ceilf(value)
