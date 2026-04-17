---
description: Bootstrap a Godot 4.6 project with .GodotHelper/ — greenfield Q&A or brownfield codebase mapping
argument-hint: "[prompt] [--force] [--gdd <path>]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
  - AskUserQuestion
---

<contract>
**Reads:** CWD contents (`project.godot` detection, existing `.GodotHelper/`), `${CLAUDE_PLUGIN_ROOT}/templates/*`, user-provided GDD (if `--gdd <path>`), `.GodotHelper/intel/*.md` (after mapper dispatch in brownfield mode).
**Writes:** `.GodotHelper/config.json`, `.GodotHelper/PROJECT.md`, `.GodotHelper/GDD.md`, `.GodotHelper/ARCHITECTURE.md`, `.GodotHelper/QUIRKS.md`, `.GodotHelper/STATE.md`. Brownfield also writes `.GodotHelper/intel/scenes.md`, `autoloads.md`, `input-map.md`, `signals.md` (via `godot-codebase-mapper` subagent).
**Dispatches:** `godot-codebase-mapper` (brownfield only).
</contract>

<objective>
Create the `.GodotHelper/` harness inside a Godot 4.6 project. Detect greenfield vs brownfield, gather or extract project context, stamp templates with filled placeholders, and leave STATE.md pointing to the next step. This is the bootstrap — everything downstream depends on these artifacts existing and being accurate.
</objective>

<arguments>
`$ARGUMENTS` may contain a freeform prompt (seed idea), `--force` (overwrite existing `.GodotHelper/`), and/or `--gdd <path>` (ingest an existing GDD markdown file).

- A flag is active only if its literal token appears in `$ARGUMENTS`.
- Everything in `$ARGUMENTS` that is not a flag/flag-value is treated as the seed prompt.
</arguments>

<process>

## 1. Detect mode

Run these checks in parallel via Bash/Glob:
- Does `./project.godot` exist? → **brownfield**
- Does `./.GodotHelper/` exist? → **already initialized**
- Is CWD otherwise empty (no `.gd`, no `.tscn`, no `project.godot`)? → **greenfield**
- Anything else (random files but no `project.godot`) → treat as greenfield but warn the user they are not inside a Godot project yet and ask whether to proceed.

If `.GodotHelper/` already exists:
- Without `--force`: refuse. Print what is already there and suggest `/godot-helper:brainstorm` or `/godot-helper:plan` if the user wants to continue work.
- With `--force`: confirm once via AskUserQuestion that they want to overwrite (show a 1-line preview of current PROJECT.md). Only proceed on explicit yes.

## 2. Greenfield flow

Gather project context via AskUserQuestion (batch into one call where possible). Required answers:
- **Game name** (short, becomes project slug)
- **Genre / pitch** (one sentence — "top-down survival roguelike", "couch-coop platformer")
- **Scope** (jam / prototype / short release / long-term)
- **Godot version** (default `4.6`)
- **2D or 3D** (or mixed)
- **Target platforms** (PC, web, mobile, console — multi-select)
- **Art style direction** (placeholder / pixel / low-poly / stylized-3D / final-assets-in-hand)
- **Solo or team** (if team: size, any roles already filled)
- **Existing GDD?** — if user says yes and did NOT pass `--gdd`, ask for the path now.

If the seed prompt from `$ARGUMENTS` is non-empty, use it to pre-fill obvious answers and confirm them rather than re-asking from scratch.

If `--gdd <path>` was passed OR the user supplied a GDD path:
- Read the file. Extract sections that map to the GDD.md template shape (vision, pillars, mechanics, world/fiction, scope, non-goals, risks).
- Fill `.GodotHelper/GDD.md` from the template and overlay the ingested content. Preserve the template's section ordering. Anything we could not map cleanly goes into a `## Unmapped from source GDD` appendix for the user to review.

Stamp templates (read each with the Read tool, substitute placeholders, write with the Write tool):

- `${CLAUDE_PLUGIN_ROOT}/templates/config.json` → `.GodotHelper/config.json` (replace godot.version if user chose non-default)
- `${CLAUDE_PLUGIN_ROOT}/templates/PROJECT.md` → `.GodotHelper/PROJECT.md`
- `${CLAUDE_PLUGIN_ROOT}/templates/GDD.md` → `.GodotHelper/GDD.md` (unless ingested from --gdd above)
- `${CLAUDE_PLUGIN_ROOT}/templates/ARCHITECTURE.md` → `.GodotHelper/ARCHITECTURE.md` (mostly empty — placeholder sections for scenes, autoloads, state, signals, input)
- `${CLAUDE_PLUGIN_ROOT}/templates/QUIRKS.md` → `.GodotHelper/QUIRKS.md` (starter sections from the template; executor/evaluator will append over time)
- `${CLAUDE_PLUGIN_ROOT}/templates/STATE.md` → `.GodotHelper/STATE.md`

## 3. Brownfield flow

Dispatch the `godot-codebase-mapper` subagent via the Task tool. Pass it:
- Absolute CWD path
- A note that this is a first-run init, so it should write ALL four intel files (`scenes.md`, `autoloads.md`, `input-map.md`, `signals.md`) from scratch
- Template paths under `${CLAUDE_PLUGIN_ROOT}/templates/intel/`

Wait for the mapper to return, then read the four intel files. Draft `ARCHITECTURE.md` from what was found — key systems, scene-tree patterns, autoload graph, any framework conventions detected (e.g. state machine style, signal bus, custom resources).

Then AskUserQuestion to confirm/edit load-bearing assumptions the draft made (e.g. "I see a `GameState` autoload that looks like the game's central store — should downstream plans treat this as authoritative?"). Keep it to 4–6 high-leverage questions. Do not re-ask things that are unambiguous from code.

Fill `PROJECT.md` and `GDD.md` via AskUserQuestion. The user may say "placeholder, I'll do this later" for GDD — in that case stamp the template as-is with a clear "# TODO: fill this in" banner at the top. `--gdd <path>` ingestion works here too, same as greenfield.

Stamp remaining templates (config.json, QUIRKS.md, STATE.md) the same way as greenfield.

## 4. STATE.md

Whichever mode ran, finalize `.GodotHelper/STATE.md` with:

```yaml
active_phase: null
active_plan: null
next_action: "run /godot-helper:brainstorm to scope your first feature"
open_questions: []
last_updated: <ISO date>
```

(Preserve whatever additional structure the template provides — this is the minimum set of fields.)

## 5. Report

Print a compact summary to the user:
- Mode used (greenfield / brownfield / force-overwrite)
- Files created (absolute paths)
- For brownfield: one-line summary of what the mapper found (# scenes, # autoloads, # input actions, # signals)
- Explicit next step: `/godot-helper:brainstorm`

</process>

<rules>
- Never silently overwrite. `.GodotHelper/` exists → refuse unless `--force` AND user confirms.
- Use `${CLAUDE_PLUGIN_ROOT}/templates/...` for ALL template reads. Never inline template content.
- If a template is missing, surface the error clearly — do not invent content.
- Do not plan features here. `/init` only sets up the harness. After running it, STATE.md must point the user at `/godot-helper:brainstorm`.
- Commit discipline: if `config.json`'s `gates.auto_commit` is true (default), make a single atomic commit `chore(godot-helper): initialize .GodotHelper/` after all files are written. Otherwise leave uncommitted for the user.
</rules>
