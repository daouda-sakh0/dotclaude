---
name: skill-author
description: Meta-skill for designing and writing high-quality Claude Code skills. Guides you through a step-by-step authoring workflow with embedded patterns, templates, and anti-patterns drawn from production-grade skill development. Use when creating a new skill or improving an existing one.
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

# Skill Author

Guide the user through designing and writing a Claude Code skill, from initial concept through production-ready SKILL.md. This meta-skill encodes the patterns, templates, and conventions learned from building production-grade skills (1,400+ line diagnostic workflows with DAG-based routing, agent hooks, and reference file ecosystems).

## When to Use This Skill

Auto-invoke when a user mentions:
- **Creating a new skill** ("I want to build a skill for...", "Help me write a skill that...")
- **Improving an existing skill** ("This skill needs better error handling", "How do I add routing to my skill?")
- **Skill architecture questions** ("Should I use a DAG?", "How do I structure my references?", "When do I need hooks?")
- **Reviewing a skill** ("Is this skill well-structured?", "What's missing from this skill?")

## Skill Complexity Scorecard

Before writing, assess the skill's complexity. This determines which sections and patterns you need. Score each dimension 0-2:

| Dimension | 0 (None) | 1 (Some) | 2 (Heavy) |
|---|---|---|---|
| **Tool diversity** | 0-1 tools | 2-5 tools | 6+ tools / multiple MCP servers |
| **Workflow branching** | Linear (A→B→C) | 1-2 decision points | DAG with conditional routing |
| **Input variety** | Single format | 2-3 formats | 5+ formats requiring resolution |
| **Error surface** | Tools rarely fail | Known failure modes | Many tools × many failure modes |
| **Output complexity** | Free-form text | Structured template | Multi-section mandatory format |
| **Domain knowledge** | Self-explanatory | Needs some reference | Deep domain with gotchas |

**Total score → Skill tier:**

| Score | Tier | Sections needed | Target SKILL.md lines |
|---|---|---|---|
| 0-3 | **Minimal** | Frontmatter, steps, output format | 50-150 lines |
| 4-7 | **Standard** | + Prerequisites, tool constraints, error handling, examples | 150-400 lines |
| 8-12 | **Advanced** | + Decision zones, constitutional rules, DAG, references, agent + hooks | 400-600 lines (use references for anything beyond) |

> **Hard rule:** SKILL.md should not exceed ~500 lines. If you're above 600 lines, extract non-routing content to `references/` files. See [Reference File Organization](#reference-file-organization) for extraction patterns.

## Skill Anatomy Reference

### Section Hierarchy

A complete advanced skill uses these sections in this order:

| # | Section | Purpose | Tier | Target lines |
|---|---|---|---|---|
| 1 | Title + objective | One-sentence goal | All | 3-5 |
| 2 | When to Use This Skill | Auto-invoke triggers, entry points table | All | 15-30 |
| 3 | Prerequisites | MCP servers, data access, authentication | Standard+ | 10-20 |
| 4 | Tool Constraints | Idiosyncratic tool behavior and workarounds | Standard+ | 10-25 |
| 5 | Decision Zones | Rules (hardcoded) vs Interpretation (agent-driven) | Advanced | 8-12 |
| 6 | Constitutional Rules | NEVER rules, conflict resolution, evidence requirements | Advanced | 15-25 |
| 7 | Workflow / DAG | Visual flow (ASCII), step numbering | Standard+ | 20-50 |
| 8 | Detailed Steps | Routing stubs with interpretation tables + reference links | All | 100-200 |
| 9 | Output Format | Mandatory output template | All | 20-35 |
| 10 | Error Handling | Error scenario → cause → action table | Standard+ | 15-25 |
| 11 | Common Issues Quick Reference | Compact lookup table (or link to reference) | Standard+ | 2-15 |
| 12 | Examples | 3-5 worked scenarios (or link to reference) | Standard+ | 2-40 |
| 13 | Known Limitations | What the skill cannot do | Standard+ | 3-8 |
| 14 | References | Links to supporting files in `./references/` | Advanced | 5-15 |

### Section Dependency Graph

```
Frontmatter
├── When to Use (defines scope)
│   └── Entry Points Table (defines all input formats)
├── Prerequisites (what must exist before skill runs)
│   └── Tool Constraints (idiosyncratic tool behavior)
├── Decision Zones (separates deterministic from flexible)
│   └── Constitutional Rules (absolute constraints)
├── Workflow DAG (visual flow)
│   └── Detailed Steps (each node in the DAG)
│       ├── SQL / Tool Call patterns (embedded in steps)
│       └── Interpretation Tables (per-step routing)
├── Output Format (mandatory template)
├── Error Handling (cross-cutting)
├── Examples (validates the workflow)
└── References (extends steps without bloating SKILL.md)
```

### Frontmatter Spec

Every SKILL.md starts with YAML frontmatter:

```yaml
---
name: my-skill-name          # lowercase, hyphenated, no spaces
description: >               # 1-2 sentences: what it does + when to use it
  One-sentence summary of what the skill does.
  Use when [specific trigger conditions].
allowed-tools: Read, Grep, Glob, Bash, mcp__server__tool
                              # Space-separated. List EVERY tool referenced in the skill body.
                              # Include optional tools too (document optionality in Prerequisites).
---
```

**Rules:**
- `name` must match the directory name (`skills/<name>/SKILL.md`)
- `description` should include trigger language ("Use when..." / "Use for...")
- `allowed-tools` is exhaustive — if a tool appears anywhere in the skill, it must be listed here
- Optional frontmatter fields: `context: fork` (runs skill in forked context)

---

## Step 1: Define Purpose & Triggers

Write a one-sentence description: `[Action verb] + [domain object] + by [method]. Use when [trigger conditions].`

List auto-invocation triggers grouped by category (natural language + structural triggers like URLs, error messages). If users can invoke with different input formats, add an **Entry Points Table**:

```markdown
| Entry point | Example | What you can extract |
|---|---|---|
| [Format] | `[concrete example]` | [Fields + resolution strategy] |
```

Rules: every row needs a concrete example, name extracted fields, order most→least common.

See [step-patterns.md](./references/step-patterns.md) for detailed trigger patterns, entry point templates, and auto-invocation examples.

---

## Step 2: Map the Workflow DAG

Choose the right topology based on complexity score:

- **Linear** (score 0-3): `Step 1 → Step 2 → Step 3 → Output`
- **Branching** (score 4-7): Decision points route to different paths
- **Full DAG** (score 8-12): Multiple branches, conditional skips, parallel paths

**Step numbering convention:**
- Main steps: integer (0, 1, 2, 3...)
- Sub-steps: letter suffix (2a, 2b)
- Fast variants: `-fast` suffix
- Discovery variants: `-discover` suffix
- Step 0: MCP access verification
- Step 0.5: Optional quick triage

Define input resolution (parse → resolve → confirm), symptom-based routing tables, skip conditions, and `${UPPERCASE}` variable passing between steps.

See [step-patterns.md](./references/step-patterns.md) for input resolution templates, symptom routing tables, DAG examples, and variable passing rules.

---

## Step 3: Write Prerequisites & Tool Constraints

List every MCP server dependency with specific tools:

```markdown
## Prerequisites

1. `[server]` MCP server configured (`server__tool_a`, `server__tool_b` tools)
2. `[server]` MCP server configured (`server__tool_c` tool) — **optional**, [setup]. Works fully without it.
```

For each tool with non-obvious behavior, document: **Constraint** → **Symptom** → **Workaround**.

For skills with many MCP dependencies, add a **Step 0: Verify MCP Access** with a probe table (server → probe call → expected result → if fails).

See [step-patterns.md](./references/step-patterns.md) for access requirements tables, tool constraint templates, and MCP verification patterns.

---

## Step 4: Write Constitutional Rules

Format absolute constraints as "Never X because Y" (5-8 rules max):

```markdown
## Constitutional Rules

1. **Never [action]** — [consequence or reason].
2. **Never [action]** — [consequence or reason].
```

Guidelines: only for catastrophic/systematically-misleading mistakes, must be independently verifiable, include the reason.

Add **Conflict Resolution** tables when multiple data sources can disagree. Add **Decision Zones** separating Rules (hardcoded — SQL, search patterns, decision tables) from Interpretation (agent reasoning — explanations, remediation selection). Add **Evidence Requirements** for skills that produce conclusions.

See [step-patterns.md](./references/step-patterns.md) for conflict resolution templates, decision zone patterns, and evidence standard formats.

---

## Step 5: Write the Steps

Every step follows this skeleton:

```markdown
### Step N: [Action verb] [what]

[1-2 sentence narrative: what this step checks and why.]

> **Requires**: [tool or prerequisite]. If unavailable, skip to Step [M].

#### Procedure
1. [First action — tool call or query]
2. [Second action]

#### Interpretation
| Result | Meaning | Next action |
|---|---|---|
| [Result A] | [What it means] | Proceed to Step [N+1] |
| [Result B] | [What it means] | **Root cause found** — go to remediation |
| No results | [What it means] | [Fallback action] |
```

Rules: every step has narrative + procedure + interpretation table, every result row routes to a next action, tool calls have fallback chains, SQL uses CTEs with `${PARAM}` placeholders (no pseudocode, no explicit `LIMIT`).

See [step-implementation.md](./references/step-implementation.md) for tool call patterns (search, query, two-step), SQL embedding rules, fallback chain templates, and cross-step reference conventions.

---

## Step 6: Write Output Format & Remediation

Start diagnostic skills with a **Status Overview** table:

```markdown
| Check | Status | Finding |
|---|---|---|
| [Check from Step N] | ✅ / ❌ / ⏭ | [One-line summary] |
```

Legend: ✅ = passed, ❌ = failed (root cause), ⏭ = skipped.

Add **Three-Tier Remediation**: Immediate Fix (action/rationale/risks table) → Long-term Improvement (current/improvement/migration/resources table) → Verification Steps. End with **Quick Links** (URLs with `${PARAM}` substitution) and **Follow-up Options** (2-4 concrete next steps).

See [output-patterns.md](./references/output-patterns.md) for full remediation templates, quick links patterns, and follow-up option examples.

---

## Step 7: Add Error Handling & Edge Cases

Create an **Error Catalog** table:

```markdown
| Scenario | Likely cause | Action |
|---|---|---|
| [Tool] returns no rows | [Why] | [Fallback, ask user, or skip] |
| [Tool] returns error: [msg] | [Cause] | [Recovery or workaround] |
| [Query] times out | [Why] | [Narrower query or alternative] |
```

Rules: one row per scenario (not per tool), concrete actions (never just "investigate"), cover both tool errors and logical contradictions, no silent termination.

Add a **Common Issues Quick Reference** (compact issue/symptom/solution table) and document **Graceful Degradation** (what to do when the skill can only partially complete).

See [output-patterns.md](./references/output-patterns.md) for error catalog examples, common issues format, and degraded mode templates.

---

## Step 8: Add Examples & References

Provide 3-5 worked examples: happy path, edge case, and "everything healthy" scenario. Each example: user says → action sequence (5-8 steps referencing workflow step numbers) → result.

### Reference File Organization

For skills with significant supporting material, use a `references/` directory:

```
skills/my-skill/
├── SKILL.md                          # Main skill (all core logic)
└── references/
    ├── common-issues.md              # Domain-specific known problems
    ├── tool-reference.md             # Detailed MCP tool documentation
    └── [domain-topic].md             # Deep-dive on specific subtopic
```

Rules: SKILL.md must be self-contained for routing — references extend, not replace. Link inline: `(reference: [file.md](./references/file.md))`. Each reference = one topic.

### Context Window Budget

**Hard rule:** SKILL.md should not exceed ~500 lines. When an agent loads a skill, the entire SKILL.md goes into context. A 1,400-line skill wastes ~60% of those tokens on implementation details the agent doesn't need until it reaches a specific step.

**Extraction triggers** — any of these signals mean content should move to a reference file:
- A section contains > 50 lines of non-routing content (SQL queries, code search patterns, tool call examples)
- The same query/pattern appears in multiple steps (consolidate into a single reference)
- Content is framework-specific or implementation-detail (probe procedures, fallback chains, worked examples)
- Content is only needed when a specific branch is taken

**What stays inline vs what gets extracted:**

| Keep in SKILL.md (routing logic) | Extract to reference (implementation details) |
|---|---|
| Step purpose (1-2 sentences) | Full SQL queries |
| Interpretation/routing tables (result → meaning → next action) | Code search patterns and parameters |
| Skip conditions and shortcuts | Multi-step tool call procedures |
| Key decision thresholds | Framework-specific check details |
| Constitutional rules and conflict resolution | Worked examples |
| Output format template | Probe/verification procedures |

**Routing stub pattern** — replace extracted sections with a 3-5 line stub:

```markdown
#### 2a. Framework Detection

Run 5 framework detection searches in parallel. See [framework-detection.md](references/framework-detection.md)
for all code search patterns. Interpret: lineage primitives found → Step 3; framework only → Step 2b;
nothing → ask user.
```

The stub preserves: (1) what to do, (2) where the details are, (3) how to route based on results. The agent reads the reference file only when it reaches that step.

### Known Limitations Section

```markdown
## Known Limitations

- [Limitation 1]: [What the skill cannot do and why]
- [Limitation 2]: [What the skill cannot do and workaround if any]
```

Be honest about boundaries. Users trust skills more when limitations are explicit.

---

## Step 9: (Optional) Design an Agent

For skills that will be run autonomously (batch processing, background diagnostics), design an agent wrapper with: YAML frontmatter (name, model, tools, hooks), description sections (examples, startup protocol, execution flow, external actions, reporting, operating rules), 4 lifecycle hooks (PostToolUse, PostToolUseFailure, PreCompact, Stop), statistics collection schema, and batch orchestration via Task tool.

See [agent-design.md](./references/agent-design.md) for agent config template, hook lifecycle table, statistics schema, and batch orchestration patterns.

---

## Templates

Choose a skeleton based on your complexity score and use it as a starting point:

- **Minimal** (score 0-3, ~50 lines): Frontmatter + steps + output format
- **Standard** (score 4-7, ~200 lines): + Prerequisites, routing, error handling, examples
- **Advanced** (score 8-12, ~500 lines): + Decision zones, constitutional rules, full DAG, references, agent hooks

See [skill-skeletons.md](./references/skill-skeletons.md) for complete starter templates for all three tiers.

---

## Anti-Patterns

8 common mistakes when writing skills: (1) Pseudocode SQL, (2) Missing Fallbacks, (3) Ambiguous Routing, (4) Skipping Evidence Requirements, (5) Monolithic SKILL.md, (6) No Decision Zones, (7) Generic Error Handling, (8) Missing Output Template.

See [anti-patterns.md](./references/anti-patterns.md) for Wrong/Right examples and explanations for each.

---

## Quality Checklist

Before considering a skill complete, verify: frontmatter correctness, workflow completeness (narrative + procedure + interpretation for every step), rules & constraints (decision zones, constitutional rules, conflict resolution), output format (template, remediation, quick links), error handling (error catalog, graceful degradation), size & references (under 600 lines, no section > 50 lines inline), and examples.

See [quality-checklist.md](./references/quality-checklist.md) for the full checkbox checklist.

---

## References

- [Step Patterns](./references/step-patterns.md) — Detailed patterns for Steps 1-4: triggers, DAG design, prerequisites, constitutional rules
- [Step Implementation](./references/step-implementation.md) — Step 5: step anatomy, tool call patterns, SQL rules, fallback chains, interpretation tables
- [Output Patterns](./references/output-patterns.md) — Steps 6-7: output format, remediation, error handling, graceful degradation
- [Skill Skeletons](./references/skill-skeletons.md) — Complete starter templates for Minimal, Standard, and Advanced tiers
- [Anti-Patterns](./references/anti-patterns.md) — 8 common mistakes with Wrong/Right examples
- [Agent Design](./references/agent-design.md) — Step 9: agent config, hooks, statistics, batch orchestration
- [Quality Checklist](./references/quality-checklist.md) — Full verification checklist for skill review
