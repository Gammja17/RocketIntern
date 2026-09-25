extends Control
## 로켓단 신입사원: scripts/data/ 의 단계(step)를 차례로 굴린다. 단계 형식은 scripts/data/README.md.

const W1 = preload("res://scripts/data/week1.gd")
const W2 = preload("res://scripts/data/week2.gd")
const W3 = preload("res://scripts/data/week3.gd")
const W4 = preload("res://scripts/data/week4.gd")
const Extra = preload("res://scripts/data/extra.gd")
const AnimMeta = preload("res://scripts/data/anim_meta.gd")
const Ach = preload("res://scripts/data/achievements.gd")

const SAVE_PATH := "user://save.json"
const ACH_PATH := "user://achievements.json"   # 새로 시작해도 남는다
const START_MONEY := 2000
const RENT := 12000
const SENIOR_HELP := 3000   # 금요일에 모자라면 선배들이 보태 주는 한도
const LIVING := 1000
const BASE_PAY := 500
const PER_SEND := 600
const QUOTA_BONUS := 1000
const REJECT_FINE := 500
const WANTED_FINE := 2000
const POSTAGE := 500
const FEED_COST := 300
const SLOT_BET := 500
const SUSP_DECAY := 30
const MEADOW_SUSP := 5      # 풀밭에 두 마리 넘게 머물면 한 마리당 밤마다
const FIRE_AT := 100
const LAST_WARNING_FINE := 5000
const TYPE_SPEED := 0.025   # 글자 하나당 초

const TRIO_TEX := preload("res://assets/trainers/teamrocket.png")

@onready var bg: TextureRect = %Bg
@onready var day_label: Label = %DayLabel
@onready var money_label: Label = %MoneyLabel
@onready var quota_label: Label = %QuotaLabel
@onready var rent_label: Label = %RentLabel
@onready var susp_bar: ProgressBar = %SuspBar
@onready var top_bar: Control = $TopBarBg
@onready var rule_label: Label = %RuleLabel
@onready var stage: TextureRect = %Stage
@onready var work_panel: Control = %WorkPanel
@onready var crate_label: Label = %CrateLabel
@onready var crate_sprite: TextureRect = %CrateSprite
@onready var name_label: Label = %NameLabel
@onready var memo_label: Label = %MemoLabel
@onready var item_label: Label = %ItemLabel
@onready var send_btn: Button = %SendBtn
@onready var release_btn: Button = %ReleaseBtn
@onready var return_btn: Button = %ReturnBtn
@onready var special_btn: Button = %SpecialBtn
@onready var docs_panel: Control = %DocsPanel
@onready var docs_label: Label = %DocsLabel
@onready var dialog_panel: Control = %DialogPanel
@onready var portrait: TextureRect = %Portrait
@onready var speaker_label: Label = %SpeakerLabel
@onready var text_label: Label = %TextLabel
@onready var choice_box: Control = %ChoiceBox
@onready var title_label: Label = %TitleLabel
@onready var restart_btn: Button = %RestartBtn
@onready var fader: ColorRect = %Fader
@onready var bgm: AudioStreamPlayer = %Bgm
@onready var sfx: AudioStreamPlayer = %Sfx
@onready var toast_panel: Control = %ToastPanel
@onready var toast_label: Label = %ToastLabel
@onready var ach_panel: Control = %AchPanel
@onready var ach_label: Label = %AchLabel

var days: Array = []
var choice_btns: Array[Button] = []

## 저장되는 상태
var st := {}
## 하루 동안만 쓰는 상태 (불러오면 그날 아침부터 다시)
var crates: Array = []
var crate_i := 0
var sent_today: Array = []
var rejected_today: Array = []
var released_today: Array = []
var kept_today: Array = []
var bonus_today := 0
var intro_seen := {}
var places_today := {}

var queue: Array = []
var waiting := ""
var choice_options: Array = []
var typing: Tween
var last_who := ""
var bgm_name := ""
var anims := {}   # TextureRect -> {frames, w, h, ms, t}
var last_pick := 0
var base_pos := {}  # 흔들림 · 튀어 오르기 뒤 돌아갈 자리
var achieved := {}
var toast_tween: Tween


func _ready() -> void:
	days = W1.DAYS + W2.DAYS + W3.DAYS + W4.DAYS
	for c in choice_box.get_children():
		choice_btns.append(c)
		c.pressed.connect(_on_choice.bind(choice_btns.size() - 1))
	send_btn.pressed.connect(_on_send)
	release_btn.pressed.connect(_on_release)
	return_btn.pressed.connect(_on_return)
	special_btn.pressed.connect(_on_special)
	restart_btn.pressed.connect(func(): get_tree().reload_current_scene())
	for n in [stage, dialog_panel, crate_sprite]:
		base_pos[n] = n.position
	if FileAccess.file_exists(ACH_PATH):
		achieved = JSON.parse_string(FileAccess.open(ACH_PATH, FileAccess.READ).get_as_text())
	%AchClose.pressed.connect(func(): ach_panel.hide(); _title_menu())
	_title_menu()


func _process(delta: float) -> void:
	for rect: TextureRect in anims:
		var a: Dictionary = anims[rect]
		a.t += delta * 1000.0
		var f := int(a.t / a.ms) % int(a.frames)
		(rect.texture as AtlasTexture).region = Rect2(f * a.w, 0, a.w, a.h)


func _unhandled_input(event: InputEvent) -> void:
	if waiting != "dialog" and waiting != "title":
		return
	var click: bool = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if click or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		if typing and typing.is_running():
			typing.kill()
			text_label.visible_ratio = 1.0
			return
		_advance()


# ── 타이틀 · 저장 ──────────────────────────────────────

func _title_menu() -> void:
	_hide_all()
	top_bar.hide()
	_set_bg("warehouse")
	_play_bgm("hideout")
	title_label.text = "로켓단 신입사원"
	title_label.show()
	var opts := [{"text": "처음부터", "call": "_new_game"}]
	if FileAccess.file_exists(SAVE_PATH):
		opts.push_front({"text": "이어하기", "call": "_load_game"})
	opts.append({"text": "도전 과제 (%d / %d)" % [achieved.size(), Ach.LIST.size()], "call": "_show_achievements"})
	_show_choice(opts)


func _show_achievements() -> Array:
	_hide_all()
	waiting = "menu"
	var lines := []
	for a in Ach.LIST:
		if achieved.has(a.id):
			var code := "" if OS.has_feature("web") else "   [%s]" % a.code
			lines.append("[달성] %s%s
    %s" % [a.name, code, a.desc])
		else:
			lines.append("[ ] ???
    %s" % ("어떤 결말에 이른다." if a.has("end") else a.desc))
	ach_label.text = "
".join(PackedStringArray(lines))
	ach_panel.show()
	return []


## 도전 과제 달성. 웹판은 SKEAM 에 알리고, exe판은 등록 코드를 보여 준다.
func _unlock(id: String) -> void:
	if achieved.has(id):
		return
	achieved[id] = true
	FileAccess.open(ACH_PATH, FileAccess.WRITE).store_string(JSON.stringify(achieved))
	var a: Dictionary = Ach.LIST.filter(func(x): return x.id == id)[0]
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.SKEAM && SKEAM.unlock('%s')" % id)
		toast_label.text = "도전 과제 달성
%s" % a.name
	else:
		toast_label.text = "도전 과제 달성: %s
등록 코드 %s" % [a.name, a.code]
	toast_panel.show()
	toast_panel.modulate.a = 0.0
	if toast_tween:
		toast_tween.kill()
	toast_tween = create_tween()
	toast_tween.tween_property(toast_panel, "modulate:a", 1.0, 0.25)
	toast_tween.tween_interval(4.0)
	toast_tween.tween_property(toast_panel, "modulate:a", 0.0, 0.5)
	toast_tween.tween_callback(toast_panel.hide)


func _new_game() -> Array:
	st = {
		"day": 0, "money": START_MONEY, "susp": 0, "flags": {}, "sent": {}, "rel": {}, "ret": {}, "spc": {},
		"trust": {"rosa": 0, "roy": 0, "meowth": 0}, "sena": 0, "watch": 0, "meadow": {}, "help": {},
		"items": {}, "visited": {}, "released_total": 0, "news": [],
	}
	_start_day(0)
	return []


func _load_game() -> Array:
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	st = JSON.parse_string(f.get_as_text())
	for k in ["day", "money", "susp", "sena", "watch", "released_total"]:
		st[k] = int(st[k])
	for k in st.trust:
		st.trust[k] = int(st.trust[k])
	for k in st.meadow:
		st.meadow[k].days = int(st.meadow[k].days)
		st.meadow[k].id = int(st.meadow[k].id)
	_start_day(st.day)
	return []


func _save() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(st))


# ── 단계 진행 ──────────────────────────────────────────

func _start_day(d: int) -> void:
	if d == 1:
		_unlock("first_day")
	st.day = d
	_save()
	var info: Dictionary = days[d]
	crates = info.get("crates", []).filter(func(c): return not c.has("if") or _check(c["if"]))
	crate_i = 0
	sent_today.clear()
	rejected_today.clear()
	released_today.clear()
	kept_today.clear()
	bonus_today = 0
	places_today.clear()
	queue = info.steps.duplicate()
	top_bar.show()
	_set_bg(info.get("bg", "city" if info.get("kind") == "sat" else "warehouse"))
	_play_bgm(info.get("bgm", "celadon" if info.get("kind") == "sat" else "hideout"))
	_refresh_bar()
	_advance()


func _advance() -> void:
	_hide_all()
	while true:
		if queue.is_empty():
			_start_day(int(st.day) + 1)
			return
		var s: Dictionary = queue.pop_front()
		if s.has("if") and not _check(s["if"]):
			continue
		match s.t:
			"title":
				_show_title(s.text)
				return
			"say":
				_show_say(s.who, s.text, s.get("shake", false), s.get("pokemon", 0))
				return
			"fx":
				_apply(s)
			"choice":
				var opts: Array = s.options.filter(func(o): return not o.has("if") or _check(o["if"]))
				_show_choice(opts)
				return
			"work":
				if crates.is_empty():
					continue
				_show_crate()
				return
			"work_resume":
				_show_crate()
				return
			"work_next":
				_next_crate()
				return
			"bg":
				_set_bg(s.name)
			"bgm":
				_play_bgm(s.name)
			"report":
				queue = _report_steps() + queue
			"evening":
				queue = _evening_steps() + queue + _meadow_steps()   # 풀밭은 그날 맨 마지막
			"meadow_tick":
				queue = _meadow_tick() + queue
			"rent":
				queue = _rent_steps() + queue
			"news":
				queue = _news_steps() + queue
			"free":
				queue = _free_steps() + queue
			"slots":
				queue = _slot_menu() + queue
			"prizes":
				queue = _prize_menu() + queue
			"shop":
				queue = _shop_menu() + queue
			"visits":
				queue = _visit_steps() + queue
			"epilogue":
				queue = W4.EPILOGUE + queue
			"ach":
				_unlock(s.id)
			"end":
				_show_end(s.text)
				return


func _hide_all() -> void:
	for n in [work_panel, docs_panel, dialog_panel, choice_box, title_label, restart_btn, rule_label, stage]:
		n.hide()
	anims.erase(crate_sprite)
	waiting = ""


func _show_title(text: String) -> void:
	waiting = "anim"
	var tw := create_tween()
	tw.tween_property(fader, "modulate:a", 1.0, 0.35)
	await tw.finished
	title_label.text = text
	title_label.show()
	waiting = "title"   # 제목이 뜨면 바로 넘길 수 있다
	create_tween().tween_property(fader, "modulate:a", 0.55, 0.35)


func _show_end(text: String) -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	for a in Ach.LIST:
		if a.get("end", "") == text:
			_unlock(a.id)
	fader.modulate.a = 0.7
	title_label.text = text
	title_label.show()
	restart_btn.show()
	waiting = "end"


func _show_say(who: String, text: String, shake := false, pokemon := 0) -> void:
	var person: Dictionary = Extra.PEOPLE.get(who, {})
	fader.modulate.a = 0.0
	dialog_panel.show()
	speaker_label.text = person.get("name", "")
	speaker_label.visible = speaker_label.text != ""
	_set_portrait(portrait, person.get("portrait", ""))
	var stage_name: String = person.get("stage", "")
	stage.visible = stage_name != "" or pokemon > 0
	anims.erase(stage)
	if stage.visible:
		if pokemon > 0:
			_set_pokemon(stage, pokemon)
		else:
			stage.texture = load("res://assets/trainers/%s.png" % stage_name)
		if who != last_who:
			stage.modulate.a = 0.0
			create_tween().tween_property(stage, "modulate:a", 1.0, 0.2)
		var base_y: float = base_pos[stage].y
		var bob := create_tween()
		bob.tween_property(stage, "position:y", base_y - 6, 0.08)
		bob.tween_property(stage, "position:y", base_y, 0.1)
	if who != last_who:
		dialog_panel.modulate.a = 0.4
		create_tween().tween_property(dialog_panel, "modulate:a", 1.0, 0.15)
	last_who = who
	text_label.text = text
	text_label.visible_ratio = 0.0
	typing = create_tween()
	typing.tween_property(text_label, "visible_ratio", 1.0, text.length() * TYPE_SPEED)
	if shake:
		_shake(dialog_panel)
		_shake(stage)
	waiting = "dialog"


func _shake(n: Control) -> void:
	var x: float = base_pos[n].x
	var tw := create_tween()
	for i in 4:
		tw.tween_property(n, "position:x", x + (8 if i % 2 == 0 else -8), 0.04)
	tw.tween_property(n, "position:x", x, 0.04)


func _set_portrait(rect: TextureRect, spec: String) -> void:
	anims.erase(rect)
	rect.visible = spec != ""
	if spec == "":
		return
	if spec == "crop:rosa":
		rect.texture = _crop(TRIO_TEX, Rect2(8, 0, 36, 36))
	elif spec == "crop:roy":
		rect.texture = _crop(TRIO_TEX, Rect2(44, 0, 36, 36))
	elif spec.begins_with("pokemon:"):
		_set_pokemon(rect, int(spec.substr(8)))
	else:
		rect.texture = load("res://assets/trainers/%s.png" % spec)


## 움직이는 스프라이트가 있으면 그걸, 없으면 정지 그림을 건다.
func _set_pokemon(rect: TextureRect, id: int) -> void:
	anims.erase(rect)
	var meta: Array = AnimMeta.META.get(id, [])
	if meta.is_empty():
		rect.texture = load("res://assets/pokemon/%d.png" % id)
		return
	var tex := _crop(load("res://assets/pokemon_anim/%d.png" % id), Rect2(0, 0, meta[1], meta[2]))
	rect.texture = tex
	anims[rect] = {"frames": meta[0], "w": meta[1], "h": meta[2], "ms": meta[3], "t": 0.0}


func _crop(tex: Texture2D, rect: Rect2) -> AtlasTexture:
	var a := AtlasTexture.new()
	a.atlas = tex
	a.region = rect
	return a


func _set_bg(bg_name: String) -> void:
	bg.texture = load("res://assets/bg/%s.png" % bg_name)


func _play_bgm(bgm_name_: String) -> void:
	if bgm_name_ == bgm_name:
		return
	bgm_name = bgm_name_
	var stream: AudioStreamMP3 = load("res://assets/music/%s.mp3" % bgm_name_)
	stream.loop = true
	bgm.stream = stream
	bgm.play()


func _play_sfx(sfx_name: String) -> void:
	sfx.stream = load("res://assets/music/%s.mp3" % sfx_name)
	sfx.play()


# ── 선택지 ─────────────────────────────────────────────

func _show_choice(opts: Array) -> void:
	choice_options = opts
	for i in choice_btns.size():
		var b := choice_btns[i]
		b.visible = i < opts.size()
		if b.visible:
			b.text = opts[i].text
	choice_box.show()
	waiting = "choice"
	choice_btns[0].grab_focus()


func _on_choice(i: int) -> void:
	if waiting != "choice":
		return
	var o: Dictionary = choice_options[i]
	last_pick = i
	if not st.is_empty():
		_apply(o)
	var extra: Array = []
	if o.has("call"):
		extra = call(o.call)
		if waiting != "choice" and waiting != "":
			return   # 새 게임 · 불러오기처럼 흐름을 새로 시작한 경우
	queue = o.get("steps", []) + extra + queue
	_advance()


## 단계나 선택지에 붙은 효과를 적용한다.
func _apply(d: Dictionary) -> void:
	st.money += d.get("money", 0)
	if d.get("susp", 0) != 0:
		_add_susp(d.susp)
	if d.has("flag"):
		st.flags[d.flag] = true
	for k in d.get("trust", {}):
		st.trust[k] += d.trust[k]
	st.sena += d.get("sena", 0)
	if st.sena >= 2:
		_unlock("same_month")
	st.watch += d.get("watch", 0)
	_refresh_bar()


func _add_susp(n: int) -> void:
	st.susp = max(0, st.susp + n)
	if n > 0:
		susp_bar.modulate = Color(2, 0.6, 0.6)
		create_tween().tween_property(susp_bar, "modulate", Color.WHITE, 0.5)
	if st.susp < FIRE_AT:
		return
	if st.flags.get("last_warning", false):
		queue = _fired_steps()
		return
	# 처음 한 번은 마지막 경고로 끝난다.
	st.flags["last_warning"] = true
	_unlock("last_warning")
	st.susp = 60
	st.money -= LAST_WARNING_FINE
	var warn := [
		{"t": "say", "who": "apollo", "urgent": true, "shake": true, "text": "신입. 뒷문 밖 풀밭에 네 발자국이 너무 많다. 모를 줄 알았나?"},
		_say("벌금 %s원이다. 이건 마지막 경고다. 한 번만 더 걸리면 그땐 끝이다." % _won(LAST_WARNING_FINE), "apollo"),
	]
	if waiting == "work" or waiting == "anim":
		warn.append({"t": "work_next"})
	queue = warn + queue
	_refresh_bar()


# ── 상자 검수 ──────────────────────────────────────────

func _show_crate() -> void:
	var c: Dictionary = crates[crate_i]
	if c.has("intro") and not intro_seen.has(c.key):
		intro_seen[c.key] = true
		queue = c.intro.map(func(x): return x.merged({"pokemon": c.id})) + [{"t": "work_resume"}] + queue
		_advance()
		return
	var info: Dictionary = days[int(st.day)]
	work_panel.show()
	docs_panel.show()
	rule_label.text = info.get("rule", "")
	rule_label.show()
	docs_label.text = "\n\n".join(PackedStringArray(_docs()))
	crate_label.text = "상자 %d / %d" % [crate_i + 1, crates.size()]
	_set_pokemon(crate_sprite, c.id)
	crate_sprite.modulate.a = 1.0
	crate_sprite.position = base_pos[crate_sprite]
	crate_sprite.pivot_offset = crate_sprite.size / 2
	crate_sprite.scale = Vector2(0.2, 0.2)
	create_tween().tween_property(crate_sprite, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	name_label.text = c.name
	memo_label.text = "수거 메모: " + c.memo
	item_label.text = c.get("item", "")
	item_label.visible = item_label.text != ""
	return_btn.visible = c.has("owner") and _week() >= 2
	return_btn.text = "주인에게 돌려보내기 (-%s원)" % _won(POSTAGE)
	special_btn.visible = c.has("special")
	if special_btn.visible:
		special_btn.text = c.special.label
	waiting = "work"


func _docs() -> Array:
	var out := []
	for d in days[int(st.day)].get("docs", []):
		if d is String:
			out.append(d)
		elif not d.has("if") or _check(d["if"]):
			out.append(d.text)
	return out


func _on_send() -> void:
	if waiting != "work":
		return
	var c: Dictionary = crates[crate_i]
	st.sent[c.key] = true
	if c.get("reject", false):
		rejected_today.append(c)
	else:
		sent_today.append(c)
		bonus_today += c.get("bonus", 0)
	_leave_crate(Vector2(420, 0))


func _on_release() -> void:
	if waiting != "work":
		return
	var c: Dictionary = crates[crate_i]
	st.rel[c.key] = true
	released_today.append(c)
	st.released_total += 1
	_unlock("back_door")
	if c.key == "eevee":
		_unlock("ribbon")
	if c.has("stray"):
		st.meadow[c.key] = {"name": c.name if not c.has("reveal") else c.reveal.split("(")[0], "id": c.id, "days": c.stray, "fed": false}
	if not c.get("reject", false):
		_add_susp(int(c.risk * days[int(st.day)].get("risk_mult", 1.0)))
	_leave_crate(Vector2(-420, 0))


func _on_return() -> void:
	if waiting != "work":
		return
	var c: Dictionary = crates[crate_i]
	st.ret[c.key] = true
	released_today.append(c)
	st.money -= POSTAGE
	_unlock("no_sender")
	if c.key == "vaporeon":
		_unlock("ribbon")
	if c.has("ret_news"):
		st.news.append(c.ret_news)
	_add_susp(int(c.risk * 0.5))
	_leave_crate(Vector2(0, -300))


func _on_special() -> void:
	if waiting != "work":
		return
	var c: Dictionary = crates[crate_i]
	st.spc[c.key] = true
	kept_today.append(c)
	if c.key == "arbok":
		_unlock("m04")
	_apply(c.special)
	queue = c.special.get("steps", []).map(func(x): return x.merged({"pokemon": c.id}) if x.get("who") == "narr" else x) + [{"t": "work_next"}] + queue
	_advance()


func _leave_crate(dir: Vector2) -> void:
	waiting = "anim"
	_refresh_bar()
	var tw := create_tween().set_parallel()
	tw.tween_property(crate_sprite, "position", base_pos[crate_sprite] + dir, 0.25)
	tw.tween_property(crate_sprite, "modulate:a", 0.0, 0.25)
	await tw.finished
	if not queue.is_empty() and queue[0].get("urgent", false):
		_advance()   # 의심도가 다 차서 경고나 해고가 끼어든 경우
		return
	_next_crate()


func _next_crate() -> void:
	crate_i += 1
	_refresh_bar()
	if crate_i < crates.size():
		_show_crate()
	else:
		_advance()


# ── 조건 ──────────────────────────────────────────────

func _check(conds) -> bool:
	if conds is String:
		conds = [conds]
	for c: String in conds:
		var neg := c.begins_with("!")
		if neg:
			c = c.substr(1)
		if _test(c) == neg:
			return false
	return true


func _test(c: String) -> bool:
	for pre in ["sent", "rel", "ret", "spc", "help", "item", "meadow"]:
		if c.begins_with(pre + ":"):
			var key := c.substr(pre.length() + 1)
			match pre:
				"help": return st.help.has(key)
				"item": return st.items.has(key)
				"meadow": return st.meadow.has(key)
				_: return st[pre].has(key)
	for op in [">=", "=="]:
		if op in c:
			var parts := c.split(op)
			var lhs := _value(parts[0])
			var rhs := int(parts[1])
			return lhs >= rhs if op == ">=" else lhs == rhs
	match c:
		"rel_today":
			return not released_today.is_empty()
		"pair_split":
			return st.sent.has("nidoran_f") != st.sent.has("nidoran_m")
	return st.flags.get(c, false)


func _value(name: String) -> int:
	if name.begins_with("trust:"):
		return int(st.trust.get(name.substr(6), 0))
	match name:
		"susp": return int(st.susp)
		"money": return int(st.money)
		"sena": return int(st.sena)
		"watch": return int(st.watch)
		"released": return int(st.released_total)
		"returned": return st.ret.size()
		"week": return _week()
	return 0


func _week() -> int:
	return int(st.day) / 6 + 1


# ── 만들어지는 단계들 ───────────────────────────────────

func _say(text: String, who := "narr") -> Dictionary:
	return {"t": "say", "who": who, "text": text}


func _report_steps() -> Array:
	var info: Dictionary = days[int(st.day)]
	var n := sent_today.size()
	var quota: int = info.quota
	var pay := BASE_PAY + n * PER_SEND
	var out := [_say("오늘 본사로 보낸 포켓몬은 %d마리다. 할당량은 %d마리였다." % [n, quota])]
	if n >= quota:
		pay += QUOTA_BONUS
		out.append(_say("할당량을 채워서 달성 수당 %s원이 붙었다." % _won(QUOTA_BONUS)))
	else:
		out.append(_say("할당량을 채우지 못해서 달성 수당은 없다."))
	if bonus_today > 0:
		pay += bonus_today
		out.append(_say("연구소 포켓몬 특별 수당으로 %s원을 더 받았다." % _won(bonus_today)))
	if not rejected_today.is_empty():
		var names := rejected_today.map(func(c): return c.get("reveal", c.name))
		pay -= REJECT_FINE * rejected_today.size()
		out.append(_say("반품된 포켓몬: %s. 한 마리당 %s원씩 깎였다." % [", ".join(PackedStringArray(names)), _won(REJECT_FINE)]))
	var missed := crates.filter(func(c): return c.get("wanted", false) and not st.sent.has(c.key) and not (st.spc.has(c.key) and c.special.get("no_fine", false)))
	if not missed.is_empty():
		pay -= WANTED_FINE * missed.size()
		var names := missed.map(func(c): return c.name)
		out.append(_say("수배 목록에 있던 %s 칸이 비어서 본사에 보고됐다. 벌금 %s원." % [", ".join(PackedStringArray(names)), _won(WANTED_FINE * missed.size())]))
		out.append({"t": "fx", "watch": 1})
	out.append({"t": "fx", "money": pay})
	out.append(_say("오늘 일당은 %s원이다." % _won(pay)))
	return out


func _evening_steps() -> Array:
	st.money -= LIVING
	st.susp = max(0, st.susp - SUSP_DECAY)
	_refresh_bar()
	var home := "warehouse" if st.flags.get("live_warehouse", false) else "room"
	var out := [{"t": "bg", "name": home}, {"t": "bgm", "name": "pallet"},
		_say("저녁값과 교통비로 %s원이 나갔다. 남은 돈은 %s원이다." % [_won(LIVING), _won(st.money)])]
	for c in released_today:
		if c.get("named", false) and not c.get("reject", false) and st.rel.has(c.key):
			out.append(_say("집에 오는 길, 가로등 아래에 %s 닮은 그림자가 잠깐 서 있다가 사라졌다." % _josa(c.name, "과", "와")))
			break
	if home == "room":
		var owned := Extra.ITEMS.filter(func(it): return st.items.has(it.key) and it.line != "")
		if not owned.is_empty():
			out.append(_say(owned[int(st.day) % owned.size()].line))
		var next := int(st.day) + 1
		if st.items.has("radio") and next < days.size() and days[next].has("rule"):
			out.append(_say("라디오 주파수를 돌리다 로켓단 무전이 잡혔다. '내일 지침: %s'" % days[next].rule))
		if days[int(st.day)].name.ends_with("목요일") and _week() < 4:
			out.append(_say("내일이 월세 갚는 날이다. 갚아야 할 돈은 %s원이다." % _won(RENT)))
	return out


func _meadow_steps() -> Array:
	if st.meadow.is_empty():
		return []
	var names := PackedStringArray(st.meadow.values().map(func(m): return m.name))
	var out := [{"t": "bg", "name": "meadow"},
		_say("밤늦게 뒷문 풀밭에 들렀다. %s 아직 남아 있다." % _josa(", ".join(names), "이", "가")).merged({"pokemon": int(st.meadow.values()[0].id)})]
	if st.meadow.size() >= 2:
		out.append(_say("풀밭에 머무는 녀석이 늘수록 누군가 눈치챌 위험도 커진다."))
	out.append({"t": "choice", "options": [
		{"text": "먹이를 두고 온다 (-%s원)" % _won(FEED_COST), "call": "_feed_meadow"},
		{"text": "그냥 돌아간다"},
	]})
	out.append({"t": "meadow_tick"})
	return out


func _feed_meadow() -> Array:
	st.money -= FEED_COST
	for k in st.meadow:
		st.meadow[k].fed = true
		st.help[k] = true
	_refresh_bar()
	return [_say("먹이 그릇을 채워 두었다. 풀숲에서 조심스럽게 다가오는 소리가 났다.")]


func _meadow_tick() -> Array:
	var out := []
	if st.meadow.size() >= 2:
		_add_susp(MEADOW_SUSP * (st.meadow.size() - 1))
	for k in st.meadow.keys():
		st.meadow[k].days -= 1
		if st.meadow[k].days <= 0:
			out.append(_say(Extra.MEADOW_LEAVE.get(k, "%s 풀밭을 떠났다." % _josa(st.meadow[k].name, "이", "가"))))
			st.meadow.erase(k)
	return out


func _rent_steps() -> Array:
	if st.flags.get("live_warehouse", false):
		return [_say("창고에서 지내니 이번 주는 월세가 없다. 대신 등이 배긴다.")]
	if st.money >= RENT:
		st.money -= RENT
		_refresh_bar()
		return [_say("밀린 월세 %s원을 갚았다. 통장에는 %s원이 남았다." % [_won(RENT), _won(st.money)])]
	var loyal: bool = not st.flags.get("reported_roy", false) and not st.flags.get("rosa_knows", false)
	if loyal and st.money >= RENT - SENIOR_HELP:
		var gap: int = RENT - st.money
		st.money = 0
		_refresh_bar()
		return [
			_say("월세가 %s원 모자랐다." % _won(gap)),
			_say("모자라는 건 우리가 낼게. 대신 다음 달엔 꼭 갚아.", "rosa"),
			_say("월세를 갚았다. 통장에는 한 푼도 남지 않았다."),
		]
	if loyal:
		st.flags["live_warehouse"] = true
		return [
			{"t": "title", "text": "금요일 밤 · 짐 싸기"},
			_say("월세를 갚지 못했다. 집주인은 내일 아침까지 방을 비우라고 했다. 짐은 가방 두 개가 전부였다."),
			_say("그럼 창고에서 자. 난로도 있어. 나옹이 코를 좀 골긴 하지만.", "rosa"),
			_say("코는 로이가 더 곤다옹.", "meowth"),
			_say("그날부터 나는 창고 다락 한쪽에서 잤다."),
		]
	return [
		{"t": "title", "text": "금요일 밤 · 짐 싸기"},
		_say("월세를 갚지 못했다. 집주인은 내일 아침까지 방을 비우라고 했다."),
		_say("가방을 들고 창고까지 걸어갔지만 문이 잠겨 있었다. 로사는 전화를 받지 않았다."),
		{"t": "end", "text": "엔딩: 잠긴 창고"},
	]


func _news_steps() -> Array:
	var out := []
	for text in st.news:
		out.append({"t": "say", "who": "news", "text": text})
	st.news = []
	return out


func _free_steps() -> Array:
	var opts := []
	for p in Extra.PLACES:
		if places_today.has(p.key) or (p.has("if") and not _check(p["if"])):
			continue
		opts.append({"text": p.text, "call": "_visit_place", "place": p.key})
	return [{"t": "choice", "options": opts}]


func _visit_place() -> Array:
	var key := _picked("place")
	places_today[key] = true
	for p in Extra.PLACES:
		if p.key == key:
			return p.steps.duplicate()
	return []


func _slot_menu() -> Array:
	var opts := [{"text": "그만하고 경품 교환소로 간다"}]
	if st.money >= SLOT_BET:
		opts.push_front({"text": "레버를 당긴다 (-%s원)" % _won(SLOT_BET), "call": "_slot_pull"})
	return [{"t": "choice", "options": opts}]


func _slot_pull() -> Array:
	st.money -= SLOT_BET
	var r := randf()
	var win := 0
	var line := ""
	if r < 0.02:
		win = 7500
		line = "7 7 7! 잭팟이다! 동전이 쏟아졌다."
		_play_sfx("jackpot")
		_unlock("jackpot")
	elif r < 0.12:
		win = 2000
		line = "체리가 셋 나란히 섰다."
		_play_sfx("win")
	elif r < 0.40:
		win = 1000
		line = "피카츄 둘에 체리 하나. 본전은 건졌다."
		_play_sfx("win")
	else:
		line = "꽝. 슬롯머신이 동전을 삼켰다."
		_play_sfx("lose")
	st.money += win
	_refresh_bar()
	return [_say("%s (지금 가진 돈 %s원)" % [line, _won(st.money)]), {"t": "slots"}]


func _prize_menu() -> Array:
	var opts := []
	for p in Extra.PRIZES:
		if (not p.has("if") or _check(p["if"])) and st.money >= p.cost:
			opts.append({"text": p.text, "call": "_buy_prize", "prize": p.key})
	var seen := Extra.PRIZES.filter(func(p): return not p.has("if") or _check(p["if"]))
	var out := []
	if seen.is_empty():
		out.append(_say("경품 진열장에는 낯선 포켓몬들뿐이었다."))
		return out
	if opts.is_empty():
		out.append(_say("진열장에서 낯익은 녀석을 봤다. 하지만 지금 가진 돈으로는 바꿀 수 없었다."))
		return out
	opts.append({"text": "그냥 나간다"})
	out.append({"t": "choice", "options": opts})
	return out


func _buy_prize() -> Array:
	var key := _picked("prize")
	for p in Extra.PRIZES:
		if p.key == key:
			st.money -= p.cost
			st.flags["bought_" + key] = true
			if key == "butterfree":
				_unlock("prize_case")
			_refresh_bar()
			return p.steps.duplicate()
	return []


func _shop_menu() -> Array:
	var opts := []
	for it in Extra.ITEMS:
		if not st.items.has(it.key) and st.money >= it.cost:
			opts.append({"text": it.text, "call": "_buy_item", "item": it.key})
	if opts.is_empty():
		return [_say("살 만한 물건이 없었다. 아니면 살 돈이 없었다.")]
	opts.append({"text": "아무것도 사지 않는다"})
	return [{"t": "choice", "options": opts}]


func _buy_item() -> Array:
	var key := _picked("item")
	for it in Extra.ITEMS:
		if it.key == key:
			st.money -= it.cost
			st.items[key] = true
			if st.items.size() == Extra.ITEMS.size():
				_unlock("my_room")
			_refresh_bar()
			return [_say("%s 샀다. 원룸에 가져다 두었다." % _josa(it.text.split(" (")[0], "을", "를"))]
	return []


func _visit_steps() -> Array:
	var out := []
	for k in st.ret:
		if Extra.VISITS.has(k) and not st.visited.has(k):
			st.visited[k] = true
			out.append(_say(Extra.VISITS[k]))
	if out.is_empty():
		out.append(_say("지난번에 찾아간 집들은 다 조용했다. 그걸로 됐다."))
	else:
		out.append(_say("아무도 나를 알아보지 못했다. 그래서 오래 보고 있을 수 있었다."))
	return out


func _fired_steps() -> Array:
	return [
		{"t": "title", "text": "해고", "urgent": true},
		{"t": "bg", "name": "warehouse"},
		_say("뒷문 밖 풀밭이 포켓몬 놀이터가 됐더군. 오늘부로 너는 로켓단원이 아니다.", "apollo"),
		_say("유니폼을 반납하고 창고를 나왔다. 풀밭 쪽에서 낯익은 울음소리가 몇 번 들렸다."),
		_say("월세는 여전히 밀려 있다. 그래도 발걸음은 생각보다 가벼웠다."),
		{"t": "end", "text": "엔딩: 뒷문으로 나간 사람"},
	]


## 방금 누른 선택지에 붙은 값을 꺼낸다.
func _picked(field: String) -> String:
	return choice_options[last_pick].get(field, "")


# ── 표시 도우미 ─────────────────────────────────────────

func _refresh_bar() -> void:
	if st.is_empty():
		return
	var info: Dictionary = days[int(st.day)]
	day_label.text = info.name
	money_label.text = "돈 %s원" % _won(st.money)
	quota_label.text = "보냄 %d / %d" % [sent_today.size(), info.get("quota", 0)]
	quota_label.visible = info.get("quota", 0) > 0
	var left := 4 - int(st.day) % 6
	rent_label.text = "월세 D-%d" % left if left > 0 else "월세 오늘"
	rent_label.visible = int(st.day) % 6 < 5 and _week() < 4 and not st.flags.get("live_warehouse", false)
	susp_bar.value = st.susp


func _won(n: int) -> String:
	var s := str(abs(n))
	var out := ""
	while s.length() > 3:
		out = "," + s.right(3) + out
		s = s.left(s.length() - 3)
	return ("-" if n < 0 else "") + s + out


## 받침이 있으면 with_b, 없으면 without_b 를 붙인다.
func _josa(word: String, with_b: String, without_b: String) -> String:
	var code := word.unicode_at(word.length() - 1)
	if code >= 0xAC00 and code <= 0xD7A3 and (code - 0xAC00) % 28 != 0:
		return word + with_b
	return word + without_b
