---
description: Surface assumptions + lock decisions — writes CONTEXT.md the planner/executor must honor
argument-hint: "<phase-number-or-slug> [--auto]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
---

<contract>
**Reads:** `.GodotHelper/PROJECT.md`, `.GodotHelper/ARCHITECTURE.md`, `.GodotHelper/QUIRKS.md`, `.GodotHelper/phases/NN-slug/PRD.md`, `.GodotHelper/phases/NN-slug/PLAN.md` (if present), `.GodotHelper/phases/NN-slug/RESEARCH.md` (if present), `${CLAUDE_PLUGIN_ROOT}/templates/phase/CONTEXT.md`.
**Writes:** `.GodotHelper/phases/NN-slug/CONTEXT.md`, `.GodotHelper/STATE.md`.
**Dispatches:** none — this is adaptive Q&A, inline only.
</contract>

<objective>
Catch load-bearing assumptions before the executor starts writing code. Read the PRD and PLAN, surface what Claude is implicitly assuming, and ask the user only about the ambiguities that will actually bite downstream. Write the answers as **locked decisions** with rationale and impact — the executor MUST honor these, no silent simplification.
</objective>

<arguments>
- `$1` — phase number or slug (required)
- `--auto` — skip interactive Q&A; Claude picks recommended defaults, writes CONTEXT.md with `(auto-selected)` markers next to each decision and a note that the user should review.
</arguments>

<preflight>
1. Resolve the phase folder (same rules as `/plan`). Must have `PRD.md`. `PLAN.md` is strongly preferred (richer ambiguity surface) but not strictly required — if absent, discuss against PRD + research-level assumptions only.
2. Read PRD.md. Extract must-haves, non-goals, success criteria, open questions.
3. Read PLAN.md if present. Extract plan summaries, file touchpoints, dependencies.
4. Read RESEARCH.md if present. Look for phrases like "assumes", "likely", "we picked X because" — these are assumption hotspots.
5. Read PROJECT.md, ARCHITECTURE.md, QUIRKS.md to ground proposed defaults in project conventions.
6. If `CONTEXT.md` already exists, read it. Do not re-ask decided questions. Layer new decisions on top; never silently overwrite prior locks.
</preflight>

<process>

## 1. Surface assumptions

Walk the PRD + PLAN + RESEARCH and build a candidate list of implicit assumptions. Typical Godot-flavor hotspots:

- **Physics body choice** — CharacterBody2D/3D vs RigidBody vs AnimatableBody? The plan picked one implicitly; confirm.
- **Input style** — action polling vs event, hold vs tap, deadzone policy for sticks?
- **Coordinate / unit conventions** — pixels per meter, up vs down-positive-Y for 2D, metric scale for 3D?
- **State management** — local scene state, autoload, custom Resource, finite state machine class?
- **Scene composition** — is this a new scene, a sub-scene instanced into an existing parent, or a script-only change?
- **Signal wiring** — direct connect vs event bus autoload?
- **Save/load expectations** — does this feature persist? If so, where and when?
- **Animation/audio** — placeholder OK, or does the PRD imply finals?
- **Testing / verification** — what does "done" look like for the evaluator beyond the PRD success criteria?
- **Edge cases the PRD left vague** — pause behavior, focus loss, screen resize, splitscreen if coop, etc.

Cross-reference with `QUIRKS.md` — if there is an existing quirk that dictates the answer, note it and lean on that convention rather than re-litigating.

## 2. Filter — ask only what matters

Drop:
- Questions already answered in PRD, PLAN, CONTEXT (existing), or locked by ARCHITECTURE/QUIRKS.
- Cosmetic choices the user explicitly said "placeholder" about in brainstorm.
- Things the planner clearly resolved (e.g. file layout in `files_touched`).

Keep:
- Decisions with >1 defensible option where the wrong pick costs meaningful rework.
- Anything that affects multiple plans (cross-cutting).
- Anything that touches existing systems flagged in ARCHITECTURE.md.

Aim for 4–10 questions. If you have more than 10, you are asking too many cosmetic ones — tighten.

## 3. Ask

### Interactive mode (default)

Use AskUserQuestion. Batch related questions. For each question:
- State the ambiguity in one sentence.
- Show 2–4 concrete options with 1-line tradeoffs each.
- Mark a **recommended default** based on the project's conventions (QUIRKS.md + ARCHITECTURE.md) and explain why.
- Accept free-form "other" answers.

If the user says "you pick" for any question, use the recommended default and note it in CONTEXT.md as `(user-delegated)`.

### `--auto` mode

Skip AskUserQuestion entirely. For every question you would have asked, choose the recommended default and mark it `(auto-selected)` in CONTEXT.md. Add a prominent banner at the top:

```
> NOTE: This CONTEXT.md was generated with --auto. Review auto-selected
> decisions before executing. Edit inline to override; the executor honors
> whatever is in this file at execute-time.
```

## 4. Write CONTEXT.md

Read `${CLAUDE_PLUGIN_ROOT}/templates/phase/CONTEXT.md`. Fill per-decision entries. **Every decision gets an ID of the form `D-NN`** (D-01, D-02, ...), monotonic within the phase. Downstream agents reference decisions by ID: planner sets `context_refs: [CONTEXT#D-02]` on plans; executor honors them; evaluator verifies adherence in `VERIFICATION.md`. Do not skip IDs or reuse them.

Each decision entry must contain:

- **ID**: `D-NN` — assigned here, immutable afterwards
- **Title**: short heading (e.g. "D-02: Physics body for player")
- **Decided**: what was chosen
- **Options considered**: brief list (the rejected alternatives)
- **Rationale**: why this one (grounded in PROJECT/ARCHITECTURE/QUIRKS when possible)
- **Impact**: which plans/files/systems this affects
- **Marker**: `(user)`, `(user-delegated)`, `(auto-selected)`, or `(from existing quirk: <anchor>)`

If layering on an existing CONTEXT.md, preserve prior decisions verbatim and continue the ID sequence from the highest existing `D-NN`. Mark any supersessions explicitly (`Supersedes: D-03`).

Write to `.GodotHelper/phases/NN-slug/CONTEXT.md`.

## 5. Update STATE.md

```yaml
active_phase: "NN-slug"
active_plan: null
next_action: "phase NN: decisions locked — run /godot-helper:execute-phase NN"
open_questions: <any the user could not answer — keep these visible>
last_updated: <ISO date>
```

## 6. Report

Print:
- Path to CONTEXT.md
- Count of decisions locked, broken down by marker (user / user-delegated / auto-selected / from-quirk)
- Any unresolved open questions the user deferred
- Next step: `/godot-helper:execute-phase NN`
- If `gates.auto_commit` is true, commit: `docs(godot-helper): lock decisions for phase NN-slug`

</process>

<rules>
- Do not re-ask questions already answered in PRD, PLAN, RESEARCH, existing CONTEXT.md, ARCHITECTURE.md, or QUIRKS.md.
- Every decision in CONTEXT.md must have rationale and impact. No naked "we picked X" entries.
- Never modify PLAN.md or PRD.md here. If a discussion reveals the plan is wrong, surface the conflict and suggest re-running `/plan` — do not silently edit.
- `--auto` is a time-saver, not a quality pass. Always print the auto-selected decisions so the user can skim and object.
</rules>
