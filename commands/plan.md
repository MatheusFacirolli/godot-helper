---
description: Research + plan a phase — parallel researcher + mapper, then planner, then goal-backward checker
argument-hint: "<phase-number-or-slug>"
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
**Reads:** `.GodotHelper/PROJECT.md`, `.GodotHelper/ARCHITECTURE.md`, `.GodotHelper/QUIRKS.md`, `.GodotHelper/phases/NN-slug/PRD.md`, `.GodotHelper/intel/*.md` (current snapshot), `${CLAUDE_PLUGIN_ROOT}/templates/phase/RESEARCH.md`, `${CLAUDE_PLUGIN_ROOT}/templates/phase/PLAN.md`.
**Writes:** `.GodotHelper/phases/NN-slug/RESEARCH.md` (via researcher), `.GodotHelper/phases/NN-slug/PLAN.md` (via planner), `.GodotHelper/intel/*.md` (refreshed slices via mapper), `.GodotHelper/STATE.md`.
**Dispatches:** `godot-researcher` and `godot-codebase-mapper` (in parallel), then `godot-planner`.
</contract>

<objective>
Turn a PRD into an executable plan composed of waves of parallelizable sub-plans. Research and codebase freshness run in parallel first; the planner consumes both before decomposing. The command finishes with a goal-backward check that every PRD must-have is covered by at least one plan's `must_haves`.
</objective>

<arguments>
`$ARGUMENTS` is a phase number (`1`, `01`) or slug (`player-movement`) or `NN-slug` (`01-player-movement`). Required.
</arguments>

<preflight>
1. Resolve the phase folder: glob `.GodotHelper/phases/*/` and match by number (prefix) or slug (suffix). Must resolve to exactly one folder. If zero or multiple, abort with a clear message.
2. Verify `PRD.md` exists in that folder. If not, abort and tell the user to run `/godot-helper:brainstorm` first.
3. Read `PROJECT.md`, `ARCHITECTURE.md`, `QUIRKS.md`, and the phase's `PRD.md`. These are the planner's context anchors.
4. Read existing `intel/*.md` if present — the mapper below will refresh selectively.
5. If `RESEARCH.md` or `PLAN.md` already exist in the phase folder, ask the user whether to regenerate, skip research, or abort.
</preflight>

<process>

## 1. Dispatch researcher + mapper IN PARALLEL

Issue both Task tool calls in the same message so they run concurrently.

**Researcher** (`godot-researcher` subagent):
- Inputs: absolute paths to PROJECT.md, ARCHITECTURE.md, QUIRKS.md, phase PRD.md, phase folder path
- Output path: `.GodotHelper/phases/NN-slug/RESEARCH.md` (template at `${CLAUDE_PLUGIN_ROOT}/templates/phase/RESEARCH.md`)
- Mandate: use the bundled `gdscript-reference` skill progressively (start from `doc_api/_common.md`, pull class docs only when needed), cite Godot 4.6 APIs by class + method, document node patterns, signal patterns, and any quirks relevant to THIS feature. If the feature has design-pattern implications (state machine, component, pooling, etc.), name the pattern and link to the relevant quirks entry.

**Mapper** (`godot-codebase-mapper` subagent, incremental mode):
- Inputs: absolute project root, current `intel/*.md` paths, phase PRD.md path (so it knows which slices matter)
- Output: refresh any `intel/*.md` slice that is stale or directly relevant to this feature. Leave untouched slices alone — do not rewrite unchanged files.

## 2. Wait for both to return

Read their outputs. Sanity-check:
- RESEARCH.md exists and has content.
- Any refreshed intel files are written.
- If either subagent reports an error, surface it to the user and stop before dispatching the planner.

## 3. Dispatch planner

Spawn `godot-planner` via Task. Pass absolute paths to:
- PROJECT.md, ARCHITECTURE.md, QUIRKS.md
- phase PRD.md, RESEARCH.md
- all current `intel/*.md`
- the PLAN.md template at `${CLAUDE_PLUGIN_ROOT}/templates/phase/PLAN.md`

Planner mandate (restated here for traceability — full prompt lives in the agent file):
- Decompose the phase into **plans**. Each plan is one subagent session, 2–3 tasks max.
- Per-plan frontmatter: `id`, `wave` (integer, 1-indexed), `depends_on` (array of plan ids), `files_touched` (globs or paths), `must_haves` (subset of PRD must-haves this plan is accountable for), `autonomous` (bool — can it run without user input between tasks?).
- Plans in the same wave must be independent (no shared files, no depends_on chain within the wave).
- Write `.GodotHelper/phases/NN-slug/PLAN.md` matching the template shape.

## 4. Goal-backward check (plan checker)

Inline (no subagent) — after planner returns:

1. Parse `PRD.md` must-haves list.
2. Parse `PLAN.md` frontmatter for each plan's `must_haves`.
3. For each PRD must-have, verify at least one plan claims it in its `must_haves`. Build a coverage table.
4. Flag gaps:
   - **Uncovered must-have** → this is a planner miss. Show the user the gap and offer: (a) have you re-dispatch the planner with the gap called out, or (b) add a manual plan to PLAN.md.
   - **Orphan plan must-have** (a plan claims a must-have the PRD does not contain) → likely scope creep. Flag and ask the user.
5. Also sanity-check wave topology: no cycles in `depends_on`, no depends_on pointing at a later wave, no plan depending on a plan in the same wave.

Print the coverage table (PRD must-have → plan id(s) covering it) to the user regardless of outcome.

## 5. Update STATE.md

```yaml
active_phase: "NN-slug"
active_plan: null
next_action: "phase NN: planned — run /godot-helper:discuss-phase NN to lock decisions, or /godot-helper:execute-phase NN if you're ready"
open_questions: <preserved + any new ones flagged by plan checker>
last_updated: <ISO date>
```

If `gates.require_discuss_phase` is true in `config.json`, `next_action` should require `discuss-phase` and not offer `execute-phase` as a shortcut.

## 6. Report

Print:
- Paths written (RESEARCH.md, PLAN.md, refreshed intel/*.md)
- Number of plans, number of waves
- Coverage table (PRD must-have → plan ids)
- Any gaps flagged
- Next step (from STATE.md's next_action)
- If `gates.auto_commit` is true, commit: `docs(godot-helper): plan phase NN-slug`

</process>

<rules>
- Researcher and mapper MUST be dispatched in the same message to run in parallel. Do not serialize them.
- Planner runs AFTER both return — it needs fresh research and fresh intel.
- Do not write GDScript from this command. Plans describe what to build; executor writes the code.
- If RESEARCH.md or intel updates conflict with locked decisions in an existing CONTEXT.md (if present), surface the conflict to the user before the planner runs.
- Never silently drop a PRD must-have. If the plan checker cannot cover one, make the gap visible.
</rules>
