# -*- coding: utf-8 -*-
class_name CatController
extends CharacterBody2D

enum CatState {
	IDLE,
	WANDER,
	EAT,
	DRINK,
	SLEEP,
	LITTER,
	PLAY,
}

const WALKABLE_BOUNDS := Rect2(96, 128, 960, 440)

@export var cat_id: String = ""
@export var display_name: String = "Cat"
@export var wander_speed: float = 110.0
@export var interaction_distance: float = 40.0
@export var decision_interval: float = 1.5

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var needs: Node = $Needs
@onready var debug_label: Label = $DebugLabel

var current_state: CatState = CatState.IDLE
var wander_cycles: int = 0

var _idle_time_remaining := 0.0
var _wander_target := Vector2.ZERO
var _random := RandomNumberGenerator.new()
var _decision_time_remaining := 0.0
var _action_cooldown_remaining := 0.0
var _action_target: Node = null
var _action_started := false
var _action_time_remaining := 0.0


func _ready() -> void:
	_random.randomize()
	_enter_idle(1.5)
	_update_debug_label()
	await get_tree().physics_frame


func _physics_process(delta: float) -> void:
	needs.call("tick", delta)
	_action_cooldown_remaining = maxf(_action_cooldown_remaining - delta, 0.0)

	if current_state == CatState.IDLE or current_state == CatState.WANDER:
		_decide_next_behavior(delta)

	match current_state:
		CatState.IDLE:
			_idle_time_remaining -= delta
			if _idle_time_remaining <= 0.0:
				_start_wander()
		CatState.WANDER:
			_update_wander()
		CatState.EAT, CatState.DRINK, CatState.SLEEP, CatState.LITTER, CatState.PLAY:
			_update_action(delta)


func _enter_idle(idle_duration: float = -1.0) -> void:
	current_state = CatState.IDLE
	velocity = Vector2.ZERO
	_idle_time_remaining = idle_duration if idle_duration > 0.0 else _random.randf_range(0.6, 1.2)
	_update_debug_label()


func _start_wander() -> void:
	_wander_target = _choose_wander_target()
	navigation_agent.target_position = _wander_target
	current_state = CatState.WANDER
	_update_debug_label()


func _update_wander() -> void:
	if global_position.distance_to(_wander_target) <= navigation_agent.target_desired_distance:
		_finish_wander()
		return

	if navigation_agent.is_navigation_finished():
		_finish_wander()
		return

	var next_path_position := navigation_agent.get_next_path_position()
	velocity = global_position.direction_to(next_path_position) * wander_speed
	move_and_slide()


func _finish_wander() -> void:
	wander_cycles += 1
	_enter_idle()


func _decide_next_behavior(delta: float) -> void:
	_decision_time_remaining -= delta
	if _decision_time_remaining > 0.0 or _action_cooldown_remaining > 0.0:
		return

	_decision_time_remaining = decision_interval
	var chosen_state := _choose_urgent_action()
	if chosen_state != CatState.IDLE:
		_start_action(chosen_state)


func _choose_urgent_action() -> CatState:
	var best_score := 0.0
	var best_state := CatState.IDLE

	if _need("hunger") >= 70.0 and _resource_available("food_bowl", "servings"):
		best_score = _need("hunger")
		best_state = CatState.EAT
	if _need("thirst") >= 70.0 and _resource_available("water_bowl", "water_amount") and _need("thirst") > best_score:
		best_score = _need("thirst")
		best_state = CatState.DRINK
	if _need("litter_need") >= 70.0 and _need("litter_need") > best_score:
		best_score = _need("litter_need")
		best_state = CatState.LITTER
	if _need("energy") <= 30.0 and 100.0 - _need("energy") > best_score:
		best_score = 100.0 - _need("energy")
		best_state = CatState.SLEEP
	if _need("play") <= 30.0 and 100.0 - _need("play") > best_score:
		best_state = CatState.PLAY

	return best_state


func _need(property_name: String) -> float:
	return float(needs.get(property_name))


func _resource_available(group_name: String, amount_property: String) -> bool:
	var resource := get_tree().get_first_node_in_group(group_name)
	return resource != null and int(resource.get(amount_property)) > 0


func _start_action(action_state: CatState) -> void:
	var target := _get_target_for_state(action_state)
	if target == null or not bool(target.call("reserve", cat_id)):
		_action_cooldown_remaining = 2.0
		return

	_action_target = target
	_action_started = false
	_action_time_remaining = 0.0
	current_state = action_state
	navigation_agent.target_position = target.call("get_interaction_point_global_position") as Vector2
	_update_debug_label()


func _get_target_for_state(action_state: CatState) -> Node:
	match action_state:
		CatState.EAT:
			return get_tree().get_first_node_in_group("food_bowl")
		CatState.DRINK:
			return get_tree().get_first_node_in_group("water_bowl")
		CatState.SLEEP:
			return get_tree().get_first_node_in_group("cat_bed")
		CatState.LITTER:
			return get_tree().get_first_node_in_group("litter_box")
		CatState.PLAY:
			return get_tree().get_first_node_in_group("cat_toy")
	return null


func _update_action(delta: float) -> void:
	if not is_instance_valid(_action_target):
		_abort_action()
		return

	if not _action_started:
		var interaction_point := _action_target.call("get_interaction_point_global_position") as Vector2
		if global_position.distance_to(interaction_point) > interaction_distance:
			if navigation_agent.is_navigation_finished():
				_abort_action()
				return
			var next_path_position := navigation_agent.get_next_path_position()
			velocity = global_position.direction_to(next_path_position) * wander_speed
			move_and_slide()
			return

		_begin_action_at_target()
		return

	velocity = Vector2.ZERO
	if current_state == CatState.SLEEP:
		needs.call("restore_energy", delta)
	_action_time_remaining -= delta
	if _action_time_remaining <= 0.0:
		_finish_action()


func _begin_action_at_target() -> void:
	_action_started = true
	match current_state:
		CatState.EAT:
			if int(_action_target.get("servings")) <= 0:
				_abort_action()
				return
			_action_target.set("servings", int(_action_target.get("servings")) - 1)
			needs.call("satisfy_hunger")
			_action_time_remaining = 1.2
		CatState.DRINK:
			if int(_action_target.get("water_amount")) <= 0:
				_abort_action()
				return
			_action_target.set("water_amount", int(_action_target.get("water_amount")) - 1)
			needs.call("satisfy_thirst")
			_action_time_remaining = 1.2
		CatState.SLEEP:
			if not bool(_action_target.call("occupy", cat_id)):
				_abort_action()
				return
			_action_time_remaining = 4.0
		CatState.LITTER:
			_action_target.call("use_litter")
			needs.call("relieve_litter")
			_action_time_remaining = 1.0
		CatState.PLAY:
			if not bool(_action_target.call("play", cat_id)):
				_abort_action()
				return
			_action_time_remaining = 2.0


func _finish_action() -> void:
	if current_state == CatState.PLAY:
		needs.call("satisfy_play")
	if current_state == CatState.SLEEP:
		_action_target.call("vacate", cat_id)
	_action_target.call("release", cat_id)
	_action_target = null
	_action_started = false
	_action_cooldown_remaining = 1.5
	_enter_idle(0.5)


func _abort_action() -> void:
	if is_instance_valid(_action_target):
		if current_state == CatState.SLEEP:
			_action_target.call("vacate", cat_id)
		_action_target.call("release", cat_id)
	_action_target = null
	_action_started = false
	velocity = Vector2.ZERO
	_action_cooldown_remaining = 2.0
	_enter_idle(0.5)


func _update_debug_label() -> void:
	if is_instance_valid(debug_label):
		debug_label.text = "%s\n%s" % [display_name, CatState.keys()[current_state]]


func _choose_wander_target() -> Vector2:
	for _attempt in 3:
		var direction := Vector2.from_angle(_random.randf_range(0.0, TAU))
		var distance := _random.randf_range(96.0, 180.0)
		var candidate := (global_position + direction * distance).clamp(WALKABLE_BOUNDS.position, WALKABLE_BOUNDS.end)
		if candidate.distance_to(global_position) >= 72.0:
			return candidate

	return WALKABLE_BOUNDS.get_center()
