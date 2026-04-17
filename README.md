# godot-helper

A Claude Code plugin tailored to **Godot 4.6** game development.

## What it does

Five slash commands form the complete workflow:

| Command | Purpose |
|---|---|
| `/godot-helper:init` | Bootstrap a new project or adopt an existing one — creates `.GodotHelper/` with GDD, architecture, project docs, quirks, and state |
| `/godot-helper:brainstorm` | Turn a feature idea into a PRD via guided Q&A |
| `/godot-helper:plan` | Research + decompose a PRD into waves of parallelizable plans with tasks |
| `/godot-helper:discuss-phase` | Surface assumptions and lock decisions before execution |
| `/godot-helper:execute-phase` | Dispatch subagents per plan in waves, commit atomically, run evaluator, keep docs current |

## Design principles

- **Self-contained** — everything lives under `godot-helper/`; per-project artifacts live under `.GodotHelper/` in the user's Godot project
- **Progressive disclosure** — bundles a GDScript reference skill (~860 class docs) that agents load on demand via a two-tier index
- **One plan = one subagent session** — each plan is tightly scoped; plans fan out in waves based on dependencies
- **Doc-driven** — `PROJECT.md`, `ARCHITECTURE.md`, `QUIRKS.md` are the project's memory and are kept current by the executor and evaluator
- **Godot-specific verification** — the evaluator runs `godot --headless` smoke tests and produces a manual playtest checklist (game feel is human-judged)

## Project artifacts (created in your Godot project)

```
.GodotHelper/
├── config.json                      helperconfig: model routing, gates, parallelism
├── PROJECT.md                       vision, scope, constraints, non-goals
├── GDD.md                           full game design doc
├── ARCHITECTURE.md                  living architecture
├── QUIRKS.md                        Godot + project-specific gotchas
├── STATE.md                         current phase, active plan, next action
├── phases/NN-slug/
│   ├── PRD.md                       from /brainstorm
│   ├── CONTEXT.md                   from /discuss-phase — locked decisions
│   ├── RESEARCH.md                  from /plan research step
│   ├── PLAN.md                      plans + tasks with wave/depends_on frontmatter
│   ├── SUMMARY.md                   what executor actually built
│   └── VERIFICATION.md              evaluator findings + manual playtest checklist
└── intel/                           codebase maps
    ├── scenes.md, autoloads.md, input-map.md, signals.md
```

## Install

### One-time (add the marketplace)

```bash
# From Claude Code:
/plugin marketplace add git@github.com:<your-username>/godot-helper.git
/plugin install godot-helper@godot-helper-marketplace
```

The marketplace name `godot-helper-marketplace` comes from `.claude-plugin/marketplace.json` — don't confuse it with the plugin name `godot-helper`.

### Dev mode (no install, no git)

```bash
claude --plugin-dir <path-to-this-repo>
```

Useful while iterating on the plugin itself.

### Updating

```bash
/plugin marketplace update godot-helper-marketplace
```

This pulls new commits from the git source. Installed plugins pick up changes on next session start. Toggle auto-update interactively via `/plugin` → **Marketplaces**.

### Uninstall

```bash
/plugin uninstall godot-helper@godot-helper-marketplace
/plugin marketplace remove godot-helper-marketplace
```

## Status

v0.1.1 — MVP. Explicitly deferred: `/debug`, `/ship`, `/note`, `/pause-work`, `/resume-work`, `/playtest` (standalone), `/run-headless` (standalone). Add after the core loop proves itself on real Godot work.

v0.1.1 hotfix: dropped the Stop hook (`@file`-prompt syntax was invalid and caused a loop); SessionStart now uses a `type: command` bash script (`hooks/session-start.sh`).
