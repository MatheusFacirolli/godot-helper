# Phase {{NN}}: {{slug}}

<!--
How this file works:

Plans are units of work, each executed by ONE subagent in ONE session. Each plan has 2–3 tasks.
Plans declare `depends_on: [<plan ids>]`. The executor does a topological sort and groups plans
into WAVES — every plan in wave N depends only on plans from waves < N. All plans in a wave run
in parallel (up to config.parallelization.max_concurrent_agents).

Frontmatter fields (required on every plan):
- id: "01", "02", ... unique within this phase (planner-assigned, monotonic)
- wave: integer ≥ 1 — assigned during planning; executor validates
- depends_on: list of plan ids this plan needs finished before it starts
- files_touched: paths this plan will create or edit (for conflict detection)
- must_haves: list of must-have indices (from PRD.md "Must-haves") this plan contributes to
- autonomous: true if the plan can run without human input; false if it needs a checkpoint
- context_refs: doc anchors the executor pre-reads (e.g. `CONTEXT#D-02`, `ARCHITECTURE#input-handling`, `QUIRKS#physics`)

Fix plans appended by the evaluator use IDs of the form `F-01`, `F-02`, ... — separate namespace from planner IDs so they never collide when referenced from SUMMARY/VERIFICATION.

Keep tasks atomic — each task = one acceptable commit.
-->

## Goal
{{one paragraph restating the PRD outcome in implementer terms — what this phase concretely ships}}

## Must-haves (goal-backward verification targets)
Copied from PRD.md. Every must-have MUST be covered by at least one plan's `must_haves` list.

- [ ] 1. {{must-have 1}}
- [ ] 2. {{must-have 2}}
- [ ] 3. {{must-have 3}}

## Plans

### Plan 01: {{plan title — e.g. "Player scene + movement script"}}
```yaml
id: "01"
wave: 1
depends_on: []
files_touched:
  - scenes/player/player.tscn
  - scripts/player/player.gd
must_haves: [1, 2]
autonomous: true
context_refs:
  - CONTEXT#D-01
  - ARCHITECTURE#scene-graph-conventions
  - QUIRKS#physics
```

**Tasks:**
1. **Create Player scene** — Build `scenes/player/player.tscn` with `CharacterBody2D` root, `CollisionShape2D`, `Sprite2D`, and `AnimationPlayer` children.
   - Acceptance: scene opens without errors; `godot --headless --check-only` passes.
   - Files: `scenes/player/player.tscn`
2. **Implement movement script** — Attach `scripts/player/player.gd`; handle `move_left`/`move_right`/`jump` actions; integrate `move_and_slide`.
   - Acceptance: scene instanced in a test scene moves on WASD input; no runtime errors.
   - Files: `scripts/player/player.gd`
3. **Wire default InputMap actions** — Add `move_left`, `move_right`, `jump` to `project.godot` InputMap with default bindings.
   - Acceptance: `intel/input-map.md` refresh shows the new actions.
   - Files: `project.godot`

---

### Plan 02: {{plan title — e.g. "Camera follow + level boundaries"}}
```yaml
id: "02"
wave: 2
depends_on: ["01"]
files_touched:
  - scenes/player/player.tscn
  - scripts/camera/follow_camera.gd
must_haves: [3]
autonomous: true
context_refs:
  - CONTEXT#D-03
  - ARCHITECTURE#camera-conventions
```

**Tasks:**
1. **Add follow camera** — Create `scripts/camera/follow_camera.gd` (smoothed follow with deadzone); add a `Camera2D` child to the Player scene using this script.
   - Acceptance: camera tracks player with visible smoothing in a test level; no stutter.
   - Files: `scripts/camera/follow_camera.gd`, `scenes/player/player.tscn`
2. **Clamp to level bounds** — Expose `limit_left/right/top/bottom` on the camera; document in `ARCHITECTURE.md` under Known systems.
   - Acceptance: camera stops at bounds; ARCHITECTURE.md updated.
   - Files: `scripts/camera/follow_camera.gd`, `ARCHITECTURE.md`

---

<!-- Add more plans as needed. Keep the --- separators for readability. -->
