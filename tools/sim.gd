extends SceneTree
## 자동 플레이 점검: godot --headless --path . -s tools/sim.gd -- <전략> [씨앗] [결말 번호]
## 전략: kind(착하게) · evil(시키는 대로) · greedy(다 풀어줌) · random
## 결말 번호: 마지막 금요일 선택지 중 몇 번째를 고를지 (0부터). 없으면 전략대로.
## 대사 전체와 날마다의 돈·의심도, 마지막 결말을 찍는다.

const KIND := ["못 본 척", "대신 서명", "솔직하게", "모른다고 한다", "데려간다", "놀아 준다", "먹이를", "내가 했다", "받을 자격", "선배들과 마지막", "혼자 조용히",
	"사양한다", "철창 문", "본사 연구동", "로사와 로이", "같이 가겠다", "빼돌린다", "달아 준다", "보태 준다", "알려 준다", "둘러댄다", "사과한다", "흘려준다",
	"포장마차", "상록숲", "게임코너", "돌려보낸", "버터플", "나옹 (", "식스테일", "그만하고", "그냥 나간다", "화분"]
const EVIL := ["알린다", "말한다", "10,000", "사례금", "받아들인다", "받는다", "아폴로를 따라", "잡아뗀다", "가만히", "그냥 돌아간다", "거절한다", "상자만",
	"백화점", "게임코너", "그만하고", "아무것도"]

var strategy := "kind"
var ending_pick := -1
var rng := RandomNumberGenerator.new()


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	strategy = args[0] if args.size() > 0 else "kind"
	rng.seed = int(args[1]) if args.size() > 1 else 1
	ending_pick = int(args[2]) if args.size() > 2 else -1
	seed(rng.seed)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://save.json"))
	var m = load("res://scenes/main.tscn").instantiate()
	root.add_child(m)
	await process_frame
	var guard := 0
	var last_day := -1
	Engine.time_scale = 50.0
	while m.waiting != "end" and guard < 20000:
		guard += 1
		if not m.st.is_empty() and m.st.day != last_day:
			last_day = m.st.day
			print("=== %s  돈 %d  의심도 %d  수사망 %d  신뢰 %s  세나 %d  풀밭 %s  원룸 %s" % [m.days[m.st.day].name, m.st.money, m.st.susp, m.st.heat, m.st.trust, m.st.sena, m.st.meadow.keys(), m.st.home.keys()])
		match m.waiting:
			"title":
				print("## ", m.title_label.text)
				m._advance()
			"dialog":
				print("[%s] %s" % [m.speaker_label.text if m.speaker_label.visible else "-", m.text_label.text])
				m._advance()
			"choice":
				var i := _pick(m.choice_options)
				print("(선택) ", m.choice_options[i].text)
				m._on_choice(i)
			"work":
				_work(m)
			"", "anim":
				await process_frame
			_:
				push_error("멈춤: waiting=" + m.waiting)
				quit(1)
				return
	print("## ", m.title_label.text, "   돈 %d  풀어준 수 %d  돌려보낸 수 %d  의심도 %d" % [m.st.money, m.st.released_total, m.st.ret.size(), m.st.susp])
	print("FLAGS ", m.st.flags.keys())
	print("ACH ", m.achieved.keys())
	print("FATES ", m.st.get("ending"), " ", m.st.get("fates"))
	quit()


func _pick(opts: Array) -> int:
	if opts.size() >= 3 and opts.any(func(o): return "트럭" in o.text and "아폴로" in o.text) and ending_pick >= 0:
		return min(ending_pick, opts.size() - 1)
	if opts[0].text == "이어하기" or opts[0].text == "처음부터":
		return opts.map(func(o): return o.text).find("처음부터")
	if strategy == "random":
		return rng.randi_range(0, opts.size() - 1)
	var prefs: Array = EVIL if strategy == "evil" else KIND
	var best := 0
	var best_score := 999
	for i in opts.size():
		for p in prefs.size():
			if prefs[p] in opts[i].text and p < best_score:
				best_score = p
				best = i
	return best


func _work(m) -> void:
	var c: Dictionary = m.crates[m.crate_i]
	var slack: int = m.crates.size() - m.days[m.st.day].quota
	var used: int = m.released_today.size() + m.kept_today.size()
	var act := "send"
	match strategy:
		"evil":
			act = "release" if c.get("reject", false) else "send"
		"greedy":
			act = "release"
		"random":
			act = ["send", "send", "release", "return", "special"][rng.randi_range(0, 4)]
		"kind":
			if c.get("reject", false):
				act = "release"
			elif m.special_btn.visible:
				act = "special"
			elif c.get("wanted", false):
				act = "send"
			elif c.key == "bulbasaur":
				act = "release"
			elif (c.get("named", false) or c.has("stray")) and used < slack:
				act = "return" if m.return_btn.visible and m.st.money > 3000 else "release"
	if act == "return" and not m.return_btn.visible:
		act = "release"
	if act == "special" and not m.special_btn.visible:
		act = "send"
	print("   %s: %s" % [act, c.name])
	match act:
		"send": m._on_send()
		"release": m._on_release()
		"return": m._on_return()
		"special": m._on_special()
