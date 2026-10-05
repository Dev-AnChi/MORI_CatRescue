# -*- coding: utf-8 -*-
class_name CatBed
extends "res://scripts/interactables/interactable.gd"

var occupied_by: Variant = null
var reserved_by: Variant = null

@onready var cushion: Polygon2D = $Cushion
@onready var occupied_indent: Polygon2D = $OccupiedIndent


func _ready() -> void:
	_refresh_visuals()


func can_interact(_actor: Variant) -> bool:
	return false


func reserve(user_id: Variant) -> bool:
	if user_id == null or (is_occupied() and occupied_by != user_id):
		return false

	var reserved := super.reserve(user_id)
	reserved_by = super.get_reserved_by()
	return reserved


func release(user_id: Variant) -> void:
	super.release(user_id)
	reserved_by = super.get_reserved_by()


func occupy(user_id: Variant) -> bool:
	if user_id == null:
		return false
	if is_occupied():
		return occupied_by == user_id

	var current_reservation: Variant = super.get_reserved_by()
	if current_reservation != null and current_reservation != user_id:
		return false
	if current_reservation == null and not reserve(user_id):
		return false

	occupied_by = user_id
	_refresh_visuals()
	return true


func vacate(user_id: Variant) -> void:
	if occupied_by != user_id:
		return

	occupied_by = null
	release(user_id)
	_refresh_visuals()


func is_occupied() -> bool:
	return occupied_by != null


func get_occupied_by() -> Variant:
	return occupied_by


func _refresh_visuals() -> void:
	if not is_node_ready():
		return

	occupied_indent.visible = is_occupied()
	cushion.color = Color(0.75, 0.52, 0.58, 1) if is_occupied() else Color(0.91, 0.66, 0.71, 1)
