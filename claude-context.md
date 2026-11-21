# Contexto exportado — Arthur: Caminho de Volta

Use este documento como contexto inicial ao continuar o projeto no Claude.

## Objetivo do projeto

Arthur: Caminho de Volta é um protótipo 2D jogável da primeira fase, **Praça da Bruxa**, desenvolvido com Godot 4.2 ou superior. O visual é desenhado integralmente por código, sem assets externos.

## Estado atual

- Projeto executado localmente com Godot 4.7.2 via Flatpak.
- Arquivos principais criados no repositório: `project.godot`, `Main.tscn`, `main.gd` e `main.gd.uid`.
- `README.md` foi atualizado com descrição, execução e controles.
- O repositório possui mudanças não confirmadas (arquivos novos e README modificado).
- Não há uma suíte de testes automatizados configurada.

## Estrutura relevante

- `project.godot`: configuração da aplicação, resolução 960×540, cena principal `res://Main.tscn` e renderizador de compatibilidade.
- `Main.tscn`: cena raiz `Node2D` chamada `Game`, ligada ao script `res://main.gd`.
- `main.gd`: gameplay, câmera lateral, inimigos, chefe, HUD, desenho procedural e sistema de resgate.
- `README.md`: instruções de execução e controles.
- `main.gd.uid`: UID do script no Godot.

## Como executar

Abrir o projeto no Godot:

```bash
flatpak run org.godotengine.Godot --path /home/renan/IA/ArthurJornay
```

No editor: pressione F6 para executar a cena principal ou F5 para iniciar o projeto.

## Controles

- Mover horizontalmente: setas esquerda/direita ou A/D.
- Mudar de faixa: setas cima/baixo ou W/S.
- Pular: Espaço.
- Ataque básico: J ou K.
- Pum Poderoso: Q; recarga de 7 segundos; atordoa inimigos e o chefe.
- Super Espetinho: E; recarga de 18 segundos; remove inimigos e causa dano ao chefe.
- Defender: segurar L ou Shift (reduz o dano em 80%, empurra o inimigo, deixa Arthur lento e impede ataques).
- Reiniciar após vencer: Enter.

## Mecânicas implementadas

- Movimento horizontal com câmera lateral.
- Movimento em três posições de faixa.
- Pulo com gravidade simples.
- Ondas de inimigos acionadas pela progressão horizontal.
- Inimigos perseguem o jogador dentro de um alcance e causam dano por contato.
- Chefe **Bruxa da Praça**, com 8 pontos de vida, ativado próximo ao fim da fase.
- Ataque básico: causa 1 dano por golpe a inimigos ou chefe.
- Pum Poderoso: atordoa inimigos por 2 segundos e o chefe por 1,4 segundo.
- Super Espetinho: limpa todos os inimigos e causa 2 danos ao chefe.
- Energia máxima de 100.
- A personagem Doroth resgata Arthur indefinidamente quando a energia chega a zero:
  - restaura 100 de energia;
  - concede invulnerabilidade;
  - remove inimigos;
  - causa 2 danos ao chefe se ele estiver ativo.
- Ao derrotar a bruxa, a tela de vitória é exibida.
- Obstáculo: poças de lama (lista `OBSTACLES` em `main.gd`) deixam Arthur 60% mais lento; pular ou trocar de faixa evita.
- Poderes extensíveis: cada poder é um script em `powers/` que estende `powers/power.gd` e é registrado em `POWER_SCRIPTS`. Doroth também é um poder, sem tecla, acionado pelo jogo.
- Sprites: Arthur (andar, pum, fogo) e Doroth (correr, poder) vêm de GIFs em `images/`, convertidos por `tools/gif_to_sheet.py` em folhas PNG em `art/` e desenhados por `sprite_anim.gd`. Se faltarem, o jogo volta ao desenho procedural.
- Doroth passeia aleatoriamente pelo cenário; no resgate corre até Arthur, a tela pisca com raios e então o poder é aplicado.
- Pum e Super Espetinho tocam a animação do Arthur e o deixam parado enquanto duram; o fogo do espetinho só elimina os inimigos quando sai da boca (0,6 s).

## Arquitetura do `main.gd`

O arquivo usa `Node2D` com `_ready`, `_input`, `_process` e `_draw`.

Principais funções:

- `_process`: atualiza tempo, movimento, pulo, cooldowns, ondas e entidades.
- `_spawn_progress`: cria duas ondas de inimigos em marcadores e ativa o chefe.
- `_update_enemies`: aproxima inimigos e aplica dano por contato.
- `_update_boss`: movimenta o chefe em direção ao jogador e aplica dano.
- `_attack`: ataque básico com alcance e faixa.
- `_pum_power`: habilidade de atordoamento.
- `_skewer_power`: habilidade poderosa que elimina inimigos e fere o chefe.
- `_take_hit` e `_doroth_rescue`: dano e resgate.
- `_restart`: reinicializa todo o estado da partida.
- `_draw_*`: renderização procedural do cenário, personagens, chefe, HUD e vitória.

## Estado Git

Saída conhecida do `git status`:

```text
## main...origin/main
 M README.md
?? Main.tscn
?? main.gd
?? main.gd.uid
?? project.godot
```

Portanto, o código ainda não foi confirmado em uma ou mais alterações novas.

## Caminho local

`/home/renan/IA/ArthurJornay`

## Solicitações anteriores nesta conversa

1. “rode o prototipo” — o usuário pediu para abrir o jogo.
2. Resultado: o projeto foi executado com `flatpak run org.godotengine.Godot --path /home/renan/IA/ArthurJornay` usando Godot 4.7.2, e a execução foi encerrada ao final da operação.
3. “exporte esse contexto para eu importar no meu claude” — gere um contexto portátil neste arquivo.

## Orientação para continuar no Claude

Antes de alterar o projeto, preservem o comportamento atual do protótipo e evitem adicionar dependências ou assets externos. Para mudanças, prefira:

- editar `main.gd` para gameplay e desenho;
- editar `Main.tscn` apenas para ajustes da cena;
- editar `project.godot` para configuração global;
- atualizar `README.md` para documentação diretamente relacionada;
- validar a alteração abrindo/executando o projeto no Godot.
