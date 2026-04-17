# Scenes — {{project_name}}

<!--
Map of scenes in the project, refreshed by godot-codebase-mapper.
For each scene: the node tree outline (names + types) and ownership notes
(who instances it, whether it's a reusable prefab, what it expects from its parent).

How to keep this current:
- `godot-codebase-mapper` refreshes this file on demand (e.g. during /plan).
- After an executor creates or significantly restructures a scene, request a refresh.
- Do NOT hand-edit the tree outlines — they drift. Notes sections are safe to hand-edit.
-->

## Scene index
| Path | Root type | Purpose |
|------|-----------|---------|
| {{res://scenes/...}} | {{e.g. Node2D}} | {{one-line purpose}} |

---

### {{res://scenes/player/player.tscn}}
**Root:** {{CharacterBody2D}}
**Purpose:** {{one line}}

```
Player (CharacterBody2D) [player.gd]
├── CollisionShape2D
├── Sprite2D
├── AnimationPlayer
└── Camera2D [follow_camera.gd]
```

**Ownership / usage:**
- Instanced by: {{scenes that add this as a child}}
- Expects: {{parent signals, groups, or services (autoloads) it needs}}
- Emits: {{signals other scenes listen to}}

---

### {{res://scenes/...}}
**Root:** {{...}}
**Purpose:** {{...}}

```
{{tree outline}}
```

**Ownership / usage:**
- Instanced by: {{...}}
- Expects: {{...}}
- Emits: {{...}}
