# -*- coding: utf-8 -*-
class_name FoodBowl
extends "res://scripts/interactables/interactable.gd"

enum FoodState {
	EMPTY,
	PARTIAL,
	FULL,
}

@export var capacity: int = 3:
	set(value):
		capacity = maxi(value, 1)
		servings = servings

@export var servings: int = 0:
	set(value):
		servings = clampi(value, 0, capacity)
		_refresh_visuals()

@onready var food_small: Polygon2D = $FoodSmall
@onready var food_full: Polygon2D = $FoodFull


func _ready() -> void:
	servings = servings


func can_interact(actor: Variant) -> bool:
	return super.can_interact(actor) and servings < capacity


func get_interaction_label(actor: Variant) -> String:
	return "Refill Food" if can_interact(actor) else "Food Bowl Full"


func interact(actor: Variant) -> void:
	if can_interact(actor):
		servings = capacity


func get_food_state() -> int:
	if servings <= 0:
		return FoodState.EMPTY
	if servings >= capacity:
		return FoodState.FULL
	return FoodState.PARTIAL


func _refresh_visuals() -> void:
	if not is_node_ready():
		return

	food_small.visible = get_food_state() == FoodState.PARTIAL
	food_full.visible = get_food_state() == FoodState.FULL
