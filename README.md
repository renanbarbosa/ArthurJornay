# Arthur: Caminho de Volta — protótipo

Protótipo 2D jogável da primeira fase, **Praça da Bruxa**, feito para Godot 4.2 ou superior. Todo o visual é desenhado pelo próprio jogo, sem downloads ou assets externos.

## Executar

1. Abra `project.godot` no Godot 4.2+.
2. Pressione **F6** para executar a cena principal ou **F5** para iniciar o projeto.

## Controles

| Ação | Teclas |
|---|---|
| Andar | Setas esquerda/direita ou A/D |
| Mover pela faixa | Setas para cima/baixo ou W/S |
| Pular | Espaço |
| Ataque básico | J ou K |
| Defender (segurar; reduz o dano em 80% e empurra o inimigo) | L ou Shift |
| Pum Poderoso (atordoa inimigos) | Q |
| Super Espetinho (remove inimigos e atinge o chefe) | E |
| Reiniciar após vencer | Enter |

Doroth passeia correndo pelo cenário. Quando a energia de Arthur chega a zero, ela corre até ele, a tela pisca com raios e ela solta o super poder: recupera toda a energia, remove os inimigos e fere a bruxa, sem limite de vezes. Derrote a Bruxa da Praça para completar a fase. Poças de lama deixam Arthur lento: pule por cima ou troque de faixa para desviar.

## Animações

As animações ficam em `images/*.gif`. O script `tools/gif_to_sheet.py` converte cada GIF numa folha de sprites em `art/` (removendo fundo de cor sólida):

```bash
python3 tools/gif_to_sheet.py
```

Depois registre a animação em `anims`, na função `_ready` do `main.gd`, com o número de quadros, a duração de cada quadro e o ponto dos pés. Se um arquivo de `art/` faltar, o jogo usa o desenho feito com formas.

## Poderes

Cada poder fica em um arquivo próprio em `powers/`, estendendo `powers/power.gd`. Para criar um poder novo, crie o arquivo, preencha nome, tecla e recarga em `_init()`, implemente `_on_activate` e `draw` (e, se quiser, uma animação do Arthur em `player_anim`), e registre o script em `POWER_SCRIPTS` no `main.gd`. A tecla, a recarga e o HUD passam a funcionar automaticamente.

O monstro misterioso, reconhecível apenas pelos olhos, aparece como pista da aventura maior.
