# Input map — {{project_name}}

<!--
Derived from the [input] section of project.godot. Refreshed by godot-codebase-mapper.
"Consumer scripts" = files that call `Input.is_action_*` or check the action by name —
used by planner/executor to find everything a binding change affects.
-->

## Actions

| Action | Default binding(s) | Consumer scripts | Notes |
|--------|--------------------|------------------|-------|
| {{move_left}}  | {{A, Left}}   | `res://scripts/player/player.gd` | {{e.g. also used by menu navigation}} |
| {{move_right}} | {{D, Right}}  | `res://scripts/player/player.gd` | |
| {{jump}}       | {{Space}}     | `res://scripts/player/player.gd` | {{hold-to-jump-higher, 200ms window}} |
| {{ui_accept}}  | {{Enter, A button}} | `res://scenes/ui/*`        | {{Godot built-in — do not remove}} |

## Notes
- {{device-specific policies — e.g. "all gameplay actions must have both keyboard and gamepad bindings"}}
- {{remap UX status — e.g. "no in-game rebinding yet; edit project.godot directly"}}
