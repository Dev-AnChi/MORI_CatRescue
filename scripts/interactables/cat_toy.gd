# -*- coding: utf-8 -*-
class_name CatToy
extends "res://scripts/interactables/interactable.gd"

var reserved_by: Variant = null
var uses_count: int = 0

@onready var toy_ball: Polygon2D = $ToyBall


func can_interact(_actor: Variant) -> bool:
	return false


func reserve(user_id: Variant) -> bool:
	var reserved := super.reserve(user_id)
	reserved_by = super.get_reserved_by()
	return reserved


func release(user_id: Variant) -> void:
	super.release(user_id)
	reserved_by = super.get_reserved_by()


func play(user_id: Variant) -> bool:
	if user_id == null or super.get_reserved_by() != user_id:
		return false

	uses_count += 1
	_refresh_visual()
	return true


func _refresh_visual() -> void:
	if not is_node_ready():
		return

	toy_ball.rotation += PI / 6.0
	toy_ball.color = Color(0.96, 0.54, 0.32, 1) if uses_count % 2 else Color(0.95, 0.72, 0.27, 1)
