extends BaseSynth
class_name MushroomSynth

var phase1 := 0.0
var phase2 := 0.0
var phase3 := 0.0
var lfo_phase := 0.0

func _generate_sample(dt: float) -> float:
	# Three detuned sines creating a shimmer pad
	var base_freq := 220.0

	phase1 += base_freq * dt * TAU
	if phase1 > TAU:
		phase1 -= TAU

	phase2 += (base_freq * 1.003) * dt * TAU
	if phase2 > TAU:
		phase2 -= TAU

	phase3 += (base_freq * 0.997) * dt * TAU
	if phase3 > TAU:
		phase3 -= TAU

	var sample := (sin(phase1) + sin(phase2) + sin(phase3)) / 3.0

	# Slow shimmer LFO
	lfo_phase += 0.08 * dt * TAU
	if lfo_phase > TAU:
		lfo_phase -= TAU
	var shimmer := (sin(lfo_phase) + 1.0) * 0.5

	# Add octave harmonic for sparkle
	var sparkle := sin(phase1 * 2.0) * 0.15 * shimmer

	return (sample * 0.35 + sparkle) * (0.7 + shimmer * 0.3)
