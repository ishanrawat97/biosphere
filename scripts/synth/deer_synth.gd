extends BaseSynth
class_name DeerSynth

var saw_phase := 0.0
var next_call := 0.0
var call_env := 0.0
var call_life := 0.0
var call_dur := 0.0
var call_freq := 140.0
var bp_prev := 0.0
var hp_prev := 0.0
var hp_input_prev := 0.0

func start() -> void:
	super.start()
	next_call = time + randf_range(1.0, 3.0)
	call_env = 0.0

func _generate_sample(dt: float) -> float:
	# Trigger deer call
	if time >= next_call and call_env <= 0.0:
		call_life = 0.0
		call_dur = randf_range(0.5, 1.2)
		call_freq = randf_range(100.0, 180.0)
		call_env = 1.0
		next_call = time + randf_range(4.0, 8.0)

	if call_env <= 0.0:
		return 0.0

	call_life += dt

	# Harmonic-rich sawtooth
	saw_phase += call_freq * dt
	if saw_phase > 1.0:
		saw_phase -= 1.0
	var saw := saw_phase * 2.0 - 1.0

	# Band-pass filter (LP then HP)
	var lp_cutoff := 400.0
	var rc_lp := 1.0 / (TAU * lp_cutoff)
	var alpha_lp := dt / (rc_lp + dt)
	bp_prev = bp_prev + alpha_lp * (saw - bp_prev)

	var hp_cutoff := 80.0
	var rc_hp := 1.0 / (TAU * hp_cutoff)
	var alpha_hp := rc_hp / (rc_hp + dt)
	hp_prev = alpha_hp * (hp_prev + bp_prev - hp_input_prev)
	hp_input_prev = bp_prev

	# Envelope
	var t_norm := call_life / call_dur
	var env := 1.0
	if t_norm < 0.15:
		env = t_norm / 0.15
	elif t_norm > 0.6:
		env = (1.0 - t_norm) / 0.4

	if call_life >= call_dur:
		call_env = 0.0

	return hp_prev * env * 0.5
