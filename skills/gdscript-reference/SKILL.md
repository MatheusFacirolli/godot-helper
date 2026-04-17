---
name: gdscript-reference
description: GDScript coding reference, scene/script patterns, progressive-disclosure Godot 4 API docs (one file per class), and headless verification. Bundled with the godot-helper plugin — auto-invoked by researcher, planner, and executor agents when writing or reasoning about Godot code.
---

# GDScript Coding Reference

Reference files live in `${CLAUDE_SKILL_DIR}/`. Load progressively — read each file when needed, not upfront.

| File | Purpose | When to read |
|------|---------|--------------|
| `quirks.md` | Known Godot gotchas and workarounds | Before writing any code |
| `gdscript.md` | GDScript syntax reference | Before writing any code |
| `scene-generation.md` | Building `.tscn` files via headless GDScript builders | Creating or modifying scenes |
| `script-generation.md` | Writing runtime `.gd` scripts for node behavior | Creating or modifying scripts |
| `coordination.md` | Ordering scene + script generation | Task involves both `.tscn` and `.gd` |
| `test-harness.md` | Headless test scripts for automated verification | Before writing tests |
| `doc_api/_common.md` | Index of ~128 common Godot classes (one-line each) | Need API ref; scan to find class names |
| `doc_api/_other.md` | Index of ~732 remaining Godot classes | Need API ref; class isn't in `_common.md` |
| `doc_api/{ClassName}.md` | Full API reference for a single Godot class | Need specific class API |

Bootstrap doc_api: `bash ${CLAUDE_SKILL_DIR}/tools/ensure_doc_api.sh`

## Commands

```bash
# Import new/modified assets (run before scene builders):
timeout 60 godot --headless --import

# Compile a scene builder (produces .tscn):
timeout 60 godot --headless --script <path_to_gd_builder>

# Validate all project scripts (parse check):
timeout 60 godot --headless --quit 2>&1

# Run a headless test:
timeout 30 godot --headless --script test/test_<name>.gd 2>&1
```

## Error Handling

Parse Godot's stderr/stdout for error lines. Common issues:
- `Parser Error` — syntax error in GDScript, fix the line indicated
- `Invalid call` / `method not found` — wrong node type or API usage, look up the class in `doc_api`
- `Cannot infer type` — `:=` used with `instantiate()` or polymorphic math functions, see type inference rules in `gdscript.md`
- Script hangs — missing `quit()` call in scene builder; kill the process and add `quit()`
