extends PanelContainer

signal toggled(element_name: String, is_active: bool)
signal volume_changed(element_name: String, vol: float)

var element_name := ""
var is_active := false

var _icon_label: Label
var _name_label: Label
var _status_dot: Panel
var _volume_slider: HSlider
var _tween: Tween

const COLOR_BG := Color("#3a5c3a")
const COLOR_BG_ACTIVE := Color("#4a7c4a")
const COLOR_GLOW := Color("#8fc86a")
const COLOR_TEXT := Color("#d4e8c4")
const COLOR_DOT_OFF := Color("#555555")
const COLOR_DOT_ON := Color("#8fc86a")

func setup(p_name: String, p_icon: String) -> void:
	element_name = p_name

	# Panel styling
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_BG
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color("#2a4a2a")
	add_theme_stylebox_override("panel", style)

	custom_minimum_size = Vector2(140, 160)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	add_child(vbox)

	# Click area button (invisible, covers whole card)
	var click_btn := Button.new()
	click_btn.flat = true
	click_btn.text = ""
	click_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	click_btn.pressed.connect(_on_click)
	click_btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	click_btn.z_index = 10
	add_child(click_btn)

	# Icon
	_icon_label = Label.new()
	_icon_label.text = p_icon
	_icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_icon_label.add_theme_font_size_override("font_size", 36)
	vbox.add_child(_icon_label)

	# Name + status row
	var name_row := HBoxContainer.new()
	name_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(name_row)

	_status_dot = Panel.new()
	_status_dot.custom_minimum_size = Vector2(8, 8)
	var dot_style := StyleBoxFlat.new()
	dot_style.bg_color = COLOR_DOT_OFF
	dot_style.corner_radius_top_left = 4
	dot_style.corner_radius_top_right = 4
	dot_style.corner_radius_bottom_left = 4
	dot_style.corner_radius_bottom_right = 4
	_status_dot.add_theme_stylebox_override("panel", dot_style)
	name_row.add_child(_status_dot)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(6, 0)
	name_row.add_child(spacer)

	_name_label = Label.new()
	_name_label.text = p_name
	_name_label.add_theme_color_override("font_color", COLOR_TEXT)
	_name_label.add_theme_font_size_override("font_size", 14)
	name_row.add_child(_name_label)

	# Volume slider
	_volume_slider = HSlider.new()
	_volume_slider.min_value = 0.0
	_volume_slider.max_value = 1.0
	_volume_slider.step = 0.01
	_volume_slider.value = 0.7
	_volume_slider.custom_minimum_size = Vector2(0, 20)
	_volume_slider.z_index = 20
	_volume_slider.mouse_filter = Control.MOUSE_FILTER_STOP

	# Style the slider
	var slider_style := StyleBoxFlat.new()
	slider_style.bg_color = Color("#2a4a2a")
	slider_style.corner_radius_top_left = 3
	slider_style.corner_radius_top_right = 3
	slider_style.corner_radius_bottom_left = 3
	slider_style.corner_radius_bottom_right = 3
	slider_style.content_margin_top = 3
	slider_style.content_margin_bottom = 3

	var slider_fill := StyleBoxFlat.new()
	slider_fill.bg_color = COLOR_GLOW
	slider_fill.corner_radius_top_left = 3
	slider_fill.corner_radius_top_right = 3
	slider_fill.corner_radius_bottom_left = 3
	slider_fill.corner_radius_bottom_right = 3
	slider_fill.content_margin_top = 3
	slider_fill.content_margin_bottom = 3

	_volume_slider.add_theme_stylebox_override("slider", slider_style)
	_volume_slider.add_theme_stylebox_override("grabber_area", slider_fill)
	_volume_slider.add_theme_stylebox_override("grabber_area_highlight", slider_fill)

	_volume_slider.value_changed.connect(_on_volume_changed)
	vbox.add_child(_volume_slider)

func _on_click() -> void:
	is_active = !is_active
	_update_visual()
	toggled.emit(element_name, is_active)

func _on_volume_changed(val: float) -> void:
	volume_changed.emit(element_name, val)

func _update_visual() -> void:
	var style: StyleBoxFlat = get_theme_stylebox("panel").duplicate()
	var dot_style: StyleBoxFlat = _status_dot.get_theme_stylebox("panel").duplicate()

	if is_active:
		style.bg_color = COLOR_BG_ACTIVE
		style.border_color = COLOR_GLOW
		dot_style.bg_color = COLOR_DOT_ON
		_flash_glow()
	else:
		style.bg_color = COLOR_BG
		style.border_color = Color("#2a4a2a")
		dot_style.bg_color = COLOR_DOT_OFF

	add_theme_stylebox_override("panel", style)
	_status_dot.add_theme_stylebox_override("panel", dot_style)

func _flash_glow() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()

	var style: StyleBoxFlat = get_theme_stylebox("panel")
	var bright := Color("#b0f080")
	var target := COLOR_GLOW

	style.border_color = bright
	_tween.tween_property(style, "border_color", target, 0.4)
