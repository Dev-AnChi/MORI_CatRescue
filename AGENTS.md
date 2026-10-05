# MORI Cat Rescue 2D — Codex Rules

## Product
MORI Cat Rescue is a cozy 2D cat rescue shelter management game.

The player rescues cats, cares for them, discovers their personalities, interviews adopters, matches cats to suitable homes, and follows up after adoption.

The goal is NOT to keep cats forever. The goal is successful placement into suitable permanent homes.

## Engine
- Godot 4.x
- GDScript
- 2D only
- mouse + touch first
- Windows first
- Android later

## Presentation
Use a cozy 2D top-down / 3/4 room view.

Do not use:
- 3D nodes
- Camera3D
- NavigationAgent3D
- MeshInstance3D
- runtime GLB assets

Use:
- Node2D
- CharacterBody2D
- NavigationAgent2D
- Area2D
- CollisionShape2D
- AnimatedSprite2D / Sprite2D
- CanvasLayer / Control
- Y-sort / z_index

## Art Pipeline
Blender is optional and should NOT be used during normal gameplay coding.

Later Blender may be used as an asset factory:
3D model -> fixed camera render -> PNG/sprite sheet -> Godot 2D.

For now use simple placeholder sprites/shapes.

## Priorities
1. gameplay logic
2. robust systems
3. management depth
4. readable UI
5. art polish later

## Input
- click/tap floor to move caretaker
- click/tap objects
- click/tap cats
- UI buttons
- no required WASD

## Cat AI
Cats are autonomous.

Minimum states:
idle, wander, eat, drink, sleep, litter, play, groom, hide, socialize, observe.

Use utility AI / weighted scoring.

## Interactables
Use a reusable interactable contract and reservations so exclusive objects cannot be used by two cats at once.

## Adoption
Never use one "good person score".

Evaluate:
1. hard constraints
2. red flags
3. lifestyle compatibility
4. household compatibility
5. cat-specific needs
6. unknown information / confidence

## Architecture
Use:
- scenes/
- scripts/
- data/
- assets/
- docs/
- tests/

Prefer composition, signals, and data-driven content.
Keep business logic out of UI scripts.

## Token Budget Rule
One Codex prompt should normally implement ONE small task:
- one framework
- one interactable
- one cat state
- one UI panel
- one data model
- one test

Do not read every documentation file every turn.
Do not implement later phases unless explicitly requested.
Do not call Blender MCP unless art is explicitly required.

## Verification
After a small change:
1. run minimal Godot verification
2. fix only blocking errors caused by the change
3. stop when the requested behavior passes

## Git
Commit stable checkpoints only.
