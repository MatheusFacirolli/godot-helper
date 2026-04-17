# Phase {{NN}} — {{slug}}: Research

<!--
Technical research for this phase. Written by godot-researcher. Cite APIs via
`gdscript-reference` skill lookups — do NOT paste full class docs here. Link the
class name and the specific signal/method of interest; the executor will load the
full doc on demand via progressive disclosure.
-->

## Relevant Godot APIs
Node types, signals, classes the executor will touch. Reference by name only; `gdscript-reference` loads details.

- **{{ClassName}}** — {{why relevant: signal / method / property of interest}}
- **{{ClassName}}** — {{...}}

## Design patterns to apply
{{state machine style, signal topology, input handling pattern — reference `godot-gdscript-patterns` skill where applicable}}

- **{{pattern name}}** — {{when/why/how it fits here}}

## Existing project code to reuse
File references — executor should read these before writing new code.

- `res://{{path/to/existing.gd}}` — {{what to reuse: function, pattern, autoload hook}}

## Performance considerations
{{expected cost: nodes spawned, physics queries, draw calls; any budgets to respect}}

## Known gotchas
Cross-reference `QUIRKS.md` sections.

- See `QUIRKS.md#{{section-anchor}}` — {{brief reminder why this phase hits that gotcha}}

## Open technical questions
Questions research couldn't close — surface in `/discuss-phase` or before execution.

- {{question}}
