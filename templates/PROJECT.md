# {{project_name}}

<!--
PROJECT.md is the constitution. It locks the high-level "why" and "what" of the
project. Update it when the vision, scope, or non-goals materially change — not
on every feature. All downstream agents read this first.
-->

## Vision
{{one paragraph: what the finished game feels like, the core fantasy, why it matters}}

## Target player
- **Genre:** {{genre — e.g. top-down roguelike, cozy farming sim, 2D platformer}}
- **Audience:** {{who plays this — age range, skill level, taste reference points}}

## Scope
**In scope**
- {{shipping feature 1}}
- {{shipping feature 2}}

**Out of scope (v1)**
- {{explicitly deferred feature 1}}
- {{explicitly deferred feature 2}}

## Platforms
- **Primary:** {{e.g. Windows desktop}}
- **Secondary:** {{e.g. Linux, Mac, Web}}
- **Input devices:** {{keyboard+mouse, gamepad, touch}}

## Constraints
- **Engine:** Godot {{godot_version}}
- **Team size:** {{solo / small team}}
- **Timeline:** {{target ship date or "open-ended"}}
- **Technical:** {{e.g. must run on integrated GPU, <200MB install}}
- **Other:** {{budget, licensing, asset sources}}

## Non-goals
- {{thing this game explicitly will NOT do — e.g. no multiplayer, no procgen}}
- {{thing this game explicitly will NOT do}}

## Key decisions (ADR-lite)
Log high-impact, hard-to-reverse decisions here. One line each; link to phase CONTEXT.md for rationale.

- {{YYYY-MM-DD}} — {{decision}} ({{phase NN or "pre-phase"}})
