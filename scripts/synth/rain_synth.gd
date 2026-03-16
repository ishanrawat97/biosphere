extends BaseSynth
class_name RainSynth

var drops: Array[Dictionary] = []
var next_drop_time := 0.0
var lp_prev := 0.0

func start() -> void:
	super.start()
	drops.clear()
	next_drop_time = 0.0

func _generate_sample(dt: float) -> float:
	# Spawn new raindrops
	if time >= next_drop_time:
		drops.append({"life": 0.0, "dur": randf_range(0.001, 0.004), "amp": randf_range(0.3, 1.0)})
		next_drop_time = time + randf_range(0.0005, 0.005)

	# Sum active drops
	var sample: float = 0.0
	var i: int = drops.size() - 1
	while i >= 0:
		var d: Dictionary = drops[i]
		d["life"] += dt
		if d["life"] < d["dur"]:
			var env: float = 1.0 - d["life"] / d["dur"]
			sample += _white_noise() * env * d["amp"] * 0.15
		else:
			drops.remove_at(i)
		i -= 1

	# Limit active drops
	if drops.size() > 80:
		drops = drops.slice(drops.size() - 80)

	# Ambient rain floor
	var rc: float = 1.0 / (TAU * 2000.0)
	var alpha: float = dt / (rc + dt)
	lp_prev = lp_prev + alpha * (_white_noise() - lp_prev)
	sample += lp_prev * 0.15

	return sample
