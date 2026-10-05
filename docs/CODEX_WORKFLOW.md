# Token-Efficient Codex Workflow

## Rule
One small task per prompt.

Do not ask Codex to complete an entire milestone in one turn.

## Standard Prompt
Read AGENTS.md.
Inspect only files relevant to this task.

Implement ONLY:
<one small task>

Do not start later tasks.
Do not use Blender MCP unless art is explicitly required.

Run one minimal verification.
Fix only blocking errors caused by this change.
Stop when the requested behavior passes.

Report:
- changed files
- test result

## First Prompt
Read AGENTS.md, docs/TASKS.md and only the relevant sections of docs/TECHNICAL_DESIGN.md.

Implement Milestone 1 Phase 1 only:
- Main.tscn
- placeholder 2D room
- NavigationRegion2D
- caretaker scene
- click/touch movement
- Y sorting

Do not start interactables.
Do not use Blender.
Run the project once and fix blocking errors only.
Update only completed Phase 1 checkboxes.
