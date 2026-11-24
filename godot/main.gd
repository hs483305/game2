extends Control

const QUESTIONS := [
	[
		{"title":"小潛潛收到 100 枚貝幣，什麼是「需要」？", "choices":["發亮的珊瑚筆", "合腳的蛙鞋", "一大袋糖果"], "answer":1, "tip":"先照顧探索必需的工具，再決定想要什麼。"},
		{"title":"三週後想買故事書，怎麼準備？", "choices":["固定先存一小部分", "等剩下很多才存", "借給陌生海怪"], "answer":0, "tip":"先存再花，小小的固定存款會慢慢累積。"},
		{"title":"想買玩具，也想留錢去旅行，怎麼辦？", "choices":["今天全部花光", "分一部分存起來", "放進海草裡忘記它"], "answer":1, "tip":"有計畫地分配，現在和未來都能照顧。"}
	],
	[
		{"title":"兩座珊瑚花園，怎麼放入貝幣？", "choices":["全放進長最快的一座", "分散放在不同地方", "保證每座都會一直長大"], "answer":1, "tip":"分散能降低單一選擇的風險，但不能保證獲利。"},
		{"title":"暴風浪讓投資暫時縮小，怎麼做？", "choices":["全部押在唯一花園", "冷靜和家人檢查計畫", "相信保證高報酬"], "answer":1, "tip":"先理解風險，重要的金錢決定和可信任的大人討論。"},
		{"title":"投資多久會有成果？哪個說法正確？", "choices":["一晚保證變十倍", "給時間成長但結果會起伏", "選對一次就不會賠"], "answer":1, "tip":"長期思考很重要，但投資仍有風險，不保證獲利。"}
	]
]
var unlocked := 1
var level := 0
var question := 0
var correct := 0
var score := 0
var keys := 0
var selected := false
var page: VBoxContainer
var title_label: Label
var info_label: Label

func _ready() -> void:
	_build_shell()
	_show_home()

func _build_shell() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#0a2839")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var glow := ColorRect.new()
	glow.color = Color("#124765")
	glow.position = Vector2(660, 0)
	glow.size = Vector2(440, 430)
	glow.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	add_child(glow)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	page = VBoxContainer.new()
	page.custom_minimum_size = Vector2(640, 440)
	page.add_theme_constant_override("separation", 20)
	center.add_child(page)
	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 36)
	title_label.add_theme_color_override("font_color", Color("#e9f4ed"))
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(title_label)
	info_label = Label.new()
	info_label.add_theme_font_size_override("font_size", 18)
	info_label.add_theme_color_override("font_color", Color("#a5c8ca"))
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	page.add_child(info_label)

func _clear_options() -> void:
	for child in page.get_children().slice(2):
		child.queue_free()

func _button(caption: String, action: Callable) -> void:
	var b := Button.new()
	b.text = caption
	b.custom_minimum_size = Vector2(450, 58)
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	b.add_theme_font_size_override("font_size", 17)
	b.add_theme_color_override("font_color", Color("#173446"))
	b.add_theme_color_override("font_hover_color", Color("#102b3a"))
	b.add_theme_color_override("font_pressed_color", Color("#102b3a"))
	b.add_theme_stylebox_override("normal", _button_style(Color("#a6e9da")))
	b.add_theme_stylebox_override("hover", _button_style(Color("#c5f5e6")))
	b.add_theme_stylebox_override("pressed", _button_style(Color("#84d7c6")))
	b.pressed.connect(action)
	page.add_child(b)

func _button_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	style.content_margin_left = 16
	style.content_margin_right = 16
	return style

func _show_home() -> void:
	_clear_options()
	title_label.text = "✦ 小小夢魔・藍洞大冒險 ✦"
	info_label.text = "跟著小潛潛探索海底，練習為需要、想要與未來做選擇。\n珍珠 %03d　・　已取得 %d 把鑰匙" % [score, keys]
	_button("開始第一關・海底小市集", func(): _start(0))
	var second := Button.new()
	second.text = "第二關・珊瑚投資站" if unlocked >= 2 else "第二關・請先取得第一把鑰匙"
	second.disabled = unlocked < 2
	second.custom_minimum_size = Vector2(450, 58)
	second.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	second.add_theme_font_size_override("font_size", 17)
	second.pressed.connect(func(): _start(1))
	page.add_child(second)
	_button("探險須知・共兩關，每關三題", func(): _show_instructions())

func _show_instructions() -> void:
	_clear_options()
	title_label.text = "探險須知"
	info_label.text = "每關有 3 個生活情境挑戰，答對 2 題就能取得鑰匙。\n每次回答都會看到提示；完成後顯示分數和學習成果。\n重要的金錢決定，記得和信任的大人討論。"
	_button("回到藍洞入口", func(): _show_home())

func _start(which: int) -> void:
	level = which
	question = 0
	correct = 0
	selected = false
	_show_question()

func _show_question() -> void:
	_clear_options()
	var q: Dictionary = QUESTIONS[level][question]
	title_label.text = ("第一關" if level == 0 else "第二關") + "・第 %d / 3 題" % (question + 1)
	info_label.text = String(q.title)
	for i in range(q.choices.size()):
		_button(String(q.choices[i]), func(): _answer(i))

func _answer(choice: int) -> void:
	if selected:
		return
	selected = true
	var q: Dictionary = QUESTIONS[level][question]
	var is_right: bool = choice == int(q.answer)
	if is_right:
		correct += 1
		score += 10
	_clear_options()
	info_label.text = ("✦ 答對了！" if is_right else "再想一想！") + String(q.tip)
	_button("繼續探索 →", func(): _next_question())

func _next_question() -> void:
	question += 1
	if question < 3:
		selected = false
		_show_question()
	else:
		_finish_level()

func _finish_level() -> void:
	_clear_options()
	var passed := correct >= 2
	if passed:
		unlocked = 2
		keys = maxi(keys, level + 1)
	title_label.text = "第一把鑰匙，到手！" if passed and level == 0 else ("藍洞探索完成・兩把鑰匙到手！" if passed else "每次練習都在進步")
	info_label.text = "本關得分：%d / 90　・　答對 %d / 3 題\n%s" % [correct * 30, correct, "你學會先照顧需要、練習為未來存錢。" if level == 0 else "你認識分散風險、耐心與投資的不確定性。"]
	_button("回到旅程・總珍珠 %03d" % score, func(): _show_home())
