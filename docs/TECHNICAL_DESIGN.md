# MORI Cat Rescue 2D — Technical Design

## Main Tree
Main
- World (Node2D)
  - Room
  - NavigationRegion2D
  - Interactables
  - Cats
  - Caretaker
- Systems (Node)
  - TimeSystem
  - SaveSystem
  - EconomySystem
  - AdoptionSystem
  - EventSystem
- UI (CanvasLayer)

## Caretaker
CharacterBody2D
- Sprite2D / AnimatedSprite2D
- CollisionShape2D
- NavigationAgent2D
- InteractionArea

Movement:
click/tap floor -> world point -> NavigationAgent2D.target_position -> follow path.

No WASD required.

## Navigation
Use NavigationRegion2D.
Use simple obstacle/collision rules for furniture.

## Y Sorting
Use y_sort_enabled or controlled z_index so actors move behind/in front of furniture naturally.

## Interactable Base
Suggested API:
- can_interact(actor) -> bool
- get_interaction_label(actor) -> String
- interact(actor) -> void
- reserve(user_id) -> bool
- release(user_id)
- is_reserved() -> bool
- get_reserved_by()

Each interactable has Marker2D named `InteractionPoint`.

## Cat Scene
Cat (CharacterBody2D)
- AnimatedSprite2D
- NavigationAgent2D
- CollisionShape2D
- InteractionArea
- NeedsComponent
- PersonalityComponent
- HealthComponent
- ObservationComponent

## Utility AI
Evaluate on an interval, not every frame.

Actions:
eat, drink, sleep, litter, play, groom, hide, socialize, wander.

Score uses:
need urgency × personality × availability × environment × health/stress + small random variation.

## Reservation
Exclusive objects must reserve.

Example:
Miso reserves Bed A -> Cam cannot select Bed A -> release on completion/cancel.

## Object States
FoodBowl: empty / partial / full
WaterBowl: empty / full
LitterBox: clean / used / dirty
Bed: free / reserved / occupied
Toy: free / reserved

## Art
Runtime art is PNG/WebP/sprite sheets.

Later Blender can batch render:
- fixed orthographic camera
- transparent background
- same light rig
- same angle
- same scale

Gameplay must not depend on Blender.

## Data
Use JSON or Resources for:
cats, traits, rescue cases, adopters, questions, red flags, items, upgrades, events.

## Adoption Evaluator
Input: cat profile + applicant profile.

Output:
- hard_blocks
- red_flags
- compatibility breakdown
- unknowns
- recommendation
- confidence
- conditions

## Save
Versioned JSON is fine initially.

## Debug
Later debug overlay:
- cat state
- utility winner
- target object
- reservation
- needs
- path status
- game time
