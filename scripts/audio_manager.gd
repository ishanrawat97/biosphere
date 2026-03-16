extends Node

const SAMPLE_RATE := 22050.0
const BUFFER_LENGTH := 0.1
const BUFFER_FRAMES := int(SAMPLE_RATE * BUFFER_LENGTH)

var elements := {
	"Wind": {"synth": WindSynth.new(), "icon": "🌬️"},
	"Rain": {"synth": RainSynth.new(), "icon": "🌧️"},
	"Thunder": {"synth": ThunderSynth.new(), "icon": "⚡"},
	"River": {"synth": RiverSynth.new(), "icon": "🌊"},
	"Ocean": {"synth": OceanSynth.new(), "icon": "🏖️"},
	"Birds": {"synth": BirdSynth.new(), "icon": "🐦"},
	"Insects": {"synth": InsectSynth.new(), "icon": "🐛"},
	"Frog": {"synth": FrogSynth.new(), "icon": "🐸"},
	"Owl": {"synth": OwlSynth.new(), "icon": "🦉"},
	"Deer": {"synth": DeerSynth.new(), "icon": "🦌"},
	"Campfire": {"synth": CampfireSynth.new(), "icon": "🔥"},
	"Mushroom": {"synth": MushroomSynth.new(), "icon": "🍄"},
	"Grass": {"synth": GrassSynth.new(), "icon": "🌿"},
}

var _players := {}
var _generators := {}
var _buffers := {}

func _ready() -> void:
	# Ensure SFX bus exists
	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "SFX")
		AudioServer.set_bus_send(AudioServer.get_bus_index("SFX"), "Master")

	for key in elements:
		var gen := AudioStreamGenerator.new()
		gen.mix_rate = SAMPLE_RATE
		gen.buffer_length = BUFFER_LENGTH

		var player := AudioStreamPlayer.new()
		player.stream = gen
		player.bus = "SFX"
		add_child(player)

		_players[key] = player
		_generators[key] = gen
		_buffers[key] = PackedVector2Array()
		_buffers[key].resize(BUFFER_FRAMES)

func _process(_delta: float) -> void:
	for key in elements:
		var synth: BaseSynth = elements[key]["synth"]
		if not synth.active:
			if _players[key].playing:
				_players[key].stop()
			continue

		if not _players[key].playing:
			_players[key].play()

		var playback: AudioStreamGeneratorPlayback = _players[key].get_stream_playback()
		if playback == null:
			continue

		var frames_available := playback.get_frames_available()
		if frames_available <= 0:
			continue

		var buf: PackedVector2Array = _buffers[key]
		if buf.size() != frames_available:
			buf.resize(frames_available)

		synth.fill_buffer(buf)
		playback.push_buffer(buf)

func toggle_element(element_name: String) -> bool:
	if not elements.has(element_name):
		return false
	var synth: BaseSynth = elements[element_name]["synth"]
	if synth.active and not synth._fading_out:
		synth.stop()
		return false
	else:
		synth.start()
		return true

func set_element_volume(element_name: String, vol: float) -> void:
	if elements.has(element_name):
		elements[element_name]["synth"].volume = vol

func set_master_volume(linear: float) -> void:
	var db := linear_to_db(clampf(linear, 0.001, 1.0))
	AudioServer.set_bus_volume_db(0, db)

func get_element_names() -> Array:
	return elements.keys()

func get_element_icon(element_name: String) -> String:
	if elements.has(element_name):
		return elements[element_name]["icon"]
	return ""
