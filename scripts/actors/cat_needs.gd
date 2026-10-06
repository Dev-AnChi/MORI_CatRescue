# -*- coding: utf-8 -*-
class_name CatNeeds
extends Node

@export_range(0.0, 100.0) var hunger := 35.0
@export_range(0.0, 100.0) var thirst := 35.0
@export_range(0.0, 100.0) var energy := 72.0
@export_range(0.0, 100.0) var litter_need := 20.0
@export_range(0.0, 100.0) var play := 70.0
@export_range(0.0, 100.0) var stress := 18.0
@export_range(0.0, 100.0) var trust := 50.0


func tick(delta: float) -> void:
	hunger = clampf(hunger + 1.0 * delta, 0.0, 100.0)
	thirst = clampf(thirst + 1.2 * delta, 0.0, 100.0)
	energy = clampf(energy - 0.7 * delta, 0.0, 100.0)
	litter_need = clampf(litter_need + 0.8 * delta, 0.0, 100.0)
	play = clampf(play - 0.9 * delta, 0.0, 100.0)
	stress = clampf(stress - 0.08 * delta, 0.0, 100.0)


func satisfy_hunger() -> void:
	hunger = maxf(hunger - 60.0, 0.0)


func satisfy_thirst() -> void:
	thirst = maxf(thirst - 65.0, 0.0)


func relieve_litter() -> void:
	litter_need = maxf(litter_need - 75.0, 0.0)


func restore_energy(delta: float) -> void:
	energy = minf(energy + 22.0 * delta, 100.0)


func satisfy_play() -> void:
	play = minf(play + 65.0, 100.0)
