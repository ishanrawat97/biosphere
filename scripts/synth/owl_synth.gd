extends BaseSynth
class_name OwlSynth

var owl_phase := 0.0
var vibrato_phase := 0.0
var next_hoot := 0.0
var hoot_env := 0.0
var hoot_life := 0.0
var hoot_dur := 0.0
var hoot_count := 0
var hoot_freq := 400.0

func start() -> void:
	super.start()
	next_hoot = time + randf_range(0.5, 2.0)
	hoot_env = 0.0
	hoot_count = 0

func _generate_sample(dt: float) -> float:
	# Trigger hoot pattern ("hoo-hoo")
	if time >= next_hoot and hoot_env <= 0.0:
		hoot_life = 0.0
		hoot_dur = randf_range(0.3, 0.5)
		hoot_freq = randf_range(350.0, 500.0)
		hoot_env = 1.0
		hoot_count += 1
		if hoot_count < 2:
			next_hoot = time + randf_range(0.4, 0.6)
		else:
			hoot_count = 0
			next_hoot = time + randf_range(3.0, 7.0)

	if hoot_env <= 0.0:
		return 0.0

	hoot_life += dt

	# Vibrato
	vibrato_phase += 5.0 * dt * TAU
	if vibrato_phase > TAU:
		vibrato_phase -= TAU
	var vibrato: float = sin(vibrato_phase) * 15.0

	# Main sine tone
	owl_phase += (hoot_freq + vibrato) * dt * TAU
	if owl_phase > TAU:
		owl_phase -= TAU

	# Smooth envelope
	var t_norm: float = hoot_life / hoot_dur
	var env: float = sin(t_norm * PI)
	env = pow(env, 0.5)

	if hoot_life >= hoot_dur:
		hoot_env = 0.0

	return sin(owl_phase) * env * 0.35
