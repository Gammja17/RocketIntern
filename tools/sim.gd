extends SceneTree
## 자동 플레이 점검: godot --headless --path . -s tools/sim.gd -- <전략>
## 전략: send_all · release_all · kind · smart · report · poor
## 대사 전체와 날마다의 돈·의심도, 마지막 결말을 찍는다.

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var strategy: String = args[0] if args.size() > 0 else "kind"
	var m = load("res://scenes/main.tscn").instantiate()
	root.add_child(m)
	await process_frame
	var guard := 0
	var last_day := -1
	while m.waiting != "end" and guard < 2000:
		guard += 1
		if m.day != last_day:
			last_day = m.day
			print("=== %s  돈 %d  의심도 %d" % [m.Days.DAYS[m.day].name, m.money, m.suspicion])
		match m.waiting:
			"title":
				print("## ", m.title_label.text)
				m._advance()
			"dialog":
				print("[%s] %s" % [m.speaker_label.text if m.speaker_label.visible else "-", m.text_label.text])
				m._advance()
			"choice":
				var pick := 1 if strategy == "report" else 0
				print("(선택) ", m.choice_options[pick].text)
				m._on_choice(pick)
			"work":
				var c: Dictionary = m.crates[m.crate_i]
				if _release(strategy, c, m):
					print("   풀어줌: %s (의심도 %d)" % [c.name, m.suspicion])
					m._on_release()
				else:
					print("   보냄: %s" % c.name)
					m._on_send()
			_:
				push_error("멈춤: waiting=" + m.waiting)
				quit(1)
				return
	print("## ", m.title_label.text, "   돈 %d  풀어준 수 %d  의심도 %d" % [m.money, m.total_released, m.suspicion])
	quit()


func _release(strategy: String, c: Dictionary, m) -> bool:
	match strategy:
		"send_all", "report":
			return false
		"release_all":
			return true
		"kind":
			return c.get("named", false) or c.get("reject", false)
		"smart":
			var slack: int = m.crates.size() - m.Days.DAYS[m.day].quota
			return (c.get("named", false) or c.get("reject", false)) and m.released_today.size() < slack
		"poor":
			return m.crate_i < 3
	return false
