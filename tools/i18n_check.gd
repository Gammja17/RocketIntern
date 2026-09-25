extends SceneTree
## 영어판 점검: godot --headless --path . -s tools/i18n_check.gd -- <판 수> [씨앗]
## 영어로 설정하고 끝까지 돌리면서, 화면에 뜨는 글자(대사 · 제목 · 선택지 · 상자 카드 · 서류철 · 위쪽 막대)에
## 한글이 남아 있으면 모아서 알려 준다.

var rng := RandomNumberGenerator.new()
var leaks := {}


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var runs := int(args[0]) if args.size() > 0 else 10
	rng.seed = int(args[1]) if args.size() > 1 else 3
	seed(rng.seed)
	Engine.time_scale = 50.0
	for r in runs:
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://save.json"))
		var m = load("res://scenes/main.tscn").instantiate()
		root.add_child(m)
		await process_frame
		m.settings.lang = "en"
		m._apply_settings(false)
		m._title_menu()
		var guard := 0
		while m.waiting != "end" and guard < 30000:
			guard += 1
			_scan(m)
			match m.waiting:
				"title", "dialog":
					m._advance()
				"choice":
					var texts: Array = m.choice_options.map(func(o): return o.text)
					var i: int = texts.find("처음부터") if texts.has("처음부터") else rng.randi_range(0, texts.size() - 1)
					m._on_choice(i)
				"work":
					[m._on_send, m._on_release, m._on_send][rng.randi_range(0, 2)].call()
				_:
					await process_frame
		_scan(m)
		m.queue_free()
		await process_frame
	var keys := leaks.keys()
	keys.sort()
	print("한글이 남은 곳: %d" % keys.size())
	for k in keys:
		print("LEAK ", leaks[k], " | ", k)
	quit()


func _scan(m) -> void:
	var nodes: Array = [m.text_label, m.title_label, m.speaker_label, m.name_label, m.memo_label, m.item_label,
		m.docs_label, m.rule_label, m.crate_label, m.day_label, m.money_label, m.quota_label, m.rent_label,
		m.return_btn, m.special_btn] + m.choice_btns
	for n in nodes:
		if not n.is_visible_in_tree():
			continue
		var shown: String = n.tr(n.text)   # 라벨 · 버튼은 그려질 때 이렇게 번역된다
		if RegEx.create_from_string("[가-힣]").search(shown):
			leaks[shown] = n.name
