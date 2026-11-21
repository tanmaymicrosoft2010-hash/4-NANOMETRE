extends Area2D

@export var launch_speed := 800.0
const STROKE := 0.2
var elapsed := 0.0


func advance(delta: float) -> void:
	elapsed = minf(STROKE, elapsed + delta)
	$Lip.position.y = -9.0 + 7.0 * elapsed / STROKE


func boot_height() -> float:
	return $Lip.global_position.y


func release() -> void:
	elapsed = 0.0
	$Lip.position.y = -9.0
