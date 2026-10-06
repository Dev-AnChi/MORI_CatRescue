# -*- coding: utf-8 -*-
class_name AdoptionDataLoader
extends RefCounted


static func load_json(path: String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return {}
	return json.data


static func load_cat_profile(path: String, live_cat: Node = null) -> Dictionary:
	var data := load_json(path) as Dictionary
	var cat_needs := data.get("needs", {}) as Dictionary
	var live_needs := live_cat.get_node_or_null("Needs") if live_cat != null else null
	var trust := float(cat_needs.get("trust", 0.0))
	if live_needs != null:
		trust = float(live_needs.get("trust"))

	var known_traits: Array[String] = []
	var unknown_traits: Array[String] = []
	var traits := data.get("traits", {}) as Dictionary
	var confidence := data.get("trait_confidence", {}) as Dictionary
	for trait_name in traits:
		if float(confidence.get(trait_name, 0.0)) >= 0.2:
			known_traits.append(str(trait_name))
		else:
			unknown_traits.append(str(trait_name))

	var health := float(cat_needs.get("health", 0.0))
	return {
		"id": str(data.get("id", "")),
		"name": str(data.get("name", "Unknown")),
		"age_group": str(data.get("age_group", "unknown")),
		"health": health,
		"trust": trust,
		"traits": traits,
		"known_traits": known_traits,
		"unknown_traits": unknown_traits,
		"adoption_ready": health >= 60.0 and trust >= 30.0,
	}


static func load_applicant(path: String) -> Dictionary:
	return load_json(path) as Dictionary


static func load_questions(path: String) -> Array:
	var loaded: Variant = load_json(path)
	return loaded as Array if loaded is Array else []
