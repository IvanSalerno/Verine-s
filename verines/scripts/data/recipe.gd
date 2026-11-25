class_name Recipe
extends RefCounted
## Dados ORIGINAIS da receita. Nunca são alterados durante um atendimento:
## dados recuperados ficam em Game.recovered e quantidades ajustadas em AdjustedRecipe.

var id: String
var display_name: String
var description: String
var base_servings: int = 4
var price_per_serving_cents: int = 0
var prep_time_sec: int = 0                 # reservado para a mecânica de tempo
var unlocked_by_default: bool = true
var steps: Array[String] = []
var clue_ids: Array[String] = []           # preenchido a partir de Clue.recipe_ids
var challenge_ids: Array[String] = []      # desafios de recuperação de dados
## Cada linha: {ingredient_id: String, amount: float, unit: Units.Unit, hidden: bool}
## hidden = true -> dado deteriorado/ilegível; "amount" guarda o valor verdadeiro.
var lines: Array[Dictionary] = []
## Etapa com fogo/forno (cozimento cronometrado). Tempo ideal em minutos = base + por_porção × porções
## (função do 1º grau; o jogador calcula e ajusta o timer na cozinha).
var heat_step: int = -1         # índice da etapa (-1 = nenhuma)
## Etapa da montagem por arrastar ingredientes (padrão: a 1ª, "Separar os ingredientes").
var assembly_step: int = 0
## Montagem empilhada (camadas visíveis, como no hambúrguer) em vez de tigela.
var stacked: bool = false
## Ingrediente que precisa ir primeiro na montagem ("" = qualquer ordem).
var assembly_first: String = ""
## Imagem usada para a camada de cada ingrediente na montagem empilhada
## (ex.: na pizza, a farinha vira "massa_pizza"). Sem entrada = imagem do próprio ingrediente.
var layer_images: Dictionary = {}
## O prato pronto (assets/pratos/<id>.png) é desenhado de lado (3/4): servido na louça lateral.
var side_dish: bool = false
var heat_base: int = 0
var heat_per_serving: int = 0

func set_heat(step_index: int, base_minutes: int, per_serving_minutes: int) -> Recipe:
	heat_step = step_index
	heat_base = base_minutes
	heat_per_serving = per_serving_minutes
	return self

func has_heat() -> bool:
	return heat_step >= 0 and heat_step < steps.size()

func heat_minutes_for(servings: int) -> int:
	return heat_base + heat_per_serving * servings

func add_line(ingredient_id: String, amount: float, unit: Units.Unit, hidden: bool = false) -> Recipe:
	lines.append({
		"ingredient_id": ingredient_id,
		"amount": amount,
		"unit": unit,
		"hidden": hidden,
	})
	return self

func get_line(ingredient_id: String) -> Dictionary:
	for line in lines:
		if line["ingredient_id"] == ingredient_id:
			return line
	return {}
