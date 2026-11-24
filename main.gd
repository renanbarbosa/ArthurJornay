extends Node2D

const PLAYER_SPEED := 250.0
const LANE_SPEED := 190.0
const PLAYER_SCREEN_X := 245.0
# Segurando a direção por RUN_DELAY segundos, o Arthur começa a correr.
const RUN_DELAY := 0.45
const RUN_FACTOR := 1.45

# Fases. Cada uma tem BG_COUNT telas de fundo: imagens art/<nome>.jpg (geradas por
# tools/build_backgrounds.py) lado a lado, cada uma com uma tela de largura (960),
# misturando-se com a anterior numa faixa de BG_OVERLAP.
#   backgrounds: imagens do caminho. "random": true sorteia a ordem (sem repetir a
#                mesma duas vezes seguidas); false alterna na ordem da lista.
#   arena: última imagem; a câmera trava nela e o chefe aparece.
#   waves: inimigos de cada onda (tipos de ENEMY_TYPES), uma a cada WAVE_SPACING.
#   boss: chave em BOSSES.
const PHASES := [
	{
		"title": "PRAÇA DA BRUXA", "backgrounds": ["praca_1", "praca_2"], "random": false, "arena": "praca_3",
		"boss": "bruxa", "win_text": "Arthur e Doroth venceram a Bruxa da Praça!",
		"waves": [
			["pitbull", "chihuahua"],
			["chihuahua", "chihuahua", "pitbull"],
			["pitbull", "pitbull"],
			["chihuahua", "pitbull", "chihuahua"],
			["pitbull", "cachorro"],
			["chihuahua", "chihuahua", "chihuahua", "pitbull"],
			["pitbull", "pitbull", "chihuahua"],
			["cachorro", "chihuahua", "chihuahua"],
			["pitbull", "pitbull", "pitbull"],
			["cachorro", "pitbull", "chihuahua"],
			["chihuahua", "chihuahua", "pitbull", "pitbull"],
			["cachorro", "cachorro"],
			["pitbull", "chihuahua", "cachorro", "chihuahua"],
			["pitbull", "pitbull", "cachorro"],
			["cachorro", "cachorro", "pitbull", "chihuahua"],
		],
	},
	{
		"title": "RUA PADRE VIEIRA", "backgrounds": ["rua_1", "rua_2", "rua_3"], "random": true, "arena": "rua_final",
		"boss": "praga", "win_text": "Arthur e Doroth venceram o Praga da Rua!",
		"waves": [
			["morador", "gordao"],
			["morador", "morador", "ifood"],
			["gordao", "gordao"],
			["ifood", "morador", "gordao"],
			["morador", "morador", "morador"],
			["gordao", "ifood", "morador", "ifood"],
			["gordao", "gordao", "morador"],
			["ifood", "ifood", "morador", "morador"],
			["gordao", "morador", "gordao"],
			["morador", "ifood", "gordao", "morador"],
			["gordao", "gordao", "ifood", "ifood"],
			["morador", "morador", "gordao", "ifood"],
			["gordao", "gordao", "gordao"],
			["ifood", "morador", "morador", "gordao", "ifood"],
			["gordao", "gordao", "morador", "morador"],
		],
	},
	{
		"title": "ITAPORANGA", "backgrounds": ["cidade_1", "cidade_2", "cidade_3"], "random": true, "arena": "cidade_final",
		"boss": "barata", "win_text": "Arthur e Doroth salvaram o vovô Nivaldo e a vovó Berenice!",
		# Vovós presos na arena (sentados acorrentados chorando) até o chefe ser derrotado.
		"captives": {"trapped": "vovos_presos", "free": "vovos_livres"},
		"waves": [
			["rato", "fantasma"],
			["rato", "rato", "fantasma"],
			["vaca", "rato"],
			["fantasma", "fantasma", "rato"],
			["vaca", "fantasma"],
			["rato", "rato", "rato", "fantasma"],
			["vaca", "vaca"],
			["fantasma", "rato", "vaca"],
			["fantasma", "fantasma", "fantasma"],
			["vaca", "rato", "rato", "fantasma"],
			["vaca", "fantasma", "vaca"],
			["rato", "rato", "fantasma", "fantasma"],
			["vaca", "vaca", "rato"],
			["fantasma", "vaca", "rato", "fantasma"],
			["vaca", "vaca", "fantasma", "rato"],
		],
	},
	{
		"title": "SALVADOR", "backgrounds": ["salvador_1", "salvador_2", "salvador_3"], "random": true, "arena": "salvador_final",
		"boss": "estrela", "win_text": "Arthur e Doroth salvaram o papai e a mamãe!",
		"captives": {"trapped": "pais_presos", "free": "pais_livres"},
		"waves": [
			["caranguejo", "lagosta"],
			["caranguejo", "caranguejo", "ermitao"],
			["lagosta", "ermitao"],
			["caranguejo", "lagosta", "caranguejo"],
			["ermitao", "ermitao", "caranguejo"],
			["lagosta", "lagosta", "caranguejo"],
			["caranguejo", "caranguejo", "caranguejo", "ermitao"],
			["lagosta", "ermitao", "lagosta"],
			["ermitao", "caranguejo", "ermitao", "caranguejo"],
			["lagosta", "lagosta", "ermitao"],
			["caranguejo", "lagosta", "ermitao", "caranguejo"],
			["lagosta", "lagosta", "lagosta"],
			["ermitao", "ermitao", "lagosta", "caranguejo"],
			["caranguejo", "caranguejo", "lagosta", "lagosta"],
			["lagosta", "ermitao", "ermitao", "lagosta", "caranguejo"],
		],
	},
	{
		"title": "BOSQUE DOS JEQUITIBÁS", "backgrounds": ["bosque_1", "bosque_2", "bosque_3"], "random": true, "arena": "bosque_final",
		"boss": "sagui", "win_text": "Arthur e Doroth salvaram a vovó!",
		"captives": {"trapped": "vovo_bosque_presa", "free": "vovo_bosque_livre"},
		"waves": [
			["arara", "preguica"],
			["arara", "arara", "hipopotamo"],
			["preguica", "arara"],
			["hipopotamo", "arara", "preguica"],
			["arara", "arara", "arara"],
			["preguica", "preguica", "arara"],
			["hipopotamo", "hipopotamo"],
			["arara", "preguica", "hipopotamo", "arara"],
			["preguica", "hipopotamo", "preguica"],
			["arara", "arara", "hipopotamo", "arara"],
			["hipopotamo", "preguica", "hipopotamo"],
			["arara", "preguica", "preguica", "arara"],
			["hipopotamo", "hipopotamo", "arara", "arara"],
			["preguica", "preguica", "hipopotamo", "arara"],
			["hipopotamo", "arara", "preguica", "hipopotamo", "arara"],
		],
	},
]
const BG_WIDTH := 960.0
const BG_OVERLAP := 160.0
const BG_STEP := BG_WIDTH - BG_OVERLAP
const BG_COUNT := 15
const LEVEL_END := BG_STEP * (BG_COUNT - 1) + BG_WIDTH
const ARENA_START := LEVEL_END - BG_WIDTH

# Chefe: aparece quando o Arthur entra na última imagem; a câmera trava na arena.
const BOSS_START := ARENA_START + 680.0
const BOSS_START_LANE := 0.15
const BOSS_TRIGGER_X := ARENA_START + 100.0
# Chefes. Vida: cada soco/chute tira 1 (poderes tiram 2).
#   entrance: animação de entrada ("" = entra andando pela direita).
#   melee: golpe de perto; ranged: projétil de longe (pule para desviar);
#   summon: chama um ajudante (helper) quando a vida cai para os valores de summon_at.
#   melee_at, ranged_at, summon_time: segundo da animação em que a ação acontece.
#   hurt/sick: [animação, primeiro quadro, último]; sick_tint: fica verde no pum.
#   flies_away: na derrota, sai voando (bruxa); senão fica caído no chão.
#   defeat_time: segundos depois da derrota até a tela de vitória (padrão 2).
const BOSSES := {
	"bruxa": {
		"title": "BRUXA DA PRAÇA", "color": "#bf5daf", "health": 24, "speed": 65.0, "cooldown": 1.3,
		"entrance": "bruxa_entrada", "walk": "bruxa_andando",
		"melee": "bruxa_vassourada", "melee_at": 0.3, "melee_range": 135.0, "melee_damage": 16.0,
		"ranged": "bruxa_magia", "ranged_at": 0.5, "ranged_min_distance": 220.0, "projectile": "magic",
		"summon": "bruxa_invocando", "summon_time": 0.6, "summon_at": [16, 8], "helper": "cachorro",
		"hurt": ["bruxa_dano", 0, 1], "sick": ["bruxa_dano", 2, 5], "sick_tint": false,
		"defeat": "bruxa_derrota", "flies_away": true,
	},
	"praga": {
		"title": "PRAGA DA RUA", "color": "#8a5a3c", "health": 26, "speed": 50.0, "cooldown": 1.2,
		"entrance": "", "walk": "praga_andando",
		"melee": "praga_muleta", "melee_at": 0.28, "melee_range": 140.0, "melee_damage": 16.0,
		"ranged": "praga_xinga", "ranged_at": 0.35, "ranged_min_distance": 200.0, "projectile": "curse",
		"summon": "praga_xinga", "summon_time": 0.4, "summon_at": [18, 9], "helper": "morador",
		"hurt": ["praga_dano", 0, 0], "sick": ["praga_dano", 0, 0], "sick_tint": true,
		"defeat": "praga_derrota", "flies_away": false,
	},
	"barata": {
		"title": "BARATA GIGANTE", "color": "#7a4a2e", "health": 28, "speed": 60.0, "cooldown": 1.1,
		"entrance": "", "walk": "barata_andando",
		"melee": "barata_arremesso", "melee_at": 0.35, "melee_range": 140.0, "melee_damage": 15.0,
		"ranged": "barata_arremesso", "ranged_at": 0.35, "ranged_min_distance": 190.0, "projectile": "rice",
		"summon": "barata_arremesso", "summon_time": 0.35, "summon_at": [20, 10], "helper": "rato",
		"hurt": ["barata_dano", 0, 0], "sick": ["barata_dano", 1, 1], "sick_tint": true,
		"defeat": "barata_derrota", "flies_away": false, "defeat_time": 3.5,
	},
	"estrela": {
		"title": "ESTRELA DO MAR", "color": "#ff7a3d", "health": 30, "speed": 70.0, "cooldown": 1.1,
		"entrance": "", "walk": "estrela_andando",
		"melee": "estrela_ataque", "melee_at": 0.26, "melee_range": 150.0, "melee_damage": 16.0,
		"ranged": "estrela_ataque", "ranged_at": 0.26, "ranged_min_distance": 200.0, "projectile": "star",
		"summon": "estrela_danca", "summon_time": 0.4, "summon_at": [22, 11], "helper": "caranguejo",
		"hurt": ["estrela_dano", 0, 0], "sick": ["estrela_dano", 1, 1], "sick_tint": true,
		"defeat": "estrela_derrota", "flies_away": false, "defeat_time": 3.5,
	},
	"sagui": {
		"title": "SAGUI ZUMBI", "color": "#6b5a45", "health": 32, "speed": 75.0, "cooldown": 1.0,
		"entrance": "", "walk": "sagui_andando",
		"melee": "sagui_ataque", "melee_at": 0.3, "melee_range": 150.0, "melee_damage": 16.0,
		"ranged": "sagui_ataque", "ranged_at": 0.3, "ranged_min_distance": 190.0, "projectile": "banana",
		"summon": "sagui_ataque", "summon_time": 0.3, "summon_at": [24, 12], "helper": "arara",
		"hurt": ["sagui_dano", 0, 0], "sick": ["sagui_dano", 1, 1], "sick_tint": true,
		"defeat": "sagui_derrota", "flies_away": false, "defeat_time": 3.5,
	},
}
# Onde ficam os prisioneiros da arena (fase 3): posição x no mundo e faixa.
const CAPTIVES_X := ARENA_START + 830.0
const CAPTIVES_LANE := -0.75
# Projéteis dos chefes: magia verde da bruxa, xingamento do Praga, arroz envenenado da
# barata, estrelinha da estrela do mar, banana do sagui. (O ermitão também atira espinhos: SPIKE_*.)
const MAGIC_SPEED := 330.0
const MAGIC_DAMAGE := 10.0
const MAGIC_HEIGHT := 100.0
const SPIKE_SPEED := 420.0

# Área do chão onde Arthur e Doroth andam. "lane" é a profundidade:
# lane_y(lane) = GROUND_Y + lane * LANE_PIXELS (posição y dos pés na tela).
const GROUND_Y := 408.0
const LANE_PIXELS := 78.0
const LANE_MIN := -0.92
const LANE_MAX := 1.35

# Pulo.
const JUMP_SPEED := 480.0
const GRAVITY := 1100.0
const LAND_TIME := 0.1
# Acima destas alturas (pulando ou em cima do banco), quem não alcança não acerta.
const ENEMY_REACH_HEIGHT := 30.0
const BOSS_REACH_HEIGHT := 90.0
const MAGIC_REACH_HEIGHT := 55.0

# Ataques do Arthur: J soco (um inimigo à frente), K chute giratório (todos em volta).
const ATTACKS := {
	"punch": {"first_frame": 0, "duration": 0.24, "cooldown": 0.3, "range": 95.0, "both_sides": false, "push": 28.0},
	"kick": {"first_frame": 3, "duration": 0.36, "cooldown": 0.55, "range": 115.0, "both_sides": true, "push": 60.0},
}
const HURT_TIME := 0.45
# Quadros de arthur_ataque desenhados virados para trás (o chute).
const KICK_MIRRORED_FRAMES := [4]

# Controle (gamepad). Os nomes seguem o padrão Xbox; no PlayStation:
# A = ✕, B = ○, X = □, Y = △, LB = L1, RB = R1, BACK = Select/Share, START = Options.
# Para trocar um botão, mude o valor aqui. Botões que existem: JOY_BUTTON_A, _B, _X, _Y,
# _LEFT_SHOULDER, _RIGHT_SHOULDER, _LEFT_STICK, _RIGHT_STICK, _BACK, _START, _GUIDE.
# Andar: direcional (D-pad) ou analógico esquerdo. Gatilho esquerdo (LT/L2) também defende.
const PAD_BUTTONS := {
	"jump": JOY_BUTTON_A,
	"punch": JOY_BUTTON_X,
	"kick": JOY_BUTTON_Y,
	"block": JOY_BUTTON_B,
	"power:pum": JOY_BUTTON_LEFT_SHOULDER,
	"power:skewer": JOY_BUTTON_RIGHT_SHOULDER,
	"confirm": JOY_BUTTON_START,
	"menu": JOY_BUTTON_BACK,
}
const PAD_DEADZONE := 0.4
# true: mostra no console (Saída) o número de cada botão apertado, para descobrir o mapeamento.
const PAD_DEBUG := false

# Defesa: segurar L ou Shift no chão.
const BLOCK_SPEED_FACTOR := 0.35
const BLOCK_DAMAGE_FACTOR := 0.2
const BLOCK_PUSHBACK := 70.0

# Obstáculos da fase, espalhados por _build_obstacles():
#   "coco":  cocô de cachorro; grudento, deixa o Arthur lento e fica amassado
#            quando ele pisa (pule por cima ou troque de faixa).
#   "banco": banco de praça; bloqueia a passagem, mas dá para pular em cima.
const OBSTACLE_START := 330.0
const OBSTACLE_SPACING := 430.0
const OBSTACLE_LANES := [0.45, -0.55, -0.4, 0.85, 0.1, -0.35, -0.5, 0.9, 0.6, 0.0, 1.1, -0.7]
const COCO_HALF_WIDTH := 30.0
const COCO_HALF_LANE := 0.25
const COCO_SPEED_FACTOR := 0.4
const BENCH_HALF_WIDTH := 70.0
const BENCH_HALF_LANE := 0.2
const BENCH_HEIGHT := 38.0

# Poderes do Arthur. Para criar um novo, veja res://powers/power.gd.
const POWER_SCRIPTS := [
	preload("res://powers/pum_power.gd"),
	preload("res://powers/skewer_power.gd"),
	preload("res://powers/doroth_power.gd"),
]

# Animações: folhas art/<nome>.png geradas por tools/build_sprites.py, que também
# grava em art/sprites.json o número de quadros e o ponto dos pés de cada uma.
# Aqui fica só a velocidade (segundos por quadro). Os sprites têm o dobro do
# tamanho lógico e são desenhados com SPRITE_SCALE.
# Se as folhas não existirem, o jogo desenha os personagens com formas.
const SpriteAnim := preload("res://sprite_anim.gd")
const SPRITE_MANIFEST := "res://art/sprites.json"
const SPRITE_SCALE := 0.5
const ANIM_SPEED := {
	"arthur_derrotado": 0.15, "banco": 1.0, "coco": 0.18,
	"hud_barra": 1.0, "hud_arthur": 1.0, "hud_comandos": 1.0, "hud_icones": 1.0,
	"arthur_parado": 0.3, "arthur_andando": 0.12, "arthur_correndo": 0.08,
	"arthur_pulo": 0.1, "arthur_ataque": 0.08, "arthur_defesa": 0.15,
	"arthur_comemora": 0.18, "arthur_pum": 0.11, "arthur_espetinho": 0.13,
	"dorothy_parada": 0.2, "dorothy_correndo": 0.08, "dorothy_lambida": 0.14, "dorothy_latido": 0.12,
	"pitbull_parado": 1.0, "pitbull_correndo": 0.07, "pitbull_ataque": 0.09, "pitbull_dano": 0.12,
	"chihuahua_correndo": 0.06, "chihuahua_ataque": 0.08, "chihuahua_dano": 0.12,
	"cachorro_correndo": 0.08, "cachorro_ataque": 0.09, "cachorro_dano": 0.12, "cachorro_surgindo": 0.12,
	"bruxa_andando": 0.13, "bruxa_entrada": 0.25, "bruxa_vassourada": 0.1, "bruxa_magia": 0.1,
	"bruxa_dano": 0.12, "bruxa_derrota": 0.3, "bruxa_invocando": 0.15,
	"gordao_andando": 0.2, "gordao_ataque": 0.14, "gordao_dano": 1.0, "gordao_derrota": 1.0,
	"morador_andando": 0.16, "morador_ataque": 0.11, "morador_dano": 1.0, "morador_derrota": 1.0,
	"ifood_moto": 0.07, "ifood_manobra": 0.12, "ifood_caido": 1.2,
	"praga_andando": 0.24, "praga_muleta": 0.14, "praga_xinga": 0.9, "praga_dano": 1.0, "praga_derrota": 1.0,
	"fantasma_voando": 0.15, "fantasma_susto": 0.15, "fantasma_dano": 1.0, "fantasma_derrota": 1.0,
	"vaca_andando": 0.16, "vaca_chifrada": 0.16, "vaca_dano": 1.0, "vaca_derrota": 1.0,
	"rato_andando": 0.1, "rato_rabada": 0.12, "rato_dano": 1.0, "rato_derrota": 1.0,
	"barata_andando": 0.14, "barata_arremesso": 0.3, "barata_dano": 1.0, "barata_derrota": 1.0,
	"vovos_presos": 0.5, "vovos_livres": 0.6,
	"caranguejo_andando": 0.12, "caranguejo_ataque": 0.12, "caranguejo_dano": 1.0, "caranguejo_derrota": 1.0,
	"ermitao_andando": 0.16, "ermitao_ataque": 0.25, "ermitao_dano": 1.0, "ermitao_derrota": 1.0,
	"lagosta_andando": 0.15, "lagosta_ataque": 0.25, "lagosta_dano": 1.0, "lagosta_derrota": 1.0,
	"estrela_andando": 0.25, "estrela_danca": 0.9, "estrela_ataque": 0.12, "estrela_dano": 1.0, "estrela_derrota": 1.0,
	"pais_presos": 0.5, "pais_livres": 0.6,
	"arara_andando": 0.1, "arara_ataque": 0.16, "arara_dano": 1.0, "arara_derrota": 1.0,
	"preguica_andando": 0.22, "preguica_ataque": 0.16, "preguica_dano": 1.0, "preguica_derrota": 1.0,
	"hipopotamo_andando": 0.18, "hipopotamo_ataque": 0.18, "hipopotamo_dano": 1.0, "hipopotamo_derrota": 1.0,
	"sagui_andando": 0.14, "sagui_ataque": 0.15, "sagui_dano": 1.0, "sagui_derrota": 1.0,
	"vovo_bosque_presa": 0.5, "vovo_bosque_livre": 0.6,
}

# Ondas de inimigos: começam em WAVE_START e se repetem a cada WAVE_SPACING
# (uma por lista em "waves" da fase), ficando mais difíceis até o chefe.
const WAVE_START := 600.0
const WAVE_SPACING := 720.0
# Tipos de inimigo. Animações: [nome em ANIM_SPEED, primeiro quadro, último quadro].
#   run: correndo; attack: ataque (o golpe acerta no quadro hit_frame);
#   idle: esperando para atacar de novo; hurt: apanhou; sick: enjoado (pum);
#   spawn: aparecendo (opcional); ko: nocauteado (opcional, senão usa hurt).
#   sick_tint: fica verde quando enjoado; ko_time: segundos até sumir.
#   hover: flutua essa altura acima do chão (fantasma); hover_moving: só enquanto
#          anda (arara voa e pousa para atacar); lunge: avança com essa
#          velocidade durante o ataque, até o golpe (chifrada da vaca).
#   shooter: em vez de golpe de perto, atira um espinho no quadro hit_frame (ermitão);
#            "reach" é a distância de onde ele atira.
#   rider: motoqueiro; não persegue: avisa (placa na borda da tela), atravessa
#          a faixa do Arthur em alta velocidade e cai da moto se apanhar.
# Para um inimigo novo: gere as folhas (tools/build_sprites.py), coloque a
# velocidade em ANIM_SPEED e adicione o tipo aqui e nas "waves" de PHASES.
const ENEMY_TYPES := {
	"pitbull": {
		"health": 2, "speed": 92.0, "reach": 70.0, "damage": 12.0, "cooldown": 1.2, "hit_frame": 3,
		"run": ["pitbull_correndo", 0, 8], "attack": ["pitbull_ataque", 0, 5], "idle": ["pitbull_parado", 0, 0],
		"hurt": ["pitbull_dano", 0, 1], "sick": ["pitbull_dano", 2, 5],
	},
	"chihuahua": {
		"health": 1, "speed": 150.0, "reach": 55.0, "damage": 7.0, "cooldown": 0.9, "hit_frame": 3,
		"run": ["chihuahua_correndo", 0, 8], "attack": ["chihuahua_ataque", 0, 4], "idle": ["chihuahua_ataque", 5, 8],
		"hurt": ["chihuahua_dano", 0, 1], "sick": ["chihuahua_dano", 2, 8],
	},
	"cachorro": {
		"health": 5, "speed": 120.0, "reach": 95.0, "damage": 18.0, "cooldown": 1.2, "hit_frame": 2,
		"run": ["cachorro_correndo", 0, 8], "attack": ["cachorro_ataque", 0, 5], "idle": ["cachorro_ataque", 6, 8],
		"hurt": ["cachorro_dano", 0, 1], "sick": ["cachorro_dano", 2, 5], "spawn": ["cachorro_surgindo", 0, 5],
	},
	# Fase 2.
	"gordao": {
		"health": 4, "speed": 70.0, "reach": 115.0, "damage": 15.0, "cooldown": 1.5, "hit_frame": 2,
		"run": ["gordao_andando", 0, 2], "attack": ["gordao_ataque", 0, 2], "idle": ["gordao_andando", 0, 0],
		"hurt": ["gordao_dano", 0, 0], "sick": ["gordao_dano", 1, 1], "ko": ["gordao_derrota", 0, 0],
		"sick_tint": true, "ko_time": 0.9,
	},
	"morador": {
		"health": 3, "speed": 115.0, "reach": 90.0, "damage": 12.0, "cooldown": 1.0, "hit_frame": 1,
		"run": ["morador_andando", 0, 2], "attack": ["morador_ataque", 0, 2], "idle": ["morador_andando", 0, 0],
		"hurt": ["morador_dano", 0, 0], "sick": ["morador_dano", 1, 1], "ko": ["morador_derrota", 0, 0],
		"sick_tint": true, "ko_time": 0.9,
	},
	"ifood": {
		"health": 1, "speed": 430.0, "reach": 50.0, "damage": 14.0, "cooldown": 0.0, "hit_frame": 0,
		"run": ["ifood_moto", 0, 2], "attack": ["ifood_manobra", 0, 0], "idle": ["ifood_moto", 0, 2],
		"hurt": ["ifood_caido", 0, 0], "sick": ["ifood_caido", 0, 0], "ko": ["ifood_caido", 0, 1],
		"ko_time": 2.0, "rider": true, "shadow": 75.0,
	},
	# Fase 3.
	"fantasma": {
		"health": 3, "speed": 100.0, "reach": 120.0, "damage": 12.0, "cooldown": 1.3, "hit_frame": 1,
		"run": ["fantasma_voando", 0, 2], "attack": ["fantasma_susto", 0, 2], "idle": ["fantasma_voando", 0, 2],
		"hurt": ["fantasma_dano", 0, 0], "sick": ["fantasma_dano", 1, 1], "ko": ["fantasma_derrota", 0, 0],
		"sick_tint": true, "ko_time": 0.9, "hover": 18.0,
	},
	"vaca": {
		"health": 5, "speed": 90.0, "reach": 120.0, "damage": 18.0, "cooldown": 1.6, "hit_frame": 2,
		"run": ["vaca_andando", 0, 2], "attack": ["vaca_chifrada", 0, 2], "idle": ["vaca_andando", 0, 0],
		"hurt": ["vaca_dano", 0, 0], "sick": ["vaca_dano", 1, 1], "ko": ["vaca_derrota", 0, 0],
		"sick_tint": true, "ko_time": 0.9, "lunge": 170.0, "shadow": 65.0,
	},
	"rato": {
		"health": 3, "speed": 125.0, "reach": 100.0, "damage": 12.0, "cooldown": 1.1, "hit_frame": 1,
		"run": ["rato_andando", 0, 2], "attack": ["rato_rabada", 0, 2], "idle": ["rato_andando", 0, 0],
		"hurt": ["rato_dano", 0, 0], "sick": ["rato_dano", 1, 1], "ko": ["rato_derrota", 0, 0],
		"sick_tint": true, "ko_time": 0.9, "shadow": 55.0,
	},
	# Fase 4.
	"caranguejo": {
		"health": 3, "speed": 105.0, "reach": 105.0, "damage": 13.0, "cooldown": 1.1, "hit_frame": 2,
		"run": ["caranguejo_andando", 0, 2], "attack": ["caranguejo_ataque", 0, 2], "idle": ["caranguejo_andando", 0, 0],
		"hurt": ["caranguejo_dano", 0, 0], "sick": ["caranguejo_dano", 1, 1], "ko": ["caranguejo_derrota", 0, 0],
		"sick_tint": true, "ko_time": 0.9, "shadow": 60.0,
	},
	"ermitao": {
		"health": 3, "speed": 75.0, "reach": 300.0, "damage": 10.0, "cooldown": 2.2, "hit_frame": 1,
		"run": ["ermitao_andando", 0, 2], "attack": ["ermitao_ataque", 0, 1], "idle": ["ermitao_andando", 0, 0],
		"hurt": ["ermitao_dano", 0, 0], "sick": ["ermitao_dano", 1, 1], "ko": ["ermitao_derrota", 0, 0],
		"sick_tint": true, "ko_time": 0.9, "shooter": true,
	},
	"lagosta": {
		"health": 4, "speed": 80.0, "reach": 150.0, "damage": 14.0, "cooldown": 1.5, "hit_frame": 1,
		"run": ["lagosta_andando", 0, 2], "attack": ["lagosta_ataque", 0, 1], "idle": ["lagosta_andando", 0, 0],
		"hurt": ["lagosta_dano", 0, 0], "sick": ["lagosta_dano", 1, 1], "ko": ["lagosta_derrota", 0, 0],
		"ko_time": 0.9, "shadow": 60.0,
	},
	# Fase 5.
	"arara": {
		"health": 2, "speed": 140.0, "reach": 135.0, "damage": 10.0, "cooldown": 1.2, "hit_frame": 1,
		"run": ["arara_andando", 0, 2], "attack": ["arara_ataque", 0, 2], "idle": ["arara_andando", 0, 2],
		"hurt": ["arara_dano", 0, 0], "sick": ["arara_dano", 1, 1], "ko": ["arara_derrota", 0, 0],
		"sick_tint": true, "ko_time": 0.9, "hover": 45.0, "hover_moving": true,
	},
	"preguica": {
		"health": 5, "speed": 50.0, "reach": 120.0, "damage": 18.0, "cooldown": 1.6, "hit_frame": 1,
		"run": ["preguica_andando", 0, 2], "attack": ["preguica_ataque", 0, 2], "idle": ["preguica_andando", 0, 0],
		"hurt": ["preguica_dano", 0, 0], "sick": ["preguica_dano", 1, 1], "ko": ["preguica_derrota", 0, 0],
		"sick_tint": true, "ko_time": 0.9, "shadow": 60.0,
	},
	"hipopotamo": {
		"health": 6, "speed": 65.0, "reach": 150.0, "damage": 16.0, "cooldown": 1.7, "hit_frame": 1,
		"run": ["hipopotamo_andando", 0, 2], "attack": ["hipopotamo_ataque", 0, 2], "idle": ["hipopotamo_andando", 0, 0],
		"hurt": ["hipopotamo_dano", 0, 0], "sick": ["hipopotamo_dano", 1, 1], "ko": ["hipopotamo_derrota", 0, 0],
		"ko_time": 0.9, "shadow": 75.0,
	},
}
# Motoqueiro: segundos de aviso antes de passar, altura do pulo que escapa dele e
# distância em que ele empina a moto.
const RIDER_WARN_TIME := 1.3
const RIDER_REACH_HEIGHT := 45.0
const RIDER_WHEELIE_DISTANCE := 260.0
const ENEMY_LANE_SPEED := 0.45
const ENEMY_KO_TIME := 0.5
const FONT_COLOR := Color("#263550")

# História de abertura: a cena N usa art/historia_N.jpg (e o fundo desfocado
# art/historia_N_fundo.jpg), geradas de images/H_N.jpeg por tools/build_historia.py.
const STORY_TEXTS := [
	"Era uma vez um menino muito inteligente chamado Arthur. Ele morava em Campinas com o papai e a mamãe. Todo dia, às 6 horas, ele pulava da cama!",
	"E corria para ver desenho na TV, com o papai e a mamãe pertinho.",
	"Depois, ia para a casa da vovó Orlene. E quem vinha correndo, abanando o rabo? A Dorothy, sua cachorrinha!",
	"Arthur e Dorothy saíam para passear juntinhos, todos os dias.",
	"O Arthur também adorava ir para a escola. Ele estudava muito e sabia tudo!",
	"À noite, a família comia espetinho. Hummm, que delícia!",
	"E antes de dormir, a mamãe lia uma historinha… até o Arthur fechar os olhinhos.",
	"Mas, numa noite, enquanto o Arthur dormia… vush! A bruxa da praça entrou voando e levou o Arthur na vassoura!",
	"Ela voou para bem longe, até a sua casa torta, lá em cima de uma árvore.",
	"Lá, ela trancou o Arthur numa sala mágica, cheia de coisas assustadoras.",
	"O Arthur chorou muito. Ele só pensava na mamãe, no papai, nas vovós, no vovô e na Dorothy.",
	"Mas o Arthur era muito esperto! Ele pensou, pensou… e resolveu o problema mais difícil do mundo. Clique, clique! Todas as portas se abriram!",
	"Ele fugiu de mansinho, bem quietinho… mas a bruxa viu!",
	"Furiosa, ela fez uma mágica e transformou os bichos e as pessoas em monstros!",
	"E, com outra mágica… zuuum! O Arthur caiu num redemoinho de estrelas.",
	"Enquanto isso, a bruxa prendeu a mamãe, o papai, as vovós e o vovô com correntes. E os monstros ficaram de guarda!",
	"Mas antes de fugir, o Arthur tinha tomado uma poção mágica… e ganhou superpoderes!",
	"Ploft! O redemoinho jogou o Arthur num lugar estranho, bem longe de casa.",
	"Lá longe, a Dorothy sentiu o cheirinho do Arthur e correu, correu, correu!",
	"Agora, Arthur e Dorothy estão juntos de novo. Uma grande aventura espera por eles. Vamos salvar a família?",
]
# Tempo de cada cena: STORY_BASE_TIME + uma letra a cada 1/STORY_READ_SPEED s (leitura devagar).
const STORY_BASE_TIME := 4.0
const STORY_READ_SPEED := 9.0
const STORY_FADE_TIME := 1.0
const STORY_TEXT_RISE_TIME := 1.6
const STORY_ZOOM := 0.1

# HUD com imagens (hud_*.png). Medidas em pixels das folhas (o dobro da tela),
# medidas em art/hud_barra.png e art/hud_comandos.png.
const HUD_SCALE := 0.5
const HUD_BAR_FILL := Rect2(166.0, 63.0, 432.0, 88.0)
const HUD_SUN_CENTER := Vector2(95.0, 97.0)
const HUD_SLOT_CENTERS := [120.0, 224.0, 328.0, 432.5, 537.5, 646.5]
const HUD_SLOT_Y := 89.0
const HUD_SLOT_SIZE := 78.0
# Ícone de cada espaço (quadro de hud_icones): soco, chute, defesa, espetinho, pum, Doroth.
const HUD_SLOTS := [
	{"icon": 0, "key": "J", "attack": "punch"},
	{"icon": 1, "key": "K", "attack": "kick"},
	{"icon": 2, "key": "L"},
	{"icon": 3, "key": "E", "power": "skewer"},
	{"icon": 4, "key": "Q", "power": "pum"},
	{"icon": 5, "key": "", "power": "doroth"},
]
# Rostos do Arthur (quadros de hud_arthur).
enum Face { HAPPY, OK, WORRIED, OUCH, DIZZY, TIRED }

var player_x := 120.0
var player_lane := 0.0
## Altura dos pés do Arthur acima do chão (0 no chão, BENCH_HEIGHT em cima do banco).
var jump_height := 0.0
var jump_velocity := 0.0
var on_ground := true
var land_time := 0.0
var energy := 100.0
var invulnerability := 0.0
var hurt_time := 0.0
var attack_cooldown := 0.0
var attack_time := 0.0
var attack_kind := "punch"
var blocking := false
var block_time := 0.0
var block_flash := 0.0
var mud_timer := 0.0
var wave_index := 0
var enemies: Array[Dictionary] = []
var boss_active := false
var boss_state := "entrance"
var boss_state_time := 0.0
var phase_index := 0
var background_sequence: Array = []
var waves: Array = []
var boss: Dictionary = BOSSES["bruxa"]
var boss_x := BOSS_START
var boss_lane := BOSS_START_LANE
var boss_health := 0
var boss_stun := 0.0
var boss_sick := false
var boss_facing := -1.0
var boss_cooldown := 0.0
var boss_summons := 0
var boss_action_done := false
var boss_lift := 0.0
var projectiles: Array[Dictionary] = []
var game_won := false
## Tela de escolha de fase (no começo do jogo e com ESC).
var choosing_phase := true
var menu_index := 0
# Opção "História" do menu de fases (antes da fase 1).
const MENU_STORY := -1
var watching_story := false
var story_index := 0
var story_time := 0.0
var story_previous := -1
var story_textures := {}
var menu_stick_dir := 0
var level_time := 0.0
var obstacles: Array[Dictionary] = []
var powers: Array = []
var facing := 1.0
var walking := false
var walk_time := 0.0
var run_time := 0.0
var anims := {}
var backgrounds := {}


func _ready() -> void:
	get_window().title = "Arthur: Caminho de Volta — Protótipo"
	_load_anims()
	for script in POWER_SCRIPTS:
		powers.append(script.new())
	for phase in PHASES:
		for bg_name in phase["backgrounds"] + [phase["arena"]]:
			var path := "res://art/%s.jpg" % bg_name
			if not backgrounds.has(bg_name) and ResourceLoader.exists(path):
				backgrounds[bg_name] = load(path)
	# O jogo começa na tela de escolha de fase. "-- --fase=2" na linha de comando
	# (ou nos argumentos do projeto) pula a escolha e começa direto na fase.
	var first_phase := -1
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--fase="):
			first_phase = clampi(int(arg.trim_prefix("--fase=")) - 1, 0, PHASES.size() - 1)
	start_phase(maxi(first_phase, 0))
	choosing_phase = first_phase < 0
	if choosing_phase:
		menu_index = MENU_STORY
	if "--historia" in OS.get_cmdline_user_args():
		start_story()


## Começa a fase `index` (0 = primeira) do início.
func start_phase(index: int) -> void:
	phase_index = index
	menu_index = index
	choosing_phase = false
	var phase: Dictionary = PHASES[index]
	waves = phase["waves"]
	boss = BOSSES[phase["boss"]]
	background_sequence = _make_background_sequence(phase)
	_restart()


## Imagens de fundo da fase, da primeira tela até a arena.
func _make_background_sequence(phase: Dictionary) -> Array:
	var choices: Array = phase["backgrounds"]
	var sequence: Array = []
	for index in range(BG_COUNT - 1):
		var bg_name: String = choices[index % choices.size()]
		if phase["random"]:
			var options := choices.filter(func(c): return sequence.is_empty() or c != sequence[-1])
			bg_name = options[randi() % options.size()]
		sequence.append(bg_name)
	sequence.append(phase["arena"])
	return sequence


## Bancos e cocôs alternados pela fase toda (menos a arena da bruxa).
func _build_obstacles() -> void:
	obstacles.clear()
	var x := OBSTACLE_START
	var index := 0
	while x < ARENA_START - 250.0:
		var lane: float = OBSTACLE_LANES[index % OBSTACLE_LANES.size()]
		obstacles.append({"kind": "coco" if index % 2 == 0 else "banco", "x": x, "lane": lane, "squashed_at": -1.0})
		x += OBSTACLE_SPACING
		index += 1


func _load_anims() -> void:
	var file := FileAccess.open(SPRITE_MANIFEST, FileAccess.READ)
	if file == null:
		return
	var manifest = JSON.parse_string(file.get_as_text())
	if not (manifest is Dictionary):
		return
	for anim_name in ANIM_SPEED:
		var info = manifest.get(anim_name)
		if info == null:
			continue
		var feet := Vector2(float(info["feet"][0]), float(info["feet"][1]))
		anims[anim_name] = SpriteAnim.new("res://art/%s.png" % anim_name, int(info["frames"]), ANIM_SPEED[anim_name], feet)


func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
		if event.pressed:
			_pad_button(event as InputEventJoypadButton)
		return
	if event is InputEventJoypadMotion:
		_pad_motion(event as InputEventJoypadMotion)
		return
	if not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	if watching_story:
		_story_input(key_event.keycode)
		return
	if choosing_phase:
		_menu_input(key_event.keycode)
		return
	var action := ""
	match key_event.keycode:
		KEY_ESCAPE:
			action = "menu"
		KEY_ENTER, KEY_KP_ENTER:
			action = "confirm"
		KEY_SPACE:
			action = "jump"
		KEY_J:
			action = "punch"
		KEY_K:
			action = "kick"
		_:
			for power in powers:
				if power.keycode != KEY_NONE and key_event.keycode == power.keycode:
					action = "power:" + power.id
	_game_action(action)


## Uma ação do jogo, venha do teclado ou do controle.
func _game_action(action: String) -> void:
	if action == "menu":
		open_phase_menu()
		return
	if game_won:
		if action == "confirm":
			start_phase((phase_index + 1) % PHASES.size())
		return
	if _movement_locked():
		return
	match action:
		"jump":
			if on_ground:
				jump_velocity = JUMP_SPEED
				on_ground = false
		"punch":
			_attack("punch")
		"kick":
			_attack("kick")
		_:
			if action.begins_with("power:"):
				var power = _power(action.substr(6))
				if power != null:
					power.try_activate(self)


## Botão do controle apertado: no menu navega, no jogo vira ação (veja PAD_BUTTONS).
func _pad_button(event: InputEventJoypadButton) -> void:
	if PAD_DEBUG:
		print("Controle %d (%s): botão %d" % [event.device, Input.get_joy_name(event.device), event.button_index])
	var action := ""
	for name in PAD_BUTTONS:
		if int(PAD_BUTTONS[name]) == int(event.button_index):
			action = name
	if watching_story:
		match event.button_index:
			JOY_BUTTON_DPAD_LEFT:
				_story_input(KEY_LEFT)
			JOY_BUTTON_DPAD_RIGHT:
				_story_input(KEY_RIGHT)
		if action == "confirm" or action == "jump":
			_story_input(KEY_ENTER)
		elif action == "menu":
			_story_input(KEY_ESCAPE)
		return
	if choosing_phase:
		match event.button_index:
			JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_UP:
				_menu_input(KEY_LEFT)
			JOY_BUTTON_DPAD_RIGHT, JOY_BUTTON_DPAD_DOWN:
				_menu_input(KEY_RIGHT)
		if action == "confirm" or action == "jump":
			_menu_input(KEY_ENTER)
		return
	if game_won and action == "jump":
		action = "confirm"
	_game_action(action)


## Analógico esquerdo no menu: cada empurrada para o lado troca uma fase.
func _pad_motion(event: InputEventJoypadMotion) -> void:
	if PAD_DEBUG and absf(event.axis_value) > 0.5:
		print("Controle %d: eixo %d = %.2f" % [event.device, event.axis, event.axis_value])
	if not choosing_phase or event.axis != JOY_AXIS_LEFT_X:
		return
	var direction := 0
	if event.axis_value > 0.6:
		direction = 1
	elif event.axis_value < -0.6:
		direction = -1
	if direction != 0 and direction != menu_stick_dir:
		_menu_input(KEY_RIGHT if direction > 0 else KEY_LEFT)
	menu_stick_dir = direction


## Algum controle conectado está com este botão apertado?
func _pad_pressed(button: int) -> bool:
	for device in Input.get_connected_joypads():
		if Input.is_joy_button_pressed(device, button):
			return true
	return false


## Direção do direcional ou do analógico esquerdo (cada eixo -1, 0 ou 1).
func _pad_direction() -> Vector2:
	var direction := Vector2.ZERO
	for device in Input.get_connected_joypads():
		var stick := Vector2(Input.get_joy_axis(device, JOY_AXIS_LEFT_X), Input.get_joy_axis(device, JOY_AXIS_LEFT_Y))
		if absf(stick.x) > PAD_DEADZONE:
			direction.x += signf(stick.x)
		if absf(stick.y) > PAD_DEADZONE:
			direction.y += signf(stick.y)
		if Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_RIGHT):
			direction.x += 1.0
		if Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_LEFT):
			direction.x -= 1.0
		if Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_DOWN):
			direction.y += 1.0
		if Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_UP):
			direction.y -= 1.0
	return Vector2(clampf(direction.x, -1.0, 1.0), clampf(direction.y, -1.0, 1.0))


## Defesa pelo controle: o botão de defesa ou o gatilho esquerdo.
func _pad_blocking() -> bool:
	if _pad_pressed(int(PAD_BUTTONS["block"])):
		return true
	for device in Input.get_connected_joypads():
		if Input.get_joy_axis(device, JOY_AXIS_TRIGGER_LEFT) > 0.5:
			return true
	return false


## Volta para a tela de escolha de fase.
func open_phase_menu() -> void:
	choosing_phase = true
	menu_index = phase_index


## Setas (ou A/D) escolhem a fase (ou a história), 1 a 9 vão direto para a fase,
## 0 ou H abrem a história, ENTER começa.
func _menu_input(keycode: Key) -> void:
	var options := PHASES.size() + 1
	match keycode:
		KEY_LEFT, KEY_A, KEY_UP, KEY_W:
			menu_index = posmod(menu_index - MENU_STORY - 1, options) + MENU_STORY
		KEY_RIGHT, KEY_D, KEY_DOWN, KEY_S:
			menu_index = posmod(menu_index - MENU_STORY + 1, options) + MENU_STORY
		KEY_ENTER, KEY_SPACE, KEY_KP_ENTER:
			if menu_index == MENU_STORY:
				start_story()
			else:
				start_phase(menu_index)
		KEY_0, KEY_H:
			start_story()
		_:
			var number := int(keycode) - int(KEY_1)
			if number >= 0 and number < PHASES.size():
				start_phase(number)


## Começa a história de abertura na primeira cena.
func start_story() -> void:
	watching_story = true
	choosing_phase = true
	menu_index = MENU_STORY
	_go_to_story_scene(0)
	story_previous = -1


func _go_to_story_scene(index: int) -> void:
	story_previous = story_index
	story_index = clampi(index, 0, STORY_TEXTS.size() - 1)
	story_time = 0.0
	# Mantém na memória só as cenas vizinhas.
	for key in story_textures.keys():
		if absi(int(key) - story_index) > 1:
			story_textures.erase(key)


## Tempo de leitura da cena (o texto mais longo fica mais tempo).
func story_scene_time(index: int) -> float:
	return STORY_BASE_TIME + String(STORY_TEXTS[index]).length() / STORY_READ_SPEED


## ENTER/ESPAÇO/→ próxima cena (na última, começa a fase 1), ← volta, ESC sai para o menu.
func _story_input(keycode: Key) -> void:
	match keycode:
		KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_RIGHT, KEY_D:
			if story_index == STORY_TEXTS.size() - 1:
				watching_story = false
				start_phase(0)
			else:
				_go_to_story_scene(story_index + 1)
		KEY_LEFT, KEY_A:
			if story_index > 0:
				_go_to_story_scene(story_index - 1)
		KEY_ESCAPE:
			watching_story = false
			choosing_phase = true
			menu_index = MENU_STORY


func _update_story(delta: float) -> void:
	story_time += delta
	if story_time >= story_scene_time(story_index) and story_index < STORY_TEXTS.size() - 1:
		_go_to_story_scene(story_index + 1)


func _process(delta: float) -> void:
	if watching_story:
		_update_story(delta)
	if choosing_phase:
		walk_time += delta
		queue_redraw()
		return
	if game_won:
		walk_time += delta
		queue_redraw()
		return

	level_time += delta
	for power in powers:
		power.update(self, delta)
	invulnerability = maxf(0.0, invulnerability - delta)
	hurt_time = maxf(0.0, hurt_time - delta)
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	attack_time = maxf(0.0, attack_time - delta)
	block_flash = maxf(0.0, block_flash - delta)
	mud_timer = maxf(0.0, mud_timer - delta)
	land_time = maxf(0.0, land_time - delta)

	blocking = (Input.is_key_pressed(KEY_L) or Input.is_key_pressed(KEY_SHIFT) or _pad_blocking()) and on_ground

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
	var pad := _pad_direction()
	horizontal = clampf(horizontal + pad.x, -1.0, 1.0)
	vertical = clampf(vertical + pad.y, -1.0, 1.0)
	_control(horizontal, vertical, delta)

	_spawn_progress()
	_update_enemies(delta)
	_update_boss(delta)
	_update_projectiles(delta)
	queue_redraw()


## Movimento do Arthur a partir das direções apertadas (-1, 0 ou 1).
func _control(horizontal: float, vertical: float, delta: float) -> void:
	if _movement_locked():
		horizontal = 0.0
		vertical = 0.0
		blocking = false
	block_time = block_time + delta if blocking else 0.0

	if horizontal != 0.0 and not blocking:
		if horizontal != facing:
			run_time = 0.0
		facing = horizontal
	walking = (horizontal != 0.0 or vertical != 0.0) and on_ground
	walk_time = walk_time + delta if walking else 0.0
	run_time = run_time + delta if horizontal != 0.0 and not blocking else 0.0

	var speed_factor := _obstacle_speed_factor()
	if blocking:
		speed_factor *= BLOCK_SPEED_FACTOR
	elif is_running():
		speed_factor *= RUN_FACTOR
	_move_player(horizontal * PLAYER_SPEED * speed_factor * delta, vertical * LANE_SPEED * speed_factor * delta / 100.0)
	if boss_active:
		player_x = maxf(player_x, ARENA_START + 30.0)
	player_x = minf(player_x, LEVEL_END - 70.0)
	_update_jump(delta)


func is_running() -> bool:
	return run_time >= RUN_DELAY and on_ground


## Move o Arthur, sem deixá-lo atravessar bancos (a não ser por cima).
func _move_player(dx: float, dlane: float) -> void:
	var new_x := maxf(0.0, player_x + dx)
	if not _blocked_by_bench(new_x, player_lane):
		player_x = new_x
	var new_lane := clampf(player_lane + dlane, LANE_MIN, LANE_MAX)
	if not _blocked_by_bench(player_x, new_lane):
		player_lane = new_lane


## Pulo e gravidade. O "chão" é o assento do banco quando o Arthur está sobre ele.
func _update_jump(delta: float) -> void:
	var floor_height := _floor_height(player_x, player_lane)
	var was_on_ground := on_ground
	if jump_height > floor_height or jump_velocity > 0.0:
		jump_height += jump_velocity * delta
		jump_velocity -= GRAVITY * delta
		if jump_height <= floor_height and jump_velocity <= 0.0:
			jump_height = floor_height
			jump_velocity = 0.0
	else:
		jump_height = floor_height
		jump_velocity = 0.0
	on_ground = jump_velocity <= 0.0 and jump_height <= floor_height + 0.5
	if on_ground and not was_on_ground:
		land_time = LAND_TIME


func _spawn_progress() -> void:
	while wave_index < waves.size() and player_x >= wave_marker(wave_index):
		var spawn_x: float = wave_marker(wave_index) + 290.0
		var wave: Array = waves[wave_index]
		var riders := 0
		for slot in range(wave.size()):
			var lane := lerpf(LANE_MIN + 0.3, LANE_MAX - 0.3, (slot + 0.5) / wave.size())
			if ENEMY_TYPES[wave[slot]].has("rider"):
				# Motoqueiros: um de cada vez, vindo da direita.
				spawn_enemy(wave[slot], Vector2(get_camera_x() + BG_WIDTH + 150.0, player_lane))
				enemies[-1]["time"] = -riders * 1.6
				riders += 1
			else:
				spawn_enemy(wave[slot], Vector2(spawn_x + slot * 105.0, lane))
		wave_index += 1

	if player_x >= BOSS_TRIGGER_X and not boss_active:
		boss_active = true
		_set_boss_state("entrance")


## Posição x em que a onda `index` aparece.
func wave_marker(index: int) -> float:
	return WAVE_START + index * WAVE_SPACING


# --- Inimigos ---

## Cria um inimigo. `position` é Vector2(x no mundo, lane).
func spawn_enemy(type: String, position: Vector2) -> void:
	var info: Dictionary = ENEMY_TYPES[type]
	enemies.append({
		"type": type, "pos": position, "health": int(info["health"]),
		"state": "warn" if info.has("rider") else ("spawn" if info.has("spawn") else "chase"), "time": 0.0,
		"stun": 0.0, "sick": false, "hit": 0.0, "cooldown": 0.0, "struck": false,
		"facing": -1.0, "anim_time": 0.0,
	})


## Inimigos que ainda lutam (sem contar os que estão saindo nocauteados).
func active_enemy_count() -> int:
	var count := 0
	for enemy in enemies:
		if enemy["state"] != "ko":
			count += 1
	return count


func _enemy_anim_duration(info: Dictionary, key: String) -> float:
	var spec: Array = info[key]
	return (int(spec[2]) - int(spec[1]) + 1) * float(ANIM_SPEED[spec[0]])


func _update_enemies(delta: float) -> void:
	for index in range(enemies.size() - 1, -1, -1):
		var enemy: Dictionary = enemies[index]
		var info: Dictionary = ENEMY_TYPES[enemy["type"]]
		var position: Vector2 = enemy["pos"]
		enemy["time"] = float(enemy["time"]) + delta
		enemy["anim_time"] = float(enemy["anim_time"]) + delta
		enemy["hit"] = maxf(0.0, float(enemy["hit"]) - delta)
		enemy["cooldown"] = maxf(0.0, float(enemy["cooldown"]) - delta)
		var dx := player_x - position.x
		var dlane := player_lane - position.y

		if info.has("rider") and enemy["state"] != "ko":
			if _update_rider(enemy, info, delta):
				enemies[index] = enemy
			else:
				enemies.remove_at(index)
			continue

		match enemy["state"]:
			"ko":
				if not info.has("ko"):
					position.x += float(enemy["facing"]) * -260.0 * delta
				if float(enemy["time"]) >= float(info.get("ko_time", ENEMY_KO_TIME)):
					enemies.remove_at(index)
					continue
			"spawn":
				if float(enemy["time"]) >= _enemy_anim_duration(info, "spawn"):
					_set_enemy_state(enemy, "chase")
			"stunned":
				enemy["stun"] = float(enemy["stun"]) - delta
				if float(enemy["stun"]) <= 0.0:
					enemy["sick"] = false
					_set_enemy_state(enemy, "chase")
			"attack":
				var hit_time := int(info["hit_frame"]) * float(ANIM_SPEED[info["attack"][0]])
				if info.has("lunge") and float(enemy["time"]) < hit_time and absf(dx) > 40.0:
					position.x += float(enemy["facing"]) * float(info["lunge"]) * delta
				if not enemy["struck"] and float(enemy["time"]) >= hit_time and info.has("shooter"):
					enemy["struck"] = true
					projectiles.append({
						"kind": "spike", "x": position.x + float(enemy["facing"]) * 40.0, "lane": position.y,
						"vx": float(enemy["facing"]) * SPIKE_SPEED, "vlane": 0.0, "life": 2.0, "age": 0.0,
						"damage": info["damage"],
					})
				elif not enemy["struck"] and float(enemy["time"]) >= hit_time:
					enemy["struck"] = true
					if absf(dx) < float(info["reach"]) + 20.0 and absf(dlane) < 0.4 and jump_height < ENEMY_REACH_HEIGHT and invulnerability <= 0.0:
						if blocking:
							position.x -= signf(dx) * BLOCK_PUSHBACK
						_take_hit(float(info["damage"]))
				if float(enemy["time"]) >= _enemy_anim_duration(info, "attack"):
					enemy["cooldown"] = info["cooldown"]
					_set_enemy_state(enemy, "chase")
			_:
				if absf(dx) < 430.0:
					if absf(dx) > 4.0:
						enemy["facing"] = signf(dx)
					var close := absf(dx) < float(info["reach"])
					if not close:
						position.x += signf(dx) * float(info["speed"]) * delta
					position.y = move_toward(position.y, player_lane, ENEMY_LANE_SPEED * delta)
					if close and absf(dlane) < 0.3 and float(enemy["cooldown"]) <= 0.0:
						_set_enemy_state(enemy, "attack")
					else:
						enemy["state"] = "idle" if close else "chase"
		enemy["pos"] = position
		enemies[index] = enemy


## Motoqueiro: avisa, atravessa a tela na faixa do Arthur e vai embora.
## Retorna false quando ele já saiu da tela.
func _update_rider(enemy: Dictionary, info: Dictionary, delta: float) -> bool:
	var position: Vector2 = enemy["pos"]
	match enemy["state"]:
		"warn":
			# Durante o aviso, acompanha a faixa do Arthur; depois a faixa fica fixa.
			position.x = get_camera_x() + BG_WIDTH + 150.0
			position.y = player_lane
			if float(enemy["time"]) >= RIDER_WARN_TIME:
				_set_enemy_state(enemy, "chase")
		"stunned":
			# Pum ou latido: cai da moto.
			_knock_out(enemy)
		_:
			position.x += float(enemy["facing"]) * float(info["speed"]) * delta
			var hits := absf(player_x - position.x) < float(info["reach"]) and absf(player_lane - position.y) < 0.3
			if hits and not enemy["struck"] and jump_height < RIDER_REACH_HEIGHT and invulnerability <= 0.0:
				enemy["struck"] = true
				_take_hit(float(info["damage"]))
			if position.x < get_camera_x() - 250.0:
				return false
	enemy["pos"] = position
	return true


func _set_enemy_state(enemy: Dictionary, state: String) -> void:
	enemy["state"] = state
	enemy["time"] = 0.0
	enemy["struck"] = false


## Arthur bate: J soco (o inimigo mais perto à frente), K chute giratório (todos em volta).
func _attack(kind: String) -> void:
	if attack_cooldown > 0.0 or blocking or game_won:
		return
	var attack: Dictionary = ATTACKS[kind]
	attack_kind = kind
	attack_cooldown = attack["cooldown"]
	attack_time = attack["duration"]
	var reach: float = attack["range"]
	var hit_any := false
	for index in range(enemies.size() - 1, -1, -1):
		var enemy: Dictionary = enemies[index]
		if enemy["state"] == "ko" or enemy["state"] == "spawn" or enemy["state"] == "warn":
			continue
		var position: Vector2 = enemy["pos"]
		var dx := position.x - player_x
		var in_front := signf(dx) == facing or absf(dx) < 12.0
		if absf(dx) < reach and absf(position.y - player_lane) < 0.65 and (in_front or attack["both_sides"]):
			_hit_enemy(enemy, float(attack["push"]))
			enemies[index] = enemy
			hit_any = true
			if not attack["both_sides"]:
				break
	if hit_any and not attack["both_sides"]:
		return
	if boss_is_fighting() and boss_state != "entrance" and absf(boss_x - player_x) < reach + 30.0 and absf(boss_lane - player_lane) < 0.7:
		damage_boss(1, 0.35)


func _hit_enemy(enemy: Dictionary, push: float) -> void:
	var position: Vector2 = enemy["pos"]
	enemy["health"] = int(enemy["health"]) - 1
	enemy["hit"] = 0.2
	position.x += _away_from_player(position.x) * push
	enemy["pos"] = position
	if int(enemy["health"]) <= 0:
		_knock_out(enemy)
	else:
		enemy["stun"] = 0.45
		enemy["sick"] = false
		_set_enemy_state(enemy, "stunned")


func _knock_out(enemy: Dictionary) -> void:
	var position: Vector2 = enemy["pos"]
	if not ENEMY_TYPES[enemy["type"]].has("rider"):
		enemy["facing"] = 1.0 if player_x >= position.x else -1.0
	_set_enemy_state(enemy, "ko")


func _take_hit(amount: float) -> void:
	if invulnerability > 0.0:
		return
	if blocking:
		amount *= BLOCK_DAMAGE_FACTOR
		block_flash = 0.35
	else:
		hurt_time = HURT_TIME
	energy = maxf(0.0, energy - amount)
	invulnerability = 0.85
	if energy <= 0.0:
		_power("doroth").try_activate(self)


func _away_from_player(x: float) -> float:
	return 1.0 if x >= player_x else -1.0


# --- Chefe ---

func _set_boss_state(state: String) -> void:
	boss_state = state
	boss_state_time = 0.0
	boss_action_done = false


func _boss_anim_duration(anim_name: String) -> float:
	var anim = get_anim(anim_name)
	if anim != null:
		return anim.duration()
	return ANIM_SPEED[anim_name] * 6.0


func _update_boss(delta: float) -> void:
	if not boss_active:
		return
	boss_state_time += delta
	boss_cooldown = maxf(0.0, boss_cooldown - delta)
	if boss_state == "defeat":
		if boss["flies_away"]:
			# Bruxa: tonta, perde o chapéu e foge voando na vassoura.
			if boss_state_time > 0.9:
				boss_x += 260.0 * delta
				boss_lift += 150.0 * delta
			if boss_state_time >= _boss_anim_duration(boss["defeat"]) + 0.3:
				game_won = true
		elif boss_state_time >= float(boss.get("defeat_time", 2.0)):
			game_won = true
		return
	if boss_state == "entrance":
		if boss["entrance"] != "":
			if boss_state_time >= _boss_anim_duration(boss["entrance"]):
				_set_boss_state("walk")
				boss_cooldown = 0.8
		else:
			# Entra andando pela direita até o lugar de começo.
			boss_facing = -1.0
			boss_x = move_toward(boss_x, BOSS_START, float(boss["speed"]) * 2.5 * delta)
			if boss_x <= BOSS_START:
				_set_boss_state("walk")
				boss_cooldown = 0.8
		return
	if boss_stun > 0.0:
		boss_stun = maxf(0.0, boss_stun - delta)
		if boss_state != "walk":
			_set_boss_state("walk")
		return
	boss_sick = false

	var dx := player_x - boss_x
	var distance := absf(dx)
	if absf(dx) > 6.0 and boss_state == "walk":
		boss_facing = signf(dx)
	match boss_state:
		"melee":
			if not boss_action_done and boss_state_time >= float(boss["melee_at"]):
				boss_action_done = true
				if distance < float(boss["melee_range"]) + 20.0 and absf(player_lane - boss_lane) < 0.55 and jump_height < BOSS_REACH_HEIGHT and invulnerability <= 0.0:
					if blocking:
						player_x += boss_facing * BLOCK_PUSHBACK * 0.5
					_take_hit(float(boss["melee_damage"]))
			if boss_state_time >= _boss_anim_duration(boss["melee"]):
				_finish_boss_action()
		"ranged":
			if not boss_action_done and boss_state_time >= float(boss["ranged_at"]):
				boss_action_done = true
				_cast_projectile()
			if boss_state_time >= _boss_anim_duration(boss["ranged"]):
				_finish_boss_action()
		"summon":
			if not boss_action_done and boss_state_time >= float(boss["summon_time"]):
				boss_action_done = true
				var spot := clampf(boss_x + boss_facing * 110.0, ARENA_START + 60.0, LEVEL_END - 60.0)
				spawn_enemy(boss["helper"], Vector2(spot, clampf(boss_lane + 0.4, LANE_MIN, LANE_MAX)))
			if boss_state_time >= _boss_anim_duration(boss["summon"]):
				_finish_boss_action()
		_:
			var summon_at: Array = boss["summon_at"]
			if boss_summons < summon_at.size() and boss_health <= int(summon_at[boss_summons]):
				boss_summons += 1
				_set_boss_state("summon")
			elif boss_cooldown <= 0.0 and distance < float(boss["melee_range"]) and absf(player_lane - boss_lane) < 0.45:
				_set_boss_state("melee")
			elif boss_cooldown <= 0.0 and distance > float(boss["ranged_min_distance"]):
				_set_boss_state("ranged")
			else:
				boss_x = move_toward(boss_x, player_x - boss_facing * 90.0, float(boss["speed"]) * delta)
				boss_lane = move_toward(boss_lane, player_lane, 0.55 * delta)
				boss_x = clampf(boss_x, ARENA_START + 50.0, LEVEL_END - 50.0)


func _finish_boss_action() -> void:
	boss_cooldown = boss["cooldown"]
	_set_boss_state("walk")


## Projétil do chefe (magia ou xingamento): vai até onde o Arthur está (pule para desviar).
func _cast_projectile() -> void:
	var start := Vector2(boss_x + boss_facing * 70.0, boss_lane)
	var travel := maxf(absf(player_x - start.x), 1.0)
	var flight_time := travel / MAGIC_SPEED
	projectiles.append({
		"kind": boss["projectile"], "x": start.x, "lane": start.y, "vx": boss_facing * MAGIC_SPEED,
		"vlane": (player_lane - start.y) / flight_time, "life": flight_time + 1.2, "age": 0.0,
	})


func _update_projectiles(delta: float) -> void:
	for index in range(projectiles.size() - 1, -1, -1):
		var shot: Dictionary = projectiles[index]
		shot["x"] = float(shot["x"]) + float(shot["vx"]) * delta
		shot["lane"] = clampf(float(shot["lane"]) + float(shot["vlane"]) * delta, LANE_MIN, LANE_MAX)
		shot["life"] = float(shot["life"]) - delta
		shot["age"] = float(shot["age"]) + delta
		var hits := absf(float(shot["x"]) - player_x) < 30.0 and absf(float(shot["lane"]) - player_lane) < 0.3 and jump_height < MAGIC_REACH_HEIGHT
		if hits and invulnerability <= 0.0:
			_take_hit(float(shot.get("damage", MAGIC_DAMAGE)))
			projectiles.remove_at(index)
		elif float(shot["life"]) <= 0.0:
			projectiles.remove_at(index)
		else:
			projectiles[index] = shot


# --- Obstáculos ---

func _obstacle_speed_factor() -> float:
	if jump_height > 0.0:
		return 1.0
	for obstacle in obstacles:
		if obstacle["kind"] == "coco":
			if absf(player_x - float(obstacle["x"])) < COCO_HALF_WIDTH and absf(player_lane - float(obstacle["lane"])) < COCO_HALF_LANE:
				mud_timer = 0.45
				if float(obstacle["squashed_at"]) < 0.0:
					obstacle["squashed_at"] = level_time
				return COCO_SPEED_FACTOR
	return 1.0


## Banco cuja área (vista de cima) contém o ponto, ou {} se não houver.
func _bench_at(x: float, lane: float) -> Dictionary:
	for obstacle: Dictionary in obstacles:
		if obstacle["kind"] == "banco" and absf(x - float(obstacle["x"])) < BENCH_HALF_WIDTH and absf(lane - float(obstacle["lane"])) < BENCH_HALF_LANE:
			return obstacle
	return {}


func _floor_height(x: float, lane: float) -> float:
	return 0.0 if _bench_at(x, lane).is_empty() else BENCH_HEIGHT


## O banco bloqueia quem tenta entrar nele estando mais baixo que o assento.
func _blocked_by_bench(x: float, lane: float) -> bool:
	if _bench_at(x, lane).is_empty() or not _bench_at(player_x, player_lane).is_empty():
		return false
	return jump_height < BENCH_HEIGHT - 1.0


func _power(power_id: String):
	for power in powers:
		if power.id == power_id:
			return power
	return null


func _movement_locked() -> bool:
	for power in powers:
		if power.is_posing() and power.locks_movement:
			return true
	return false


func _restart() -> void:
	player_x = 120.0
	player_lane = 0.0
	jump_height = 0.0
	jump_velocity = 0.0
	on_ground = true
	land_time = 0.0
	energy = 100.0
	invulnerability = 0.0
	hurt_time = 0.0
	attack_cooldown = 0.0
	attack_time = 0.0
	blocking = false
	block_time = 0.0
	block_flash = 0.0
	mud_timer = 0.0
	facing = 1.0
	walking = false
	walk_time = 0.0
	run_time = 0.0
	wave_index = 0
	enemies.clear()
	projectiles.clear()
	boss_active = false
	boss_state = "entrance"
	boss_state_time = 0.0
	boss_x = BOSS_START if boss["entrance"] != "" else LEVEL_END + 120.0
	boss_lane = BOSS_START_LANE
	boss_health = int(boss["health"])
	boss_stun = 0.0
	boss_sick = false
	boss_facing = -1.0
	boss_cooldown = 0.0
	boss_summons = 0
	boss_lift = 0.0
	game_won = false
	level_time = 0.0
	_build_obstacles()
	for power in powers:
		power.reset()


# --- API pública usada pelos poderes (res://powers/) ---

## O chefe está na arena e ainda não foi derrotado.
func boss_is_fighting() -> bool:
	return boss_active and boss_health > 0


## Atordoa os inimigos. `sick` = enjoados (cara verde do pum).
func stun_enemies(seconds: float, sick := false) -> void:
	for index in range(enemies.size()):
		var enemy: Dictionary = enemies[index]
		if enemy["state"] == "ko" or enemy["state"] == "warn":
			continue
		enemy["stun"] = seconds
		enemy["sick"] = sick
		_set_enemy_state(enemy, "stunned")
		enemies[index] = enemy


## Todos os inimigos (e os projéteis do chefe) saem nocauteados.
func clear_enemies() -> void:
	for index in range(enemies.size()):
		var enemy: Dictionary = enemies[index]
		if enemy["state"] != "ko":
			_knock_out(enemy)
			enemies[index] = enemy
	projectiles.clear()


func stun_boss(seconds: float, sick := false) -> void:
	if boss_is_fighting() and boss_state != "entrance":
		boss_stun = maxf(boss_stun, seconds)
		boss_sick = sick


func damage_boss(amount: int, stun_seconds: float) -> void:
	if not boss_is_fighting() or boss_state == "entrance":
		return
	boss_health = maxi(0, boss_health - amount)
	boss_stun = maxf(boss_stun, stun_seconds)
	boss_sick = false
	if boss_health == 0:
		boss_stun = 0.0
		projectiles.clear()
		_set_boss_state("defeat")


func restore_energy() -> void:
	energy = 100.0


func set_energy(value: float) -> void:
	energy = clampf(value, 0.0, 100.0)


func set_invulnerable(seconds: float) -> void:
	invulnerability = seconds


## Câmera segue o Arthur, para no fim da fase e fica travada na arena da bruxa.
func get_camera_x() -> float:
	if boss_active:
		return ARENA_START
	return clampf(player_x - PLAYER_SCREEN_X, 0.0, ARENA_START)


## Limites de profundidade do chão: Vector2(mínimo, máximo).
func lane_limits() -> Vector2:
	return Vector2(LANE_MIN, LANE_MAX)


## Animação carregada pelo nome (veja ANIM_SPEED), ou null se o arquivo não existe.
func get_anim(anim_name: String):
	var anim = anims.get(anim_name)
	if anim != null and anim.is_loaded():
		return anim
	return null


func lane_y(lane: float) -> float:
	return GROUND_Y + lane * LANE_PIXELS


func draw_oval(center: Vector2, radii: Vector2, color: Color) -> void:
	draw_set_transform(center, 0.0, radii / 10.0)
	draw_circle(Vector2.ZERO, 10.0, color)
	draw_set_transform(Vector2.ZERO)


# --- Desenho ---

func _draw() -> void:
	var viewport := get_viewport_rect().size
	if watching_story:
		_draw_story(viewport)
		return
	if choosing_phase:
		_draw_phase_menu(viewport)
		return
	var camera_x := get_camera_x()
	_draw_background(viewport, camera_x)

	# Bancos, cocôs e personagens: ordenados pela profundidade (y dos pés), de trás para frente.
	var layers: Array = []
	for obstacle in obstacles:
		var obstacle_x := float(obstacle["x"]) - camera_x
		if obstacle_x > -100.0 and obstacle_x < viewport.x + 100.0:
			var depth := lane_y(float(obstacle["lane"]))
			if obstacle["kind"] == "coco":
				depth -= 20.0
			layers.append([depth, obstacle["kind"], obstacle])
	for enemy in enemies:
		var position: Vector2 = enemy["pos"]
		layers.append([lane_y(position.y), "enemy", enemy])
	if boss_active:
		layers.append([lane_y(boss_lane), "boss", null])
	if PHASES[phase_index].has("captives") and CAPTIVES_X - camera_x < viewport.x + 200.0:
		layers.append([lane_y(CAPTIVES_LANE), "captives", null])
	for shot in projectiles:
		layers.append([lane_y(float(shot["lane"])) + 0.5, "magic", shot])
	layers.append([_player_depth(), "player", null])
	for power in powers:
		var depth: float = power.world_depth(self)
		if not is_nan(depth):
			layers.append([depth, "power", power])
	layers.sort_custom(func(a, b): return a[0] < b[0])

	var player_screen := Vector2(player_x - camera_x, lane_y(player_lane) - jump_height)
	for layer in layers:
		match layer[1]:
			"banco":
				_draw_bench(Vector2(float(layer[2]["x"]) - camera_x, lane_y(float(layer[2]["lane"]))))
			"coco":
				_draw_coco(Vector2(float(layer[2]["x"]) - camera_x, lane_y(float(layer[2]["lane"]))), layer[2])
			"enemy":
				var position: Vector2 = layer[2]["pos"]
				_draw_enemy(Vector2(position.x - camera_x, layer[0]), layer[2])
			"boss":
				_draw_boss(Vector2(boss_x - camera_x, layer[0]))
			"captives":
				_draw_captives(Vector2(CAPTIVES_X - camera_x, layer[0]))
			"magic":
				if layer[2]["kind"] == "curse":
					_draw_curse(Vector2(float(layer[2]["x"]) - camera_x, layer[0]), layer[2])
				elif layer[2]["kind"] == "rice":
					_draw_rice(Vector2(float(layer[2]["x"]) - camera_x, layer[0]), layer[2])
				elif layer[2]["kind"] == "star":
					_draw_star_shot(Vector2(float(layer[2]["x"]) - camera_x, layer[0]), layer[2])
				elif layer[2]["kind"] == "banana":
					_draw_banana(Vector2(float(layer[2]["x"]) - camera_x, layer[0]), layer[2])
				elif layer[2]["kind"] == "spike":
					_draw_spike(Vector2(float(layer[2]["x"]) - camera_x, layer[0]), layer[2])
				else:
					_draw_magic(Vector2(float(layer[2]["x"]) - camera_x, layer[0]), layer[2])
			"power":
				layer[2].draw_world(self, camera_x)
			"player":
				_draw_player_layer(player_screen)

	for power in powers:
		if power.is_active():
			power.draw(self, player_screen)

	_draw_hud(viewport)
	for power in powers:
		if power.is_active():
			power.draw_hud(self, viewport)
	if game_won:
		_draw_win_overlay(viewport)


## Profundidade do Arthur. Em cima de um banco (ou pulando sobre ele), fica na frente do banco.
func _player_depth() -> float:
	var depth := lane_y(player_lane)
	var bench := _bench_at(player_x, player_lane)
	if not bench.is_empty() and jump_height >= BENCH_HEIGHT - 1.0:
		depth = maxf(depth, lane_y(float(bench["lane"])) + 1.0)
	return depth


func _draw_player_layer(player_screen: Vector2) -> void:
	_draw_player(player_screen)
	if mud_timer > 0.0:
		_draw_mud_splash(Vector2(player_screen.x, lane_y(player_lane)))
	if blocking and block_flash > 0.0:
		_draw_shield(player_screen)


func _draw_background(viewport: Vector2, camera_x: float) -> void:
	if backgrounds.size() < 2:
		_draw_procedural_background(viewport, camera_x)
		return
	for index in range(background_sequence.size()):
		var texture: Texture2D = backgrounds.get(background_sequence[index])
		var left := index * BG_STEP - camera_x
		if texture == null or left > viewport.x or left + BG_WIDTH < 0.0:
			continue
		var source_scale := texture.get_width() / BG_WIDTH
		var faded := 0.0 if index == 0 else BG_OVERLAP
		# Faixa de transição: a imagem aparece aos poucos sobre a anterior.
		var slices := 32
		var slice_width := faded / slices
		for slice in range(slices if faded > 0.0 else 0):
			var alpha := (slice + 0.5) / slices
			alpha = alpha * alpha * (3.0 - 2.0 * alpha)
			draw_texture_rect_region(texture,
				Rect2(left + slice * slice_width, 0.0, slice_width + 0.5, viewport.y),
				Rect2(slice * slice_width * source_scale, 0.0, slice_width * source_scale, texture.get_height()),
				Color(1.0, 1.0, 1.0, alpha))
		draw_texture_rect_region(texture,
			Rect2(left + faded, 0.0, BG_WIDTH - faded, viewport.y),
			Rect2(faded * source_scale, 0.0, (BG_WIDTH - faded) * source_scale, texture.get_height()))


## Fundo desenhado com formas, usado se as imagens de art/ não existirem.
func _draw_procedural_background(viewport: Vector2, camera_x: float) -> void:
	draw_rect(Rect2(Vector2.ZERO, viewport), Color("#8be0ff"))
	draw_circle(Vector2(825.0, 82.0), 42.0, Color("#ffe577"))
	draw_rect(Rect2(0.0, 220.0, viewport.x, 100.0), Color("#7dca79"))
	draw_rect(Rect2(0.0, 315.0, viewport.x, viewport.y - 315.0), Color("#f6d590"))
	draw_rect(Rect2(0.0, 528.0, viewport.x, viewport.y - 528.0), Color("#72c65e"))

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

	draw_rect(Rect2(0.0, 308.0, viewport.x, 7.0), Color("#ffe9a8"))
	draw_string(ThemeDB.fallback_font, Vector2(18.0, 294.0), "PRACA DA BRUXA", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, Color("#477c5d"))


## Cocô: fedendo com moscas; depois que o Arthur pisa, fica amassado.
func _draw_coco(position: Vector2, obstacle: Dictionary) -> void:
	var anim = get_anim("coco")
	var squashed_at := float(obstacle["squashed_at"])
	if anim == null:
		draw_oval(position, Vector2(COCO_HALF_WIDTH, 10.0), Color("#7a4a2e"))
		if squashed_at < 0.0:
			draw_circle(position + Vector2(0.0, -12.0), 14.0, Color("#9c6440"))
		return
	var frame: int = anim.frame_at(level_time, true, 0, 2)
	if squashed_at >= 0.0:
		frame = anim.frame_at(level_time - squashed_at, false, 3, 5)
	anim.draw(self, frame, position + Vector2(0.0, 6.0), SPRITE_SCALE)


## Banco de praça. `center` é o centro da base no chão.
func _draw_bench(center: Vector2) -> void:
	var sprite = get_anim("banco")
	if sprite != null:
		var front := center + Vector2(0.0, BENCH_HALF_LANE * LANE_PIXELS)
		draw_oval(center + Vector2(0.0, 6.0), Vector2(BENCH_HALF_WIDTH + 6.0, 18.0), Color(0.22, 0.27, 0.31, 0.25))
		sprite.draw(self, 0, front, SPRITE_SCALE)
		return
	var w := BENCH_HALF_WIDTH
	var d := BENCH_HALF_LANE * LANE_PIXELS
	var h := BENCH_HEIGHT
	var iron := Color("#34406a")
	var wood := Color("#e0893f")
	var wood_dark := Color("#b8652a")
	var wood_light := Color("#f7ae62")
	draw_oval(center + Vector2(0.0, 4.0), Vector2(w + 10.0, d + 6.0), Color(0.22, 0.27, 0.31, 0.22))
	# Pés de trás e encosto.
	for side in [-1.0, 1.0]:
		draw_rect(Rect2(center.x + side * (w - 6.0) - 3.0, center.y - d - h - 40.0, 6.0, h + 40.0), iron)
	for plank in range(2):
		var plank_y := center.y - d - h - 38.0 + plank * 16.0
		draw_rect(Rect2(center.x - w - 4.0, plank_y, (w + 4.0) * 2.0, 11.0), wood)
		draw_rect(Rect2(center.x - w - 4.0, plank_y + 8.0, (w + 4.0) * 2.0, 3.0), wood_dark)
	# Assento (vista de cima) e borda da frente.
	draw_rect(Rect2(center.x - w, center.y - d - h, w * 2.0, d * 2.0), wood_light)
	for line in range(1, 3):
		draw_line(Vector2(center.x - w, center.y - d - h + line * d * 2.0 / 3.0), Vector2(center.x + w, center.y - d - h + line * d * 2.0 / 3.0), wood_dark, 2.0)
	draw_rect(Rect2(center.x - w, center.y + d - h, w * 2.0, 7.0), wood_dark)
	# Pés da frente.
	for side in [-1.0, 1.0]:
		draw_rect(Rect2(center.x + side * (w - 6.0) - 3.5, center.y + d - h + 7.0, 7.0, h - 7.0), iron)
		draw_rect(Rect2(center.x + side * (w - 6.0) - 7.0, center.y + d - 3.0, 14.0, 4.0), iron)


func _draw_mud_splash(feet: Vector2) -> void:
	var wobble := sin(Time.get_ticks_msec() * 0.02) * 4.0
	draw_circle(feet + Vector2(-22.0, -10.0 - wobble), 4.0, Color("#7a4a2e"))
	draw_circle(feet + Vector2(20.0, -14.0 + wobble), 5.0, Color("#9c6440"))
	draw_circle(feet + Vector2(-8.0, -20.0 + wobble), 3.0, Color("#7a4a2e"))
	draw_circle(feet + Vector2(10.0, -6.0 - wobble), 3.0, Color("#9c6440"))


## Brilho e "DEFESA!" quando um golpe acerta a defesa.
func _draw_shield(player_screen: Vector2) -> void:
	var center := player_screen + Vector2(40.0 * facing, -70.0)
	draw_circle(center, 18.0 * (1.0 + block_flash), Color(1.0, 0.95, 0.5, block_flash * 2.0))
	draw_string(ThemeDB.fallback_font, player_screen + Vector2(-30.0, -150.0), "DEFESA!", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 18, Color("#2c7fd6"))


func _draw_player(position: Vector2) -> void:
	if invulnerability > 0.0 and hurt_time <= 0.0 and int(Time.get_ticks_msec() / 100) % 2 == 0:
		return
	if get_anim("arthur_parado") != null:
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


## Animação e quadro do Arthur agora: [nome, quadro].
func player_frame() -> Array:
	for power in powers:
		var from_power: Array = power.player_frame(self)
		if not from_power.is_empty():
			return from_power
	if game_won:
		return ["arthur_comemora", get_anim("arthur_comemora").frame_at(walk_time)]
	if hurt_time > 0.0:
		return ["arthur_defesa", 3 + mini(2, int((HURT_TIME - hurt_time) / 0.15))]
	if blocking:
		return ["arthur_defesa", 2 if block_flash > 0.0 else (0 if block_time < 0.1 else 1)]
	if attack_time > 0.0:
		var attack: Dictionary = ATTACKS[attack_kind]
		var elapsed: float = float(attack["duration"]) - attack_time
		var step := mini(2, int(elapsed / (float(attack["duration"]) / 3.0)))
		return ["arthur_ataque", int(attack["first_frame"]) + step]
	if not on_ground:
		var frame := 4
		if jump_velocity > 250.0:
			frame = 1
		elif jump_velocity > 0.0:
			frame = 2
		elif jump_velocity > -250.0:
			frame = 3
		return ["arthur_pulo", frame]
	if land_time > 0.0:
		return ["arthur_pulo", 5]
	if walking:
		var walk_anim := "arthur_correndo" if is_running() else "arthur_andando"
		return [walk_anim, get_anim(walk_anim).frame_at(walk_time)]
	return ["arthur_parado", get_anim("arthur_parado").frame_at(Time.get_ticks_msec() / 1000.0)]


## Desenha o Arthur com as folhas de sprites.
func _draw_player_sprite(position: Vector2) -> void:
	# Sombra no chão ou no assento do banco.
	var floor_height := _floor_height(player_x, player_lane)
	var shadow_center := Vector2(position.x, lane_y(player_lane) - floor_height + 4.0)
	var shadow_size := clampf(1.0 - (jump_height - floor_height) / 220.0, 0.5, 1.0)
	draw_oval(shadow_center, Vector2(30.0, 8.0) * shadow_size, Color(0.22, 0.27, 0.31, 0.25))

	var current := player_frame()
	var anim = get_anim(current[0])
	if anim != null:
		var flip := facing
		# No quadro do chute a perna aponta para trás na folha: espelha para chutar para a frente.
		if current[0] == "arthur_ataque" and current[1] in KICK_MIRRORED_FRAMES:
			flip = -facing
		anim.draw(self, current[1], position, SPRITE_SCALE, flip)


## Animação e quadro de um inimigo: [nome, quadro].
func enemy_frame(enemy: Dictionary) -> Array:
	var info: Dictionary = ENEMY_TYPES[enemy["type"]]
	var t := float(enemy["time"])
	var key := "run"
	var loop := true
	match enemy["state"]:
		"spawn":
			key = "spawn"
			loop = false
		"attack":
			key = "attack"
			loop = false
		"stunned":
			key = "sick" if enemy["sick"] else "hurt"
		"ko":
			key = "ko" if info.has("ko") else "hurt"
			loop = false
		"idle":
			key = "idle"
		_:
			t = float(enemy["anim_time"])
			# Motoqueiro empina a moto perto do Arthur.
			if info.has("rider") and absf(player_x - Vector2(enemy["pos"]).x) < RIDER_WHEELIE_DISTANCE:
				key = "attack"
	var spec: Array = info[key]
	var anim = get_anim(spec[0])
	if anim == null:
		return [spec[0], -1]
	return [spec[0], anim.frame_at(t, loop, int(spec[1]), int(spec[2]))]


func _draw_enemy(position: Vector2, enemy: Dictionary) -> void:
	if enemy["state"] == "warn":
		_draw_rider_warning(position.y, float(enemy["time"]))
		return
	var info: Dictionary = ENEMY_TYPES[enemy["type"]]
	var current := enemy_frame(enemy)
	var anim = get_anim(current[0])
	if anim == null:
		_draw_enemy_shape(position, enemy["state"] == "stunned")
		return
	var knocked: bool = enemy["state"] == "ko"
	var fade := 1.0
	var spin := 0.0
	var lift := 0.0
	if knocked:
		var k := float(enemy["time"]) / float(info.get("ko_time", ENEMY_KO_TIME))
		if info.has("ko"):
			# Cai sentado e some aos poucos no fim.
			fade = clampf((1.0 - k) / 0.35, 0.0, 1.0)
		else:
			fade = 1.0 - k
			spin = -float(enemy["facing"]) * k * 2.5
			lift = sin(k * PI) * 60.0
	if not knocked and enemy["state"] != "spawn":
		draw_oval(position + Vector2(0.0, 3.0), Vector2(float(info.get("shadow", 40.0)), 9.0), Color(0.22, 0.27, 0.31, 0.22))
	var tint := Color(1.0, 1.0, 1.0, fade)
	if float(enemy["hit"]) > 0.0:
		tint = Color(2.2, 2.2, 2.2, fade)
	elif enemy["sick"] and enemy["state"] == "stunned" and info.get("sick_tint", false):
		tint = Color(0.65, 1.25, 0.55, fade)
	var hovering: bool = info.has("hover") and not knocked
	if info.get("hover_moving", false) and enemy["state"] != "chase" and enemy["state"] != "idle":
		hovering = false
	if hovering:
		lift += float(info["hover"]) + sin(float(enemy["anim_time"]) * 3.0) * 5.0
	anim.draw(self, current[1], position + Vector2(0.0, -lift), SPRITE_SCALE, float(enemy["facing"]), spin, Vector2.ONE, tint)


## Placa de aviso na borda direita, na faixa por onde o motoqueiro vai passar.
func _draw_rider_warning(screen_y: float, time: float) -> void:
	if time < 0.0:
		return
	var viewport := get_viewport_rect().size
	var center := Vector2(viewport.x - 34.0, screen_y - 40.0)
	var blink := int(time * 6.0) % 2 == 0
	draw_colored_polygon(PackedVector2Array([center + Vector2(0.0, -26.0), center + Vector2(25.0, 18.0), center + Vector2(-25.0, 18.0)]), Color("#263550"))
	draw_colored_polygon(PackedVector2Array([center + Vector2(0.0, -20.0), center + Vector2(19.0, 14.0), center + Vector2(-19.0, 14.0)]), Color("#ffd23f") if blink else Color("#ff8a3d"))
	draw_string(ThemeDB.fallback_font, center + Vector2(-4.0, 11.0), "!", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 22, Color("#263550"))
	var honk := "BIBI!"
	draw_string_outline(ThemeDB.fallback_font, center + Vector2(-70.0, -14.0), honk, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, 5, Color.WHITE)
	draw_string(ThemeDB.fallback_font, center + Vector2(-70.0, -14.0), honk, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, Color("#e0301e"))
	draw_oval(Vector2(viewport.x - 60.0, screen_y + 3.0), Vector2(60.0, 9.0), Color(1.0, 0.3, 0.2, 0.25 if blink else 0.12))


func _draw_enemy_shape(position: Vector2, stunned: bool) -> void:
	draw_oval(position + Vector2(0.0, 5.0), Vector2(24.0, 7.0), Color(0.22, 0.27, 0.31, 0.18))
	var body_color := Color("#a769d5")
	draw_circle(position + Vector2(0.0, -25.0), 22.0, body_color)
	draw_circle(position + Vector2(-7.0, -28.0), 4.0, Color.WHITE)
	draw_circle(position + Vector2(8.0, -28.0), 4.0, Color.WHITE)
	draw_circle(position + Vector2(-6.0, -28.0), 2.0, FONT_COLOR)
	draw_circle(position + Vector2(9.0, -28.0), 2.0, FONT_COLOR)
	if stunned:
		draw_string(ThemeDB.fallback_font, position + Vector2(-18.0, -58.0), "Z z", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, Color("#fff5a8"))


## Animação e quadro do chefe: [nome, quadro].
func boss_frame() -> Array:
	var t := boss_state_time
	match boss_state:
		"entrance":
			if boss["entrance"] != "":
				return [boss["entrance"], _frame_of(boss["entrance"], t, false)]
			return [boss["walk"], _frame_of(boss["walk"], t, true)]
		"defeat", "melee", "ranged", "summon":
			var anim_name: String = boss[boss_state]
			return [anim_name, _frame_of(anim_name, t, false)]
	if boss_stun > 0.0:
		var spec: Array = boss["sick"] if boss_sick else boss["hurt"]
		var anim = get_anim(spec[0])
		if anim == null:
			return [spec[0], -1]
		return [spec[0], anim.frame_at(t, true, int(spec[1]), int(spec[2]))]
	return [boss["walk"], _frame_of(boss["walk"], t, true)]


func _frame_of(anim_name: String, time: float, loop: bool) -> int:
	var anim = get_anim(anim_name)
	return -1 if anim == null else anim.frame_at(time, loop)


func _draw_boss(position: Vector2) -> void:
	var current := boss_frame()
	var anim = get_anim(current[0])
	draw_oval(position + Vector2(0.0, 5.0), Vector2(54.0, 12.0) * clampf(1.0 - boss_lift / 300.0, 0.3, 1.0), Color(0.22, 0.27, 0.31, 0.22))
	if anim == null:
		_draw_boss_shape(position, boss_stun > 0.0)
		return
	var flip := boss_facing
	if boss_state == "defeat" and boss["flies_away"] and boss_state_time > 0.9:
		flip = 1.0
	var tint := Color.WHITE
	if boss_stun > 0.0 and boss_sick and boss["sick_tint"]:
		tint = Color(0.65, 1.25, 0.55)
	anim.draw(self, current[1], position + Vector2(0.0, -boss_lift), SPRITE_SCALE, flip, 0.0, Vector2.ONE, tint)


func _draw_boss_shape(position: Vector2, stunned: bool) -> void:
	draw_colored_polygon(PackedVector2Array([
		position + Vector2(-42.0, -32.0),
		position + Vector2(-37.0, -105.0),
		position + Vector2(-22.0, -133.0),
		position + Vector2(0.0, -111.0),
		position + Vector2(24.0, -137.0),
		position + Vector2(42.0, -94.0),
		position + Vector2(48.0, -32.0)
	]), Color("#a14c9a"))
	draw_circle(position + Vector2(0.0, -116.0), 31.0, Color("#9be05a"))
	draw_circle(position + Vector2(-10.0, -116.0), 4.0, Color("#fff1ac"))
	draw_circle(position + Vector2(11.0, -116.0), 4.0, Color("#fff1ac"))
	if stunned:
		draw_string(ThemeDB.fallback_font, position + Vector2(-24.0, -162.0), "Z z", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 20, Color("#fff5a8"))


## Bola de magia verde girando, com sombra no chão.
func _draw_magic(ground: Vector2, shot: Dictionary) -> void:
	var age := float(shot["age"])
	var center := ground + Vector2(0.0, -MAGIC_HEIGHT * 0.5 - sin(age * 9.0) * 4.0)
	draw_oval(ground + Vector2(0.0, 3.0), Vector2(16.0, 5.0), Color(0.22, 0.27, 0.31, 0.25))
	draw_circle(center, 22.0, Color(0.45, 1.0, 0.3, 0.25))
	draw_circle(center, 15.0, Color("#5be33a"))
	draw_circle(center, 9.0, Color("#c8ff8a"))
	for i in range(3):
		var angle := age * 8.0 + i * TAU / 3.0
		draw_circle(center + Vector2(cos(angle), sin(angle)) * 18.0, 3.0, Color("#f6ff9e"))
	draw_circle(center - Vector2(float(shot["vx"]) * 0.06, 0.0), 7.0, Color(0.45, 1.0, 0.3, 0.4))


## Balão de xingamento do Praga: "#@$%!" voando e balançando, com sombra no chão.
func _draw_curse(ground: Vector2, shot: Dictionary) -> void:
	var age := float(shot["age"])
	var center := ground + Vector2(0.0, -MAGIC_HEIGHT * 0.55 - sin(age * 9.0) * 5.0)
	draw_oval(ground + Vector2(0.0, 3.0), Vector2(18.0, 5.0), Color(0.22, 0.27, 0.31, 0.25))
	var tail := -signf(float(shot["vx"]))
	draw_set_transform(center, sin(age * 14.0) * 0.12, Vector2.ONE)
	draw_colored_polygon(PackedVector2Array([Vector2(tail * 14.0, 12.0), Vector2(tail * 36.0, 28.0), Vector2(tail * 2.0, 17.0)]), Color("#263550"))
	draw_set_transform(center, sin(age * 14.0) * 0.12, Vector2(3.8, 2.2))
	draw_circle(Vector2.ZERO, 10.0, Color("#263550"))
	draw_circle(Vector2.ZERO, 9.2, Color("#fffbe8"))
	draw_set_transform(center, sin(age * 14.0) * 0.12, Vector2.ONE)
	var symbols := ["#", "@", "$", "%", "!", "&", "*"]
	var text := ""
	for i in range(4):
		text += symbols[(int(age * 8.0) + i * 3) % symbols.size()]
	draw_string(ThemeDB.fallback_font, Vector2(-25.0, 7.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 19, Color("#e0301e"))
	draw_set_transform(Vector2.ZERO)


## Bola de arroz envenenado da barata: verde brilhante, com grãos soltando atrás.
func _draw_rice(ground: Vector2, shot: Dictionary) -> void:
	var age := float(shot["age"])
	var center := ground + Vector2(0.0, -MAGIC_HEIGHT * 0.5 - sin(age * 9.0) * 4.0)
	var back := -signf(float(shot["vx"]))
	draw_oval(ground + Vector2(0.0, 3.0), Vector2(16.0, 5.0), Color(0.22, 0.27, 0.31, 0.25))
	for i in range(9):
		var k := float(i) / 9.0
		var grain := center + Vector2(back * (14.0 + k * 55.0), sin(age * 20.0 + i * 1.7) * (4.0 + k * 10.0))
		draw_set_transform(grain, age * 6.0 + i, Vector2(1.0, 0.5))
		draw_circle(Vector2.ZERO, 3.2 - k * 1.4, Color(0.55, 1.0, 0.35, 1.0 - k * 0.7))
	draw_set_transform(Vector2.ZERO)
	draw_circle(center, 20.0, Color(0.45, 1.0, 0.3, 0.25))
	draw_circle(center, 14.0, Color("#3fae2a"))
	for i in range(7):
		var angle := i * TAU / 7.0 + age * 3.0
		draw_set_transform(center + Vector2(cos(angle), sin(angle)) * 7.0, angle, Vector2(1.0, 0.5))
		draw_circle(Vector2.ZERO, 3.5, Color("#d9ffb0"))
	draw_set_transform(Vector2.ZERO)


## Vovô Nivaldo e vovó Berenice: acorrentados chorando enquanto o chefe vive;
## livres e felizes (correntes quebrando, acenando, pulando) depois da derrota.
func _draw_captives(center: Vector2) -> void:
	var anim = get_anim(captives_frame()[0])
	draw_oval(center + Vector2(0.0, 4.0), Vector2(85.0, 12.0), Color(0.22, 0.27, 0.31, 0.22))
	if anim != null:
		# O ponto dos pés da folha fica num dos dois; desenha o par centralizado.
		var shift: float = (anim.cell_size().x * 0.5 - anim.feet.x) * SPRITE_SCALE
		anim.draw(self, captives_frame()[1], center - Vector2(shift, 0.0), SPRITE_SCALE)


## Animação e quadro dos prisioneiros da arena: [nome, quadro].
func captives_frame() -> Array:
	var captives: Dictionary = PHASES[phase_index]["captives"]
	var t := Time.get_ticks_msec() / 1000.0
	if boss_active and boss_state == "defeat":
		var anim = get_anim(captives["free"])
		var since := boss_state_time
		return [captives["free"], 0 if since < 0.7 or anim == null else anim.frame_at(since, true, 1, 2)]
	var trapped = get_anim(captives["trapped"])
	# Chorando (dois quadros) e, de vez em quando, se abraçam.
	if fmod(t, 6.0) > 4.8 or trapped == null:
		return [captives["trapped"], 2]
	return [captives["trapped"], trapped.frame_at(t, true, 0, 1)]


## Estrelinha colorida girando, jogada pela estrela do mar.
func _draw_star_shot(ground: Vector2, shot: Dictionary) -> void:
	var age := float(shot["age"])
	var center := ground + Vector2(0.0, -MAGIC_HEIGHT * 0.5 - sin(age * 9.0) * 4.0)
	draw_oval(ground + Vector2(0.0, 3.0), Vector2(16.0, 5.0), Color(0.22, 0.27, 0.31, 0.25))
	var points := PackedVector2Array()
	var inner := PackedVector2Array()
	for i in range(10):
		var angle := age * 10.0 + i * TAU / 10.0
		var radius := 20.0 if i % 2 == 0 else 8.0
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
		inner.append(center + Vector2(cos(angle), sin(angle)) * radius * 0.7)
	draw_colored_polygon(points, Color("#7a2a8a"))
	draw_colored_polygon(inner, Color("#ff9a3d"))
	draw_circle(center, 4.0, Color("#ffe9a8"))


## Banana girando, jogada pelo sagui.
func _draw_banana(ground: Vector2, shot: Dictionary) -> void:
	var age := float(shot["age"])
	var center := ground + Vector2(0.0, -MAGIC_HEIGHT * 0.5 - sin(age * 9.0) * 4.0)
	draw_oval(ground + Vector2(0.0, 3.0), Vector2(14.0, 5.0), Color(0.22, 0.27, 0.31, 0.25))
	var spin := age * 12.0
	draw_arc(center, 20.0, spin, spin + 2.4, 14, Color("#7a5a10"), 15.0)
	draw_arc(center, 20.0, spin + 0.1, spin + 2.3, 14, Color("#ffd23f"), 11.0)
	draw_arc(center, 23.0, spin + 0.4, spin + 2.0, 10, Color("#fff2a0"), 3.0)
	var tip := center + Vector2(cos(spin), sin(spin)) * 20.0
	draw_circle(tip, 4.5, Color("#5a3d10"))


## Espinho da concha do ermitão, voando reto na faixa.
func _draw_spike(ground: Vector2, shot: Dictionary) -> void:
	var dir := signf(float(shot["vx"]))
	var tip := ground + Vector2(dir * 16.0, -45.0)
	draw_oval(ground + Vector2(0.0, 3.0), Vector2(12.0, 4.0), Color(0.22, 0.27, 0.31, 0.25))
	for i in range(3):
		var trail := tip - Vector2(dir * (30.0 + i * 12.0), -4.0 + i * 4.0)
		draw_line(trail, trail - Vector2(dir * 18.0, 0.0), Color(1.0, 1.0, 1.0, 0.6 - i * 0.15), 2.0)
	draw_colored_polygon(PackedVector2Array([tip, tip - Vector2(dir * 30.0, 6.0), tip - Vector2(dir * 30.0, -6.0)]), Color("#3b3540"))
	draw_colored_polygon(PackedVector2Array([tip, tip - Vector2(dir * 24.0, 3.0), tip - Vector2(dir * 24.0, -2.0)]), Color("#d8d2c4"))


func _draw_hud(viewport: Vector2) -> void:
	var font := ThemeDB.fallback_font
	if get_anim("hud_barra") != null and get_anim("hud_comandos") != null:
		_draw_energy_bar(Vector2(12.0, 8.0))
		var panel = get_anim("hud_comandos")
		_draw_command_panel(Vector2(viewport.x - panel.cell_size().x * HUD_SCALE - 10.0, 8.0))
	else:
		_draw_simple_hud(viewport)

	if boss_active and not game_won:
		draw_rect(Rect2(viewport.x * 0.5 - 155.0, 110.0, 310.0, 47.0), Color(1.0, 1.0, 1.0, 0.9))
		draw_string(font, Vector2(viewport.x * 0.5 - 139.0, 130.0), boss["title"], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, FONT_COLOR)
		draw_rect(Rect2(viewport.x * 0.5 - 139.0, 137.0, 278.0, 11.0), Color("#ead8e9"))
		draw_rect(Rect2(viewport.x * 0.5 - 139.0, 137.0, 278.0 * float(boss_health) / float(boss["health"]), 11.0), Color(boss["color"]))
	elif level_time < 3.5 and not game_won:
		# Nome da fase no começo.
		var title := "FASE %d — %s" % [phase_index + 1, PHASES[phase_index]["title"]]
		var alpha := clampf((3.5 - level_time) / 0.6, 0.0, 1.0)
		var title_size := font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 30)
		var title_pos := Vector2(viewport.x * 0.5 - title_size.x * 0.5, 175.0)
		draw_string_outline(font, title_pos, title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 30, 8, Color(0.15, 0.2, 0.31, alpha))
		draw_string(font, title_pos, title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 30, Color(1.0, 0.93, 0.55, alpha))

	# Avisos de poder pronto, na faixa de grama de baixo.
	var ready_x := 14.0
	for power in powers:
		if power.keycode != KEY_NONE and power.is_ready():
			var ready_text: String = "%s PRONTO!" % power.display_name.to_upper()
			var text_width := font.get_string_size(ready_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12).x
			draw_rect(Rect2(ready_x, viewport.y - 17.0, text_width + 16.0, 15.0), Color(1.0, 1.0, 1.0, 0.85))
			draw_string(font, Vector2(ready_x + 8.0, viewport.y - 5.0), ready_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12, power.hud_color)
			ready_x += text_width + 26.0


## Rosto do Arthur no HUD, conforme a energia e o que está acontecendo.
func hud_face() -> int:
	if _power("doroth").is_active():
		return Face.DIZZY
	if hurt_time > 0.0:
		return Face.OUCH
	if energy > 70.0:
		return Face.HAPPY
	if energy > 45.0:
		return Face.OK
	if energy > 25.0:
		return Face.WORRIED
	return Face.TIRED


## Barra de energia: moldura com sol (rosto do Arthur dentro) e barra que esvazia.
func _draw_energy_bar(top_left: Vector2) -> void:
	var frame = get_anim("hud_barra")
	var fill := Rect2(top_left + HUD_BAR_FILL.position * HUD_SCALE, HUD_BAR_FILL.size * HUD_SCALE)
	var amount := energy / 100.0
	var color := Color("#5fd64a")
	if amount <= 0.25:
		color = Color("#ff5a4f")
	elif amount <= 0.5:
		color = Color("#ffb53b")
	# Barra por baixo da moldura (o interior da moldura é escuro, então desenha por cima).
	frame.draw_at(self, 0, top_left, HUD_SCALE)
	if amount > 0.0:
		var bar := Rect2(fill.position + Vector2(2.0, 3.0), Vector2((fill.size.x - 4.0) * amount, fill.size.y - 6.0))
		draw_rect(bar, color)
		draw_rect(Rect2(bar.position, Vector2(bar.size.x, bar.size.y * 0.35)), Color(1.0, 1.0, 1.0, 0.3))
	var faces = get_anim("hud_arthur")
	if faces != null:
		var face_size: Vector2 = faces.cell_size() * HUD_SCALE
		var center := top_left + HUD_SUN_CENTER * HUD_SCALE
		faces.draw_at(self, hud_face(), center - face_size * 0.5, HUD_SCALE)


## Painel de comandos: um ícone por espaço, com a tecla e a recarga escurecendo o ícone.
func _draw_command_panel(top_left: Vector2) -> void:
	var font := ThemeDB.fallback_font
	var panel = get_anim("hud_comandos")
	panel.draw_at(self, 0, top_left, HUD_SCALE)
	var icons = get_anim("hud_icones")
	var slot_size := HUD_SLOT_SIZE * HUD_SCALE
	for index in range(HUD_SLOTS.size()):
		var slot: Dictionary = HUD_SLOTS[index]
		var center := top_left + Vector2(HUD_SLOT_CENTERS[index], HUD_SLOT_Y) * HUD_SCALE
		var box := Rect2(center - Vector2.ONE * slot_size * 0.5, Vector2.ONE * slot_size)
		if icons != null:
			var icon_size: Vector2 = icons.cell_size() * HUD_SCALE * 0.9
			icons.draw_at(self, int(slot["icon"]), center - icon_size * 0.5, HUD_SCALE * 0.9)
		var waiting := _slot_cooldown(slot)
		if waiting > 0.0:
			draw_rect(Rect2(box.position, Vector2(box.size.x, box.size.y * waiting)), Color(0.08, 0.06, 0.15, 0.65))
		elif slot.get("key", "") == "L" and blocking:
			draw_rect(box, Color(0.5, 0.85, 1.0, 0.3))
		var label: String = slot["key"]
		if slot.get("power", "") == "doroth":
			label = "x%d" % _power("doroth").uses
		if label != "":
			var label_pos := box.position + Vector2(box.size.x - 11.0, box.size.y - 2.0)
			draw_string_outline(font, label_pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 11, 4, Color("#263550"))
			draw_string(font, label_pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 11, Color("#fff4c2"))
	var panel_size: Vector2 = panel.cell_size() * HUD_SCALE
	var hint := "← → ↑ ↓ andar (segure: correr)   ESPAÇO pular"
	var hint_pos := top_left + Vector2(panel_size.x * 0.5 - font.get_string_size(hint, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 11).x * 0.5, panel_size.y + 6.0)
	draw_string_outline(font, hint_pos, hint, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 11, 4, Color(1.0, 1.0, 1.0, 0.85))
	draw_string(font, hint_pos, hint, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 11, FONT_COLOR)


## Fração da recarga que falta (0 = pronto) do espaço do painel.
func _slot_cooldown(slot: Dictionary) -> float:
	if slot.has("attack"):
		var attack: Dictionary = ATTACKS[slot["attack"]]
		return attack_cooldown / float(attack["cooldown"]) if attack_kind == slot["attack"] else 0.0
	if slot.has("power"):
		var power = _power(slot["power"])
		if power.id == "doroth":
			return 1.0 if power.is_active() else 0.0
		return power.cooldown_left / power.cooldown if power.cooldown > 0.0 else 0.0
	return 0.0


## HUD só com formas (se as imagens hud_* não existirem).
func _draw_simple_hud(viewport: Vector2) -> void:
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
	draw_rect(Rect2(viewport.x - 404.0, 18.0, 384.0, 84.0), Color(1.0, 1.0, 1.0, 0.88))
	draw_string(font, Vector2(viewport.x - 386.0, 41.0), "← → andar (segure: correr)  ↑ ↓ faixa  ESPAÇO pular", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12, FONT_COLOR)
	draw_string(font, Vector2(viewport.x - 386.0, 62.0), "J soco   K chute giratório   L ou SHIFT defender", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12, FONT_COLOR)
	draw_string(font, Vector2(viewport.x - 386.0, 84.0), "   ".join(power_parts), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, Color("#a14c68"))


## Tela de escolha de fase: um cartão por fase, com a imagem da arena e o chefe.
func _draw_phase_menu(viewport: Vector2) -> void:
	var font := ThemeDB.fallback_font
	var selected: Dictionary = PHASES[maxi(menu_index, 0)]
	var backdrop: Texture2D = backgrounds.get(selected["backgrounds"][0])
	if menu_index == MENU_STORY:
		backdrop = _story_texture(STORY_TEXTS.size(), true)
	if backdrop != null:
		draw_texture_rect(backdrop, Rect2(Vector2.ZERO, viewport), false)
	else:
		draw_rect(Rect2(Vector2.ZERO, viewport), Color("#8be0ff"))
	draw_rect(Rect2(Vector2.ZERO, viewport), Color(0.1, 0.12, 0.22, 0.55))

	var title := "ARTHUR: CAMINHO DE VOLTA"
	var title_size := font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 34)
	draw_string_outline(font, Vector2(viewport.x * 0.5 - title_size.x * 0.5, 62.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 34, 10, Color("#263550"))
	draw_string(font, Vector2(viewport.x * 0.5 - title_size.x * 0.5, 62.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 34, Color("#ffe066"))
	var subtitle := "ASSISTA À HISTÓRIA OU ESCOLHA A FASE"
	var subtitle_size := font.get_string_size(subtitle, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 20)
	draw_string_outline(font, Vector2(viewport.x * 0.5 - subtitle_size.x * 0.5, 98.0), subtitle, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 20, 6, Color("#263550"))
	draw_string(font, Vector2(viewport.x * 0.5 - subtitle_size.x * 0.5, 98.0), subtitle, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 20, Color.WHITE)

	var count := PHASES.size()
	var cards := count + 1
	var gap := 12.0
	var card_width := minf(210.0, (viewport.x - 40.0 - gap * (cards - 1)) / cards)
	var card_height := 250.0
	var left := viewport.x * 0.5 - (card_width * cards + gap * (cards - 1)) * 0.5
	_draw_story_card(Rect2(left, 140.0, card_width, card_height), menu_index == MENU_STORY)
	left += card_width + gap
	for index in range(count):
		var phase: Dictionary = PHASES[index]
		var chosen := index == menu_index
		var bounce := sin(walk_time * 5.0) * 4.0 if chosen else 0.0
		var card := Rect2(left + index * (card_width + gap), 140.0 - bounce, card_width, card_height)
		if chosen:
			draw_rect(card.grow(5.0), Color("#ffe066"))
		draw_rect(card, Color("#fff4d6") if chosen else Color(1.0, 0.96, 0.85, 0.75))
		var picture := Rect2(card.position + Vector2(8.0, 8.0), Vector2(card_width - 16.0, (card_width - 16.0) * 9.0 / 16.0))
		var arena: Texture2D = backgrounds.get(phase["arena"])
		if arena != null:
			draw_texture_rect(arena, picture, false)
		else:
			draw_rect(picture, Color("#8be0ff"))
		var boss_info: Dictionary = BOSSES[phase["boss"]]
		var boss_anim = get_anim(boss_info["walk"])
		if boss_anim != null:
			var boss_scale := SPRITE_SCALE * 0.42
			boss_anim.draw(self, boss_anim.frame_at(walk_time) if chosen else 0, picture.position + Vector2(picture.size.x * 0.72, picture.size.y - 4.0), boss_scale, -1.0)
		var label := "FASE %d" % (index + 1)
		draw_string(font, card.position + Vector2(12.0, picture.size.y + 40.0), label, HORIZONTAL_ALIGNMENT_LEFT, card_width - 20.0, 22, Color("#a14c68"))
		# Nome da fase: diminui a letra até caber no cartão (ou quebra em duas linhas).
		var title_text: String = phase["title"]
		var title_font := 15
		while title_font > 11 and font.get_string_size(title_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, title_font).x > card_width - 20.0:
			title_font -= 1
		draw_multiline_string(font, card.position + Vector2(12.0, picture.size.y + 66.0), title_text, HORIZONTAL_ALIGNMENT_LEFT, card_width - 20.0, title_font, 2, FONT_COLOR)
		draw_multiline_string(font, card.position + Vector2(12.0, picture.size.y + 108.0), "Chefe: " + String(boss_info["title"]).capitalize(), HORIZONTAL_ALIGNMENT_LEFT, card_width - 20.0, 12, 2, Color("#477c5d"))
		draw_string(font, card.position + Vector2(card_width - 26.0, card_height - 12.0), str(index + 1), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, Color(0.15, 0.2, 0.31, 0.5))

	var hint := "← → escolher     ENTER começar     0 história     1-%d fases     ESC no jogo volta aqui" % count
	var hint_size := font.get_string_size(hint, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 15)
	draw_string_outline(font, Vector2(viewport.x * 0.5 - hint_size.x * 0.5, 418.0), hint, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 15, 5, Color("#263550"))
	draw_string(font, Vector2(viewport.x * 0.5 - hint_size.x * 0.5, 418.0), hint, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 15, Color.WHITE)

	var arthur = get_anim("arthur_andando")
	var doroth = get_anim("dorothy_correndo")
	if arthur != null:
		arthur.draw(self, arthur.frame_at(walk_time), Vector2(viewport.x * 0.5 - 40.0, 528.0), SPRITE_SCALE * 0.7)
	if doroth != null:
		doroth.draw(self, doroth.frame_at(walk_time), Vector2(viewport.x * 0.5 + 50.0, 528.0), SPRITE_SCALE * 0.7)


## Cartão "História" no menu de fases.
func _draw_story_card(card: Rect2, chosen: bool) -> void:
	var font := ThemeDB.fallback_font
	if chosen:
		card.position.y -= sin(walk_time * 5.0) * 4.0
		draw_rect(card.grow(5.0), Color("#ffe066"))
	draw_rect(card, Color("#fff4d6") if chosen else Color(1.0, 0.96, 0.85, 0.75))
	var picture := Rect2(card.position + Vector2(8.0, 8.0), Vector2(card.size.x - 16.0, (card.size.x - 16.0) * 9.0 / 16.0))
	var cover := _story_texture(1, false)
	if cover != null:
		var source_height := cover.get_width() * picture.size.y / picture.size.x
		draw_texture_rect_region(cover, picture, Rect2(0.0, (cover.get_height() - source_height) * 0.5, cover.get_width(), source_height))
	# Botão de "play" sobre a imagem.
	var center := picture.get_center()
	draw_circle(center, 17.0, Color(0.15, 0.2, 0.31, 0.75))
	draw_colored_polygon(PackedVector2Array([center + Vector2(-6.0, -10.0), center + Vector2(-6.0, 10.0), center + Vector2(11.0, 0.0)]), Color.WHITE)
	draw_string(font, card.position + Vector2(12.0, picture.size.y + 40.0), "HISTÓRIA", HORIZONTAL_ALIGNMENT_LEFT, card.size.x - 20.0, 20, Color("#a14c68"))
	draw_multiline_string(font, card.position + Vector2(12.0, picture.size.y + 66.0), "Como tudo começou", HORIZONTAL_ALIGNMENT_LEFT, card.size.x - 20.0, 14, 2, FONT_COLOR)
	draw_string(font, card.position + Vector2(12.0, picture.size.y + 108.0), "%d cenas" % STORY_TEXTS.size(), HORIZONTAL_ALIGNMENT_LEFT, card.size.x - 20.0, 12, Color("#477c5d"))
	draw_string(font, card.position + Vector2(card.size.x - 26.0, card.size.y - 12.0), "0", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, Color(0.15, 0.2, 0.31, 0.5))


## Imagem da cena `number` (1 = primeira); `blurred` pega o fundo desfocado.
func _story_texture(number: int, blurred: bool) -> Texture2D:
	var key := "%d%s" % [number, "_fundo" if blurred else ""]
	if not story_textures.has(key):
		var path := "res://art/historia_%s.jpg" % key
		story_textures[key] = load(path) if ResourceLoader.exists(path) else null
	return story_textures[key]


## Uma cena da história: fundo desfocado, imagem com zoom lento à esquerda e o
## texto subindo à direita. A troca de cena é um esmaecer cruzado.
func _draw_story(viewport: Vector2) -> void:
	var fade := clampf(story_time / STORY_FADE_TIME, 0.0, 1.0)
	var showing_previous := story_previous >= 0 and fade < 1.0
	if showing_previous:
		_draw_story_scene(viewport, story_previous, story_scene_time(story_previous), 1.0, false)
	_draw_story_scene(viewport, story_index, story_time, fade if showing_previous else 1.0, true)

	var font := ThemeDB.fallback_font
	var counter := "%d / %d" % [story_index + 1, STORY_TEXTS.size()]
	draw_string_outline(font, Vector2(viewport.x - 110.0, 30.0), counter, HORIZONTAL_ALIGNMENT_RIGHT, 80.0, 15, 5, Color("#263550"))
	draw_string(font, Vector2(viewport.x - 110.0, 30.0), counter, HORIZONTAL_ALIGNMENT_RIGHT, 80.0, 15, Color.WHITE)
	# Barra de progresso da cena.
	var progress := clampf(story_time / story_scene_time(story_index), 0.0, 1.0)
	draw_rect(Rect2(0.0, viewport.y - 4.0, viewport.x, 4.0), Color(0.0, 0.0, 0.0, 0.35))
	draw_rect(Rect2(0.0, viewport.y - 4.0, viewport.x * (story_index + progress) / STORY_TEXTS.size(), 4.0), Color("#ffe066"))

	var last := story_index == STORY_TEXTS.size() - 1
	var hint := "ENTER próxima     ← volta     ESC menu"
	if last:
		hint = "ENTER começar a aventura!     ESC menu"
	var hint_size := 18 if last else 13
	var hint_width := font.get_string_size(hint, HORIZONTAL_ALIGNMENT_LEFT, -1.0, hint_size).x
	var hint_alpha := 0.6 + 0.4 * sin(walk_time * 4.0) if last else 0.8
	var hint_pos := Vector2(viewport.x - 30.0 - hint_width, viewport.y - 22.0)
	draw_string_outline(font, hint_pos, hint, HORIZONTAL_ALIGNMENT_LEFT, -1.0, hint_size, 5, Color(0.15, 0.2, 0.31, hint_alpha))
	draw_string(font, hint_pos, hint, HORIZONTAL_ALIGNMENT_LEFT, -1.0, hint_size, Color(1.0, 0.94, 0.6, hint_alpha) if last else Color(1.0, 1.0, 1.0, hint_alpha))


func _draw_story_scene(viewport: Vector2, index: int, time: float, alpha: float, with_text: bool) -> void:
	var tint := Color(1.0, 1.0, 1.0, alpha)
	var backdrop := _story_texture(index + 1, true)
	if backdrop != null:
		draw_texture_rect(backdrop, Rect2(Vector2.ZERO, viewport), false, tint)
	else:
		draw_rect(Rect2(Vector2.ZERO, viewport), Color(0.12, 0.1, 0.22, alpha))

	# Imagem à esquerda: aproxima devagar (zoom) durante a cena.
	var picture_texture := _story_texture(index + 1, false)
	var picture_height := viewport.y - 110.0
	var aspect := 1400.0 / 1018.0
	if picture_texture != null:
		aspect = float(picture_texture.get_width()) / picture_texture.get_height()
	var picture := Rect2(28.0, 42.0, picture_height * aspect, picture_height)
	draw_rect(picture.grow(5.0), Color(1.0, 0.96, 0.84, alpha))
	if picture_texture != null:
		var progress := clampf(time / story_scene_time(index), 0.0, 1.0)
		var zoom := 1.0 + STORY_ZOOM * progress
		var size := Vector2(picture_texture.get_width(), picture_texture.get_height()) / zoom
		# Cenas pares aproximam do centro para a direita, ímpares para a esquerda.
		var drift := 0.5 + (0.25 if index % 2 == 0 else -0.25) * progress
		var origin := Vector2((picture_texture.get_width() - size.x) * drift, (picture_texture.get_height() - size.y) * 0.4)
		draw_texture_rect_region(picture_texture, picture, Rect2(origin, size), tint)
	else:
		draw_rect(picture, Color(0.3, 0.25, 0.45, alpha))
	if not with_text:
		return

	# Texto à direita: sobe de baixo até o lugar e continua subindo bem devagar.
	var font := ThemeDB.fallback_font
	var text: String = STORY_TEXTS[index]
	var text_left := picture.end.x + 26.0
	var text_width := viewport.x - text_left - 28.0
	var font_size := 22
	var text_size := font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, text_width, font_size)
	while font_size > 16 and text_size.y > picture_height - 40.0:
		font_size -= 1
		text_size = font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, text_width, font_size)
	var rise := clampf(time / STORY_TEXT_RISE_TIME, 0.0, 1.0)
	rise = 1.0 - pow(1.0 - rise, 3.0)
	var drift_up := minf(time, story_scene_time(index)) * 2.0
	var text_top := picture.get_center().y - text_size.y * 0.5 + (1.0 - rise) * 160.0 + 20.0 - drift_up
	var text_alpha := alpha * rise
	var first_line := Vector2(text_left, text_top + font.get_ascent(font_size))
	draw_multiline_string_outline(font, first_line, text, HORIZONTAL_ALIGNMENT_LEFT, text_width, font_size, -1, 7, Color(0.1, 0.08, 0.2, text_alpha))
	draw_multiline_string(font, first_line, text, HORIZONTAL_ALIGNMENT_LEFT, text_width, font_size, -1, Color(1.0, 1.0, 1.0, text_alpha))


func _draw_win_overlay(viewport: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, viewport), Color(0.13, 0.17, 0.28, 0.6))
	var panel := Rect2(viewport.x * 0.5 - 300.0, viewport.y * 0.5 - 115.0, 600.0, 230.0)
	draw_rect(panel, Color("#fff4d6"))
	var celebrate = get_anim("arthur_comemora")
	if celebrate != null:
		celebrate.draw(self, celebrate.frame_at(walk_time), panel.position + Vector2(95.0, 205.0), SPRITE_SCALE * 1.15)
	var text_x := panel.position.x + 190.0
	draw_string(ThemeDB.fallback_font, Vector2(text_x, viewport.y * 0.5 - 32.0), "FASE COMPLETA!", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 34, Color("#a14c68"))
	draw_string(ThemeDB.fallback_font, Vector2(text_x, viewport.y * 0.5 + 13.0), PHASES[phase_index]["win_text"], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 15, FONT_COLOR)
	var next_text := "ENTER para a fase %d" % (phase_index + 2) if phase_index + 1 < PHASES.size() else "ENTER para jogar de novo"
	draw_string(ThemeDB.fallback_font, Vector2(text_x, viewport.y * 0.5 + 57.0), next_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, Color("#477c5d"))


func _cooldown_text(value: float) -> String:
	return "OK" if value <= 0.0 else "%.0fs" % ceilf(value)
