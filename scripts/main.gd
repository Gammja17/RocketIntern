extends Control
## 로켓단 신입사원: 하루 흐름(브리핑 → 상자 검수 → 일당 → 퇴근)을 days.gd 의 단계대로 굴린다.

const Days = preload("res://scripts/days.gd")

const START_MONEY := 2000
const RENT := 15000
const SENIOR_HELP := 3000   # 금요일에 모자라면 선배들이 보태 주는 한도
const LIVING := 1000
const BASE_PAY := 500
const PER_SEND := 600
const QUOTA_BONUS := 1000
const REJECT_FINE := 500
const SUSP_DECAY := 30
const FIRE_AT := 100

const TRIO_TEX := preload("res://assets/trainers/teamrocket.png")
const NAMES := {"rosa": "로사", "roy": "로이", "meowth": "나옹", "apollo": "아폴로", "boss": "비주기", "me": "나"}

@onready var day_label: Label = %DayLabel
@onready var money_label: Label = %MoneyLabel
@onready var quota_label: Label = %QuotaLabel
@onready var rent_label: Label = %RentLabel
@onready var susp_bar: ProgressBar = %SuspBar
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
@onready var dialog_panel: Control = %DialogPanel
@onready var portrait: TextureRect = %Portrait
@onready var speaker_label: Label = %SpeakerLabel
@onready var text_label: Label = %TextLabel
@onready var choice_box: Control = %ChoiceBox
@onready var choice_btns: Array[Button] = [%Choice0, %Choice1]
@onready var title_label: Label = %TitleLabel
@onready var restart_btn: Button = %RestartBtn

var portraits := {}
var stages := {}

var day := 0
var money := START_MONEY
var suspicion := 0
var flags := {}
var sent := {}
var released := {}
var total_released := 0

var crates: Array = []
var crate_i := 0
var sent_today: Array = []
var rejected_today: Array = []
var released_today: Array = []
var bonus_today := 0

var queue: Array = []
var waiting := ""
var choice_options: Array = []


func _ready() -> void:
	portraits = {
		"rosa": _crop(TRIO_TEX, Rect2(8, 0, 36, 36)),
		"roy": _crop(TRIO_TEX, Rect2(44, 0, 36, 36)),
		"meowth": load("res://assets/pokemon/52.png"),
		"apollo": load("res://assets/trainers/archer.png"),
		"boss": load("res://assets/trainers/giovanni.png"),
	}
	stages = {
		"rosa": TRIO_TEX, "roy": TRIO_TEX, "meowth": TRIO_TEX,
		"apollo": portraits.apollo, "boss": portraits.boss,
	}
	send_btn.pressed.connect(_on_send)
	release_btn.pressed.connect(_on_release)
	for i in choice_btns.size():
		choice_btns[i].pressed.connect(_on_choice.bind(i))
	restart_btn.pressed.connect(func(): get_tree().reload_current_scene())
	_start_day(0)


func _crop(tex: Texture2D, rect: Rect2) -> AtlasTexture:
	var a := AtlasTexture.new()
	a.atlas = tex
	a.region = rect
	return a


func _unhandled_input(event: InputEvent) -> void:
	if waiting != "dialog" and waiting != "title":
		return
	var click: bool = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if click or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_advance()


# ── 단계 진행 ──────────────────────────────────────────

func _start_day(d: int) -> void:
	day = d
	var info: Dictionary = Days.DAYS[d]
	crates = info.crates
	crate_i = 0
	sent_today.clear()
	rejected_today.clear()
	released_today.clear()
	bonus_today = 0
	queue = info.steps.duplicate()
	_refresh_bar()
	_advance()


func _advance() -> void:
	_hide_all()
	while true:
		if queue.is_empty():
			_start_day(day + 1)
			return
		var s: Dictionary = queue.pop_front()
		if s.has("if") and not _check(s["if"]):
			continue
		match s.t:
			"title":
				title_label.text = s.text
				title_label.show()
				waiting = "title"
				return
			"say":
				_show_say(s.who, s.text)
				return
			"fx":
				money += s.get("money", 0)
				suspicion += s.get("susp", 0)
				if s.has("flag"):
					flags[s.flag] = true
				_refresh_bar()
			"choice":
				_show_choice(s.options)
				return
			"work":
				_show_crate()
				return
			"report":
				queue = _report_steps() + queue
			"evening":
				queue = _evening_steps() + queue
			"rent":
				queue = _rent_steps() + queue
			"ending":
				queue = _ending_steps() + queue
			"end":
				title_label.text = s.text
				title_label.show()
				restart_btn.show()
				waiting = "end"
				return


func _hide_all() -> void:
	for n in [work_panel, dialog_panel, choice_box, title_label, restart_btn, rule_label, stage]:
		n.hide()
	waiting = ""


func _show_say(who: String, text: String) -> void:
	dialog_panel.show()
	speaker_label.text = NAMES.get(who, "")
	speaker_label.visible = who != "narr"
	text_label.text = text
	portrait.texture = portraits.get(who)
	portrait.visible = portrait.texture != null
	stage.texture = stages.get(who)
	stage.visible = stage.texture != null
	waiting = "dialog"


func _show_choice(options: Array) -> void:
	choice_options = options
	for i in choice_btns.size():
		choice_btns[i].text = options[i].text
	choice_box.show()
	stage.texture = TRIO_TEX
	stage.show()
	waiting = "choice"
	choice_btns[0].grab_focus()


func _on_choice(i: int) -> void:
	if waiting != "choice":
		return
	flags[choice_options[i].flag] = true
	_advance()


# ── 상자 검수 ──────────────────────────────────────────

func _show_crate() -> void:
	var c: Dictionary = crates[crate_i]
	work_panel.show()
	rule_label.text = Days.DAYS[day].rule
	rule_label.show()
	crate_label.text = "상자 %d / %d" % [crate_i + 1, crates.size()]
	crate_sprite.texture = load("res://assets/pokemon/%d.png" % c.id)
	name_label.text = c.name
	memo_label.text = "수거 메모: " + c.memo
	item_label.text = c.item
	item_label.visible = c.item != ""
	waiting = "work"


func _on_send() -> void:
	if waiting != "work":
		return
	var c: Dictionary = crates[crate_i]
	sent[c.key] = true
	if c.get("reject", false):
		rejected_today.append(c)
	else:
		sent_today.append(c)
		bonus_today += c.get("bonus", 0)
	_next_crate()


func _on_release() -> void:
	if waiting != "work":
		return
	var c: Dictionary = crates[crate_i]
	released[c.key] = true
	released_today.append(c)
	total_released += 1
	if not c.get("reject", false):
		suspicion += int(c.risk * Days.DAYS[day].risk_mult)
	if suspicion >= FIRE_AT:
		queue = _fired_steps()
		_refresh_bar()
		_advance()
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
	if c.begins_with("sent:"):
		return sent.has(c.substr(5))
	if c.begins_with("rel:"):
		return released.has(c.substr(4))
	if c.begins_with("susp>="):
		return suspicion >= int(c.substr(6))
	match c:
		"rel_today":
			return not released_today.is_empty()
		"pair_split":
			return sent.has("nidoran_f") != sent.has("nidoran_m")
	return flags.get(c, false)


# ── 만들어지는 단계들 ───────────────────────────────────

func _say(text: String, who := "narr") -> Dictionary:
	return {"t": "say", "who": who, "text": text}


func _report_steps() -> Array:
	var n := sent_today.size()
	var quota: int = Days.DAYS[day].quota
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
	out.append({"t": "fx", "money": pay})
	out.append(_say("오늘 일당은 %s원이다." % _won(pay)))
	return out


func _evening_steps() -> Array:
	money -= LIVING
	suspicion = max(0, suspicion - SUSP_DECAY)
	_refresh_bar()
	var out := [_say("저녁값과 교통비로 %s원이 나갔다. 남은 돈은 %s원이다." % [_won(LIVING), _won(money)])]
	for c in released_today:
		if c.get("named", false) and not c.get("reject", false):
			out.append(_say("집에 오는 길, 가로등 아래에 %s 닮은 그림자가 잠깐 서 있다가 사라졌다." % _josa(c.name, "과", "와")))
			break
	if day == 3:
		out.append(_say("내일이 월세 마감이다. 내야 할 돈은 %s원이다." % _won(RENT)))
	elif day > 0 and day < 3:
		out.append(_say("금요일 월세 마감까지 %d일 남았다. 내야 할 돈은 %s원이다." % [4 - day, _won(RENT)]))
	return out


func _rent_steps() -> Array:
	if money >= RENT:
		money -= RENT
		_refresh_bar()
		return [_say("월세 %s원을 냈다. 통장에는 %s원이 남았다." % [_won(RENT), _won(money)])]
	if not flags.get("reported_roy", false) and money >= RENT - SENIOR_HELP:
		var gap := RENT - money
		money = 0
		flags["helped"] = true
		_refresh_bar()
		return [
			_say("월세가 %s원 모자랐다." % _won(gap)),
			_say("모자라는 건 우리가 낼게. 대신 다음 달엔 꼭 갚아.", "rosa"),
			_say("월세를 냈다. 통장에는 한 푼도 남지 않았다."),
		]
	flags["evicted"] = true
	return [_say("월세를 낼 수 없었다. 통장에는 %s원뿐이었다." % _won(money))]


func _ending_steps() -> Array:
	var loyal: bool = not flags.get("reported_roy", false)
	if flags.get("evicted", false):
		if loyal:
			return [
				{"t": "title", "text": "금요일 밤 · 짐 싸기"},
				_say("집주인은 내일 아침까지 방을 비우라고 했다. 짐은 가방 두 개가 전부였다."),
				_say("그럼 창고에서 자. 난로도 있어. 나옹이 코를 좀 골긴 하지만.", "rosa"),
				_say("셋이 살던 데서 넷이 사는 거지 뭐. 좁아도 괜찮아.", "roy"),
				_say("코는 로이가 더 곤다옹.", "meowth"),
				{"t": "end", "text": "엔딩: 창고 식구"},
			]
		return [
			{"t": "title", "text": "금요일 밤 · 짐 싸기"},
			_say("집주인은 내일 아침까지 방을 비우라고 했다."),
			_say("가방을 들고 창고까지 걸어갔지만 문이 잠겨 있었다. 로사는 전화를 받지 않았다."),
			{"t": "end", "text": "엔딩: 잠긴 창고"},
		]
	if total_released <= 3:
		return [
			{"t": "title", "text": "다음 주 월요일"},
			_say("이번 주 실적 1위라지. 신입치고는 대단하군. 다음 주부터 새 창고 하나를 맡아라.", "boss"),
			_say("월요일, 내 밑으로 신입이 한 명 들어왔다."),
			_say("…상자에 가끔 편지나 이름표 같은 게 딸려 와. 그런 건 그냥 안 읽는 게 편해.", "me"),
			_say("그게 누가 했던 말인지 떠올리는 데 한참 걸렸다."),
			{"t": "end", "text": "엔딩: 안 읽는 게 편해"},
		]
	if loyal and total_released >= 8:
		return [
			{"t": "title", "text": "금요일 밤 · 창고"},
			_say("나옹이 아껴 두던 참치캔을 꺼내 왔다. 넷이서 창고 난로 앞에 둘러앉았다."),
			_say("이번 주도 우리 창고가 실적 꼴찌래.", "rosa"),
			_say("그래도 1등 하는 것도 있잖아. 뒷문 풀밭에 사는 포켓몬 수.", "roy"),
			_say("로켓단 최약체 삼인조, 아니 이제 사인조다옹!", "meowth"),
			_say("다음 주에도 이 창고의 상자는 자꾸 비어서 올라갈 것이다."),
			{"t": "end", "text": "엔딩: 실적 꼴찌 창고"},
		]
	return [
		{"t": "title", "text": "금요일 밤"},
		_say("월세는 냈다. 방은 지켰다."),
		_say("휴대폰에 다음 주 할당량 공지가 벌써 와 있었다. 월요일은 여섯 마리."),
		{"t": "end", "text": "엔딩: 다음 주도 출근"},
	]


func _fired_steps() -> Array:
	return [
		{"t": "title", "text": "해고"},
		_say("뒷문 밖 풀밭이 포켓몬 놀이터가 됐더군. 오늘부로 너는 로켓단원이 아니다.", "apollo"),
		_say("유니폼을 반납하고 창고를 나왔다. 풀밭 쪽에서 낯익은 울음소리가 몇 번 들렸다."),
		_say("월세는 여전히 밀려 있다. 그래도 발걸음은 생각보다 가벼웠다."),
		{"t": "end", "text": "엔딩: 뒷문으로 나간 사람"},
	]


# ── 표시 도우미 ─────────────────────────────────────────

func _refresh_bar() -> void:
	var info: Dictionary = Days.DAYS[day]
	day_label.text = info.name
	money_label.text = "돈 %s원" % _won(money)
	quota_label.text = "보냄 %d / %d" % [sent_today.size(), info.quota]
	rent_label.text = "월세 D-%d" % (4 - day) if day < 4 else "월세 오늘"
	susp_bar.value = suspicion


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
