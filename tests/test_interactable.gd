# -*- coding: utf-8 -*-
extends "res://scripts/interactables/interactable.gd"

var interaction_count := 0

@onready var placeholder: Polygon2D = $Placeholder


func interact(actor: Variant) -> void:
	if not can_interact(actor):
		return

	interaction_count += 1
	placeholder.color = Color(0.49, 0.77, 0.54, 1) if interaction_count % 2 else Color(0.43, 0.63, 0.88, 1)
	print("[PASS] TestInteractable interaction %d" % interaction_count)
