extends Control

const SoundButtonScript := preload("res://scripts/sound_button.gd")
const MasterVolumeScript := preload("res://scripts/master_volume.gd")

var _grid: GridContainer

func _ready() -> void:
	# Background color
	var bg := ColorRect.new()
	bg.color = Color("#1a2e1a")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Main vertical layout
	var main_vbox := VBoxContainer.new()
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_vbox.add_theme_constant_override("separation", 0)
	add_child(main_vbox)

	# Header
	var header := _create_header()
	main_vbox.add_child(header)

	# Separator
	var sep := HSeparator.new()
	sep.add_theme_stylebox_override("separator", StyleBoxLine.new())
	main_vbox.add_child(sep)

	# Scroll container for grid
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_vbox.add_child(scroll)

	# Center container
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)

	# Grid
	_grid = GridContainer.new()
	_grid.columns = 4
	_grid.add_theme_constant_override("h_separation", 16)
	_grid.add_theme_constant_override("v_separation", 16)
	center.add_child(_grid)

	# Create sound buttons
	var element_names := AudioManager.get_element_names()
	for el_name in element_names:
		var btn := PanelContainer.new()
		btn.set_script(SoundButtonScript)
		btn.setup(el_name, AudioManager.get_element_icon(el_name))
		btn.toggled.connect(_on_element_toggled)
		btn.volume_changed.connect(_on_element_volume)
		_grid.add_child(btn)

	# Footer
	var footer := _create_footer()
	main_vbox.add_child(footer)

func _create_header() -> MarginContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)

	var hbox := HBoxContainer.new()
	margin.add_child(hbox)

	# Title
	var title := Label.new()
	title.text = "🌍 Biosphere"
	title.add_theme_color_override("font_color", Color("#8fc86a"))
	title.add_theme_font_size_override("font_size", 28)
	hbox.add_child(title)

	# Subtitle
	var subtitle := Label.new()
	subtitle.text = "  Nature Soundscape Sandbox"
	subtitle.add_theme_color_override("font_color", Color("#7a9a6a"))
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(subtitle)

	# Spacer
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)

	# Master volume
	var master_vol := HBoxContainer.new()
	master_vol.set_script(MasterVolumeScript)
	master_vol.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(master_vol)

	return margin

func _create_footer() -> MarginContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 12)

	var label := Label.new()
	label.text = "Click to toggle sounds • Layer them to create your biosphere"
	label.add_theme_color_override("font_color", Color("#5a7a5a"))
	label.add_theme_font_size_override("font_size", 12)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	margin.add_child(label)

	return margin

func _on_element_toggled(element_name: String, _is_active: bool) -> void:
	AudioManager.toggle_element(element_name)

func _on_element_volume(element_name: String, vol: float) -> void:
	AudioManager.set_element_volume(element_name, vol)
