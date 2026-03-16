extends BaseSynth
class_name WindSynth

var lfo_phase := 0.0
var prev_sample := 0.0

func _generate_sample(dt: float) -> float:
	# LFO modulates cutoff between 400-1200 Hz
	lfo_phase += 0.15 * dt * TAU
	if lfo_phase > TAU:
		lfo_phase -= TAU
	var lfo := (sin(lfo_phase) + sin(lfo_phase * 0.7)) * 0.5
	var cutoff := 800.0 + lfo * 400.0

	# Simple one-pole low-pass filter on white noise
	var rc := 1.0 / (TAU * cutoff)
	var alpha := dt / (rc + dt)
	var noise := _white_noise()
	prev_sample = prev_sample + alpha * (noise - prev_sample)
	return prev_sample * 0.6
