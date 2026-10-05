# -*- coding: utf-8 -*-
class_name Interactable
extends Node2D

var _reserved_by: Variant = null


func can_interact(actor: Variant) -> bool:
	return actor != null


func get_interaction_label(_actor: Variant) -> String:
	return "Interact"


func interact(_actor: Variant) -> void:
	pass


func reserve(user_id: Variant) -> bool:
	if user_id == null:
		return false

	if not is_reserved():
		_reserved_by = user_id
		return true

	return _reserved_by == user_id


func release(user_id: Variant) -> void:
	if _reserved_by == user_id:
		_reserved_by = null


func is_reserved() -> bool:
	return _reserved_by != null


func get_reserved_by() -> Variant:
	return _reserved_by


func get_interaction_point_global_position() -> Vector2:
	var interaction_point := get_node_or_null("InteractionPoint") as Marker2D
	return interaction_point.global_position if interaction_point else global_position
