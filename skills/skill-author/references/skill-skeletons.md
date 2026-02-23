# Skill Skeletons

Complete starter templates for all three skill tiers. Copy the appropriate skeleton and fill in the placeholders.

---

## Minimal Skill Skeleton (~50 lines)

Use for simple tool wrappers or single-purpose skills (score 0-3).

````markdown
---
name: my-simple-skill
description: [One sentence]. Use when [trigger].
allowed-tools: Read, Grep, Glob, Bash
---

# [Skill Name]

[One-sentence objective.]

## When to Use This Skill

Auto-invoke when a user mentions:
- [Trigger phrase 1]
- [Trigger phrase 2]

## Steps

### Step 1: [Action]

[What to do.]

### Step 2: [Action]

[What to do.]

### Step 3: [Action]

[What to do.]

## Output Format

Present results as:

```
[Template]
```
````

---

## Standard Skill Skeleton (~200 lines)

Use for multi-step skills with routing and error handling (score 4-7).

````markdown
---
name: my-standard-skill
description: >
  [What it does]. Use when [triggers].
allowed-tools: Read, Grep, Glob, Bash, mcp__server__tool_a, mcp__server__tool_b
---

# [Skill Name]

[One-sentence objective.]

## When to Use This Skill

Auto-invoke when a user mentions:
- **[Category 1]**
  - [Specific trigger]
- **[Category 2]**
  - [Specific trigger]

### Supported Entry Points

| Entry point | Example | What you can extract |
|---|---|---|
| [Format 1] | `[example]` | [Fields] |
| [Format 2] | `[example]` | [Fields] |

## Prerequisites

1. `[server]` MCP server configured (`server__tool_a` tool)
2. `[server]` MCP server configured (`server__tool_b` tool) — **optional**

## Tool Constraints

### [Tool Name]: [Constraint]

**Constraint**: [Description]
**Workaround**: [How to work around it]

## Workflow

```
Step 1: [Description]
├── Step 2a: [Branch A]
└── Step 2b: [Branch B]
Step 3: [Merge point]
Step 4: Output
```

### Step 1: [Action verb] [what]

[Narrative preamble.]

[Procedure — tool calls, queries.]

| Result | Meaning | Action |
|---|---|---|
| [Result A] | [Meaning] | Go to Step 2a |
| [Result B] | [Meaning] | Go to Step 2b |

### Step 2a: [Action verb] [what]

> **Requires**: [tool]. If unavailable, skip to Step 3.

[Procedure.]

### Step 2b: [Action verb] [what]

[Procedure.]

### Step 3: [Action verb] [what]

[Procedure.]

## Output Format

### Status Overview

| Check | Status | Finding |
|---|---|---|
| [Step 1 check] | ✅ / ❌ / ⏭ | [Finding] |
| [Step 2 check] | ✅ / ❌ / ⏭ | [Finding] |

### Recommendation

[Structured recommendation.]

### Quick Links

- **[System]**: [URL]

### Follow-up Options

1. [Option 1]
2. [Option 2]

## Error Handling

| Scenario | Likely cause | Action |
|---|---|---|
| [Scenario 1] | [Cause] | [Action] |
| [Scenario 2] | [Cause] | [Action] |

## Examples

### Example 1: [Scenario name]

**User says**: "[Message]"
**Action sequence**: [Step-by-step]
**Result**: [Conclusion]

### Example 2: [Scenario name]

**User says**: "[Message]"
**Action sequence**: [Step-by-step]
**Result**: [Conclusion]

## Known Limitations

- [Limitation 1]
````

---

## Advanced Skill Skeleton (~500+ lines)

Use for full DAG workflows with constitutional rules, references, and optional agent support (score 8-12).

````markdown
---
name: my-advanced-skill
description: >
  [Expert-level description]. Automates [process] by [method].
  Use when [detailed trigger conditions].
allowed-tools: Read, Grep, Glob, Bash, mcp__server_a__tool_1, mcp__server_a__tool_2, mcp__server_b__tool_1, mcp__server_c__tool_1
---

# [Skill Name]

[One-sentence objective.]

## When to Use This Skill

Auto-invoke when a user mentions:
- **[Category 1]**
  - [Trigger with URL pattern example]
  - [Trigger with natural language example]
- **[Category 2]**
  - [Trigger]
- **[Category 3]** (e.g., dashboard status strings)
  - [Trigger]

### Supported Entry Points

| Entry point | Example | What you can extract |
|---|---|---|
| [Format 1] | `[concrete example]` | [Fields + resolution strategy] |
| [Format 2] | `[concrete example]` | [Fields + resolution strategy] |
| [Format 3] | `[concrete example]` | [Fields + resolution strategy] |
| [Format 4] | `[concrete example]` | [Fields + resolution strategy] |

## Prerequisites

1. `[server-a]` MCP server configured (`tool_1`, `tool_2` tools)
2. `[server-b]` MCP server configured (`tool_1` tool)
3. `[server-c]` MCP server configured (`tool_1` tool) — **optional**, [setup instructions]. The skill works fully without it.

| Resource | Table/Endpoint | Required role | Purpose |
|---|---|---|---|
| `project.dataset` | `table_name` | `roles/X` | Step N: [purpose] |

## Tool Constraints

### [Tool A]: [Constraint]

**Constraint**: [Description]
**Symptom**: [Error or unexpected behavior]
**Workaround**: [Alternative approach]

### [Tool B]: [Constraint]

**Constraint**: [Description]
**Symptom**: [Error or unexpected behavior]
**Workaround**: [Alternative approach]

## Decision Zones

| Zone | Owner | Bound by | Examples |
|---|---|---|---|
| **Rules / Execution** | Hardcoded | Cannot change | SQL queries, search patterns, decision tables |
| **Interpretation / Action** | Agent reasoning | Principles | Root cause explanations, remediation selection, user communication |

## Constitutional Rules

1. **Never [action A]** — [reason].
2. **Never [action B]** — [reason].
3. **Never [action C]** — [reason].
4. **Never [action D]** — [reason].
5. **Never [action E]** — [reason].

### Conflict Resolution

| Conflict | Resolution | Rationale |
|---|---|---|
| [Source A] says X, [Source B] says Y | Trust [Source] | [Why] |

## Workflow

```
Step 0: MCP access verification
├── Step 0.5: Quick triage†
├── Step 1: [Classification / Input resolution]
│   └── [Symptom routing table]
├── Step 2: [Investigation phase]
│   ├── Step 2a: [Branch A — e.g., framework detection]
│   ├── Step 2b: [Branch B — e.g., config checks]†
│   ├── Step 2c: [Branch C — e.g., environment checks]
│   └── Step 2d: [Branch D — e.g., extract identifiers]
├── Step 3: [Deep analysis phase]
│   ├── Step 3a: [Analysis type 1]
│   ├── Step 3b: [Analysis type 2]†
│   ├── Step 3c-fast: [Quick check variant]†
│   ├── Step 3c: [Full analysis]
│   └── Step 3d: [Error log analysis]
├── Step 4: [Resolution/verification phase]
│   ├── Step 4a-discover: [Discovery variant]†
│   ├── Step 4a: [Verification A]
│   ├── Step 4b: [Verification B]
│   ├── Step 4c: [Verification C]
│   └── Step 4d: [Verification D]
├── Step 5: Remediation
│   ├── Step 5a: Immediate fix
│   ├── Step 5b: Long-term improvement
│   └── Step 5c: Verification steps
└── Step 6: Output & follow-up

† = conditional (skip if prerequisite not met)
```

### Step 0: Verify MCP Access

[Probe table — see MCP Access Verification Pattern above]

### Step 0.5: Quick Triage

[Fast check using lightweight tool — route to specific step if conclusive, else continue]

### Step 1: [Input Resolution & Routing]

#### Input Resolution

[Parse → resolve → confirm pattern]

#### Symptom Routing

[Decision table mapping symptoms to starting steps]

### Step 2a: [Branch A]

[Full step anatomy: narrative → requires → procedure → interpretation table]

### Step 2b: [Branch B]

> **Skip condition**: Skip if [condition from Step 2a].

[Step body]

[... continue for all steps ...]

### Step 5a: Immediate Fix

| Root cause | Immediate fix | Rationale | Risks |
|---|---|---|---|
| [Cause 1] | [Fix] | [Why] | [Risks] |
| [Cause 2] | [Fix] | [Why] | [Risks] |

### Step 5b: Long-term Improvement

| Current state | Improvement | Migration path | Resources |
|---|---|---|---|
| [State] | [Better approach] | [How] | [Links] |

### Step 5c: Verification Steps

1. [Re-trigger]
2. [Re-query]
3. [Check downstream]
4. [Check UI — note delays]

### Step 6: Follow-up Options

| Option | When to suggest | Action |
|---|---|---|
| [Option 1] | [Condition] | [What happens] |
| [Option 2] | [Condition] | [What happens] |

## Output Format

[Status Overview table + Root Cause & Remediation + Quick Links + Follow-up — see Step 6 patterns above]

## Error Handling

| Scenario | Likely cause | Action |
|---|---|---|
| [Scenario 1] | [Cause] | [Action] |
| [... more rows ...] | | |

## Common Issues Quick Reference

| Issue | Symptom | Solution |
|---|---|---|
| [Issue 1] | [Symptom] | [Solution] |
| [... more rows ...] | | |

## Examples

### Example 1: [Happy path]

**User says**: "[Message]"
**Action sequence**:
1. [Input resolution]
2. [Route to Step X]
3. [Key finding]
4. [Conclusion]
**Result**: [One-sentence summary]

### Example 2: [Edge case]

**User says**: "[Message]"
**Action sequence**:
1. [Input resolution]
2. [Unusual routing]
3. [Partial result]
**Result**: [One-sentence summary]

### Example 3: [Everything healthy]

**User says**: "[Message]"
**Action sequence**:
1. [Full workflow passes]
**Result**: "All checks passed — [domain object] is healthy."

## Known Limitations

- [Limitation 1]: [What the skill cannot do]
- [Limitation 2]: [What the skill cannot do]

## References

- [Common Issues](./references/common-issues.md) — [what it covers]
- [Tool Reference](./references/tool-reference.md) — [what it covers]
- [Domain Topic 1](./references/topic-1.md) — [what it covers]
- [Documentation Links](./references/documentation-links.md) — [what it covers]
````
