# Phase {{NN}} — {{slug}}: Locked Context

<!--
These decisions MUST be honored by downstream planner/executor. No silent simplification —
if a decision becomes impractical during planning or execution, SURFACE it and ASK, don't
quietly deviate. Edits to this file require human confirmation.

Decision ID format: `D-NN` (D-01, D-02, ...). Monotonic within this phase.
Downstream agents reference decisions by ID: planner sets `context_refs: [CONTEXT#D-02]`
on plans; executor honors them; evaluator verifies adherence.
-->

## Locked decisions
Each decision: ID + title + chosen approach + rationale + rejected alternatives + impact on downstream work.

### D-01: {{decision title}}
- **Decided:** {{chosen approach}}
- **Rationale:** {{why}}
- **Rejected:** {{alternatives and why each lost}}
- **Impact:** {{which plans / files / systems this binds}}

### D-02: {{decision title}}
- **Decided:** {{...}}
- **Rationale:** {{...}}
- **Rejected:** {{...}}
- **Impact:** {{...}}

## Deferred / explicitly out-of-scope
Things that came up but will NOT be handled in this phase.

- {{item}} — {{why deferred, where it might land later}}

## Clarified ambiguities
PRD items that were vague and now are not.

- **{{PRD line / topic}}** — {{clarification}}
