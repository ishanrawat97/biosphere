extends BaseSynth
class_name InsectSynth

var osc1_phase := 0.0
var osc2_phase := 0.0
var am_phase := 0.0
var am_freq := 18.0

func start() -> void:
	super.start()
	am_freq = randf_range(10.0, 30.0)

func _generate_sample(dt: float) -> float:
	# Two high-freq oscillators
	osc1_phase += 5200.0 * dt * TAU
	if osc1_phase > TAU:
		osc1_phase -= TAU
	osc2_phase += 6800.0 * dt * TAU
	if osc2_phase > TAU:
		osc2_phase -= TAU

	var carrier: float = sin(osc1_phase) * 0.5 + sin(osc2_phase) * 0.3

	# Amplitude modulation (cricket-like chirr)
	am_phase += am_freq * dt * TAU
	if am_phase > TAU:
		am_phase -= TAU
	var am: float = (sin(am_phase) + 1.0) * 0.5

	# Slow on/off pattern
	var pattern: float = sin(time * 0.5 * TAU)
	var gate: float = 1.0 if pattern > -0.3 else 0.0

	return carrier * am * gate * 0.2
