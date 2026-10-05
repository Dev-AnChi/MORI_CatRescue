# -*- coding: utf-8 -*-
class_name CatController
extends CharacterBody2D

enum CatState {
	IDLE,
	WANDER,
}

const WALKABLE_BOUNDS := Rect2(96, 128, 960, 440)

@export var cat_id: String = ""
@export var display_name: String = "Cat"
@export var wander_speed: float = 110.0

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var current_state: CatState = CatState.IDLE
var wander_cycles: int = 0

var _idle_time_remaining := 0.0
var _wander_target := Vector2.ZERO
var _random := RandomNumberGenerator.new()


func _ready() -> void:
	_random.randomize()
	_enter_idle(1.5)
	await get_tree().physics_frame


func _physics_process(delta: float) -> void:
	match current_state:
		CatState.IDLE:
			_idle_time_remaining -= delta
			if _idle_time_remaining <= 0.0:
				_start_wander()
		CatState.WANDER:
			_update_wander()


func _enter_idle(idle_duration: float = -1.0) -> void:
	current_state = CatState.IDLE
	velocity = Vector2.ZERO
	_idle_time_remaining = idle_duration if idle_duration > 0.0 else _random.randf_range(0.6, 1.2)


func _start_wander() -> void:
	_wander_target = _choose_wander_target()
	navigation_agent.target_position = _wander_target
	current_state = CatState.WANDER


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


func _choose_wander_target() -> Vector2:
	for _attempt in 3:
		var direction := Vector2.from_angle(_random.randf_range(0.0, TAU))
		var distance := _random.randf_range(96.0, 180.0)
		var candidate := (global_position + direction * distance).clamp(WALKABLE_BOUNDS.position, WALKABLE_BOUNDS.end)
		if candidate.distance_to(global_position) >= 72.0:
			return candidate

	return WALKABLE_BOUNDS.get_center()
