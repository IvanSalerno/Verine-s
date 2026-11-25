# Verine's — protótipo Godot 4 (GDScript)

## Como abrir
1. Abra a pasta no Godot 4.3+ (Importar → project.godot). Aguarde o editor indexar os `class_name`.
2. Aperte F5 (cena principal: `scenes/main.tscn`).

## Arquitetura
- Autoloads (ordem importa): `GameData` (catálogo) → `Game` (dinheiro, estoque, melhorias) → `Flow` (estados e regras do atendimento).
- `scripts/core`: Units, Money (centavos), AnswerValidator, ChallengeFactory, GameStates.
- `scripts/data`: Ingredient, Recipe (dados originais), AdjustedRecipe (ajuste por pedido), Clue, Order, Dish, Upgrade, MathChallenge.
- `scripts/ui/main.gd`: toda a interface por código, só mouse (desafios com 4 alternativas A–D).

## Para a equipe definir
Catálogo definitivo, balanceamento (valores em `Flow`), história/desfecho, tempo e pedidos simultâneos (v2).

## Imagens
Copie as imagens dos clientes para `assets/clientes/` com estes nomes:
- `cliente_vermelho.png` (Cliente, casaco com camisa vermelho.png)
- `cliente_azul.png` (Cliente_loiro_camisa_azul.png)
- `cliente_amarelo.png` (Cliente_moleton_amarelo.png)
Sem as imagens, o jogo mostra blocos coloridos no lugar. Depois de copiar, abra o editor do Godot para ele importar os arquivos.
Cena do restaurante: `scenes/restaurant_view.tscn` (edite os blocos no editor).

## Placar e dias
- Placar de pontos no canto superior direito; contador de dias no centro superior.
- O dia fecha a cada 2 pedidos concluídos (`Flow.ORDERS_PER_DAY`). No fim do dia há um desafio de gestão opcional (bônus em dinheiro e pontos).
- Recorde salvo em `user://verines.cfg`.
- Matérias: razão/proporção, unidades, geometria, estatística, probabilidade, combinatória, equações, função, sistema, PA, juros compostos, raiz quadrada e matrizes (`scripts/core/math_topics.gd`).

## Páginas (v6)
- Salão (`scenes/salao_view.tscn`): atendimento, investigação e entrega.
- Cozinha (`scenes/cozinha_view.tscn`): ajuste de quantidades (desafios) e preparo.
- Despensa e escritório (`scenes/despensa_view.tscn`): estoque, compras, melhorias.
- Menu inicial: Novo jogo, Continuar, Configurações, Créditos. Menu de jogo (☰ no canto superior esquerdo): Salvar, Configurações, Menu principal.
- Salvamento em `user://verines_save.json` (manual pelo ☰ e automático a cada novo dia). Créditos: edite `scripts/data/credits.gd`.
- Atenção: esta versão adiciona o autoload `Settings` ao project.godot.

## Imagens dos cenários
Coloque em `assets/cenarios/` (PNG, formato bem largo, ideal 1248×230 px ou o dobro, 2496×460):
- `salao.png`, `cozinha.png`, `despensa.png`
Se o arquivo existir, ele vira o fundo da página e os blocos coloridos somem. Sem o arquivo, a blocagem continua.

## Imagens (v8) — pasta assets/cenarios/
- `salao.png`: atendimento ao cliente (Salão)
- `caixa_registradora.png`: pagamento e troco (entrega)
- `cozinha.png`: ajuste das quantidades e prato pronto
- `preparacao.png`: etapas de preparo (separar, misturar, montar, finalizar)
- `fogao.png`: etapas com fogo (assar, cozinhar, fritar, aquecer, calda)
- `livro_receitas.png` (ou `livro de receitas.png`): fundo do menu inicial
- `despensa.png`: opcional (sem ela, a Despensa usa blocos)

## Clientes (v13, base v8)
Arquivos `cliente_<nome>.png` (vermelho, azul, amarelo, careca, alto, oculos, cracha), em `assets/clientes/`
(também aceita `assets/cenarios/`, `assets/` e a raiz do projeto). Cada personagem usa sempre a mesma imagem;
a tabela está em `scripts/ui/salao_view.gd` (constante `CUSTOMER_LOOK`) e pode ser editada.
Imagens não encontradas são avisadas na aba Saída do Godot.

## Novas mecânicas (v14) — inspiradas em Good Pizza, Great Pizza
Veja `PROPOSTAS.md` (o que foi feito e o que ficou no backlog).
- Cozimento cronometrado: tempo ideal = base + por_porção × porções (receitas em `GameData._build_heat`).
- Pedidos personalizados (`mods` nos pedidos): +50% / −25% / sem ingrediente.
- Felicidade -> estrelas -> gorjeta/reembolso; reputação; prato do dia.
- Upgrades: forno profissional, forno digital, cardápio ilustrado.

## Balão de fala (v15)
- O pedido do cliente e o enunciado dos desafios ligados a ele aparecem num balão ao lado do cliente,
  no Salão (`scripts/ui/speech_bubble.gd`), e não mais no painel de baixo.
- Quais desafios vão para o balão: constante `BUBBLE_CHALLENGE_CONTEXTS` em `scripts/ui/salao_view.gd`
  (`"order"` = ajuste da receita, `"delivery"` = porções e troco). Planejamento de compras e desafio
  de gestão do dia não têm cliente e continuam no painel.
- Posição e largura: `BUBBLE_POS` e `BUBBLE_WIDTH` em `salao_view.gd`. Cores e bordas: `speech_bubble.gd`.
- Textos longos diminuem a fonte automaticamente para caber no balão (mínimo 11).

## Alternativas A–D (v16)
- Não há mais teclado: toda questão tem 4 alternativas (A, B, C, D) num bloco branco logo abaixo do enunciado
  (dentro do balão, nos desafios do cliente; no painel, nos demais).
- Clicar numa alternativa já responde: certa fica verde; errada fica vermelha, é desativada e conta como erro.
- `scripts/core/choice_maker.gd` converte qualquer desafio (inteiro, decimal, dinheiro, fração, matriz) em
  múltipla escolha, gerando 3 erradas plausíveis (dobro/metade, ±1 passo, ±10%, fração complementar,
  ordem trocada etc.). É chamado em `Flow.begin_challenge()`; os geradores de desafio não precisam mudar.
- O formato das alternativas vem do enunciado: "em reais" → R$; "porcentagem" → %; "(responda em g)" ou
  "Quantos gramas/ml/minutos/metros" → número com unidade.
- Durante um desafio no balão, o Salão fica mais alto (`CHALLENGE_HEIGHT` em `salao_view.gd`).

## Tela cheia e balões (v17)
- A faixa cinza do meio saiu: a cena da página (Salão, Cozinha, Despensa) ocupa a tela toda, ao fundo.
- Tudo o que era texto/botão no painel de baixo agora fica num balão creme com borda marrom e cantos
  arredondados: à esquerda (cena visível à direita) durante o jogo; centralizado nos menus, no livro de
  receitas, nas configurações e nos desafios sem cliente. Texto longo rola dentro do balão.
- Saldo, dia e pontos ficam em balõezinhos na barra superior; avisos aparecem num balão no rodapé e somem
  depois de alguns segundos.
- Cores e bordas de toda a interface: `scripts/ui/ui_style.gd` (tema aplicado em `main.gd`).
- Blocagem das cenas refeita para 1280×720 (os elementos ficam de x ≈ 570 em diante, ao lado do balão).
  Edite os blocos no editor se quiser reposicionar algo.
- Imagens de fundo: agora o ideal é 1280×720 (16:9) ou 2560×1440. Imagens largas antigas (1248×230)
  vão aparecer ampliadas e cortadas nas laterais, porque preenchem a tela mantendo a proporção.

## Tela cheia e qualquer monitor (v18)
- O jogo abre em tela cheia (`window/size/mode=3`) e se adapta à proporção do monitor
  (`window/stretch/aspect="expand"`): 16:9, 16:10, 4:3, ultrawide...
- Configurações > Tela cheia continua funcionando (salvo como `fullscreen_v2`, ligado por padrão).
- Os elementos de cada cena ficam no nó `Palco` (1280×720, preso ao canto inferior direito). Em telas mais
  largas o espaço extra aparece à esquerda, atrás do balão de informações; em telas mais altas, em cima
  (a parede da blocagem estica). Piso, parede e imagem de fundo cobrem a tela toda.
- O balão de fala do cliente fica dentro do Palco, acompanhando o cliente.
- Correção: o enunciado dos desafios do cliente aparece sempre no balão de fala (antes podia sumir se o
  cliente estivesse escondido ou se a limpeza do texto falhasse).

## Escolha da receita pelo livro (v19)
- O atendimento não lista mais todas as receitas. O cliente faz o pedido no balão de fala e, logo abaixo,
  um bloco branco mostra só os NOMES das receitas desbloqueadas.
- Para decidir, abra o livro de receitas (botão "Abrir o livro de receitas" ou "Livro de receitas" no topo).
  Com um cliente esperando, o livro abre no balão lateral e o cliente continua à vista, com os nomes no balão
  dele: dá para escolher direto do livro.
- Nome errado: fica vermelho, é desativado e conta como erro (reduz o pagamento), como antes.
- Pistas e "Pedir pista extra" continuam no balão de informações. Lógica nova: `Flow.choose_recipe()`.

## Correção importante (v19)
- A cena, o cliente e o balão de fala não apareciam desde a v17: as camadas de tela cheia eram ancoradas
  com `set_anchors_preset()`, que mantém o tamanho atual (zero). Agora usam
  `set_anchors_and_offsets_preset()`, e a cena ocupa a tela toda.

## Backlog implementado (v20)
Veja a tabela completa em `PROPOSTAS.md`. Resumo: contas diárias e falência; paciência dos clientes
(desligável); fila de 2 clientes e segundo prato; pedidos por telefone (rota/Pitágoras e frete);
restrições alimentares com substitutos; Gazeta do Bairro (rival, gráfico, evento do dia, desafio de
estatística); porção econômica/generosa; montagem por arrastar ingredientes; decoração do Salão;
capítulos com metas.
- Novos arquivos: `scripts/ui/ingredient_chip.gd`, `drop_bowl.gd`, `bar_chart.gd`.
- Novo estado `NEWSPAPER` (no fim do enum, os saves antigos continuam válidos).
- Novos ingredientes: leite e queijo sem lactose, farinha e macarrão sem glúten (estoque inicial zero).

## Introdução em 3 cenas (v21)
- "Novo jogo" abre a história: 3 cenas em tela cheia, cada uma com imagem e legenda num balão creme.
- Botão "Próximo" (na última cena, "Começar"): **clicar** passa de cena; **segurar 1 segundo** pula a
  introdução e começa o jogo na hora (uma barrinha no botão mostra o tempo).
- Imagens: `assets/intro/cena_1.png`, `cena_2.png`, `cena_3.png` (aceita .jpg/.webp; ideal 1920×1080).
  Sem imagem, aparece um fundo liso com o nome do arquivo esperado.
- Textos das cenas, tempo de segurar e duração do fade: constantes no topo de `scripts/ui/intro_story.gd`.

## Personagens fixos (v22)
Os clientes são 7 personagens fixos, cada um com a sua imagem em `assets/clientes/`:
João (`cliente_cracha`), Felipe (`cliente_oculos`), Marta (`cliente_vermelho`, a única mulher),
Pedro (`cliente_azul`), Caio (`cliente_amarelo`), Seu Tavares (`cliente_careca`) e Rafael (`cliente_alto`).
Os 24 pedidos foram distribuídos entre eles (`GameData`); a ligação nome → imagem está em
`CUSTOMER_LOOK` (`salao_view.gd`). O mesmo personagem não é chamado duas vezes seguidas.

## Imagens dos ingredientes e Hambúrguer (v23)
- **Imagens dos ingredientes**: coloque em `assets/ingredientes/` com o id do ingrediente como nome
  (aceita .png, .webp, .jpg). Arquivos esperados: farinha.png, acucar.png, macarrao.png, molho_tomate.png, queijo.png, leite.png, ovo.png, leite_zero.png, queijo_zero.png, farinha_sg.png, macarrao_sg.png, pao_hamburguer.png, carne_hamburguer.png, alface.png, tomate.png.
  Ideal: 128×128 com fundo transparente. Sem imagem, aparece um círculo colorido.
  Elas aparecem nas fichas da bancada, na tigela, na animação e na lista de ingredientes da cozinha.
- **Hambúrguer da Casa** (receita nova, liberada desde o início): pão, carne, queijo, alface e tomate.
  Etapas: grelhar a carne (timer) → montar o hambúrguer → servir. Pistas: lanche, grelhado, pão, camadas.
  4 pedidos novos (Pedro, Caio, Felipe sem lactose, Rafael com +50% de queijo). Estoque inicial incluído.
- **Animações da montagem**: o ingrediente voa em arco da ficha até a tigela, gira e cai com um "pulinho";
  a tigela achata e volta. No hambúrguer, cada ingrediente cai do alto e quica como uma camada, e no fim a
  tampa do pão (com gergelim) cai por cima. Ingrediente errado: a ficha balança e pisca em vermelho.
  Ajustes: constantes no topo de `scripts/ui/cozinha_view.gd` (tempos, tamanho das camadas).
- Receita com montagem em outra etapa ou empilhada: `Recipe.assembly_step` e `Recipe.stacked`.

## Hambúrguer com imagens e primeiro pedido (v24)
- O primeiro pedido do jogo (tutorial, João) agora é um Hambúrguer da Casa para 2. Estoque inicial inclui queijo.
- Imagens em `assets/ingredientes/`: `pao_hamburguer_base.png` (metade de baixo), `carne_hamburguer.png`,
  `queijo.png`, `alface.png`, `tomate.png` e `pao_hamburguer.png` (tampa com gergelim, também usada na ficha).
  Os arquivos foram recortados e o fundo branco virou transparente.
- Na montagem do hambúrguer as camadas usam essas imagens; o pão precisa ir primeiro (a base), e a tampa cai
  no final. Encaixe das camadas: `IMG_WIDTHS`, `IMG_STEPS` e `TOP_BUN_OVERLAP` em `cozinha_view.gd`.

## Assets na identidade visual + Pizza (v25)
- **Ajuste de estilo dos ingredientes**: os assets planos (fundo branco, cores saturadas) passam por
  `tools/stylize_assets.py`: fundo transparente, saturação menor, tom quente, sombra suave nas bordas,
  grão de papel e contorno marrom-escuro (o mesmo das linhas da cozinha e dos personagens).
  Uso: `python3 tools/stylize_assets.py original.png assets/ingredientes/nome.png`.
  Os originais ficam em `assets/originais/` (ignorada pelo Godot).
- **Novos assets**: `macarrao.png`, `molho_tomate.png`, `queijo_ralado.png` (ingredientes);
  `assets/pratos/macarrao_ao_molho.png`, `pizza.png` (pratos prontos) e `prato.png` (louça);
  `cenarios/cozinha.png` e `cenarios/livro_receitas.png` (menu); `clientes/cliente_cracha.png` (João) e
  `cliente_oculos.png` (Felipe). As imagens do hambúrguer também foram reestilizadas.
- **Pratos prontos**: quando o prato fica pronto, ele aparece sobre a louça na bancada (com um "pop").
  A foto do prato também aparece no livro de receitas. Arquivo: `assets/pratos/<id_da_receita>.png`.
- **Hambúrguer**: montado sobre a louça (imagem achatada em perspectiva).
- **Pizza de Queijo** (receita nova): farinha, molho de tomate e queijo ralado; abrir a massa → assar →
  servir. Pistas: redonda, massa aberta, forno, molho, queijo derretido. 3 pedidos (Caio, Marta e João por
  telefone). Sem lactose troca o queijo ralado pelo queijo sem lactose.
- **Despensa**: as barras de estoque mostram a imagem do ingrediente e a quantidade (nome ao passar o mouse).

## Pizza em perspectiva (v26)
- A pizza e seus ingredientes agora têm vista lateral 3/4, como o hambúrguer: `massa_pizza.png` (massa crua,
  nova), `molho_tomate.png`, `queijo_ralado.png`, `pratos/pizza.png` e a louça lateral `pratos/prato_lateral.png`.
  Geradas a partir das imagens vistas de cima por `tools/perspective_assets.py` (achata a imagem e dá
  espessura com cópias mais escuras por baixo) + o mesmo estilo de `stylize_assets.py`.
- A pizza é montada em camadas no prato: farinha (vira a massa) → molho → queijo ralado; depois vai ao forno.
  Etapas: Montar a pizza → Assar no forno → Servir.
- Hambúrguer e pizza são montados e servidos sobre a louça lateral; `pratos/hamburguer.png` (hambúrguer pronto)
  foi gerado a partir das camadas.
- `Recipe.layer_images` escolhe a imagem de cada camada (ex.: farinha → massa_pizza; queijo sem lactose → queijo).

## Sprites que faltavam (v27)
- **Ingredientes desenhados** (no estilo do jogo: contorno marrom, cores quentes, rótulos creme):
  `farinha` (saco de papel + montinho), `farinha_sg` (faixa verde "sem glúten"), `acucar` (pote de vidro com
  tampa de madeira, como os potes do salão), `leite` (caixinha azul), `leite_zero` (caixinha verde
  "zero lactose"), `ovo` (três ovos), `macarrao` (feixe de espaguete com cinta "Macarrão"), `macarrao_sg`
  (cinta verde) e `queijo_zero` (fatia com etiqueta "sem lactose"). O ninho de macarrão antigo foi guardado
  em `assets/originais/`.
- **Pratos prontos** (vista 3/4, servidos na louça lateral): `bolo`, `pudim_verine`, `lasanha`, `panqueca`
  (mais `pizza` e `hamburguer`). `Recipe.side_dish` indica pratos desenhados de lado.
- Scripts: `tools/draw_ingredient_sprites.py` e `tools/draw_dish_sprites.py` desenham; `stylize_assets.py`
  aplica o estilo. Todos os 16 ingredientes e 7 pratos agora têm imagem.
