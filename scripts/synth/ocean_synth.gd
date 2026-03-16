extends BaseSynth
class_name OceanSynth

var wave_phase := 0.0
var wave_period := 8.0
var lp_prev := 0.0
var sub_phase := 0.0

func start() -> void:
	super.start()
	wave_phase = 0.0
	wave_period = randf_range(6.0, 10.0)

func _generate_sample(dt: float) -> float:
	# Slow wave envelope (6-10s cycle)
	wave_phase += dt / wave_period
	if wave_phase > 1.0:
		wave_phase -= 1.0
		wave_period = randf_range(6.0, 10.0)

	# Wave crest shape: rises slowly, crashes quickly
	var env: float = sin(wave_phase * PI)
	env = pow(env, 0.7) as float

	# Filtered noise for wave sound
	var cutoff: float = 600.0 + env * 1500.0
	var rc: float = 1.0 / (TAU * cutoff)
	var alpha: float = dt / (rc + dt)
	lp_prev = lp_prev + alpha * (_white_noise() - lp_prev)

	var sample: float = lp_prev * (0.2 + env * 0.4)

	# Sub-bass thud at wave crest
	if env > 0.7:
		sub_phase += 45.0 * dt * TAU
		if sub_phase > TAU:
			sub_phase -= TAU
		sample += sin(sub_phase) * (env - 0.7) * 0.5

	return sample
