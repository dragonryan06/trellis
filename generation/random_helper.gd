extends Node

# Error margin for cumulative weighting
const EPSILON := 0.001

func get_weighted_random_key(table: Dictionary[String, float]) -> String:
	var point := randf()
	var sum := 0.0
	for i in range(len(table)):
		sum += table.values()[i]
		if (point <= sum + EPSILON):
			return table.keys()[i]
	return "WEIGHTS DIDN'T ADD TO 1.0!"
