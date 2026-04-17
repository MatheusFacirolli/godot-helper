# Headless Test Harness

Write `test/test_{name}.gd` — a SceneTree script that loads the scene under test and verifies behavior via console assertions. Run headless before the user does manual playtesting.

## SceneTree Script Contract

Tests must `extend SceneTree` (not Node):
- `_initialize()` for setup (not `_ready()`)
- `_process(delta: float) -> bool` — return `false` to keep running, `true` to finish
- Call `quit()` when all assertions complete

## Console Assertions

Use `print("ASSERT PASS: ...")` / `print("ASSERT FAIL: ...")` to verify properties that can be checked programmatically:

```gdscript
extends SceneTree

var _scene: Node
var _frames: int = 0

func _initialize() -> void:
    var packed: PackedScene = load("res://scenes/main.tscn")
    _scene = packed.instantiate()
    root.add_child(_scene)

func _process(delta: float) -> bool:
    _frames += 1
    if _frames < 10:
        return false  # let physics settle

    var player: Node = _scene.get_node_or_null("Player")
    if player:
        print("ASSERT PASS: Player node exists")
    else:
        print("ASSERT FAIL: Player node missing")

    quit()
    return true
```

## Simulated Input

For tests needing player input, use a Timer to trigger actions:

```gdscript
    var timer := Timer.new()
    timer.wait_time = 1.0
    timer.one_shot = true
    timer.timeout.connect(func(): Input.action_press("move_forward"))
    root.add_child(timer)
    timer.start()
```

## Running Tests

```bash
timeout 30 godot --headless --script test/test_<name>.gd 2>&1
```

Check stdout for `ASSERT FAIL` lines. Fix any failures before handing off for manual testing.

## What to Test Headless vs Manually

**Automate (headless):**
- Node existence and hierarchy
- Script attachment and class types
- Signal connections
- Initial property values
- Input action registration
- Basic physics (velocity, collision layers)
- State machine transitions

**Leave for manual testing:**
- Visual appearance and polish
- Animation quality and timing
- Sound and music
- Camera feel
- Gameplay feel and balance
- UI layout and responsiveness
