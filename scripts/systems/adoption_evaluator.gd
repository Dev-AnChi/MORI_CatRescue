# -*- coding: utf-8 -*-
class_name AdoptionEvaluator
extends RefCounted

const HARD_BLOCK_TAGS := ["hard_block_welfare"]
const RED_FLAG_TAGS := ["red_flag_punitive", "red_flag_medical", "red_flag_commitment", "red_flag_expectations"]


static func evaluate(cat_profile: Dictionary, applicant: Dictionary, answers: Dictionary) -> Dictionary:
	var tags: Array[String] = []
	for question_id in answers:
		var answer := answers[question_id] as Dictionary
		for tag in answer.get("tags", []):
			tags.append(str(tag))

	var hard_blocks: Array[String] = []
	var red_flags: Array[String] = []
	for tag in tags:
		if tag in HARD_BLOCK_TAGS and not tag in hard_blocks:
			hard_blocks.append(tag)
		if tag in RED_FLAG_TAGS and not tag in red_flags:
			red_flags.append(tag)

	var household := applicant.get("household", {}) as Dictionary
	var schedule := applicant.get("work_schedule", {}) as Dictionary
	var housing_score := 85.0 if bool(household.get("secure_windows", false)) else 35.0
	var schedule_score := clampf(85.0 - float(schedule.get("hours_away_per_day", 8)) * 4.0 + float(schedule.get("remote_days_per_week", 0)) * 5.0, 20.0, 95.0)
	var experience_score := 85.0 if str(applicant.get("experience", "")) == "previous_cat_owner" else 50.0
	var finance_score := 85.0 if str(applicant.get("budget_band", "")) == "stable" else 50.0
	var expectations_score := 75.0
	if "patient" in tags or "cat_knowledge" in tags:
		expectations_score += 15.0
	if not red_flags.is_empty():
		expectations_score -= 30.0
	var household_score := 80.0 if (household.get("children", []) as Array).is_empty() else 60.0
	var cat_specific_score := clampf((float(cat_profile.get("health", 0.0)) + float(cat_profile.get("trust", 0.0))) * 0.5, 0.0, 100.0)

	var compatibility_scores := {
		"housing": roundi(housing_score),
		"schedule": roundi(schedule_score),
		"experience": roundi(experience_score),
		"finances": roundi(finance_score),
		"expectations": roundi(expectations_score),
		"household": roundi(household_score),
		"cat_specific_suitability": roundi(cat_specific_score),
	}
	var total := 0.0
	for score in compatibility_scores.values():
		total += float(score)
	var average := total / compatibility_scores.size()

	var conditions: Array[String] = []
	if float(schedule.get("hours_away_per_day", 0)) >= 8.0:
		conditions.append("Provide enrichment and a check-in plan for long workdays.")
	if not cat_profile.get("unknown_traits", []).is_empty():
		conditions.append("Use a gradual settling-in plan while Miso's unknown traits are observed.")

	var recommendation := "POOR_MATCH"
	if not hard_blocks.is_empty():
		recommendation = "REJECT"
	elif not red_flags.is_empty():
		recommendation = "ACCEPTABLE_WITH_CONDITIONS" if average >= 60.0 else "INVESTIGATE"
	elif average >= 80.0:
		recommendation = "STRONG_MATCH"
	elif average >= 65.0:
		recommendation = "ACCEPTABLE_WITH_CONDITIONS" if not conditions.is_empty() else "ACCEPTABLE"
	elif average >= 50.0:
		recommendation = "INVESTIGATE"

	var strong_points: Array[String] = []
	if housing_score >= 75.0:
		strong_points.append("Secure housing")
	if experience_score >= 75.0:
		strong_points.append("Previous cat experience")
	if finance_score >= 75.0:
		strong_points.append("Stable budget")
	var concerns: Array[String] = []
	if float(schedule.get("hours_away_per_day", 0)) >= 8.0:
		concerns.append("Away from home about 8 hours/day")
	for flag in red_flags:
		concerns.append(flag.replace("red_flag_", "").replace("_", " "))

	var confidence := clampf(70.0 - float(cat_profile.get("unknown_traits", []).size()) * 8.0 - red_flags.size() * 10.0, 25.0, 95.0)
	return {
		"hard_blocks": hard_blocks,
		"red_flags": red_flags,
		"compatibility_scores": compatibility_scores,
		"unknowns": cat_profile.get("unknown_traits", []),
		"recommendation": recommendation,
		"confidence": roundi(confidence),
		"conditions": conditions,
		"strong_points": strong_points,
		"concerns": concerns,
	}
