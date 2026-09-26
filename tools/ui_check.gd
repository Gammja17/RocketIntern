extends SceneTree
## 화면 잘림 점검: godot --path . -s tools/ui_check.gd -- <언어 ko|en> <가로> <세로> [판 수]
## (창이 있어야 세로 배치가 되므로 --headless 없이 돌린다)
## 끝까지 돌리면서 장면마다 패널이 화면 밖으로 나가거나, 함께 보이는 패널끼리 겹치는지 잰다.

var rng := RandomNumberGenerator.new()
var found := {}


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	var lang: String = a[0] if a.size() > 0 else "ko"
	DisplayServer.window_set_size(Vector2i(int(a[1]) if a.size() > 1 else 960, int(a[2]) if a.size() > 2 else 540))
	var runs := int(a[3]) if a.size() > 3 else 2
	rng.seed = 5
	seed(5)
	Engine.time_scale = 50.0
	for r in runs:
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://save.json"))
		var m = load("res://scenes/main.tscn").instantiate()
		root.add_child(m)
		await process_frame
		m.settings.lang = lang
		m._apply_settings(false)
		m._title_menu()
		var guard := 0
		while m.waiting != "end" and guard < 30000:
			guard += 1
			await process_frame   # 레이아웃이 자리 잡은 뒤에 잰다
			if m.typing and m.typing.is_running():
				m.typing.kill()
				m.text_label.visible_ratio = 1.0
			if not _measure(m, false).is_empty():
				for i in 4:
					await process_frame   # 줄바꿈이 자리 잡을 때까지 기다렸다가 다시 잰다
				_measure(m, true)
			match m.waiting:
				"title", "dialog":
					m._advance()
				"choice":
					var texts: Array = m.choice_options.map(func(o): return o.text)
					m._on_choice(texts.find("처음부터") if texts.has("처음부터") else rng.randi_range(0, texts.size() - 1))
				"work":
					[m._on_send, m._on_release, m._on_send][rng.randi_range(0, 2)].call()
		m.queue_free()
		await process_frame
	print("잘림 · 겹침: %d가지" % found.size())
	for k in found:
		print("CLIP ", k, " | ", found[k])
	quit()


func _measure(m, record: bool) -> Array:
	var bad := []
	var screen: Rect2 = m.get_viewport_rect()
	var panels := {"위쪽 막대": m.top_bar, "규칙 줄": m.rule_label, "상자 카드": m.work_panel, "서류철": m.docs_panel,
		"대화창": m.dialog_panel, "선택지": m.choice_box, "제목": m.title_label}
	var shown := {}
	for name in panels:
		var c: Control = panels[name]
		if c.is_visible_in_tree():
			shown[name] = c.get_global_rect()
	# 선택지는 보이는 버튼까지만
	if shown.has("선택지"):
		var r := Rect2()
		for b in m.choice_btns:
			if b.visible:
				r = b.get_global_rect() if r.size == Vector2.ZERO else r.merge(b.get_global_rect())
		shown["선택지"] = r
	if shown.has("규칙 줄") and m.rule_label.text == "":
		shown.erase("규칙 줄")
	for name in shown:
		var r: Rect2 = shown[name]
		if r.end.y > screen.end.y + 1 or r.end.x > screen.end.x + 1 or r.position.y < -1 or r.position.x < -1:
			bad.append(["%s가 화면 밖으로 나감" % name, r])
	var pairs := [["위쪽 막대", "규칙 줄"], ["위쪽 막대", "상자 카드"], ["위쪽 막대", "대화창"], ["규칙 줄", "상자 카드"],
		["상자 카드", "서류철"], ["대화창", "선택지"], ["규칙 줄", "선택지"], ["위쪽 막대", "선택지"], ["제목", "선택지"]]
	for p in pairs:
		if shown.has(p[0]) and shown.has(p[1]) and shown[p[0]].grow(-2).intersects(shown[p[1]].grow(-2)):
			bad.append(["%s와 %s가 겹침" % p, shown[p[0]].intersection(shown[p[1]])])
	if record:
		for b in bad:
			_note(b[0], m, b[1])
	return bad


func _note(what: String, m, r: Rect2) -> void:
	if found.has(what):
		return
	var day: String = m.days[m.st.day].name if not m.st.is_empty() else "타이틀"
	var hint: String = m.text_label.text if m.dialog_panel.visible else (m.name_label.text if m.work_panel.visible else "")
	found[what] = "%s · %s · %s · %s" % [day, m.waiting, r, hint.substr(0, 40)]
