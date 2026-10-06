# -*- coding: utf-8 -*-
class_name AdoptionWall
extends Control

var system: Node
var panel: Panel
var content: VBoxContainer


func _ready() -> void:
	visible = false
	system = get_tree().get_first_node_in_group("adoption_system")
	_build_shell()
	if system != null:
		system.adoption_recorded.connect(_on_adoption_recorded)
	var wall_button := get_node_or_null("../AdoptionWallButton") as Button
	if wall_button != null:
		wall_button.pressed.connect(show_wall)


func _build_shell() -> void:
	panel = Panel.new()
	panel.position = Vector2(280, 120)
	panel.size = Vector2(590, 400)
	add_child(panel)
	content = VBoxContainer.new()
	content.position = Vector2(24, 20)
	content.size = Vector2(542, 355)
	content.add_theme_constant_override("separation", 10)
	panel.add_child(content)


func show_wall() -> void:
	visible = true
	_refresh()


func _on_adoption_recorded(record: Dictionary) -> void:
	if bool(record.get("approved", false)):
		show_wall()


func _refresh() -> void:
	for child in content.get_children():
		child.queue_free()
	_add_text("ADOPTION WALL", 22)
	var history: Array = system.get("adoption_history")
	var approved_entries := 0
	for entry in history:
		var record := entry as Dictionary
		if bool(record.get("approved", false)):
			approved_entries += 1
			_add_text("%s\nAdopted by %s\n%s\nStatus: Starting a new home" % [record.get("cat_name", ""), record.get("applicant_name", ""), record.get("adoption_timestamp_or_game_day", "")], 17)
	if approved_entries == 0:
		_add_text("No cats have started a new home yet.")
	var close := Button.new()
	close.text = "Close"
	close.pressed.connect(_close)
	content.add_child(close)


func _add_text(text: String, font_size := 16) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	content.add_child(label)


func _close() -> void:
	visible = false
