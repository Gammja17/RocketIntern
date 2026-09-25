extends SceneTree
## 화면 캡처: godot --path . -s tools/shot.gd -- <저장할 폴더>
## 타이틀 · 요일 제목 · 대화 · 1주차/2주차 검수 · 토요일 · 뒷문 풀밭을 png 로 저장한다.

var m
var out := ""


func _initialize() -> void:
	out = OS.get_cmdline_user_args()[0]
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://save.json"))
	m = load("res://scenes/main.tscn").instantiate()
	root.add_child(m)
	await _frames(10)
	await _save("title")
	m._on_choice(0)
	await _until("title")
	await _save("day_title")
	m._advance()
	await _until("dialog")
	await _frames(90)
	await _save("dialog_narr")
	for i in 2:
		m._advance()
	await _frames(90)
	await _save("dialog_rosa")
	while m.waiting != "work":
		m._advance()
		await _frames(1)
	await _frames(20)
	await _save("work_w1")
	m._start_day(6)
	await _to_work()
	await _save("work_w2")
	m._start_day(9)
	await _to_work()
	await _save("work_arbok")
	m._start_day(5)
	await _until_choice()
	await _save("saturday")
	m.st.meadow = {"cubone": {"name": "탕구리", "id": 104, "days": 5, "fed": false}, "ditto": {"name": "메타몽", "id": 132, "days": 99, "fed": false}}
	m.queue = m._meadow_steps()
	m._advance()
	await _frames(90)
	await _save("meadow")
	quit()


func _to_work() -> void:
	while m.waiting != "work":
		if m.waiting == "choice":
			m._on_choice(0)
		elif m.waiting == "dialog" or m.waiting == "title":
			m._advance()
		await _frames(1)
	await _frames(20)


func _until_choice() -> void:
	while m.waiting != "choice":
		if m.waiting == "dialog" or m.waiting == "title":
			m._advance()
		await _frames(1)
	await _frames(10)


func _until(w: String) -> void:
	while m.waiting != w:
		await _frames(1)
	await _frames(5)


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _save(name: String) -> void:
	await _frames(3)
	root.get_texture().get_image().save_png("%s/%s.png" % [out, name])
