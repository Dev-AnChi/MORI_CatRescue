# -*- coding: utf-8 -*-
class_name CaretakerController
extends CharacterBody2D

@export var move_speed: float = 220.0
@export var interaction_distance: float = 48.0

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var _has_target := false
var _pending_interactable: Node = null


func _ready() -> void:
	# Wait until NavigationRegion2D has synchronized its map before accepting paths.
	call_deferred("_sync_navigation")


func _sync_navigation() -> void:
	await get_tree().physics_frame


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_handle_world_click(_screen_to_world(event.position))
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch and event.pressed:
		_handle_world_click(_screen_to_world(event.position))
		get_viewport().set_input_as_handled()


func _physics_process(_delta: float) -> void:
	if _pending_interactable != null:
		if not is_instance_valid(_pending_interactable) or not bool(_pending_interactable.call("can_interact", self)):
			_cancel_pending_interaction()
		elif _is_within_interaction_range(_pending_interactable):
			_complete_pending_interaction()
			return

	if not _has_target:
		velocity = Vector2.ZERO
		return

	if navigation_agent.is_navigation_finished():
		_stop_at_destination()
		return

	var next_path_position := navigation_agent.get_next_path_position()
	var direction := global_position.direction_to(next_path_position)
	velocity = direction * move_speed
	move_and_slide()

	if global_position.distance_to(navigation_agent.target_position) <= navigation_agent.target_desired_distance:
		_stop_at_destination()


func _set_destination(destination: Vector2) -> void:
	navigation_agent.target_position = destination
	_has_target = true


func _stop_at_destination() -> void:
	_has_target = false
	velocity = Vector2.ZERO


func _handle_world_click(world_position: Vector2) -> void:
	var interactable := _find_interactable_at(world_position)
	if interactable != null and bool(interactable.call("can_interact", self)):
		_pending_interactable = interactable
		_set_destination(interactable.call("get_interaction_point_global_position") as Vector2)
		return

	_cancel_pending_interaction()
	_set_destination(world_position)


func _find_interactable_at(world_position: Vector2) -> Node:
	var query := PhysicsPointQueryParameters2D.new()
	query.position = world_position
	query.collide_with_areas = true
	query.collide_with_bodies = false

	for result in get_world_2d().direct_space_state.intersect_point(query):
		var current_node := result.collider as Node
		while current_node != null:
			if current_node.has_method("can_interact") and current_node.has_method("interact") and current_node.has_method("get_interaction_point_global_position"):
				return current_node
			current_node = current_node.get_parent()

	return null


func _is_within_interaction_range(interactable: Node) -> bool:
	return global_position.distance_to(interactable.call("get_interaction_point_global_position") as Vector2) <= interaction_distance


func _complete_pending_interaction() -> void:
	var interactable := _pending_interactable
	_pending_interactable = null
	_stop_at_destination()
	interactable.call("interact", self)


func _cancel_pending_interaction() -> void:
	_pending_interactable = null


func _screen_to_world(screen_position: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * screen_position
