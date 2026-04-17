---
name: godot-helper-artifacts
description: Read/update rules for the per-project artifacts under `.GodotHelper/` (PROJECT.md, GDD.md, ARCHITECTURE.md, QUIRKS.md, STATE.md, CONTEXT.md, PRD.md, PLAN.md, SUMMARY.md, VERIFICATION.md, intel/*). Use whenever an agent in a godot-helper-managed project needs to know which living doc to consult or update — especially during /init, /brainstorm, /plan, /discuss-phase, and /execute-phase.
---

# godot-helper Artifacts

This skill teaches agents **which `.GodotHelper/` file to read and when to update it**. Every godot-helper command and subagent operates on these artifacts. Keep them accurate: the next session's context depends on it.

## Progressive-disclosure norm

**Do not read every artifact upfront.** Load on demand:

- **Always relevant** (read at session start or when a command begins): `STATE.md`, `config.json`, plus the current phase's `CONTEXT.md` if one exists.
- **Load when planning or executing**: `PROJECT.md`, `ARCHITECTURE.md`, `QUIRKS.md`.
- **Load when implementing feature code**: the phase `PRD.md`, `RESEARCH.md`, the specific `PLAN.md` entry you own, and dependency `SUMMARY.md` entries.
- **Load only when mapping the codebase**: `intel/scenes.md`, `intel/autoloads.md`, `intel/input-map.md`, `intel/signals.md`. These are refreshed by `godot-codebase-mapper` on demand; stale-acceptable otherwise.
- **GDD.md**: load when the feature touches core mechanics (movement, combat, economy, progression, UX rules). Skip for pure plumbing/refactor work.

## Artifact reference

| Path | Purpose | Read when | Update when | Owner |
|------|---------|-----------|-------------|-------|
| `.GodotHelper/config.json` | helperconfig: model routing, parallelism cap, gate toggles, godot version | Session start; before dispatching subagents | User edits; rarely touched by agents | User / `/init` |
| `.GodotHelper/PROJECT.md` | Vision, scope, constraints, non-goals, target audience | Any planning or execution (load once per session) | Only on a major pivot (scope change, audience change) | `/init`, user |
| `.GodotHelper/GDD.md` | Full game design doc — mechanics, systems, progression, narrative | Implementing anything that touches core mechanics | When mechanics change or new mechanics are designed | `/init`, user, `godot-planner` (minor) |
| `.GodotHelper/ARCHITECTURE.md` | Living architecture — systems, autoloads, scene graph, data flow | **Before planning or executing anything** | **Whenever a new system/node/autoload is added, or an existing one is meaningfully changed** | `godot-executor`, `godot-evaluator` |
| `.GodotHelper/QUIRKS.md` | Project-specific quirks + Godot gotchas; sectioned (Input / Physics / Rendering / Pipeline / Conventions) | **Before writing any code** | **When a new footgun is discovered** — add a dated, anchor-linked entry | `godot-executor`, `godot-evaluator` |
| `.GodotHelper/STATE.md` | Current phase, active plan, next action, open questions, last-touched timestamp | Session start | **At every milestone**: end of a plan, phase complete, phase paused, new phase started | Every command |
| `.GodotHelper/phases/NN-slug/PRD.md` | Feature spec: problem, player-facing behavior, must-haves, non-goals, asset notes | During plan, discuss, and execute | Rarely — only if `/brainstorm` is rerun; otherwise frozen | `/brainstorm` |
| `.GodotHelper/phases/NN-slug/CONTEXT.md` | **Locked decisions** from `/discuss-phase` — trade-offs, chosen approaches, rejected alternatives | **Every planner/executor run touching this phase** | `/discuss-phase` only — executor and planner **must not edit**; they must honor | `/discuss-phase` |
| `.GodotHelper/phases/NN-slug/RESEARCH.md` | Technical research: API references, design patterns, relevant existing code | Planner and executor working on this phase | Written once by `godot-researcher`; re-run only if research gaps surface | `godot-researcher` |
| `.GodotHelper/phases/NN-slug/PLAN.md` | Plans with frontmatter (`id`, `wave`, `depends_on`, `files_touched`, `must_haves`, `autonomous`) and tasks | `/discuss-phase`, `/execute-phase`, wave dispatch | Evaluator may append fix plans in a new wave after verification | `godot-planner`, `godot-evaluator` (appends only) |
| `.GodotHelper/phases/NN-slug/SUMMARY.md` | What the executor actually built, per plan. Append-only | Executors on dependent plans read predecessors' entries | **One entry per plan executed**, appended on plan completion | `godot-executor` |
| `.GodotHelper/phases/NN-slug/VERIFICATION.md` | Evaluator pass/fail per must-have + manual playtest checklist (animation feel, audio, game-feel items a human must judge) | `/execute-phase` post-wave; user before sign-off | Written by `godot-evaluator` at end of phase | `godot-evaluator` |
| `.GodotHelper/intel/scenes.md` | Scene tree outlines + owner chains | Planning features that modify existing scenes | When `godot-codebase-mapper` is invoked (on demand) | `godot-codebase-mapper` |
| `.GodotHelper/intel/autoloads.md` | Autoload registrations from `project.godot` | Planning/executing features that interact with singletons | After adding/removing an autoload, or via mapper refresh | `godot-codebase-mapper`, `godot-executor` (on autoload changes) |
| `.GodotHelper/intel/input-map.md` | InputMap actions | Planning/executing any input-handling feature | After editing the InputMap, or via mapper refresh | `godot-codebase-mapper`, `godot-executor` (on input changes) |
| `.GodotHelper/intel/signals.md` | Signal graph across scripts | Planning features that route through existing signals | Via mapper refresh — usually not hand-edited | `godot-codebase-mapper` |

## Update rules every agent must internalize

1. **New system/node/autoload → ARCHITECTURE.md in the same commit.** Don't defer. If the plan added a `HealthComponent` autoload or a new `UI/` scene branch, the architecture doc gets the delta now, not "later."
2. **New gotcha discovered → QUIRKS.md entry.** Use a short section anchor (e.g. `## Physics: CharacterBody2D move_and_slide returns void in 4.6`). Include the date and one-line fix. No prose essays.
3. **Plan completed → append SUMMARY.md entry and update STATE.md.** SUMMARY entry is append-only: `## Plan <id> — <one-line>` + files touched + deviations from plan. STATE moves "active plan" forward.
4. **Phase completed → evaluator writes VERIFICATION.md, updates ARCHITECTURE and QUIRKS if warranted, advances STATE.md.**
5. **Never silently simplify past a CONTEXT.md locked decision.** If the executor hits a constraint that makes the locked approach infeasible, **stop and fail loud** — surface the conflict to the user rather than quietly swap in a different approach. CONTEXT is a contract.
6. **Changing input actions, autoloads, or scene structure → refresh the matching `intel/*.md`** file in the same commit (or dispatch the codebase-mapper on the relevant slice). Stale intel silently poisons later planning runs.
7. **Never overwrite PRD.md from inside `/plan` or `/execute-phase`.** PRD is set by `/brainstorm`. If it's wrong, re-run brainstorm.
8. **SUMMARY.md is append-only.** Do not edit past entries; add a new one with a corrective note if needed.
9. **STATE.md is the single source of truth for "what's happening right now."** If it disagrees with reality, STATE wins until a human updates it — but updating it accurately at every milestone is non-negotiable.

## Quick decision tree for an executor

- About to write code? Read `QUIRKS.md` + the phase `CONTEXT.md` + your `PLAN.md` entry + dependency `SUMMARY.md` entries.
- About to add a system/autoload/scene? Plan the `ARCHITECTURE.md` edit into your commit.
- Hit a Godot footgun? Add a `QUIRKS.md` entry before moving on.
- Finished your plan? Append to `SUMMARY.md`, nudge `STATE.md`, commit.
- Blocked by a CONTEXT decision? Stop. Surface the conflict. Do not improvise.

## Cross-agent data contracts

These fields are load-bearing across agents. The planner writes them; the executor consumes them and appends downstream; the evaluator verifies against them. Do not skip fields — downstream agents expect them.

### `PLAN.md` — per-plan frontmatter (yaml fence inside each plan heading)

Required fields:

```yaml
id: "01"                       # zero-padded string, monotonic within a phase
wave: 1                        # integer ≥ 1
depends_on: []                 # list of plan IDs (strings); wave must be > max(dep.wave)
files_touched:                 # best-effort list of res:// paths the plan creates or modifies
  - res://scripts/player.gd
must_haves: [1, 2]             # indexes into the phase-level Must-haves list (1-based)
autonomous: true               # false if plan needs mid-flight human input (rare)
context_refs:                  # doc anchors executor pre-reads; at minimum: relevant CONTEXT decision IDs
  - CONTEXT#D-02
  - ARCHITECTURE#input-handling
  - QUIRKS#physics
```

Fix plans appended by the evaluator use IDs of the form `F-MM` (e.g. `F-01`, `F-02`), monotonic within the phase and separate from planner IDs. Their `wave` is `max(existing wave) + 1`. This guarantees fix plans never collide with planner IDs when SUMMARY entries are cross-referenced.

### `CONTEXT.md` — decision IDs

Every locked decision in `CONTEXT.md` gets an ID `D-NN` (`D-01`, `D-02`, ...), monotonic within the phase. Format per entry:

```markdown
### D-01: {{decision title}}
**Decided:** {{chosen approach}}
**Rationale:** {{why}}
**Rejected:** {{alternatives and why}}
**Impact:** {{which plans / files / systems this binds}}
```

Planner, executor, and evaluator reference decisions by ID (`context_refs: [CONTEXT#D-01]`, "verified D-01 honored", etc.). `/discuss-phase` is responsible for assigning IDs and maintaining monotonicity.

### `SUMMARY.md` — per-plan entry fields

Every plan entry the executor appends must contain these fields. The evaluator reads them verbatim to produce `VERIFICATION.md`:

```markdown
## Plan <id> — <title> (wave <N>)
- **Executed:** <ISO date>
- **Commits:** <first sha>..<last sha>
- **Files created:** <res:// paths>
- **Files modified:** <res:// paths>
- **Must-haves claimed:** <indexes from plan frontmatter that this plan actually satisfied>
- **Public API added:** <new signals / autoloads / classes / input actions — evaluator cross-checks ARCHITECTURE/intel drift>
- **Deviations from plan:** <any — with reason; empty if none>
- **CONTEXT decisions honored:** <list of D-IDs pre-read and respected>
- **Needs manual playtest:** <items the executor cannot self-verify (animation feel, audio mix, collision response tuning)>
- **Surprises / notes:** <anything the planner didn't foresee>
```

Omitting any of these breaks the evaluator — if a field genuinely has no content, emit the field with "(none)".

### `VERIFICATION.md` — fix-plan referencing

When the evaluator proposes a fix plan, it writes a stub in `VERIFICATION.md` using the `F-MM` scheme above AND appends the full plan to `PLAN.md` under a new wave. The stub in `VERIFICATION.md` always links to the fuller entry in `PLAN.md` by ID so the user can jump between views.
