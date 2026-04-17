---
description: Execute a phase — wave-based parallel executor dispatch, evaluator pass, doc updates
argument-hint: "<phase-number-or-slug> [--resume]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
  - TodoWrite
  - AskUserQuestion
---

<contract>
**Reads:** `.GodotHelper/config.json`, `.GodotHelper/PROJECT.md`, `.GodotHelper/ARCHITECTURE.md`, `.GodotHelper/QUIRKS.md`, `.GodotHelper/phases/NN-slug/PRD.md`, `PLAN.md`, `CONTEXT.md` (if present), `RESEARCH.md`, `SUMMARY.md` (if `--resume` or rerun), `${CLAUDE_PLUGIN_ROOT}/templates/phase/SUMMARY.md`, `${CLAUDE_PLUGIN_ROOT}/templates/phase/VERIFICATION.md`.
**Writes:** `.GodotHelper/phases/NN-slug/SUMMARY.md` (appended by executors), `VERIFICATION.md` (via evaluator), `.GodotHelper/STATE.md`, possibly `.GodotHelper/ARCHITECTURE.md` and `.GodotHelper/QUIRKS.md` (if agents flag updates), possibly append fix plans to `PLAN.md`.
**Dispatches:** `godot-executor` (one per plan, up to `max_concurrent_agents` per wave), then `godot-evaluator`.
</contract>

<objective>
Run the phase. Parse PLAN.md into waves, dispatch executors in parallel per wave, shepherd their outputs into SUMMARY.md, then run the evaluator. If gaps are found, offer to append fix plans as a new wave and re-run. End state: either the phase is complete and STATE.md says so, or STATE.md clearly marks what is still outstanding.
</objective>

<arguments>
- `$1` — phase number or slug (required)
- `--resume` — resume from the last incomplete wave (reads SUMMARY.md to figure out what's done)
</arguments>

<preflight>
1. Resolve the phase folder (same rules as `/plan`).
2. Verify `PLAN.md` exists. If not, abort and tell the user to run `/godot-helper:plan` first.
3. Read `config.json` → `parallelization.max_concurrent_agents` (default 3), `gates.auto_commit`, `gates.require_discuss_phase`, `doc_updates.*`.
4. If `require_discuss_phase` is true and CONTEXT.md is missing, abort and tell the user to run `/godot-helper:discuss-phase` first.
5. Read PRD.md, PLAN.md, CONTEXT.md (if present), RESEARCH.md. Read ARCHITECTURE.md, QUIRKS.md, PROJECT.md.
6. Parse PLAN.md frontmatter for each plan. Extract: `id`, `wave`, `depends_on`, `files_touched`, `must_haves`, `autonomous`.
7. Validate the wave graph:
   - `depends_on` must only reference plans in strictly earlier waves.
   - Each wave's plans must have non-overlapping `files_touched` (no concurrent writes to the same file).
   - No cycles.
   - Every `id` referenced in `depends_on` must exist.
   If validation fails, print the specific issue and abort — do not dispatch anything.
8. If `--resume`, read `SUMMARY.md`. Mark plans already logged as "done" and start dispatch from the first wave that still has incomplete plans.
</preflight>

<process>

## 1. Plan the run

Group plans by `wave`. For each wave, note which plans will dispatch and which are already done (resume case). Use TodoWrite to track wave-level progress for the user's visibility.

If no plans remain to run (everything is done per SUMMARY.md), skip straight to evaluator.

## 2. Execute waves sequentially; plans within a wave in parallel

For each wave in ascending order:

### 2a. Dispatch executors in parallel

Spawn one `godot-executor` subagent per plan in the wave, up to `max_concurrent_agents`. If the wave has more plans than the cap, dispatch in batches — wait for a batch to return before starting the next (within the same wave).

Each executor gets these absolute paths + inline data:
- `PROJECT.md`, `ARCHITECTURE.md`, `QUIRKS.md` (project-level context)
- `PRD.md`, `CONTEXT.md` (if present), `RESEARCH.md` (phase-level context)
- The full text of ITS OWN plan entry from PLAN.md (frontmatter + body)
- SUMMARY.md entries for any plan this one `depends_on` (so it can read dependency outputs; these exist because dependencies were in earlier waves)
- Absolute phase folder path
- The bundled `gdscript-reference` skill (mention by name so the executor invokes it)
- `config.json` `gates.auto_commit` value — the executor makes atomic commits per task when auto_commit is true

Executor mandate (restated; full prompt in agent file):
- Implement each task in the plan.
- Commit atomically per task (if auto_commit true).
- Append a SUMMARY.md entry for this plan: what was built, files touched, any divergences from the plan, any new quirks discovered, any architecture additions, any followups.
- If the executor detects a new system worth documenting → note it in its SUMMARY entry under `architecture_notes:`.
- If the executor hits a Godot gotcha → note it under `quirks_notes:`.

### 2b. Wait + collect

After each wave, wait for all executors to return. Read the SUMMARY.md entries they appended.

Sanity checks:
- Did any executor fail or stop mid-plan? If yes: STOP the wave sequence. Report which plan(s) failed, summarize what got done, update STATE.md to point at the failure, and exit. Do NOT proceed to the next wave on a failed wave — dependents might break.
- Did any executor touch files outside its `files_touched` declaration? Flag but do not block (the plan file may have been imprecise); note in the report.

### 2c. Between-wave summary

Print a compact wave summary to the user: plans completed, files touched, any flags. Continue to the next wave.

## 3. Evaluator pass

After all waves complete, dispatch `godot-evaluator` via Task. Pass:
- PRD.md, CONTEXT.md, SUMMARY.md, ARCHITECTURE.md, QUIRKS.md
- Absolute phase folder path
- Godot executable hint from `config.godot.executable_hint` (if set)
- The VERIFICATION.md template path at `${CLAUDE_PLUGIN_ROOT}/templates/phase/VERIFICATION.md`

Evaluator mandate:
- Verify each PRD must-have: pass / fail / needs-playtest
- Run `godot --headless --check-only` or equivalent smoke tests if a Godot executable is available
- Write VERIFICATION.md with:
  - Auto-verified items (script compiles, scenes load, signals connect, expected nodes exist)
  - Manual playtest checklist (animation feel, collision response, game feel — things the evaluator cannot judge)
  - Gaps: any must-have that failed or is inconclusive, with a suggested fix direction
- Note any architecture or quirks updates worth propagating to the project-level docs

## 4. Handle gaps

Read VERIFICATION.md. If it contains gap entries:

- Summarize each gap to the user.
- Offer via AskUserQuestion: (a) append fix plans as a new wave to PLAN.md and re-run this command on `--resume`, (b) accept gaps as-is and move on (they stay in STATE.md open_questions), (c) abort and let the user handle manually.
- If (a): generate plan stubs for the gaps (one plan per gap, or grouped if tightly related), append them to PLAN.md with `wave: <next>`, `depends_on: []` unless clearly dependent, and a `gap_closure: true` marker. Do NOT auto-run — tell the user to re-invoke `/godot-helper:execute-phase NN --resume` when ready.

## 5. Propagate doc updates

If `doc_updates.auto_update_architecture` is true (default):
- Scan SUMMARY.md entries for `architecture_notes:`. Also scan VERIFICATION.md for flagged architecture changes.
- Append/merge those notes into `.GodotHelper/ARCHITECTURE.md`. Use clearly dated sections (`## <ISO date> — phase NN-slug`).

If `doc_updates.auto_update_quirks` is true (default):
- Same for `quirks_notes:` → `.GodotHelper/QUIRKS.md`. Group under the matching section (Input / Physics / Rendering / Pipeline / Conventions) based on the quirk's nature; if none fits, create a new section.

Show the user a diff of what was added to each doc before writing. With `--auto` or `gates.auto_commit`, just write and note it in the report.

## 6. Update STATE.md

If all must-haves pass and no gaps remain:
```yaml
active_phase: null
active_plan: null
next_action: "phase NN complete — run /godot-helper:brainstorm to scope the next feature"
open_questions: []
last_updated: <ISO date>
```

If gaps remain and user chose "append fix plans":
```yaml
active_phase: "NN-slug"
active_plan: null
next_action: "phase NN: evaluator found gaps — see VERIFICATION.md; re-run /godot-helper:execute-phase NN --resume"
open_questions: <gap summaries>
last_updated: <ISO date>
```

If gaps were accepted as-is:
```yaml
active_phase: null
active_plan: null
next_action: "phase NN closed with known gaps — see VERIFICATION.md"
open_questions: <gap summaries>
last_updated: <ISO date>
```

If a wave failed mid-run:
```yaml
active_phase: "NN-slug"
active_plan: "<last incomplete plan id>"
next_action: "phase NN wave <W> failed on plan <id> — see SUMMARY.md; resume with /godot-helper:execute-phase NN --resume after fixing"
open_questions: <failure reasons>
last_updated: <ISO date>
```

## 7. Report

Print:
- Waves executed, plans per wave, success/fail counts
- Path to VERIFICATION.md
- Must-have coverage table (PRD must-have → pass / fail / playtest)
- Any architecture/quirks updates applied
- Next step (from STATE.md)
- Commit hashes created by executors (if auto_commit true)

</process>

<rules>
- Executors within a wave run IN PARALLEL. Dispatch them in a single message.
- Waves run SEQUENTIALLY. A wave only starts after all plans in the prior wave have returned successfully.
- Never silently move past a failed executor. Halt and update STATE.md to make the failure visible.
- Never rewrite PLAN.md's existing plans. Fix plans are APPENDED as a new wave, with `gap_closure: true`.
- Never overwrite ARCHITECTURE.md or QUIRKS.md wholesale. Append dated sections.
- `--resume` respects existing SUMMARY.md entries — do not re-run completed plans.
- Honor `config.json.gates.auto_commit`: if false, skip commits and let the user stage/commit manually.
</rules>
