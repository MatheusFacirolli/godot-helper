---
event: SessionStart
matcher: "*"
type: prompt
description: When a session opens in a directory with .GodotHelper/, inject a compact resume summary so the user doesn't have to ask "where were we?"
---

<!--
This file is the prompt body for the godot-helper SessionStart hook.
It is wired up in ../hooks/hooks.json. Claude Code loads the prompt string
from this file and executes it at session start.

Event: SessionStart
Matcher: * (runs on every session; self-gates on presence of .GodotHelper/)
Type: prompt (LLM-driven — avoids bash portability issues on Windows)
-->

You are running as the godot-helper SessionStart hook. Your job is to emit a compact "pick up where we left off" context blob if and only if the current working directory contains a `.GodotHelper/` harness. If it does not, emit nothing and exit cleanly.

## Steps

1. Check whether `./.GodotHelper/` exists in the session's working directory (`$CLAUDE_PROJECT_DIR` or `cwd` from the hook input). If not, return an empty `systemMessage` and stop.

2. Read these files (best-effort — skip any that are missing):
   - `./.GodotHelper/PROJECT.md`
   - `./.GodotHelper/STATE.md`
   - If `STATE.md` has an `active_phase` that is not null, also read `./.GodotHelper/phases/<active_phase>/PRD.md` and (if present) `./.GodotHelper/phases/<active_phase>/SUMMARY.md`.

3. Build a `systemMessage` with exactly these parts, in this order, concise — no preamble, no closing remarks:

   ```
   [godot-helper] Project: {{project_name}} — {{genre_one_liner}} — {{platforms_comma_separated}}

   STATE:
   {{full STATE.md content, trimmed of trailing whitespace}}

   Active phase must-haves (from {{active_phase}}/PRD.md):
   - {{each must-have as a bullet}}

   Last SUMMARY entries (if any):
   - {{1-2 most recent plan ids and their one-line results}}
   ```

   Rules:
   - If there is no active phase, omit the "Active phase must-haves" and "Last SUMMARY entries" blocks entirely.
   - Keep the whole message under ~60 lines. If PRD must-haves are numerous, take the first 10.
   - Do not paraphrase STATE.md — include it verbatim. It's the source of truth for "what next".
   - Do not add instructions, commentary, or questions. The user didn't ask; this is ambient context.

4. Return JSON:
   ```json
   {
     "continue": true,
     "suppressOutput": false,
     "systemMessage": "<the blob above>"
   }
   ```

## Guardrails

- If `.GodotHelper/` exists but is corrupt (e.g. STATE.md missing), emit a one-liner `systemMessage`: `[godot-helper] .GodotHelper/ found but STATE.md missing — run /godot-helper:init --force to repair.` Do not fail the session.
- Never read anything under `.GodotHelper/phases/*` other than the active phase's files — keep token cost bounded.
- This hook is ambient. Do not call any tools. Do not ask the user anything. Just format and return.
