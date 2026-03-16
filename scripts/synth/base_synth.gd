extends RefCounted
class_name BaseSynth

const SAMPLE_RATE := 22050.0
const BUFFER_LENGTH := 0.1
const FADE_OUT_TIME := 0.2

var active := false
var phase := 0.0
var time := 0.0
var volume := 1.0

var _fading_out := false
var _fade_progress := 0.0

func start() -> void:
	active = true
	_fading_out = false
	_fade_progress = 0.0

func stop() -> void:
	if active:
		_fading_out = true
		_fade_progress = 0.0

func fill_buffer(buffer: PackedVector2Array) -> void:
	var frames := buffer.size()
	var dt := 1.0 / SAMPLE_RATE
	for i in frames:
		var sample := 0.0
		if active:
			sample = _generate_sample(dt) * volume
			if _fading_out:
				_fade_progress += dt
				var fade_factor := 1.0 - clampf(_fade_progress / FADE_OUT_TIME, 0.0, 1.0)
				sample *= fade_factor
				if _fade_progress >= FADE_OUT_TIME:
					active = false
					_fading_out = false
		time += dt
		var v := clampf(sample, -1.0, 1.0)
		buffer[i] = Vector2(v, v)

func _generate_sample(_dt: float) -> float:
	return 0.0

func _white_noise() -> float:
	return randf_range(-1.0, 1.0)

func _sine(freq: float, dt: float) -> float:
	phase += freq * dt * TAU
	if phase > TAU:
		phase -= TAU
	return sin(phase)
