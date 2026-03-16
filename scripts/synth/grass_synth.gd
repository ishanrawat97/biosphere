extends BaseSynth
class_name GrassSynth

var hp_prev := 0.0
var hp_input_prev := 0.0
var am_phase := 0.0

func _generate_sample(dt: float) -> float:
	var noise := _white_noise()

	# High-pass filter for airy rustling
	var hp_cutoff := 3000.0
	var rc := 1.0 / (TAU * hp_cutoff)
	var alpha := rc / (rc + dt)
	hp_prev = alpha * (hp_prev + noise - hp_input_prev)
	hp_input_prev = noise

	# Slow amplitude modulation (gentle gusts)
	am_phase += 0.25 * dt * TAU
	if am_phase > TAU:
		am_phase -= TAU
	var am: float = (sin(am_phase) + sin(am_phase * 1.7) * 0.5) * 0.33 + 0.67

	return hp_prev * am * 0.2
