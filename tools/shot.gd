extends SceneTree
## 화면 캡처: godot --path . -s tools/shot.gd -- <폴더>
## 대화 · 상자 검수 · 선택지 장면을 png 로 저장한다.

func _initialize() -> void:
	var out: String = OS.get_cmdline_user_args()[0]
	var m = load("res://scenes/main.tscn").instantiate()
	root.add_child(m)
	await process_frame
	m._advance()                       # 제목 → 첫 대사
	await _save(out + "/dialog.png")
	for i in 2:
		m._advance()
	await _save(out + "/dialog_rosa.png")
	m._advance()
	await _save(out + "/dialog_roy.png")
	while m.waiting != "work":
		m._advance()
	m._on_release()                    # 첫 상자는 풀어줘서 의심도 막대를 채운다
	await _save(out + "/work.png")
	while m.waiting != "choice":       # 수요일 로이 선택지까지
		if m.waiting == "work":
			m._on_send()
		else:
			m._advance()
	await _save(out + "/choice.png")
	quit()


func _save(path: String) -> void:
	for i in 3:
		await process_frame
	root.get_texture().get_image().save_png(path)
