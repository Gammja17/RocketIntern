extends SceneTree
## 경우의 수 탐색: godot --headless --path . -s tools/explore.gd -- <판 수> [씨앗]
## 성향이 제각각인 가상 플레이어로 끝까지 돌리고, 서로 다른 결말 조합(결말 · 로사 · 로이 · 세나 · 나옹 · 원룸 식구)을 센다.
## 대본의 분기점(선택지 · 사연 있는 상자) 수도 함께 센다.

var rng := RandomNumberGenerator.new()
var persona := {}


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var runs := int(args[0]) if args.size() > 0 else 200
	rng.seed = int(args[1]) if args.size() > 1 else 7
	seed(rng.seed)
	Engine.time_scale = 50.0   # 연출 애니메이션을 기다리지 않게
	_count_branches()
	var combos := {}
	var endings := {}
	var fates := {"rosa": {}, "roy": {}, "sena": {}, "meowth": {}}
	var stuck := 0
	for r in runs:
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://save.json"))
		persona = {
			"release": rng.randf_range(0.0, 0.3), "named_bias": rng.randf_range(0.0, 0.8),
			"return": rng.randf_range(0.0, 1.0), "special": rng.randf() < 0.7, "meadow": rng.randf(),
			"cap": rng.randf_range(40.0, 90.0), "heat_cap": rng.randf_range(30.0, 110.0),
		}
		var m = load("res://scenes/main.tscn").instantiate()
		root.add_child(m)
		await process_frame
		var guard := 0
		var last_day := -1
		while m.waiting != "end" and guard < 30000:
			guard += 1
			if OS.has_environment("EXPLORE_TRACE") and not m.st.is_empty() and m.st.day != last_day:
				last_day = m.st.day
				print("  day ", last_day, " money ", m.st.money, " susp ", m.st.susp, " heat ", m.st.heat)
			match m.waiting:
				"title", "dialog":
					m._advance()
				"choice":
					m._on_choice(_pick(m, m.choice_options))
				"work":
					_work(m)
				_:
					await process_frame
		if m.waiting != "end":
			stuck += 1
			print("멈춤: ", m.st.get("day"), " ", m.waiting)
		else:
			var e: String = m.st.get("ending", "?")
			var f: Dictionary = m.st.get("fates", {})
			var home := PackedStringArray(m.st.home.keys())
			home.sort()
			# 한 달 뒤 신문: 어떤 기사가 붙었는지 (조건이 맞은 기사 번호)
			var news := PackedStringArray()
			var ep: Array = load("res://scripts/data/week4.gd").EPILOGUE
			for i in ep.size():
				if ep[i].t == "say" and (not ep[i].has("if") or m._check(ep[i]["if"])):
					news.append(str(i))
			var sig := "%s|%s|%s|%s|%s|%s|%s" % [e, f.get("rosa"), f.get("roy"), f.get("sena"), f.get("meowth"), ",".join(home), ",".join(news)]
			combos[sig] = combos.get(sig, 0) + 1
			print("SIG ", sig)
			endings[e] = endings.get(e, 0) + 1
			for who in fates:
				fates[who][f.get(who)] = fates[who].get(f.get(who), 0) + 1
		m.queue_free()
		await process_frame
	print("판 수 %d · 멈춤 %d" % [runs, stuck])
	var core := {}
	var with_home := {}
	for sig in combos:
		var parts: PackedStringArray = sig.split("|")
		core["|".join(parts.slice(0, 5))] = true
		with_home["|".join(parts.slice(0, 6))] = true
	print("1) 큰 결말 × 동료 운명: %d" % core.size())
	print("2) + 원룸 식구: %d" % with_home.size())
	print("3) + 한 달 뒤 신문 (결말 화면 전체): %d" % combos.size())
	print("결말: ", endings)
	for who in fates:
		print("  %s: %s" % [who, fates[who]])
	quit()


func _pick(m, opts: Array) -> int:
	var texts := opts.map(func(o): return o.text)
	if texts.has("처음부터"):
		return texts.find("처음부터")
	if texts[0].begins_with("레버를"):
		return 0 if rng.randf() < 0.3 else texts.size() - 1
	if texts[0].begins_with("몸통박치기"):
		return rng.randi_range(0, 2)
	# 풀밭: 성향에 따라 먹이 · 놀기 · 입양
	if texts[0].begins_with("먹이를"):
		for i in texts.size():
			if "데려간다" in texts[i] and rng.randf() < persona.meadow:
				return i
		if rng.randf() < persona.meadow:
			return rng.randi_range(0, texts.size() - 2)
		return texts.size() - 1
	return rng.randi_range(0, opts.size() - 1)


func _work(m) -> void:
	var c: Dictionary = m.crates[m.crate_i]
	var p: float = persona.release
	if c.get("named", false) or c.has("stray"):
		p = lerp(p, 1.0, persona.named_bias * 0.8)
	if c.get("reject", false):
		p = 0.8
	if c.get("wanted", false):
		p *= 0.3
	# 사람처럼: 의심도가 한계에 가까우면 덜 풀어주고, 월세가 모자라거나 수사망이 괜찮으면 더 보낸다
	var risk := int(c.get("risk", 10) * m.days[m.st.day].get("risk_mult", 1.0))
	if m.st.susp + risk >= persona.cap:
		p *= 0.15
	if m.st.money < 6000:
		p *= 0.6
	if m.st.heat >= persona.heat_cap and c.get("named", false):
		p = maxf(p, 0.8)
	if m.special_btn.visible and persona.special:
		m._on_special()
	elif rng.randf() < p:
		if m.return_btn.visible and rng.randf() < persona.return and m.st.money > 2000:
			m._on_return()
		else:
			m._on_release()
	else:
		m._on_send()


## 대본의 분기점: 선택지(둘 이상) + 사연 있는 상자(보내기 · 풀어주기 · 돌려보내기 · 특별 행동이 서로 다른 결과로 이어짐).
func _count_branches() -> void:
	var days: Array = load("res://scripts/data/week1.gd").DAYS + load("res://scripts/data/week2.gd").DAYS + load("res://scripts/data/week3.gd").DAYS + load("res://scripts/data/week4.gd").DAYS
	var n := {"choices": 0, "battles": 0}
	var story_crates := 0
	var walk := func(steps: Array, self_ref) -> void:
		for s in steps:
			if s.t == "choice":
				n.choices += 1
				for o in s.options:
					self_ref.call(o.get("steps", []), self_ref)
			elif s.t == "battle":
				n.battles += 1
	for d in days:
		walk.call(d.steps, walk)
		for c in d.get("crates", []):
			if c.get("named", false) or c.has("stray") or c.has("special") or c.has("owner"):
				story_crates += 1
	var places: int = load("res://scripts/data/extra.gd").PLACES.size()
	print("분기점: 이야기 선택지 %d · 사연 있는 상자 %d · 배틀 %d · 토요일 장소 %d곳 × 3주 · 매일 밤 풀밭" % [n.choices, story_crates, n.battles, places])
	print("분기점 합계(풀밭 제외): %d" % (n.choices + story_crates + n.battles + 3))
