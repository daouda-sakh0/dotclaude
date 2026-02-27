# Memory Unit Schema

Each archival memory is a standalone Markdown file with YAML frontmatter.

## File Format

```markdown
---
id: mem_YYYYMMDD_HHMMSS_XXXX
type: episodic | semantic | procedural
tags: [tag1, tag2, tag3]
created: YYYY-MM-DDTHH:MM:SSZ
last_accessed: YYYY-MM-DDTHH:MM:SSZ
access_count: 1
importance: 7
---
# Title

Content here — distilled insight, not raw transcript.
```

## Field Definitions

| Field | Type | Required | Description |
|---|---|---|---|
| `id` | string | yes | Unique ID: `mem_YYYYMMDD_HHMMSS_XXXX` (XXXX = 4 random hex) |
| `type` | enum | yes | One of: `episodic`, `semantic`, `procedural` |
| `tags` | string[] | yes | 2-6 lowercase kebab-case tags for index lookup |
| `created` | ISO 8601 | yes | Creation timestamp in UTC |
| `last_accessed` | ISO 8601 | yes | Last retrieval timestamp (initially same as created) |
| `access_count` | integer | yes | Number of times retrieved (starts at 1) |
| `importance` | integer | yes | Base importance score, 1-10 |

## Type Guidelines

### `episodic` — What happened
- Interaction histories and decisions
- Debugging sessions and their outcomes
- Significant conversations or context
- Example: "Debugged styx workflow timeout — root cause was missing partition"

### `semantic` — What is true
- Project structures and architectures
- Codebase facts (key files, patterns, conventions)
- Domain knowledge and definitions
- Example: "data-pipeline-x uses Flyte with 3 tasks: extract, transform, load"

### `procedural` — How to do it
- Debugging strategies and playbooks
- Workflow recipes (how to deploy X, how to debug Y)
- Tool usage patterns
- Example: "To debug Styx failures: check instances → get logs → check lineage"

## Importance Scale

| Score | Meaning | Example |
|---|---|---|
| 1-2 | Minor, transient | One-off workaround |
| 3-4 | Useful but narrow | Project-specific fact |
| 5-6 | Broadly useful | Common debugging pattern |
| 7-8 | Important | User preference or major convention |
| 9-10 | Critical | Core architectural decision |

## Tag Conventions

- Lowercase kebab-case: `styx-debugging`, `python-testing`
- Use specific terms over generic: `flyte-logs` over `logs`
- Include tool/system names: `bigquery`, `styx`, `gantry`
- Include action verbs where relevant: `debugging`, `deploying`, `configuring`
- 2-6 tags per memory — enough for discovery, not so many as to dilute

## File Location

Place files in the subdirectory matching their type:
- `archival/episodic/mem_20260226_143022_a7f3.md`
- `archival/semantic/mem_20260226_150000_b2c1.md`
- `archival/procedural/mem_20260226_160000_d4e5.md`

## Content Guidelines

- **Distill, don't dump.** Each memory should be a self-contained insight, not a conversation transcript.
- **Be specific.** Include file paths, command names, error messages when relevant.
- **Be actionable.** A reader should be able to use this memory without additional context.
- **Keep it short.** Most memories should be 5-20 lines of content (excluding frontmatter).
