class_name Dish
extends RefCounted
## Prato em preparo. NÃO INICIADO → EM PREPARAÇÃO → PRONTO → ENTREGUE (ou INUTILIZADO).

enum State { NOT_STARTED, PREPARING, READY, DELIVERED, UNUSABLE }

var recipe_id: String
var servings: int
var steps: Array[String] = []
var steps_done: int = 0
var state: State = State.NOT_STARTED
var ingredients_consumed: bool = false
<<<<<<< HEAD
var cook_result: String = ""   # "perfeito", "bom", "cru" ou "queimado" (etapa com fogo)
var cook_diff: int = 0         # minutos usados menos o tempo ideal
var placed: Array[String] = [] # montagem: ingredientes já colocados na tigela (etapa "Separar")
=======
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d

func _init(p_recipe_id: String, p_servings: int, p_steps: Array) -> void:
	recipe_id = p_recipe_id
	servings = p_servings
	steps.assign(p_steps)

func start() -> void:
	if state == State.NOT_STARTED:
		state = State.PREPARING

## Executa a próxima etapa. Retorna true se avançou.
func advance() -> bool:
	if state != State.PREPARING:
		return false
	steps_done += 1
	if steps_done >= steps.size():
		state = State.READY
	return true

func next_step_label() -> String:
	if steps_done < steps.size():
		return steps[steps_done]
	return ""

func to_dict() -> Dictionary:
	return {
		"recipe_id": recipe_id, "servings": servings, "steps": steps, "steps_done": steps_done,
		"state": int(state), "ingredients_consumed": ingredients_consumed,
<<<<<<< HEAD
		"cook_result": cook_result, "cook_diff": cook_diff, "placed": placed,
=======
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	}

static func from_dict(d: Dictionary) -> Dish:
	var dish := Dish.new(str(d.get("recipe_id", "")), int(d.get("servings", 1)), d.get("steps", []))
	dish.steps_done = int(d.get("steps_done", 0))
	dish.state = int(d.get("state", 0)) as State
	dish.ingredients_consumed = bool(d.get("ingredients_consumed", false))
<<<<<<< HEAD
	dish.cook_result = str(d.get("cook_result", ""))
	dish.cook_diff = int(d.get("cook_diff", 0))
	for p in d.get("placed", []):
		dish.placed.append(str(p))
=======
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	return dish
