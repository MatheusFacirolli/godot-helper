# Architecture — {{project_name}}

<!--
When to update this doc:
- A new autoload is added or removed → update "Autoloads"
- A new runtime system is introduced (combat, inventory, save, etc.) → add a "Known systems" subsection
- A scripting pattern changes materially (e.g. state machine style, signal conventions) → update "Scripting patterns"
- Project structure changes (new top-level folder, moved assets) → update "Project structure"
- Build or asset pipeline changes → update those sections

Agents writing code MUST check this file before adding a new system and MUST update it after adding one.
-->

## Engine & version
- **Godot:** {{godot_version}} (pinned)
- **Export templates:** {{installed / pending}}
- **Language:** GDScript (primary), {{C# / GDExtension if applicable}}

## Project structure
```
{{project_root}}/
├── project.godot
├── scenes/
├── scripts/
├── assets/
│   ├── art/
│   ├── audio/
│   └── fonts/
├── autoload/
└── addons/
```
{{brief notes on why the tree is shaped this way}}

## Autoloads
| Name | Path | Purpose |
|------|------|---------|
| {{AutoloadName}} | `res://autoload/{{file}}.gd` | {{what it does}} |

## Scene graph conventions
- **Naming:** {{e.g. PascalCase nodes, snake_case files}}
- **Ownership:** {{who instances what; when to use `owner` vs. `get_parent()`}}
- **Root nodes:** {{preferred root types per scene category (Node2D for gameplay, Control for UI, etc.)}}
- **Groups:** {{conventions for `add_to_group` usage}}

## Scripting patterns
- **State machines:** {{enum-based / Node-based / plugin — pick one and describe}}
- **Signals:** {{naming convention, when to use signals vs. direct calls, who connects to what}}
- **Input:** {{Input singleton vs. `_unhandled_input`; action-based vs. key-based}}
- **Resources:** {{custom `Resource` usage for data; `.tres` vs `.res` policy}}

## Data flow
{{how data moves between systems — e.g. "UI reads from PlayerStats autoload via signals; gameplay writes to PlayerStats directly"}}

## Asset pipeline
- **Art:** {{source app → export settings → import presets}}
- **Audio:** {{format, loudness target, import presets}}
- **Fonts:** {{format, fallback chain}}
- **Placeholder policy:** {{when placeholders are acceptable, how they're labeled}}

## Known systems
One subsection per major runtime system. Populate as systems are added.

### {{System name}}
- **Entry points:** {{scene/script}}
- **Dependencies:** {{other systems, autoloads}}
- **Public API:** {{signals emitted, methods meant to be called from outside}}
- **Notes:** {{gotchas, why built this way — link QUIRKS.md entries when relevant}}

## Performance notes
- **Target frame rate:** {{60 fps / 30 fps}}
- **Budget:** {{draw calls, nodes per scene, physics bodies}}
- **Profiling cadence:** {{when/how we profile}}

## Build pipeline
- **Export presets:** {{which platforms, where configured}}
- **CI:** {{if any — what runs on push}}
- **Versioning:** {{semver / date-based / none}}
