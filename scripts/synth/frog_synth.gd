extends BaseSynth
class_name FrogSynth

var carrier_phase := 0.0
var mod_phase := 0.0
var next_croak := 0.0
var croak_env := 0.0
var croak_dur := 0.0
var croak_life := 0.0
var croak_freq := 220.0

func start() -> void:
	super.start()
	next_croak = time + randf_range(0.2, 1.0)
	croak_env = 0.0

func _generate_sample(dt: float) -> float:
	# Trigger new croak
	if time >= next_croak and croak_env <= 0.0:
		croak_life = 0.0
		croak_dur = randf_range(0.08, 0.2)
		croak_freq = randf_range(180.0, 350.0)
		croak_env = 1.0
		# Frogs often croak in pairs
		if randf() > 0.5:
			next_croak = time + randf_range(0.25, 0.5)
		else:
			next_croak = time + randf_range(1.0, 3.0)

	if croak_env <= 0.0:
		return 0.0

	croak_life += dt

	# FM synthesis croak
	var mod_freq := croak_freq * 2.0
	mod_phase += mod_freq * dt * TAU
	if mod_phase > TAU:
		mod_phase -= TAU
	var fm: float = sin(mod_phase) * croak_freq * 0.8

	carrier_phase += (croak_freq + fm) * dt * TAU
	if carrier_phase > TAU:
		carrier_phase -= TAU

	# Envelope: quick attack, sustain, quick release
	var t_norm := croak_life / croak_dur
	var env := 1.0
	if t_norm < 0.1:
		env = t_norm / 0.1
	elif t_norm > 0.7:
		env = (1.0 - t_norm) / 0.3

	if croak_life >= croak_dur:
		croak_env = 0.0

	return sin(carrier_phase) * env * 0.4
