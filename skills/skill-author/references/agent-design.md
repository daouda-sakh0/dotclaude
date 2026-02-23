# Agent Design Patterns

For skills that will be run autonomously (e.g., batch processing, background diagnostics), design an agent wrapper.

---

## Agent Config Template

Create `agents/<agent-name>.md`:

```yaml
---
name: my-agent
model: sonnet                           # sonnet for cost-effective, opus for complex reasoning
color: cyan                             # semantic color for the agent
tools:
  # Core tools (from skill's allowed-tools)
  - Read
  - Grep
  - Glob
  - Bash
  # MCP tools
  - mcp__server__tool_a
  - mcp__server__tool_b
  # Skill loader (agent loads the skill at startup)
  - Skill
  # Team coordination (for batch/orchestrated scenarios)
  - SendMessage
  - TaskUpdate
  - TaskList
  - TaskGet
hooks:
  PostToolUse:
    - matcher: "mcp__.*"                # match all MCP tool calls
      hooks:
        - type: command
          command: "$CLAUDE_PROJECT_DIR/agents/hooks/<agent-name>/track-progress.sh"
          timeout: 5000
  PostToolUseFailure:
    - matcher: "mcp__.*"
      hooks:
        - type: command
          command: "$CLAUDE_PROJECT_DIR/agents/hooks/<agent-name>/track-failure.sh"
          timeout: 5000
  PreCompact:
    - hooks:
        - type: command
          command: "$CLAUDE_PROJECT_DIR/agents/hooks/<agent-name>/preserve-state.sh"
          timeout: 10000
  Stop:
    - hooks:
        - type: command
          command: "$CLAUDE_PROJECT_DIR/agents/hooks/<agent-name>/verify-completion.sh"
          timeout: 10000
description: >
  [One paragraph: what the agent does, what skill it uses, how it's orchestrated]
---
```

---

## Agent Description Sections

After the YAML frontmatter, the agent descriptor includes:

1. **Examples** (2 scenarios — happy path + degraded)
2. **Startup Protocol** (load skill → read task → mark in_progress → initialize tracking)
3. **Execution Flow** (high-level: which skill steps to run, what to collect)
4. **External Actions** (e.g., PR creation, notifications — with eligibility tables)
5. **Reporting Back** (structured report template + statistics schema)
6. **Operating Rules** (binding constraints — one task per instance, evidence-only conclusions, etc.)

---

## Hook Lifecycle

Four hooks cover the full agent lifecycle:

| Hook | Trigger | Purpose | Key pattern |
|---|---|---|---|
| **PostToolUse** | After MCP tool succeeds | Track progress | Infer current step from tool name; append to JSONL progress file |
| **PostToolUseFailure** | After MCP tool fails | Classify error + inject guidance | Map error string to category (auth/timeout/not_found); generate tool-specific recovery instructions |
| **PreCompact** | Before context compaction | Preserve diagnostic state | Reconstruct state from JSONL; output recovery context (steps completed, last step, failures, resume instructions) |
| **Stop** | Agent attempts to exit | Prevent premature termination | Check minimum tool calls; check for conclusion keywords in last message; block exit if incomplete |

**Hook implementation patterns:**

Each hook is a bash script that:
1. Reads JSON from stdin (`$CLAUDE_TOOL_USE_RESULT` or `$CLAUDE_STOP_HOOK_INPUT`)
2. Extracts relevant fields (tool name, error text, session ID)
3. Appends structured events to a JSONL progress file (`/tmp/<agent>-${SESSION_ID}.progress.jsonl`)
4. Optionally outputs guidance text (injected into the agent's conversation as `additionalContext`)

**Exit code convention:**
- `0` = allow the action to proceed
- `2` = block the action (with message explaining why)

---

## Statistics Collection Schema

For agents that need to report metrics:

```json
{
  "schema_version": "1",
  "context": {
    "primary_id": "...",
    "secondary_id": "...",
    "timestamp_start": "ISO 8601",
    "timestamp_end": "ISO 8601"
  },
  "diagnostic": {
    "result": "SUCCESS | FAILURE | INCONCLUSIVE | BLOCKED",
    "category": "...",
    "steps_executed": ["0.5", "1", "2a"]
  },
  "tools": {
    "tools_called": ["tool_name"],
    "tools_failed": [{"tool": "name", "error_category": "auth"}],
    "blocked_by_tool": null
  },
  "efficiency": {
    "total_turns_approx": 0,
    "action_taken": false,
    "action_url": null
  }
}
```

---

## Batch Orchestration via Task

For running the agent across multiple targets:

1. **Parent agent** creates tasks via `TaskCreate` (one per target)
2. **Parent agent** launches child agents via `Task` tool (one per task, in parallel)
3. **Child agents** read their task via `TaskGet`, execute the skill, report via `SendMessage`, mark task `completed`
4. **Parent agent** collects results and presents summary

**Task description format:**
```
primary_id: ...
secondary_id: ...
[optional] context_field: ...
[optional] flags: ...
```
