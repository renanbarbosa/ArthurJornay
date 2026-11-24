# Contexto para o Claude no Chrome — gerar imagens no Google Gemini

## Quem é você nesta tarefa

Você vai usar o **gemini.google.com** (modelo de imagem "Nano Banana"), já logado na conta
do usuário, para gerar **folhas de sprites em pixel art** para um jogo. Trabalhe sempre numa
**aba nova**. Não envie fotos reais de pessoas: só as referências em pixel art que o
usuário anexar ou que já estiverem na conversa do Gemini.

Antes de gastar créditos, confirme com o usuário quantas imagens/tentativas pode gerar.
Mostre cada resultado ao usuário antes de baixar.

## O projeto

"Arthur: Caminho de Volta" é um jogo 2D de ação lateral (beat 'em up) para crianças, feito
em Godot. O menino Arthur foge do vilão Gmork e atravessa a "Praça da Bruxa", com a ajuda
da cachorrinha Dorothy, enfrentando cachorros bravos e, no fim, a Bruxa da Praça, que mora
numa casa em cima de uma árvore. Tom: muito colorido, saturado, engraçado, nunca assustador.

Personagens (já definidos em pixel art, manter idênticos):
- **Arthur**: menino de cabelo castanho, óculos azuis, camiseta amarela com um sol
  desenhado, calça preta, tênis escuros.
- **Dorothy**: cachorra dourada (tipo golden retriever), coleira vermelha.
- **Bruxa da Praça**: pele verde-limão, cabelo laranja armado com galhinhos, chapéu roxo
  remendado com ninho de passarinho, vestido roxo com remendos, xale verde-escuro,
  meias listradas, um tênis vermelho e uma bota preta, vassoura de galho torto.
- **Pitbull** (cinza-azulado, coleira de espinhos), **Chihuahua** (bege, suéter rosa),
  **Cachorro da bruxa** (roxo, chapéu e capa de bruxa).

## Formato obrigatório das imagens

- Folha de sprites em **grade** (3 colunas × 2 ou 3 linhas), leitura da esquerda para a
  direita, de cima para baixo.
- Personagem **de lado, virado para a DIREITA**, do mesmo tamanho em todas as células.
- **Fundo magenta sólido (#FF00FF)**. Sem sombras, sem texto, sem números.
- Proporção 3:2 (paisagem).

Defeitos que já apareceram e que você deve **recusar e pedir correção**:
- cópias "fantasmas" semitransparentes do personagem;
- partes de um quadro invadindo a célula vizinha (vassoura, braço, cabelo);
- textos/legendas escritos nas células ("Got Hit" etc.);
- linhas extras da grade atravessando o personagem;
- personagem errado num quadro (ex.: um pitbull na folha do chihuahua);
- número de quadros diferente do pedido.

Frase de correção útil (mesma conversa):
`Regenerate it. Each frame must be completely inside its own cell, nothing crossing the
cell borders, no ghost copies, no text, no extra lines, exactly N frames.`

## Regras para colar no fim de TODOS os prompts

```
RULES:
- Use the character from the attached reference images. It must be identical in every
  frame (same colors, clothes, accessories and proportions). Only the pose changes.
- Same pixel art style, outline thickness and saturated colors as the reference.
- Side view facing RIGHT.
- All cells exactly the same size, separated by thin dark lines, the character centered
  in each cell and at the SAME SIZE in every cell.
- Each frame must be COMPLETELY inside its own cell: nothing crossing the cell borders,
  no parts of other frames, no transparent ghost copies.
- Feet on the same invisible ground line in every cell (except airborne frames).
- No text, no labels, no captions, no numbers, no extra guide lines.
- Plain solid magenta background (#FF00FF) in every cell, no shadows.
- Landscape image, 3:2 aspect ratio.
```

## Lista de imagens a gerar (em ordem de prioridade)

Para cada uma: abra uma conversa (ou use a do personagem), **anexe as referências
indicadas** (o usuário fornece os arquivos da pasta `images/` do projeto), cole o prompt +
RULES, confira os defeitos acima e baixe.

### 1. `Bruxa_Andando.jpeg` — anexar: `Bruxa_Ref.jpeg`, `Bruxa_Magia.jpeg`
```
Create a SPRITE SHEET of the witch's walking animation loop: 9 frames in a grid of 3
columns and 3 rows. A clumsy, stomping, grumpy walk, leaning forward, the broom held in
one hand close to her body, the hat wobbling, the hair bouncing. Frame 9 leads smoothly
back to frame 1.
```

### 2. `Bruxa_Vassourada.jpeg` — anexar: `Bruxa_Ref.jpeg`, `Bruxa_Magia.jpeg`
```
Create a SPRITE SHEET of the witch's broom swing attack: exactly 6 frames in a grid of 3
columns and 2 rows. 1 lifting the broom behind her with both hands, 2 winding up, 3 a big
swing forward to the RIGHT with motion lines, 4 the broom hitting with a white impact star
and flying straw, 5 follow through, almost losing her balance, 6 back to standing, grumpy.
The whole broom must stay inside each cell.
```

### 3. `Bruxa_Entrada.jpeg` — anexar: `Bruxa_Ref.jpeg`, `Bruxa_Magia.jpeg`
```
Create a SPRITE SHEET of the witch's dramatic entrance: exactly 6 frames in a grid of 3
columns and 2 rows. 1 sitting on her flying broom high in the cell, 2 descending with the
hair and shawl blowing up, 3 a clumsy landing, stumbling, 4 jumping off the broom,
5 fixing her hat, 6 pointing forward to the RIGHT with an evil cackle. The witch and the
broom must be smaller if needed to stay fully inside each cell.
```

### 4. `Dorothy_Parada.jpeg` — anexar: `Dorothy_Ref.jpeg`, `Dorothy_Correndo.jpeg`
```
Create a SPRITE SHEET of Dorothy's idle animation loop: exactly 6 frames in a grid of 3
columns and 2 rows. Standing happily, panting with the tongue out, tail wagging (the tail
in a different position in each frame), frame 3 blinking, frame 4 tilting her head,
frame 5 sniffing the ground, frame 6 back to the first pose. Every frame sharp and fully
opaque, no blur.
```

### 5. `Chihuahua_Ataque.jpeg` — anexar: `Chihuahua.jpeg`, `Chihuahua_Correndo.jpeg`
```
Create a SPRITE SHEET of the chihuahua's jumping bite attack: exactly 6 frames in a grid of
3 columns and 2 rows. ONLY this chihuahua in every frame (light tan fur, huge ears,
bulging eyes, hot pink sweater, rhinestone collar), never another dog. 1 crouching and
trembling with rage, 2 springing up, 3 flying forward with mouth open, 4 BITE in mid-air
with a small white impact star, 5 landing, 6 barking furiously.
```

### 6. `Arthur_Andando.jpeg` e `Arthur_Correndo.jpeg` — anexar: `Arthur_Ref.jpeg`, `Arthur_Defesa.jpeg`
```
Create a SPRITE SHEET of Arthur's walking animation loop: 9 frames in a grid of 3 columns
and 3 rows. A bouncy, confident walk with arms swinging opposite to the legs, happy face,
both feet close to the ground. Frame 9 leads smoothly back to frame 1.
```
```
Create a SPRITE SHEET of Arthur's running animation loop: 9 frames in a grid of 3 columns
and 3 rows. A fast run, body leaning forward, arms pumping, big strides with both feet
off the ground in the airborne frames, determined happy face. Frame 9 leads back to 1.
```

### 7. Opcional (o script já corrige as linhas): `Arthur_Ataque`, `Arthur_Pum`, `Arthur_Parado`
Mesmos prompts originais, com as RULES acima (o problema foi uma grade extra de linhas
atravessando o personagem).

## Onde salvar

O Chrome baixa em `~/Downloads`. Renomeie com **exatamente** os nomes acima e mova para
`/home/renan/IA/ArthurJornay/images/` (substituindo os antigos). Depois avise o usuário:
o Claude Code converte as folhas (`tools/build_sprites.py`) e integra no jogo.

## Estado atual (para referência)

Todas as folhas das fases 1 e 2 já foram geradas, conferidas e integradas ao jogo
(`tools/build_sprites.py`). Use esta lista só se for refazer alguma imagem ou
criar animações novas (ex.: fase 3, Lara, Arthur levando dano).

O arquivo `Gemini_Generated_Image_cpimwfcpimwfcpim.jpeg` (pulo em 8 quadros, parte de
frente) não tem uso definido: pergunte ao usuário antes de mexer.
