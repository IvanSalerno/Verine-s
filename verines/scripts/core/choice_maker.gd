class_name ChoiceMaker
extends RefCounted
## Transforma qualquer desafio (inteiro, decimal, dinheiro, fração, valores com ";")
## em múltipla escolha com 4 alternativas (A, B, C, D): a correta + 3 erradas plausíveis.
## É chamado em Flow.begin_challenge(), então os geradores de desafio não precisam mudar.
##
## Formato das alternativas, deduzido do enunciado:
##   "em reais"            -> dinheiro (R$ 12,50)
##   "porcentagem"         -> 50%
##   "(responda em g)", "Quantos gramas/ml/minutos/metros" -> número + unidade
##   tipo FRACTION         -> fração simplificada (3/4)
##   tipo STRUCTURED       -> "13; 14"

const CHOICE_COUNT := 4
const LETTERS: Array[String] = ["A", "B", "C", "D"]
const FILLER := "Nenhuma das anteriores"

## Converte o desafio no lugar. Desafios que já são de múltipla escolha só são completados/cortados para 4.
static func prepare(c: MathChallenge, rng: RandomNumberGenerator) -> void:
	if c == null:
		return
	if c.type == MathChallenge.Type.MULTIPLE_CHOICE:
		_fit_existing(c)
		c.statement = _clean_statement(c.statement)
		return
	var fmt := _detect_format(c)
	var correct_text := ""
	var wrong: Array[String] = []
	match c.type:
		MathChallenge.Type.FRACTION:
			var e: Array = c.expected
			correct_text = _fmt_fraction(int(e[0]), int(e[1]))
			wrong = _fraction_distractors(int(e[0]), int(e[1]), rng)
		MathChallenge.Type.STRUCTURED:
			var vals: Array = c.expected
			correct_text = _fmt_list(vals)
			wrong = _list_distractors(vals, rng)
		_:
			var v := float(c.expected)
			var integer := c.type == MathChallenge.Type.INTEGER
			correct_text = _fmt_number(v, fmt)
			wrong = _number_distractors(v, integer, fmt, rng)
	var all: Array[String] = [correct_text]
	for w in wrong:
		if all.size() >= CHOICE_COUNT:
			break
		if not (w in all):
			all.append(w)
	while all.size() < CHOICE_COUNT:
		all.append(FILLER if not (FILLER in all) else "%s (%d)" % [FILLER, all.size()])
	# embaralha mantendo o registro da correta
	var order: Array = range(CHOICE_COUNT)
	for i in range(order.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = order[i]
		order[i] = order[j]
		order[j] = tmp
	c.choices.clear()
	for k in order:
		c.choices.append(all[int(k)])
	c.expected = order.find(0)
	c.type = MathChallenge.Type.MULTIPLE_CHOICE
	c.tolerance = 0.0
	c.statement = _clean_statement(c.statement)

## Texto do botão: "A) R$ 12,50".
static func label(index: int, text: String) -> String:
	return "%s) %s" % [LETTERS[index] if index < LETTERS.size() else str(index + 1), text]

# ------------------------------------------------------------------ formato
static func _detect_format(c: MathChallenge) -> String:
	var s := c.statement.to_lower()
	var lines := s.split("\n", false)
	var question: String = lines[lines.size() - 1] if lines.size() > 0 else s
	if "em reais" in s:
		return "money"
	if "porcentagem" in question:
		return "percent"
	var rx := RegEx.create_from_string("\\(responda em ([^)]+)\\)")
	var m := rx.search(c.statement)
	if m != null:
		return "unit:" + m.get_string(1).strip_edges()
	var units := {"gramas": "g", "mililitros": "ml", " ml ": "ml", "minutos": "min",
		"cm²": "cm²", "m²": "m²", "metros": "m"}
	for key in units:
		if key in question:
			return "unit:" + str(units[key])
	return "plain"

static func _fmt_number(v: float, fmt: String) -> String:
	if fmt == "money":
		return Money.format(roundi(v * 100.0))
	var txt := Units.fmt_amount(v)
	if fmt == "percent":
		return txt + "%"
	if fmt.begins_with("unit:"):
		return "%s %s" % [txt, fmt.substr(5)]
	return txt

## Tira do enunciado as instruções de digitação (agora há alternativas).
## Se algo der errado na limpeza, devolve o enunciado original (nunca some com a questão).
static func _clean_statement(text: String) -> String:
	var cleaned := _clean_statement_raw(text)
	return cleaned if cleaned.strip_edges() != "" else text

static func _clean_statement_raw(text: String) -> String:
	var t := text
	var rx_paren := RegEx.create_from_string("\\s*\\((responda em [^)]*|ex\\.:[^)]*|em reais[^)]*|só o número[^)]*|fração[^)]*)\\)")
	if rx_paren.is_valid():
		t = rx_paren.sub(t, "", true)
	t = t.replace("Responda separando por ponto e vírgula:", "As alternativas mostram:")
	var rx_matrix := RegEx.create_from_string("Responda em ordem de leitura ([^,]*\\)), separados por ponto e vírgula\\.\\s*Ex\\.:[0-9; ]*")
	if rx_matrix.is_valid():
		t = rx_matrix.sub(t, "As alternativas mostram os valores em ordem de leitura $1.", true)
	return t.strip_edges()

# ------------------------------------------------------------ distratores
## Erros típicos: dobro/metade, somar ou tirar um "passo", errar 10%, etc.
static func _number_distractors(v: float, integer: bool, fmt: String, _rng: RandomNumberGenerator) -> Array[String]:
	var step := _nice_step(absf(v), integer, fmt)
	var raw: Array[float] = [v + step, v - step, v * 2.0, v / 2.0, v + 2.0 * step, v - 2.0 * step,
		v * 1.1, v * 0.9, v * 1.5, v + 3.0 * step]
	# os três primeiros vêm de um sorteio entre os erros "mais próximos" e os "conceituais"
	var near: Array[float] = [raw[0], raw[1], raw[4], raw[5], raw[9]]
	var concept: Array[float] = [raw[2], raw[3], raw[6], raw[7], raw[8]]
	near.shuffle()
	concept.shuffle()
	var ordered: Array[float] = [near[0], concept[0], near[1], concept[1], near[2], concept[2], near[3], concept[3]]
	var correct_text := _fmt_number(v, fmt)
	var out: Array[String] = []
	for x in ordered:
		var y := x
		if integer:
			if absf(y - roundf(y)) > 0.0001:
				continue
			y = roundf(y)
		elif fmt == "money":
			y = roundf(y * 100.0) / 100.0
		else:
			y = roundf(y * 100.0) / 100.0
		if v > 0.0 and y <= 0.0:
			continue
		var txt := _fmt_number(y, fmt)
		if txt != correct_text and not (txt in out):
			out.append(txt)
		if out.size() >= CHOICE_COUNT - 1:
			return out
	# reserva: passos cada vez maiores para cima
	var k := 4.0
	while out.size() < CHOICE_COUNT - 1 and k < 30.0:
		var txt2 := _fmt_number(roundf((v + k * step) * 100.0) / 100.0, fmt)
		if txt2 != correct_text and not (txt2 in out):
			out.append(txt2)
		k += 1.0
	return out

static func _nice_step(a: float, integer: bool, fmt: String) -> float:
	if fmt == "money":
		if a < 5.0:
			return 0.5
		if a < 20.0:
			return 1.0
		if a < 100.0:
			return 5.0
		return 10.0
	var target := a * 0.1
	for s in [0.5, 1.0, 2.0, 5.0, 10.0, 20.0, 25.0, 50.0, 100.0, 250.0, 500.0]:
		if integer and s < 1.0:
			continue
		if s >= target:
			return s
	return 1000.0

static func _gcd(a: int, b: int) -> int:
	a = absi(a)
	b = absi(b)
	while b != 0:
		var t := b
		b = a % b
		a = t
	return maxi(a, 1)

static func _fmt_fraction(n: int, d: int) -> String:
	var g := _gcd(n, d)
	return "%d/%d" % [n / g, d / g]

static func _fraction_distractors(n: int, d: int, _rng: RandomNumberGenerator) -> Array[String]:
	var g := _gcd(n, d)
	var rn := n / g
	var rd := d / g
	var cands: Array = [[d - n, d], [n + 1, d], [n - 1, d], [rn, rd + 1], [rn + 1, rd + 1],
		[rn, rd * 2], [rd - rn, rd + rn], [n, d + n], [rn + 1, rd]]
	var head: Array = cands.slice(0, 5)
	head.shuffle()
	cands = head + cands.slice(5)
	var correct := _fmt_fraction(n, d)
	var out: Array[String] = []
	for f in cands:
		var a := int(f[0])
		var b := int(f[1])
		if a <= 0 or b <= 0 or a > b:
			continue
		var txt := _fmt_fraction(a, b)
		if txt != correct and not (txt in out) and txt != "1/1":
			out.append(txt)
		if out.size() >= CHOICE_COUNT - 1:
			break
	return out

static func _fmt_list(vals: Array) -> String:
	var parts: PackedStringArray = []
	for x in vals:
		parts.append(Units.fmt_amount(float(x)))
	return "; ".join(parts)

## Erros típicos em matrizes: ordem trocada, um elemento errado, todos deslocados.
static func _list_distractors(vals: Array, rng: RandomNumberGenerator) -> Array[String]:
	var correct := _fmt_list(vals)
	var cands: Array = []
	var rev := vals.duplicate()
	rev.reverse()
	cands.append(rev)
	for i in vals.size():
		var one := vals.duplicate()
		one[i] = float(one[i]) + (rng.randi_range(1, 3) * (1 if rng.randf() < 0.5 else -1))
		cands.append(one)
	var shifted := vals.duplicate()
	for i in shifted.size():
		shifted[i] = float(shifted[i]) + 2.0
	cands.append(shifted)
	cands.shuffle()
	var out: Array[String] = []
	for arr in cands:
		var ok := true
		for x in arr:
			if float(x) <= 0.0:
				ok = false
		if not ok:
			continue
		var txt := _fmt_list(arr)
		if txt != correct and not (txt in out):
			out.append(txt)
		if out.size() >= CHOICE_COUNT - 1:
			break
	return out

## Múltipla escolha que já existia: completa até 4 ou corta mantendo a correta.
static func _fit_existing(c: MathChallenge) -> void:
	var correct := int(c.expected)
	while c.choices.size() < CHOICE_COUNT:
		c.choices.append(FILLER)
	while c.choices.size() > CHOICE_COUNT:
		var drop := c.choices.size() - 1
		if drop == correct:
			drop -= 1
		c.choices.remove_at(drop)
