---
description: Scope a feature into a PRD — guided Q&A, writes phases/NN-slug/PRD.md, stops at PRD
argument-hint: "[feature idea]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

<contract>
**Reads:** `.GodotHelper/PROJECT.md`, `.GodotHelper/GDD.md`, `.GodotHelper/ARCHITECTURE.md`, `.GodotHelper/STATE.md`, `.GodotHelper/phases/` (to pick next number), `${CLAUDE_PLUGIN_ROOT}/templates/phase/PRD.md`.
**Writes:** `.GodotHelper/phases/NN-slug/PRD.md`, `.GodotHelper/STATE.md`.
**Dispatches:** none (this command is intentionally inline — no subagents).
</contract>

<objective>
Turn a rough feature idea into a PRD that downstream commands (`plan`, `discuss-phase`, `execute-phase`) can consume without re-asking the user what the feature is. Stop at PRD — no planning, no task decomposition. That is `plan`'s job.
</objective>

<arguments>
`$ARGUMENTS` is the feature seed. If empty, ask "What do you want to build?" via AskUserQuestion before doing anything else.
</arguments>

<preflight>
1. Verify `.GodotHelper/` exists. If not, abort and tell the user to run `/godot-helper:init` first.
2. Read `PROJECT.md`, `GDD.md`, `ARCHITECTURE.md`. These anchor the conversation — the PRD should be consistent with the game's pillars and existing architecture.
3. Scan `.GodotHelper/phases/` via Glob (`phases/*/`). Extract existing phase numbers (prefix `NN-`). Next phase number = max + 1, zero-padded to 2 digits. If none, start at `01`.
</preflight>

<process>

## 1. Clarify the idea

If `$ARGUMENTS` is non-empty, echo it back as your working interpretation ("I understand you want to build: <restatement>"). If it is empty, ask the user what they want to build.

## 2. Guided Q&A

Use AskUserQuestion (batch questions where it makes sense). Cover these dimensions — skip any that were already unambiguously answered in `$ARGUMENTS`:

- **Player-facing behavior**: what does the player see/do/feel when this ships? Describe it like a short trailer clip.
- **Must-haves**: what MUST work for this phase to count as done? Phrase each as a testable statement.
- **Nice-to-haves**: what would be great but can slip?
- **Non-goals**: what is explicitly OUT of scope for this phase? (prevents scope creep downstream)
- **Success criteria**: how will the user know it works? (Include one playtest question — games are felt, not just tested.)
- **Asset needs**: placeholder (primitives/free assets) vs final art/audio? If final, are the assets in hand, or does this phase generate a TODO for the art pipeline?
- **Dependencies on existing systems**: does this touch existing scenes/autoloads? Name them. (Helps the planner target codebase-mapper refreshes later.)
- **Fits the GDD?**: quick check — is this consistent with the pillars and scope in GDD.md? If not, flag the tension (but don't block — the user may be intentionally extending scope).

Keep the conversation tight. 6–10 total questions is the sweet spot. Push back gently if the user gives vague answers on must-haves or success criteria — those are load-bearing for the evaluator later.

## 3. Name the phase

Derive a short slug from the feature name (kebab-case, <= 30 chars). Examples: `player-movement`, `save-system`, `boss-arena-layout`. Confirm the slug via AskUserQuestion if it is not obvious.

Phase folder: `.GodotHelper/phases/NN-slug/` where `NN` is the next number from preflight.

## 4. Stamp the PRD

Read `${CLAUDE_PLUGIN_ROOT}/templates/phase/PRD.md`. Fill placeholders from the Q&A answers. Expected sections (from the template; defer to its exact layout):

- Summary (one paragraph)
- Player-facing behavior
- Must-haves (bulleted, each testable)
- Nice-to-haves
- Non-goals
- Success criteria (including at least one manual-playtest check)
- Assets (placeholder / final + what's needed)
- Dependencies (existing systems touched)
- Open questions (things the user was not sure about — these will become discuss-phase material)

Write to `.GodotHelper/phases/NN-slug/PRD.md`.

## 5. Update STATE.md

Edit `.GodotHelper/STATE.md` to reflect:

```yaml
active_phase: "NN-slug"
active_plan: null
next_action: "phase NN: PRD ready — run /godot-helper:plan NN to research + plan"
open_questions: <preserved from PRD Open Questions section>
last_updated: <ISO date>
```

## 6. Report

Print:
- Phase created: `.GodotHelper/phases/NN-slug/PRD.md` (absolute path)
- One-line summary of the phase
- Next step: `/godot-helper:plan NN` (or `/godot-helper:plan NN-slug`)
- If `gates.auto_commit` is true in `config.json`, commit: `docs(godot-helper): PRD for phase NN-slug`

</process>

<rules>
- Do NOT create CONTEXT.md, RESEARCH.md, or PLAN.md here. This command stops at PRD.
- Do NOT write GDScript. If the user starts describing implementation, redirect: "That's an implementation detail — we'll cover it in /plan."
- If the feature is clearly two features jammed together, suggest splitting into two phases. Ask the user; don't split silently.
- Stay grounded in PROJECT.md/GDD.md/ARCHITECTURE.md. If the feature contradicts a locked decision, flag it plainly.
</rules>
