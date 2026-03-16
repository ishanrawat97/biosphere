extends BaseSynth
class_name BirdSynth

var chirps: Array[Dictionary] = []
var next_chirp_time := 0.0

func start() -> void:
	super.start()
	chirps.clear()
	next_chirp_time = time + randf_range(0.1, 0.5)

func _generate_sample(dt: float) -> float:
	# Spawn chirp events
	if time >= next_chirp_time:
		var base_freq := randf_range(1500.0, 4000.0)
		var sweep_dir := 1.0 if randf() > 0.4 else -1.0
		chirps.append({
			"life": 0.0,
			"dur": randf_range(0.05, 0.15),
			"base_freq": base_freq,
			"sweep": randf_range(1000.0, 3000.0) * sweep_dir,
			"phase": 0.0,
			"amp": randf_range(0.3, 0.7)
		})
		# Sometimes rapid double chirp
		if randf() > 0.6:
			next_chirp_time = time + randf_range(0.05, 0.12)
		else:
			next_chirp_time = time + randf_range(0.3, 1.2)

	var sample := 0.0
	var i := chirps.size() - 1
	while i >= 0:
		var c: Dictionary = chirps[i]
		c["life"] += dt
		if c["life"] < c["dur"]:
			var t_norm: float = c["life"] / c["dur"]
			var env := sin(t_norm * PI)
			var freq: float = c["base_freq"] + c["sweep"] * t_norm
			c["phase"] += freq * dt * TAU
			sample += sin(c["phase"]) * env * c["amp"] * 0.3
		else:
			chirps.remove_at(i)
		i -= 1

	if chirps.size() > 10:
		chirps = chirps.slice(chirps.size() - 10)

	return sample
