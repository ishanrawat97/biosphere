extends BaseSynth
class_name ThunderSynth

var rumble_phase := 0.0
var next_crack := 0.0
var crack_env := 0.0
var lp_prev := 0.0

func start() -> void:
	super.start()
	next_crack = time + randf_range(2.0, 6.0)
	crack_env = 0.0

func _generate_sample(dt: float) -> float:
	var sample := 0.0

	# Low rumble
	rumble_phase += 40.0 * dt * TAU
	if rumble_phase > TAU:
		rumble_phase -= TAU
	sample += sin(rumble_phase) * 0.15

	# Filtered noise rumble bed
	var rc := 1.0 / (TAU * 150.0)
	var alpha := dt / (rc + dt)
	lp_prev = lp_prev + alpha * (_white_noise() - lp_prev)
	sample += lp_prev * 0.2

	# Thunder crack events
	if time >= next_crack:
		crack_env = 1.0
		next_crack = time + randf_range(8.0, 15.0)

	if crack_env > 0.0:
		sample += _white_noise() * crack_env * 0.7
		crack_env = maxf(crack_env - dt * 1.5, 0.0)

	return sample * 0.7
