# -*- coding: utf-8 -*-
class_name AdoptionSystem
extends Node

signal adoption_recorded(record: Dictionary)

const DataLoader = preload("res://scripts/systems/adoption_data_loader.gd")
const Evaluator = preload("res://scripts/systems/adoption_evaluator.gd")

const MISO_DATA_PATH := "res://data/cats/miso.json"
const APPLICANT_DATA_PATH := "res://data/adopters/applicant_minh_001.json"
const QUESTIONS_PATH := "res://data/questions/adoption_questions.json"

var cat_profile: Dictionary = {}
var applicant_profile: Dictionary = {}
var questions: Array = []
var answers: Dictionary = {}
var adoption_history: Array[Dictionary] = []
var application_status := "pending"


func _ready() -> void:
	add_to_group("adoption_system")
	refresh_profiles()
	applicant_profile = DataLoader.load_applicant(APPLICANT_DATA_PATH)
	questions = DataLoader.load_questions(QUESTIONS_PATH)


func refresh_profiles() -> void:
	cat_profile = DataLoader.load_cat_profile(MISO_DATA_PATH, _get_miso())


func begin_questionnaire() -> bool:
	return application_status == "pending" and not cat_profile.is_empty()


func submit_answer(question_id: String, answer: Dictionary) -> void:
	if application_status == "pending":
		answers[question_id] = answer


func questionnaire_complete() -> bool:
	return answers.size() >= mini(questions.size(), 5)


func evaluate_current() -> Dictionary:
	refresh_profiles()
	return Evaluator.evaluate(cat_profile, applicant_profile, answers)


func decide(player_decision: String, evaluation: Dictionary) -> Dictionary:
	if application_status != "pending":
		return {}

	var approved := player_decision != "REJECT"
	var record := {
		"cat_id": cat_profile.get("id", ""),
		"cat_name": cat_profile.get("name", ""),
		"applicant_id": applicant_profile.get("id", ""),
		"applicant_name": applicant_profile.get("name", ""),
		"approved": approved,
		"adoption_timestamp_or_game_day": Time.get_datetime_string_from_system(),
		"recommendation": evaluation.get("recommendation", "INVESTIGATE"),
		"player_decision": player_decision,
		"followup_status": "new_home" if approved else "not_started",
	}
	adoption_history.append(record)
	application_status = "approved" if approved else "rejected"

	if approved:
		_remove_miso_from_shelter()
	adoption_recorded.emit(record)
	return record


func _remove_miso_from_shelter() -> void:
	var miso := _get_miso()
	if miso == null:
		return
	for group_name in ["food_bowl", "water_bowl", "litter_box", "cat_bed", "cat_toy"]:
		var target := get_tree().get_first_node_in_group(group_name)
		if target != null:
			if target.has_method("vacate"):
				target.call("vacate", "miso")
			target.call("release", "miso")
	miso.call("prepare_for_adoption")
	miso.queue_free()


func _get_miso() -> Node:
	return get_node_or_null("../World/Actors/Miso")
