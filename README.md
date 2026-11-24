# Arthur: Caminho de Volta — protótipo

Protótipo 2D jogável com cinco fases, **Praça da Bruxa**, **Rua Padre Vieira**, **Itaporanga**, **Salvador** e **Bosque dos Jequitibás**, feito para Godot 4.2 ou superior. Os personagens e cenários são imagens geradas por IA e convertidas pelos scripts de `tools/`; sem elas o jogo desenha tudo com formas.

## Executar

1. Abra `project.godot` no Godot 4.2+.
2. Pressione **F6** para executar a cena principal ou **F5** para iniciar o projeto.

O jogo começa na tela de **escolha de fase**: setas para escolher, ENTER para começar (ou as teclas 1 a 5). Durante o jogo, ESC volta para essa tela.

O primeiro cartão do menu é a **História** (tecla 0 ou H): 20 cenas contam como Arthur foi levado pela bruxa e reencontrou a Dorothy. Cada cena mostra a imagem com um zoom lento e esmaece para a próxima; o texto sobe ao lado. A cena passa sozinha depois de um tempo para ler devagar (4 s + 1 s a cada 9 letras, de 10 a 20 s por cena). ENTER/→ (ou A no controle) pula para a próxima, ← volta, ESC (Back) sai para o menu. Na última cena, ENTER começa a fase 1. `-- --historia` abre a história direto.

As imagens vêm de `images/H_1.jpeg` … `H_20.jpeg`: `python3 tools/build_historia.py` corta a moldura branca e grava `art/historia_N.jpg` e o fundo desfocado `art/historia_N_fundo.jpg`. Os textos ficam em `STORY_TEXTS` no `main.gd`, um por cena, na mesma ordem das imagens.

Para pular a escolha e começar direto numa fase: `godot --path . -- --fase=2` (no editor: *Projeto > Configurações do Projeto > Editor > Run > Main Run Args*, com `-- --fase=2`).

## Controles

| Ação | Teclas | Controle (Xbox / PlayStation) |
|---|---|---|
| Andar (segurando, Arthur começa a correr) | Setas esquerda/direita ou A/D | Direcional ou analógico esquerdo |
| Mover pela faixa | Setas para cima/baixo ou W/S | Direcional ou analógico esquerdo |
| Pular | Espaço | A / ✕ |
| Soco (um inimigo à frente) | J | X / □ |
| Chute giratório (todos em volta, recarga maior) | K | Y / △ |
| Defender (segurar; reduz o dano em 80% e empurra o inimigo) | L ou Shift | B / ○ ou gatilho esquerdo |
| Pum Poderoso (atordoa inimigos) | Q | LB / L1 |
| Super Espetinho (remove inimigos e atinge o chefe) | E | RB / R1 |
| Escolher e começar a fase (ou a história) no menu | Setas e Enter | Direcional ou analógico, A / ✕ ou Start |
| Próxima fase após vencer (depois da última, volta à primeira) | Enter | Start ou A / ✕ |
| Voltar para a escolha de fase | Esc | Back / Select |

Para trocar os botões do controle, edite `PAD_BUTTONS` no `main.gd`. Com `PAD_DEBUG := true`, o console do Godot mostra o número de cada botão apertado.

Doroth passeia pelo cenário, correndo ou parada abanando o rabo. Quando a energia de Arthur chega a zero, ele cai derrotado no chão; ela corre até ele (a tela pisca com raios) e lambe o rosto dele enquanto corações enchem a tela e a barra de energia vai enchendo. Depois solta o super latido, que derruba os inimigos e fere a bruxa, e Arthur levanta. Sem limite de vezes.

Inimigos: pitbull (forte), chihuahua (rápido, cai com um golpe) e cachorro da bruxa (aparece numa nuvem de magia, aguenta 5 golpes e morde forte). Eles se aproximam, inclusive mudando de faixa, e atacam de perto. Com o pum ficam enjoados (cara verde).

### Fase 1: Praça da Bruxa

A fase tem 15 telas e 15 ondas de inimigos (cerca de 2 minutos até a bruxa). A Bruxa da Praça chega voando na vassoura e tem 24 de vida (pelo menos 20 golpes). De longe ela joga bolas de magia verde (pule para desviar), de perto dá vassouradas e, com 16 e 8 de vida, invoca um cachorro. Derrotada, ela perde o chapéu e foge voando: fase completa. Cocôs de cachorro grudam no tênis e deixam Arthur lento (e ficam amassados): pule por cima ou troque de faixa para desviar. Bancos de praça bloqueiam a passagem, mas dá para pular em cima deles; lá no alto os inimigos não alcançam Arthur (a bruxa alcança).

### Fase 2: Rua Padre Vieira

Mesma dinâmica, com 15 telas (fundos `rua_1`, `rua_2` e `rua_3` sorteados) e 15 ondas. Inimigos enfeitiçados:

- **Gordão do espetinho**: lento, aguenta 4 golpes e bate forte com o espetinho de linguiça (alcance maior).
- **Morador de rua com a faca**: mais rápido, aguenta 3 golpes.
- **Motoqueiro de entregas**: não persegue. Uma placa piscando com "BIBI!" aparece na borda direita, na faixa do Arthur; depois ele atravessa a tela em alta velocidade. Pule ou troque de faixa para desviar. Um golpe, o pum ou o latido derrubam ele da moto.

Chefe: **o Praga** (26 de vida), que entra mancando pela direita sob o viaduto. De longe xinga (balões de "#@$%!" que voam até o Arthur; pule para desviar), de perto bate com a muleta e, com 18 e 9 de vida, chama um morador de rua para ajudar. Derrotado, cai sentado no chão.

### Fase 3: Itaporanga

Mesma dinâmica, com 15 telas (fundos `cidade_1`, `cidade_2` e `cidade_3` sorteados) e 15 ondas. Inimigos:

- **Fantasma da casa abandonada**: flutua e dá um susto com olhos verdes e bafo verde (aguenta 3 golpes).
- **Boi foragido** (vaca zumbi): raspa a pata, avança e dá uma chifrada forte (aguenta 5 golpes).
- **Rato gigante** da máquina de arroz: rápido, vira de costas e dá uma rabada (aguenta 3 golpes).

Chefe: **a Barata Gigante** (28 de vida), na frente da máquina de arroz, ao pôr do sol. Joga bolas de arroz envenenado (de longe e de perto; pule para desviar) e, com 20 e 10 de vida, chama um rato gigante. Enquanto ela está viva, o **vovô Nivaldo e a vovó Berenice** ficam sentados acorrentados, chorando, no canto da arena. Quando ela é derrotada, as correntes quebram e os dois ficam de pé, acenando e pulando de alegria.

### Fase 4: Salvador

Mesma dinâmica, na orla, com 15 telas (fundos `salvador_1`, `salvador_2` e `salvador_3` sorteados) e 15 ondas. Inimigos:

- **Caranguejo**: dá pinçadas (aguenta 3 golpes).
- **Ermitão**: fica de longe e atira espinhos da concha, que voam retos na faixa dele (pule ou troque de faixa). Aguenta 3 golpes.
- **Lagosta zumbi**: lenta, solta um bafo fedido que alcança mais longe (aguenta 4 golpes).

Chefe: **a Estrela do Mar** (30 de vida), na frente do resort. Dá braçadas de perto, joga estrelinhas de longe (pule para desviar) e, com 22 e 11 de vida, dança e chama um caranguejo. Enquanto ela está viva, o **papai e a mamãe** ficam sentados acorrentados, chorando; quando ela é derrotada, ficam de pé, acenando e pulando de alegria.

### Fase 5: Bosque dos Jequitibás

Mesma dinâmica, no parque, com 15 telas (fundos `bosque_1`, `bosque_2` e `bosque_3` sorteados) e 15 ondas. Inimigos:

- **Arara**: rápida, voa (flutua no alto) e pousa para soltar um bafo fedido (aguenta 2 golpes).
- **Preguiça**: bem lenta, mas a garra mágica bate forte (aguenta 5 golpes).
- **Hipopótamo zumbi**: grande, bafo fedido de longe (aguenta 6 golpes).

Chefe: **o Sagui Zumbi** (32 de vida), na frente da jaula. Joga bananas de longe (pule para desviar), bate de perto e, com 24 e 12 de vida, chama uma arara. Enquanto ele está vivo, a **vovó** fica sentada acorrentada, chorando; quando ele é derrotado, ela fica de pé, acena e pula de alegria.

## Animações

As folhas de animação são geradas por IA (Nano Banana) em grade, com fundo magenta, e ficam em `images/` (ex.: `images/Bruxa_Magia.jpeg`, 3×3). O script abaixo converte todas para `art/<nome>.png` e grava `art/sprites.json` (quadros e ponto dos pés):

```bash
python3 tools/build_sprites.py              # todas
python3 tools/build_sprites.py bruxa_magia  # só uma
python3 tools/build_sprites.py --preview    # também salva tools/_preview.png para conferir
```

Ele apaga as linhas da grade (inclusive linhas extras sobre o personagem), textos indicados, o fundo magenta, as sombras roxas e pedaços de quadros vizinhos, iguala a altura de cada personagem entre as folhas e alinha os pés. A lista de folhas e os ajustes de cada uma ficam em `SHEETS`, no próprio script.

Uma grade pode virar várias animações (ex.: `gordao.jpeg` vira `gordao_andando`, `gordao_ataque`, `gordao_dano` e `gordao_derrota`): cada uma escolhe seus quadros em `frames` e todas usam os mesmos quadros de medida (`measure`), para o personagem ficar do mesmo tamanho.

Para uma animação nova: coloque a imagem em `images/`, adicione a folha em `SHEETS`, rode o script e coloque a velocidade (segundos por quadro) em `ANIM_SPEED`, no `main.gd`. Se um arquivo de `art/` faltar, o jogo usa o desenho feito com formas.

A pasta `images/` tem um `.gdignore`: o Godot não importa as imagens de origem, só as de `art/`.

## HUD

No canto esquerdo, a barra de energia (`hud_barra`) com o rosto do Arthur dentro do sol (`hud_arthur`: feliz, normal, preocupado, dor, tonto, cansado). No direito, o painel de comandos (`hud_comandos`) com um ícone por ação (`hud_icones`), a tecla e a recarga escurecendo o ícone; no espaço da Doroth aparece o número de resgates. As posições da barra e dos espaços (`HUD_*` no `main.gd`) foram medidas nas imagens: se trocar as imagens, meça de novo.

## Fases e fundos

Cada fase fica em `PHASES` no `main.gd`: imagens de fundo, se a ordem é sorteada, imagem da arena, ondas de inimigos e chefe (os chefes ficam em `BOSSES`). Toda fase tem 15 telas: 14 do caminho e a arena, onde a câmera trava e o chefe aparece.

As imagens de `images/` são preparadas por:

```bash
python3 tools/build_backgrounds.py          # todas
python3 tools/build_backgrounds.py rua_1    # só uma
```

O script alinha o chão de todas na mesma altura, suaviza bordas e salva em `art/<nome>.jpg` (1920×1080):

- Fase 1: `praca_1.jpeg` (parquinho), `praca_2.jpeg` (parquinho de cachorros) e `praca_3.jpeg` (casa da bruxa, arena) viram `art/praca_N.jpg`. A 1 e a 2 se alternam.
- Fase 2: `bacK_1.jpeg`, `back_2.jpeg` e `back_3.jpeg` viram `art/rua_1..3.jpg` (em ordem sorteada, sem repetir a mesma seguida) e `final.jpeg` vira `art/rua_final.jpg` (arena).
- Fase 3: `back1.jpeg`, `back2.jpeg` e `back3.jpeg` viram `art/cidade_1..3.jpg` (sorteadas) e `maquina.jpeg` vira `art/cidade_final.jpg` (arena). A `back1.jpeg` veio com faixas laterais mais claras, cortadas pelo script (`crop`).
- Fase 4: `sal_back1.jpeg`, `sal_back2.jpeg` e `sal_back3.jpeg` viram `art/salvador_1..3.jpg` (sorteadas) e `sal_final.jpeg` vira `art/salvador_final.jpg` (arena).
- Fase 5: `j_back1.jpeg`, `j_back2.jpeg` e `j_back3.jpeg` viram `art/bosque_1..3.jpg` (sorteadas) e `j_final.jpeg` vira `art/bosque_final.jpg` (arena).

Na fase 2, o script alinha quatro linhas em todas as imagens: topo da grade, topo do muro, pé do muro (começo da calçada, onde começa o chão do jogo) e meio-fio. Nas fases 3, 4 e 5, três: começo da calçada (ou do caminho de pedras), meio-fio e começo da rua (ou da areia, ou da grama). Se trocar uma imagem, meça de novo essas linhas em `IMAGES`, no script.

## Poderes

Cada poder fica em um arquivo próprio em `powers/`, estendendo `powers/power.gd`. Para criar um poder novo, crie o arquivo, preencha nome, tecla e recarga em `_init()`, implemente `_on_activate` e `draw` (e, se quiser, uma animação do Arthur em `player_anim`), e registre o script em `POWER_SCRIPTS` no `main.gd`. A tecla, a recarga e o HUD passam a funcionar automaticamente.

O monstro misterioso, reconhecível apenas pelos olhos, aparece como pista da aventura maior.
