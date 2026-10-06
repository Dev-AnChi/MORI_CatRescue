# -*- coding: utf-8 -*-
class_name AdoptionPanel
extends Control

var system: Node
var panel: Panel
var content: VBoxContainer
var question_index := 0
var evaluation: Dictionary = {}


func _ready() -> void:
	visible = false
	system = get_tree().get_first_node_in_group("adoption_system")
	_build_shell()
	var adoption_button := get_node_or_null("../AdoptionButton") as Button
	if adoption_button != null:
		adoption_button.pressed.connect(open_panel)


func open_panel() -> void:
	if system == null:
		return
	visible = true
	if not bool(system.call("begin_questionnaire")):
		_render_status("This application has already been decided.")
		return
	question_index = 0
	_render_question()


func _build_shell() -> void:
	panel = Panel.new()
	panel.position = Vector2(94, 34)
	panel.size = Vector2(964, 580)
	add_child(panel)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)
	content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	margin.add_child(content)


func _clear_content() -> void:
	for child in content.get_children():
		child.queue_free()


func _add_text(text: String, font_size := 16) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	content.add_child(label)


func _add_button(text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 36)
	button.pressed.connect(callback)
	content.add_child(button)


func _render_question() -> void:
	_clear_content()
	var cat := system.get("cat_profile") as Dictionary
	var applicant := system.get("applicant_profile") as Dictionary
	_add_text("ADOPTION INTERVIEW — %s" % str(cat.get("name", "Miso")), 22)
	_add_text("CAT PROFILE: %s | %s | Health %d | Trust %d | Ready: %s" % [cat.get("name", ""), cat.get("age_group", ""), int(cat.get("health", 0)), int(cat.get("trust", 0)), "Yes" if bool(cat.get("adoption_ready", false)) else "No"])
	_add_text("Known: %s    Unknown: %s" % [_join_values(cat.get("known_traits", [])), _join_values(cat.get("unknown_traits", []))])
	var household := applicant.get("household", {}) as Dictionary
	_add_text("APPLICANT: %s | %s | Adults %s | Children %s | Pets %s | Secure windows: %s" % [applicant.get("name", ""), household.get("housing_type", ""), household.get("adults", 0), _join_values(household.get("children", [])), _join_values(household.get("pets", [])), household.get("secure_windows", false)])
	_add_text("Schedule: %s hours away/day, %s remote days/week | Experience: %s | Budget: %s" % [applicant.get("work_schedule", {}).get("hours_away_per_day", 0), applicant.get("work_schedule", {}).get("remote_days_per_week", 0), applicant.get("experience", ""), applicant.get("budget_band", "")])

	var questions: Array = system.get("questions")
	if question_index >= questions.size():
		evaluation = system.call("evaluate_current") as Dictionary
		_render_evaluation()
		return

	var question: Dictionary = questions[question_index]
	_add_text("Question %d/%d: %s" % [question_index + 1, questions.size(), question.get("prompt", "")], 18)
	for answer in question.get("answers", []):
		var answer_data := answer as Dictionary
		_add_button(_readable(str(answer_data.get("id", ""))), _on_answer.bind(str(question.get("id", "")), answer_data))
	_add_button("Close", _close_panel)


func _on_answer(question_id: String, answer: Dictionary) -> void:
	system.call("submit_answer", question_id, answer)
	question_index += 1
	_render_question()


func _render_evaluation() -> void:
	_clear_content()
	_add_text("MATCH EVALUATION", 22)
	_add_text("Recommendation: %s   Confidence: %d%%" % [evaluation.get("recommendation", "INVESTIGATE"), int(evaluation.get("confidence", 0))], 19)
	_add_text("Compatibility: %s" % _format_scores(evaluation.get("compatibility_scores", {})))
	_add_text("Strong points: %s" % _join_values(evaluation.get("strong_points", [])))
	_add_text("Concerns: %s" % _join_values(evaluation.get("concerns", [])))
	_add_text("Hard blocks: %s" % _join_values(evaluation.get("hard_blocks", [])))
	_add_text("Red flags: %s" % _join_values(evaluation.get("red_flags", [])))
	_add_text("Unknown: %s" % _join_values(evaluation.get("unknowns", [])))
	if not (evaluation.get("conditions", []) as Array).is_empty():
		_add_text("Conditions: %s" % _join_values(evaluation.get("conditions", [])))
	_add_button("APPROVE", _on_decision.bind("APPROVE"))
	if not (evaluation.get("conditions", []) as Array).is_empty():
		_add_button("APPROVE WITH CONDITIONS", _on_decision.bind("APPROVE_WITH_CONDITIONS"))
	_add_button("REJECT", _on_decision.bind("REJECT"))


func _on_decision(decision: String) -> void:
	var record := system.call("decide", decision, evaluation) as Dictionary
	if record.is_empty():
		_render_status("Application was already decided.")
		return
	if bool(record.get("approved", false)):
		var wall := get_node_or_null("../AdoptionWall")
		if wall != null:
			wall.call("show_wall")
		visible = false
	else:
		_render_status("Application rejected. Miso remains in the shelter.")


func _render_status(message: String) -> void:
	_clear_content()
	_add_text("ADOPTION", 22)
	_add_text(message, 18)
	_add_button("Close", _close_panel)


func _close_panel() -> void:
	visible = false


func _join_values(values: Variant) -> String:
	var items: Array = values as Array
	if items.is_empty():
		return "None"
	var strings: Array[String] = []
	for item in items:
		strings.append(_readable(str(item)))
	return ", ".join(strings)


func _format_scores(scores: Variant) -> String:
	var values := scores as Dictionary
	var parts: Array[String] = []
	for key in values:
		parts.append("%s %s" % [_readable(str(key)), values[key]])
	return " | ".join(parts)


func _readable(value: String) -> String:
	return value.replace("_", " ").capitalize()
