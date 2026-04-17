# Signal graph — {{project_name}}

<!--
How to keep this current:
- `godot-codebase-mapper` scans `signal ` declarations and `.connect(` calls to build this.
- After an executor adds/removes a signal or changes a connection, request a mapper refresh.
- Hand-edit the "Notes" lines to capture intent; leave emitter/consumer lists to the mapper.

Organize by emitter class. Within each emitter, list every declared signal with params + consumers.
-->

## Emitters

### {{Node or Class name}} (`res://{{path/to/file.gd}}`)

- **`{{signal_name}}({{param: Type, ...}})`**
  - Emitted when: {{condition}}
  - Consumers:
    - `res://{{path/to/consumer.gd}}` — {{what it does on receipt}}
    - `res://{{...}}` — {{...}}
  - Notes: {{e.g. "emitted once per frame max; consumers should be cheap"}}

- **`{{signal_name}}()`**
  - Emitted when: {{...}}
  - Consumers: {{...}}
  - Notes: {{...}}

---

### {{Node or Class name}} (`res://{{path/to/file.gd}}`)

- **`{{signal_name}}({{params}})`**
  - Emitted when: {{...}}
  - Consumers: {{...}}
  - Notes: {{...}}

## Orphan signals
Signals declared but with no detected consumers — may be dead code or reserved for future use.

- `{{Class.signal_name}}` — {{suspected reason / TODO}}
