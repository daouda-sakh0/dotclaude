# Step Patterns: Steps 1-4

Detailed patterns for defining purpose/triggers, mapping workflow DAGs, writing prerequisites, and establishing constitutional rules.

---

## Step 1: Define Purpose & Triggers

### Single-Sentence Description Pattern

Write one sentence that answers: "What does this skill do, and when should it be invoked?"

**Pattern:** `[Action verb] + [domain object] + by [method]. Use when [trigger conditions].`

**Example:**
> Systematically diagnose and troubleshoot why workflows are not producing data lineage or producing incorrect lineage.

**Template:**
```
[Verb] [what] by [how]. Use when [conditions].
```

### Auto-Invocation Triggers

List the exact phrases or contexts that should cause Claude to load this skill. Group by category:

```markdown
## When to Use This Skill

Auto-invoke this skill when a user mentions:
- **[Category 1]** (e.g., "Primary use case")
  - Specific phrase or URL pattern
  - Another specific phrase
- **[Category 2]** (e.g., "Validation use case")
  - Specific phrase
- **[Category 3]** (e.g., "Troubleshooting")
  - Specific phrase
```

**Key:** Include both natural language triggers ("lineage isn't appearing") and structural triggers (specific URL patterns, dashboard statuses, error messages).

### Entry Points Table Pattern

If users can invoke the skill with different input formats, document every one:

```markdown
### Supported Entry Points

| Entry point | Example | What you can extract |
|---|---|---|
| [Format name] | `[concrete example]` | [Fields extracted + resolution strategy] |
| [Format name] | `[concrete example]` | [Fields extracted + resolution strategy] |
```

**Rules:**
- Every row must have a concrete example (not abstract descriptions)
- The "What you can extract" column must name the specific fields/variables
- Include a resolution strategy if the format doesn't directly provide all needed fields
- Order from most common to least common

---

## Step 2: Map the Workflow DAG

### Input Resolution Pattern

When users can provide partial information, define a resolution strategy:

1. **Parse** the user's input for known patterns (URLs, IDs, names)
2. **Resolve** missing fields using queries or tool calls (document which query fills which gap)
3. **Confirm** resolved values with the user (structured message showing what was found)

**Template:**
```markdown
### Input Resolution

When the user provides [partial info], resolve the full context:

1. **Extract from input**: Parse for [patterns]. Extract `${FIELD_A}`, `${FIELD_B}`.
2. **If `${FIELD_C}` is missing**: Query [source] using `${FIELD_A}` to find it.
3. **If `${FIELD_D}` is missing**: Query [source] using `${FIELD_B}` to find it.
4. **Confirm**: Present resolved values to user before proceeding.

Only ask the user directly if [specific condition where no automated resolution is possible].
```

### Symptom-Based Routing Pattern

When different user symptoms map to different starting points in the workflow:

```markdown
### Symptom Routing

If the user's symptom is unclear, ask:
> Which best describes your situation?
> 1. [Symptom A]
> 2. [Symptom B]
> ...

| Symptom | Starting step | Rationale |
|---|---|---|
| [Symptom A] | Step X | [Why this starting point] |
| [Symptom B] | Step Y | [Why this starting point] |
| Unknown / unclear | Step 1 | Default: start from beginning |

**Auto-detection**: If the user's message contains [specific strings], skip the clarification and route directly.
```

### DAG Design

Choose the right topology for your workflow:

**Linear** (score 0-3): Steps execute in fixed order.
```
Step 1 → Step 2 → Step 3 → Output
```

**Branching** (score 4-7): Decision points route to different paths.
```
Step 1 → Step 2 ─┬─ [condition A] → Step 3a → Step 4
                  └─ [condition B] → Step 3b → Step 4
```

**Full DAG** (score 8-12): Multiple branches, conditional skips, parallel paths.
```
## Workflow

Step 0: Environment setup
├── Step 0.5: Quick triage
├── Step 1: Classification
│   └── Step 1a: Sub-classification
├── Step 2: Investigation
│   ├── Step 2a: [Branch A]
│   ├── Step 2b: [Branch B]†
│   └── Step 2c: [Branch C]
├── Step 3: Deep analysis
│   ├── Step 3a: [Analysis type 1]
│   └── Step 3b: [Analysis type 2]†
├── Step 4: Resolution
│   ├── Step 4a: [Resolution path 1]
│   └── Step 4b: [Resolution path 2]
└── Step 5: Output & follow-up

† = conditional (skip if prerequisite condition not met)
```

### Step Numbering Convention

- **Main steps**: Integer (0, 1, 2, 3...)
- **Sub-steps**: Letter suffix (2a, 2b, 2c)
- **Fast variants**: Suffix `-fast` (3c-fast for quick triage before deep 3c)
- **Discovery variants**: Suffix `-discover` (4a-discover for finding targets before 4a analysis)
- **Step 0**: Reserved for environment/MCP access verification
- **Step 0.5**: Optional quick triage (fast check before full workflow)

### Skip Conditions & Shortcuts

Document when steps can be skipped:

```markdown
> **Skip condition**: Skip this step if [condition from earlier step].
> **Shortcut**: If Step 0.5 already found [result], jump directly to Step [N].
```

### Variable Passing Between Steps

Use consistent parameter placeholders throughout:

```
${UPPERCASE_WITH_UNDERSCORES}
```

**Rules:**
- All caps, underscores, curly braces: `${WORKFLOW_ID}`, `${COMPONENT_ID}`
- Define each variable where it's first resolved (in Input Resolution or a specific step)
- Reference freely in later steps without redefining
- Never fill in placeholders in the skill itself — the agent substitutes at runtime

---

## Step 3: Write Prerequisites & Tool Constraints

### MCP Server Requirements Pattern

List every MCP server the skill depends on, with specific tools:

```markdown
## Prerequisites

1. `[server-name]` MCP server configured (`server-name__tool_a`, `server-name__tool_b` tools)
2. `[server-name]` MCP server configured (`server-name__tool_c` tool) — **optional**, [how to set up]. The skill works fully without it.
```

**Rules:**
- Number each prerequisite
- Name the specific tools from each server (not just the server)
- Mark optional servers explicitly with bold **optional**
- For optional servers, explain what functionality degrades without them

### Access Requirements Table

When the skill needs specific data access (databases, APIs, GCP projects):

```markdown
| Resource | Specific table/endpoint | Required role | Purpose in skill |
|---|---|---|---|
| `project.dataset` | `table_name` | `roles/bigquery.dataViewer` | Step 3c: query lineage logs |
```

### Tool Constraint Documentation

For each tool with non-obvious behavior, document the constraint, the symptom of violating it, and the workaround:

```markdown
## Tool Constraints

### [Tool Name]: [Short constraint description]

**Constraint**: [What you cannot do]
**Symptom**: [Error message or unexpected behavior if violated]
**Workaround**: [How to achieve the same result within the constraint]
```

**Example (from lineage-debugger):**
```markdown
### BigQuery MCP: No explicit LIMIT clauses

**Constraint**: The tool auto-appends `LIMIT 10` to every query.
**Symptom**: `Expected end of input but got keyword LIMIT` error.
**Workaround**: Use a CTE with `ROW_NUMBER()` and filter `WHERE rn <= N` instead of `LIMIT N`.
```

### MCP Access Verification Pattern (4-Phase)

For skills with many MCP dependencies, add a Step 0 that verifies access:

```markdown
### Step 0: Verify MCP Access

Run a lightweight probe for each required MCP server:

| Server | Probe call | Expected result | If fails |
|---|---|---|---|
| `bigquery-mcp` | `execute_query(query="SELECT 1")` | Returns `1` | BLOCKED — cannot proceed |
| `code-search` | `count_matches(query="test", limit=1)` | Returns count | Skip code search steps |
| `text2sql-mcp` | `text2sql(question="test", cluster="X")` | Returns SQL string | Skip Vedder steps (optional) |

**If a required server fails**: Report BLOCKED with the server name and stop.
**If an optional server fails**: Note degraded capability and continue.
```

---

## Step 4: Write Constitutional Rules

### NEVER Rules Pattern

Constitutional rules are absolute constraints the agent must never violate, regardless of context. Format each as "Never X because Y":

```markdown
## Constitutional Rules

1. **Never [action]** — [consequence or reason].
2. **Never [action]** — [consequence or reason].
```

**Example rules (from lineage-debugger):**
```markdown
1. **Never declare a root cause without citing the specific query result, log entry, or tool output** — every root cause must reference the step and evidence that supports it.
2. **Never modify hardcoded SQL queries** — use them exactly as written in the skill.
3. **Never omit sections from the Output Format template** — every section must appear even if a step was skipped (mark as ⏭).
```

**Guidelines for writing NEVER rules:**
- Only create rules for mistakes that would be **catastrophic** or **systematically misleading**
- Each rule must be independently verifiable (can you check compliance mechanically?)
- Include the reason — agents follow rules better when they understand why
- Keep to 5-8 rules maximum; too many dilutes their force

### Conflict Resolution Tables

When the skill uses multiple data sources that can disagree:

```markdown
### Conflict Resolution

| Conflict | Resolution | Rationale |
|---|---|---|
| Source A says X, Source B says Y | Trust Source [A/B] | [A/B] is [closer to raw data / more authoritative / etc.] |
| Step N shows pass, Step M shows fail | [Which takes precedence] | [Why] |
```

**Rule:** Raw/primary data always beats derived/post-processed data. Explicit precedence prevents agent confusion.

### Decision Zones Pattern

Separate what is hardcoded (agent must follow exactly) from what requires judgment:

```markdown
## Decision Zones

| Zone | Owner | Bound by | Examples |
|---|---|---|---|
| **Rules / Execution** | Hardcoded in skill | Cannot change | SQL queries, code search patterns, decision tables, URI construction |
| **Interpretation / Action** | Agent reasoning | Principles, not rules | Explaining root causes to users, selecting relevant remediation, adapting to context |

Never improvise in the Rules zone (e.g., never rewrite a SQL query).
Never rigidly template in the Interpretation zone (e.g., always tailor explanations to the user's context).
```

### Evidence Requirements

If the skill produces conclusions (diagnoses, recommendations, assessments):

```markdown
### Evidence Standard

Every [conclusion type] must cite:
- The specific step that produced the evidence
- The tool call or query that returned the data
- The exact result (value, row count, error message) that supports the conclusion

Pattern: "Found [evidence] in Step [N] via [tool/query]: [specific result]"
```
