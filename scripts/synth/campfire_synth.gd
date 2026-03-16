extends BaseSynth
class_name CampfireSynth

var crackle_lp := 0.0
var next_pop := 0.0
var pop_env := 0.0

func start() -> void:
	super.start()
	next_pop = time + randf_range(0.1, 0.5)

func _generate_sample(dt: float) -> float:
	var sample := 0.0

	# Base crackle: filtered noise
	var cutoff := 3000.0 + _white_noise() * 1000.0
	var rc := 1.0 / (TAU * cutoff)
	var alpha := dt / (rc + dt)
	crackle_lp = crackle_lp + alpha * (_white_noise() - crackle_lp)
	sample += crackle_lp * 0.2

	# Random amplitude variation for crackle character
	var crackle_mod := absf(_white_noise())
	sample *= (0.5 + crackle_mod * 0.5)

	# Random pops
	if time >= next_pop:
		pop_env = randf_range(0.5, 1.0)
		next_pop = time + randf_range(0.05, 0.4)

	if pop_env > 0.0:
		sample += _white_noise() * pop_env * 0.4
		pop_env = maxf(pop_env - dt * 15.0, 0.0)

	return sample * 0.6
