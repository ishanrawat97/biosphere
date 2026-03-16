extends HBoxContainer

var _slider: HSlider

func _ready() -> void:
	var label := Label.new()
	label.text = "Master"
	label.add_theme_color_override("font_color", Color("#d4e8c4"))
	label.add_theme_font_size_override("font_size", 14)
	add_child(label)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(10, 0)
	add_child(spacer)

	_slider = HSlider.new()
	_slider.min_value = 0.0
	_slider.max_value = 1.0
	_slider.step = 0.01
	_slider.value = 0.8
	_slider.custom_minimum_size = Vector2(150, 20)

	var track_style := StyleBoxFlat.new()
	track_style.bg_color = Color("#2a4a2a")
	track_style.corner_radius_top_left = 3
	track_style.corner_radius_top_right = 3
	track_style.corner_radius_bottom_left = 3
	track_style.corner_radius_bottom_right = 3
	track_style.content_margin_top = 3
	track_style.content_margin_bottom = 3

	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = Color("#8fc86a")
	fill_style.corner_radius_top_left = 3
	fill_style.corner_radius_top_right = 3
	fill_style.corner_radius_bottom_left = 3
	fill_style.corner_radius_bottom_right = 3
	fill_style.content_margin_top = 3
	fill_style.content_margin_bottom = 3

	_slider.add_theme_stylebox_override("slider", track_style)
	_slider.add_theme_stylebox_override("grabber_area", fill_style)
	_slider.add_theme_stylebox_override("grabber_area_highlight", fill_style)

	_slider.value_changed.connect(_on_value_changed)
	add_child(_slider)

	# Set initial volume
	_on_value_changed(_slider.value)

func _on_value_changed(val: float) -> void:
	AudioManager.set_master_volume(val)
