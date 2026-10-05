# -*- coding: utf-8 -*-
class_name WaterBowl
extends "res://scripts/interactables/interactable.gd"

enum WaterState {
	EMPTY,
	FULL,
}

@export var capacity: int = 3:
	set(value):
		capacity = maxi(value, 1)
		water_amount = water_amount

@export var water_amount: int = 0:
	set(value):
		water_amount = clampi(value, 0, capacity)
		_refresh_visuals()

@onready var water_surface: Polygon2D = $WaterSurface


func _ready() -> void:
	water_amount = water_amount


func can_interact(actor: Variant) -> bool:
	return super.can_interact(actor) and water_amount < capacity


func get_interaction_label(actor: Variant) -> String:
	return "Refill Water" if can_interact(actor) else "Water Bowl Full"


func interact(actor: Variant) -> void:
	if can_interact(actor):
		water_amount = capacity


func get_water_state() -> int:
	return WaterState.EMPTY if water_amount <= 0 else WaterState.FULL


func _refresh_visuals() -> void:
	if not is_node_ready():
		return

	water_surface.visible = get_water_state() == WaterState.FULL
