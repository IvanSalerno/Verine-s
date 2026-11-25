class_name AdjustedRecipe
extends RefCounted
## Receita ajustada para UM pedido (porções do cliente e personalizações como "50% a mais de
## queijo" ou "sem cebola"). Não altera a receita original.

var recipe_id: String
var servings: int
var base_servings: int
## Cada linha: {ingredient_id, original_id, amount (na unidade da receita), unit, base_needed (int, unidade base), known}
## ingredient_id pode ser um substituto (ex.: leite sem lactose) por causa de uma restrição alimentar;
## original_id é sempre o ingrediente escrito na receita.
var lines: Array[Dictionary] = []

## mods: lista de {ingredient_id, percent}. percent = +50 (50% a mais), -25 (25% a menos), -100 (sem).
## restrictions: ids de GameData.RESTRICTIONS (ex.: "sem_lactose") -> troca pelos substitutos.
static func build(recipe: Recipe, p_servings: int, recovered: Dictionary, mods: Array = [], restrictions: Array = []) -> AdjustedRecipe:
	var a := AdjustedRecipe.new()
	a.recipe_id = recipe.id
	a.servings = p_servings
	a.base_servings = recipe.base_servings
	for line in recipe.lines:
		var ing_id: String = line["ingredient_id"]
		var use_id: String = GameData.substitute_for(ing_id, restrictions)
		var unit: Units.Unit = line["unit"]
		var ing: Ingredient = GameData.ingredients[ing_id]
		if not Units.compatible(unit, ing.unit):
			push_error("Unidade incompatível em %s / %s" % [recipe.id, ing_id])
		var percent := 0
		for m in mods:
			if m["ingredient_id"] == ing_id:
				percent = int(m["percent"])
		var known := true
		var base_amount: float = line["amount"]
		if line["hidden"]:
			known = recovered.has(recipe.id) and recovered[recipe.id].has(ing_id)
			if known:
				base_amount = recovered[recipe.id][ing_id]
		if percent <= -100:
			known = true   # ingrediente removido a pedido do cliente: não precisa recuperar
			a.lines.append({"ingredient_id": use_id, "original_id": ing_id, "amount": 0.0, "unit": unit, "base_needed": 0, "known": true})
			continue
		var scaled := 0.0
		var needed := 0
		if known:
			scaled = base_amount * p_servings / float(recipe.base_servings) * (1.0 + percent / 100.0)
			needed = ceili(Units.to_base(scaled, unit))
		a.lines.append({
			"ingredient_id": use_id,
			"original_id": ing_id,
			"amount": scaled,
			"unit": unit,
			"base_needed": needed,
			"known": known,
		})
	return a

## Cópia com as quantidades multiplicadas (porção econômica/generosa).
func scaled(factor: float) -> AdjustedRecipe:
	var a := AdjustedRecipe.new()
	a.recipe_id = recipe_id
	a.servings = servings
	a.base_servings = base_servings
	for line in lines:
		var l: Dictionary = line.duplicate()
		l["amount"] = float(line["amount"]) * factor
		l["base_needed"] = ceili(int(line["base_needed"]) * factor) if int(line["base_needed"]) > 0 else 0
		a.lines.append(l)
	return a

## Ingredientes que precisam ir para a tigela na montagem (ids já substituídos).
func required_ids() -> Array[String]:
	var out: Array[String] = []
	for line in lines:
		if int(line["base_needed"]) > 0:
			out.append(str(line["ingredient_id"]))
	return out

func is_complete() -> bool:
	for line in lines:
		if not line["known"]:
			return false
	return true
