# Phase {{NN}} — {{slug}}: Verification

<!--
Written by godot-evaluator after all plans in the phase are executed.
Splits verification into:
1. Auto-verifiable (scripts exist, nodes present, headless check passes, etc.) — done here.
2. Human-only (game feel, animation timing, audio mix, collision response) — checklist for the player.

If gaps are found, append fix plans to PLAN.md in a new wave rather than editing this file.
-->

## Auto-verified must-haves
One row per PRD must-have. Evidence = file path, commit sha, or command output.

| # | Must-have | Status | Evidence |
|---|-----------|--------|----------|
| 1 | {{must-have text}} | PASS / FAIL | {{file:line or command output summary}} |
| 2 | {{must-have text}} | PASS / FAIL | {{...}} |

## Items needing manual playtesting
Checklist — the human player runs the game and ticks these.

- [ ] **Game feel:** {{e.g. "jump arc feels responsive, not floaty"}}
- [ ] **Animation:** {{e.g. "run cycle matches movement speed; no foot-sliding"}}
- [ ] **Audio:** {{e.g. "jump SFX plays at peak, not on release"}}
- [ ] **Collision response:** {{e.g. "wall bump doesn't visibly jitter"}}
- [ ] **Input latency:** {{e.g. "input → visible motion feels immediate"}}
- [ ] **Edge cases:** {{e.g. "holding jump + moving off a ledge behaves as expected"}}

## Gaps discovered
Each gap → a suggested fix plan to append to `PLAN.md` in a new wave.

### Gap {{N}}: {{short title}}
- **What's missing / broken:** {{description}}
- **Suggested fix plan:** {{plan id, title, tasks outline}}
- **Must-haves affected:** {{list}}

## Overall verdict
{{one of: READY — all must-haves pass and manual checklist is reasonable to complete / NEEDS FIXES — gaps above must be closed before phase can ship / BLOCKED — decision needed from human}}

**Rationale:** {{one paragraph}}
