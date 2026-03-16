extends BaseSynth
class_name RiverSynth

var lfo1_phase := 0.0
var lfo2_phase := 0.0
var lp_prev := 0.0
var hp_prev := 0.0
var hp_input_prev := 0.0

func _generate_sample(dt: float) -> float:
	# Dual LFO modulation
	lfo1_phase += 0.3 * dt * TAU
	if lfo1_phase > TAU:
		lfo1_phase -= TAU
	lfo2_phase += 0.17 * dt * TAU
	if lfo2_phase > TAU:
		lfo2_phase -= TAU

	var mod: float = (sin(lfo1_phase) + sin(lfo2_phase) * 0.6) * 0.5
	var noise: float = _white_noise()

	# Band-pass: LP at 3000 Hz then HP at 200 Hz
	var lp_cutoff: float = 2500.0 + mod * 500.0
	var rc_lp: float = 1.0 / (TAU * lp_cutoff)
	var alpha_lp: float = dt / (rc_lp + dt)
	lp_prev = lp_prev + alpha_lp * (noise - lp_prev)

	var hp_cutoff: float = 200.0
	var rc_hp: float = 1.0 / (TAU * hp_cutoff)
	var alpha_hp: float = rc_hp / (rc_hp + dt)
	hp_prev = alpha_hp * (hp_prev + lp_prev - hp_input_prev)
	hp_input_prev = lp_prev

	var sample: float = hp_prev * (0.4 + mod * 0.1)
	return sample
