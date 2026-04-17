#!/usr/bin/env bash
# godot-helper SessionStart hook.
# If the current working directory is a godot-helper-managed project
# (contains `.GodotHelper/STATE.md`), emit a compact resume-context blob
# as a systemMessage so Claude can pick up where the user left off.
#
# Runs in ~10ms on a real project; no-op on non-godot-helper projects.

set -euo pipefail

if [ ! -f ".GodotHelper/STATE.md" ]; then
  # Not a godot-helper project — emit nothing.
  exit 0
fi

# Build a compact message. Keep it under ~80 lines of output.
{
  # Optional: project name from first H1 of PROJECT.md
  if [ -f ".GodotHelper/PROJECT.md" ]; then
    name="$(grep -m1 '^# ' .GodotHelper/PROJECT.md 2>/dev/null | sed 's/^# //' || true)"
    if [ -n "${name:-}" ]; then
      printf '[godot-helper] Project: %s\n\n' "$name"
    else
      printf '[godot-helper] Picking up where we left off.\n\n'
    fi
  else
    printf '[godot-helper] Picking up where we left off.\n\n'
  fi

  printf 'STATE.md:\n'
  printf -- '---\n'
  # Cap STATE.md content at 120 lines for safety
  head -n 120 .GodotHelper/STATE.md
  printf -- '---\n'
} > /tmp/godot-helper-session-start.txt 2>/dev/null || {
  # Windows bash may not have /tmp; fall back to inline echo
  true
}

# Emit JSON with systemMessage. Prefer jq for safe escaping; fall back to python.
msg_file="/tmp/godot-helper-session-start.txt"
if [ ! -f "$msg_file" ]; then
  # Inline fallback (no temp file available)
  msg="$({
    [ -f ".GodotHelper/PROJECT.md" ] && grep -m1 '^# ' .GodotHelper/PROJECT.md | sed 's/^# /[godot-helper] Project: /'
    echo
    echo "STATE.md:"
    echo "---"
    head -n 120 .GodotHelper/STATE.md
    echo "---"
  })"
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$msg" | jq -Rs '{systemMessage: .}'
  elif command -v python >/dev/null 2>&1 || command -v python3 >/dev/null 2>&1; then
    PY="$(command -v python3 || command -v python)"
    printf '%s' "$msg" | "$PY" -c 'import json,sys; print(json.dumps({"systemMessage": sys.stdin.read()}))'
  else
    # Last resort: print raw; Claude Code will surface stdout as a message
    printf '%s\n' "$msg"
  fi
  exit 0
fi

if command -v jq >/dev/null 2>&1; then
  jq -Rs '{systemMessage: .}' < "$msg_file"
elif command -v python >/dev/null 2>&1 || command -v python3 >/dev/null 2>&1; then
  PY="$(command -v python3 || command -v python)"
  "$PY" -c 'import json,sys; print(json.dumps({"systemMessage": sys.stdin.read()}))' < "$msg_file"
else
  cat "$msg_file"
fi
