extends Control

@export var p1_health : int
@export var p2_health : int
@export var p3_health : int
@export var p4_health : int

func _process(delta: float) -> void:
	$P1Health.text = "p1: " + str(p1_health)
	$P2Health.text = "p2: " + str(p2_health)
	$P3Health.text = "p3: " + str(p3_health)
	$P4Health.text = "p4: " + str(p4_health)
