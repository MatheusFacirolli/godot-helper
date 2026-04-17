# Quirks & gotchas — {{project_name}}

<!--
Append new gotchas as you discover them. Each entry:
- Short heading (searchable)
- One-paragraph description
- Link or file reference if applicable
Keep entries atomic — one gotcha per entry. If a whole new domain appears, add a new `## Section`.

Agents: before writing code that touches Input / Physics / Rendering / etc., scan the relevant
section here. After discovering a new gotcha while implementing, append an entry before finishing.
-->

## Input
{{stub — e.g. "Input.is_action_just_pressed only fires in _process/_physics_process; using it in _input can miss frames."}}

## Physics
{{stub — e.g. "CharacterBody2D.move_and_slide resets velocity.y on floor collision; cache before the call if you need it."}}

## Rendering
{{stub — e.g. "TextureRect.stretch_mode STRETCH_KEEP_ASPECT_CENTERED requires a minimum_size or it collapses."}}

## Asset pipeline
{{stub — e.g. "Reimporting .png with Filter=off requires clearing .godot/imported or the filter stays on."}}

## Scene/Node lifecycle
{{stub — e.g. "_ready runs after children's _ready; don't assume parent state is final in a child's _ready."}}

## GDScript
{{stub — e.g. "Typed arrays (Array[Node]) don't accept null in @export unless you type it Variant."}}

## Project conventions
{{stub — project-specific rules the team agreed on: naming, folder structure, commit style, etc.}}
