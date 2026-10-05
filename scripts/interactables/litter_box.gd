# -*- coding: utf-8 -*-
class_name LitterBox
extends "res://scripts/interactables/interactable.gd"

enum LitterState {
	CLEAN,
	USED,
	DIRTY,
}

@export var dirty_threshold: int = 3:
	set(value):
		dirty_threshold = maxi(value, 1)
		uses_since_clean = uses_since_clean

@export var uses_since_clean: int = 0:
	set(value):
		uses_since_clean = maxi(value, 0)
		_refresh_visuals()

@onready var used_mark: Polygon2D = $UsedMark
@onready var dirty_marks: Polygon2D = $DirtyMarks


func _ready() -> void:
	uses_since_clean = uses_since_clean


func use_litter() -> void:
	uses_since_clean += 1


func can_interact(actor: Variant) -> bool:
	return super.can_interact(actor) and get_litter_state() != LitterState.CLEAN


func get_interaction_label(actor: Variant) -> String:
	return "Clean Litter Box" if can_interact(actor) else "Litter Box Clean"


func interact(actor: Variant) -> void:
	if can_interact(actor):
		uses_since_clean = 0


func get_litter_state() -> int:
	if uses_since_clean <= 0:
		return LitterState.CLEAN
	if uses_since_clean >= dirty_threshold:
		return LitterState.DIRTY
	return LitterState.USED


func _refresh_visuals() -> void:
	if not is_node_ready():
		return

	used_mark.visible = get_litter_state() == LitterState.USED
	dirty_marks.visible = get_litter_state() == LitterState.DIRTY
