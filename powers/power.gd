extends RefCounted
## Base de todos os poderes do Arthur.
##
## Para criar um poder novo:
##   1. Crie um arquivo em res://powers/ começando com `extends "res://powers/power.gd"`.
##   2. Em `_init()`, preencha id, display_name, hud_label, keycode, cooldown e effect_duration.
##   3. Sobrescreva `_on_activate(game)` com o efeito do poder.
##   4. Sobrescreva `draw(game, player_screen)` (e, se quiser, `draw_hud`) com o visual
##      exibido enquanto o efeito dura.
##   5. Registre o script em POWER_SCRIPTS, no main.gd. A tecla, o HUD e a recarga
##      passam a funcionar sozinhos.
##
## `game` é o nó principal (main.gd). Use a API pública dele:
## stun_enemies, clear_enemies, stun_boss, damage_boss, restore_energy,
## set_invulnerable, boss_is_fighting, lane_y, get_camera_x, get_anim, draw_oval,
## player_x, player_lane, facing.
##
## Para o Arthur fazer uma animação durante o poder, coloque o nome dela em
## `player_anim` (veja `anims` em _ready, no main.gd) e ajuste `effect_duration`.

var id := ""
var display_name := ""
var hud_label := ""
## KEY_NONE: o poder não tem tecla e é acionado pelo próprio jogo (ex.: Doroth).
var keycode: Key = KEY_NONE
var cooldown := 0.0
var effect_duration := 0.0
var hud_color := Color("#a14c68")
## Animação do Arthur enquanto o efeito dura (nome em game.anims). "" = nenhuma.
var player_anim := ""
## Arthur fica parado (sem andar, pular ou atacar) enquanto o efeito dura.
var locks_movement := false

var cooldown_left := 0.0
var effect_left := 0.0
var uses := 0


func is_ready() -> bool:
	return cooldown_left <= 0.0


func is_active() -> bool:
	return effect_left > 0.0


## Segundos desde que o poder foi ativado (enquanto o efeito dura).
func elapsed() -> float:
	return effect_duration - effect_left


func try_activate(game) -> bool:
	if not is_ready():
		return false
	cooldown_left = cooldown
	effect_left = effect_duration
	uses += 1
	_on_activate(game)
	return true


func update(game, delta: float) -> void:
	cooldown_left = maxf(0.0, cooldown_left - delta)
	effect_left = maxf(0.0, effect_left - delta)
	_on_update(game, delta)


func reset() -> void:
	cooldown_left = 0.0
	effect_left = 0.0
	uses = 0


# --- Pontos de extensão para cada poder ---

func _on_activate(_game) -> void:
	pass


func _on_update(_game, _delta: float) -> void:
	pass


## Desenho no mundo chamado sempre, mesmo sem o efeito ativo (ex.: Doroth
## passeando). É chamado duas vezes por quadro: antes do Arthur
## (behind_player = true) e depois dele (false); desenhe só em uma delas.
func draw_world(_game, _camera_x: float, _behind_player: bool) -> void:
	pass


## Desenho no mundo, depois do Arthur. Só é chamado enquanto o efeito está ativo.
func draw(_game, _player_screen: Vector2) -> void:
	pass


## Desenho por cima do HUD. Só é chamado enquanto o efeito está ativo.
func draw_hud(_game, _viewport: Vector2) -> void:
	pass
