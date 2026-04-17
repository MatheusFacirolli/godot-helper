# Phase {{NN}} — {{slug}}: Execution Log

<!--
Appended to by each godot-executor subagent after it finishes its plan.
One section per plan, in execution order. Used by the evaluator and by
downstream plans (via `depends_on`) to know what actually landed.

This is a TEMPLATE file — stamped verbatim into .GodotHelper/phases/NN-slug/SUMMARY.md
at phase creation. It is an artifact, not a report.
-->

## Per-plan entries

All fields below are REQUIRED. Missing fields break the evaluator — if a field has no content, emit "(none)".

## Plan 01 — {{title}} (wave {{N}})
- **Executed:** {{YYYY-MM-DD HH:MM}}
- **Commits:** {{sha-short..sha-short}}
- **Files created:**
  - `{{res:// path}}`
- **Files modified:**
  - `{{res:// path}}`
- **Must-haves claimed:** [{{indexes from plan frontmatter this plan actually satisfied}}]
- **Public API added:** {{new signals / autoloads / classes / input actions / scene templates — evaluator cross-checks ARCHITECTURE + intel drift. "(none)" if purely internal.}}
- **Deviations from plan:** {{anything changed vs. the plan — with reason. "(none)" if clean.}}
- **CONTEXT decisions honored:** [{{D-01, D-03, ...}}]
- **Needs manual playtest:** {{items the executor cannot self-verify — animation feel, audio mix, collision response tuning. "(none)" if fully auto-verified.}}
- **Surprises / notes:** {{anything the evaluator or next plan should know. "(none)" if clean.}}

---

## Plan 02 — {{title}} (wave {{N}})
- **Executed:** {{YYYY-MM-DD HH:MM}}
- **Commits:** {{sha-short..sha-short}}
- **Files created:** {{...}}
- **Files modified:** {{...}}
- **Must-haves claimed:** [{{...}}]
- **Public API added:** {{...}}
- **Deviations from plan:** {{...}}
- **CONTEXT decisions honored:** [{{...}}]
- **Needs manual playtest:** {{...}}
- **Surprises / notes:** {{...}}

---
