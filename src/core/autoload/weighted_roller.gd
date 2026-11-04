class_name WeightedRoll

var pool: Dictionary = {}
var total_weight: int = 0

func _init(init_pool) -> void:
	pool = init_pool
	
	for weight in pool.values():
		total_weight += weight

func roll() -> Variant:
	if pool.is_empty(): return null
	
	var result = pool.keys().back()
	var chance = randf() * total_weight
	
	for value in pool:
		var weight = pool[value]
		chance -= weight
		
		if chance < 0.0:
			result = value
			break
	
	return result
