# Verine's — propostas inspiradas em Good Pizza, Great Pizza

Base: versão 8 dos gráficos (v13 = v8 + clientes) com as mudanças da v14.
Referência: Good Pizza, Great Pizza (TapBlaze): pedidos "enigmáticos", montagem exata do pedido, forno,
reação do cliente (boa/meh/ruim) com gorjeta, esclarecimento que reduz a felicidade, upgrades de
equipamento, ciclo diário com lucro, história por capítulos, entrega e eventos.

## Já implementado na v14
| Mecânica do GPGP | Adaptação no Verine's | Matéria |
|---|---|---|
| Esclarecer o pedido custa felicidade | Pista extra e resposta errada reduzem a **felicidade do cliente** (0 a 100) | — |
| Reação do cliente + gorjeta | Felicidade vira **1 a 5 estrelas**: 5★ = +20%, 4★ = +10%, 3★ = +5%, 2★ = 0, 1★ = reembolso de 10% | Porcentagem |
| Forno com ponto certo | **Cozimento cronometrado**: tempo ideal = base + por_porção × porções; o jogador calcula e ajusta o timer. Perfeito / bom / cru / queimado | Função do 1º grau |
| Pedidos com detalhes ("só metade com...") | **Pedidos personalizados**: "50% a mais de leite", "sem queijo", "25% menos de açúcar" | Proporção e porcentagem |
| Equipamentos que facilitam o trabalho | Upgrades **Forno profissional / digital** (mais margem no cozimento) e **Cardápio ilustrado** (+gorjeta) | — |
| Reputação da pizzaria | **Reputação** (1 a 5) por média móvel das estrelas; alta (≥ 4) paga +10%, baixa (< 2) paga −10% | Média |
| Variedade diária | **Prato do dia**: +30% no valor e o dobro de chance de ser pedido | Porcentagem |
| Fechamento do dia | Resumo mostra reputação; começa o dia anunciando o prato do dia | — |

## Implementado na v20 (antigo backlog)
| Proposta | Como ficou no Verine's | Matéria | Onde ajustar |
|---|---|---|---|
| Fim de jogo por prejuízo | Aluguel e contas cobrados ao fechar o dia (R$ 12,00 + R$ 3,00 por capítulo). Começar o dia com saldo negativo **3 dias seguidos** = falência (final próprio). A ajuda do vizinho continua. | Aritmética financeira | `Game.RENT_CENTS`, `RENT_PER_CHAPTER`, `BANKRUPT_DAYS` |
| Tempo e paciência | Barra de paciência sobre o cliente (verde → amarelo → vermelho). Rápido: +5 de felicidade; demorado: −10; esgotada: −20. Pausa em menus, resultado, fim do dia e jornal. Pode ser desligada em Configurações. | — | `Flow.PATIENCE_SEC_BY_TIER` |
| Vários pratos e atendimentos simultâneos | **Fila**: a partir de 2 pedidos concluídos, chega um 2º cliente que espera ao lado do balcão (a paciência dele cai pela metade da velocidade; se acabar, ele vai embora e a reputação cai). **Segundo prato**: alguns pedidos (da Marta e do Seu Tavares) pedem a sobremesa logo depois do primeiro prato. | — | `Flow.QUEUE_*`, `followup` nos pedidos |
| Entrega/telefone | Pedidos por telefone com endereço em quadras. Na entrega: **rota** (nível 1: soma das quadras; nível 2+: Pitágoras em linha reta), **frete** (R$ 1,50/km) e troco com o frete incluído. | Geometria, Pitágoras, proporção | `ChallengeFactory.BLOCK_METERS`, `FREIGHT_CENTS_PER_KM` |
| Restrições alimentares | "Sem lactose" e "sem glúten" como regra do pedido: a receita troca os ingredientes por substitutos (mais caros, comprados na Despensa) e a montagem exige o substituto. | Custos | `GameData.RESTRICTIONS` |
| Rival e jornal do dia | **Gazeta do Bairro** no início de cada dia: manchete do capítulo, evento do dia, gráfico de barras Verine's × Cantina do Bortolo e um desafio opcional de estatística (soma, média, mediana) com bônus. | Estatística, leitura de gráficos | `GameData.RIVAL_NAME`, `ChallengeFactory.news` |
| Porção econômica × generosa | Antes de cozinhar: Econômica (−20% de ingredientes, −12 de felicidade), Normal ou Generosa (+20%, +8). | Porcentagem | `Flow.PORTION_FACTORS`, `PORTION_SATISFACTION` |
| Montagem visual e decoração | Etapa "Separar os ingredientes": **arrastar** (ou clicar) os ingredientes certos da bancada para a tigela; errado conta como erro. **Decoração** cosmética na Despensa (quadro do vovô, plantas, toalhas, luzes) aparece no Salão. | — | `cozinha_view.gd`, `salao_view.gd` |
| Capítulos, eventos e metas | 3 capítulos (pelos pedidos concluídos), cada um com uma meta e recompensa. Eventos do dia sorteados (chuva, calor, festa, promoção, crítico gastronômico, movimento intenso) com efeitos na paciência, gorjeta, compras, reputação e fila. | — | `GameData.CHAPTERS`, `GameData.EVENTS` |

## Ideias para depois
- Atender dois clientes ao mesmo tempo (dois pedidos abertos), e não só fila.
- Pedido com dois pratos preparados juntos, na mesma conta.
- Arte própria para o telefone, a fila, a tigela e a decoração (hoje são blocos).
