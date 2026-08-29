---
name: wiki
description: >
  Manage the Obsidian knowledge vault. Subcommands: distill-session (capture session knowledge),
  help (show usage). Future: recall, organize. Invoke as `/wiki <subcommand>`.
allowed-tools: Read, Edit, Write, AskUserQuestion
---

# Wiki

Manage the user's Obsidian knowledge vault at `/Users/daoudasakho/src/notes/`.

## Instructions

Parse the user's subcommand and execute the corresponding operation.

### Argument Handling

- `/wiki` or `/wiki help` → run help
- `/wiki distill-session` → run distill-session
- Any unrecognized subcommand → run help

---

## Subcommand: `distill-session`

Scan the current session for all knowledge gained and distill it into the Obsidian vault.

### The Knowledge Vault

The vault uses a four-bucket system. Every piece of knowledge belongs in exactly one bucket:

| Bucket | File | What goes here | Format conventions |
|---|---|---|---|
| **Facts** | `Facts.md` | Reference data, links, metric names, env vars, team/system ownership | Tables for reference data, bullet lists for links |
| **Procedures** | `Procedures.md` | Step-by-step execution paths, SOPs, playbooks, how-to guides | Numbered steps, code blocks for commands, troubleshooting sections |
| **Concepts** | `Concepts.md` | Mental models, principles, frameworks, architecture, strategic alignment | Bullet lists for principles, bold for key terms, headers for hierarchy |
| **Questions** | `Questions.md` | Unanswered items — the knowledge frontier | Never delete; mark answered and move answer to proper bucket |

### Constitutional Rules

1. **Never delete questions** — Mark as answered and move the answer to the appropriate bucket.
2. **Never duplicate code blocks** — Reference the source (file path, PR link, doc URL) instead.
3. **Never add verbose prose** — Each bucket section must be scannable in <2 minutes. Strip filler.
4. **Never overwrite existing content** — Merge into existing sections. Read the file first.
5. **Never guess bucket placement** — If unsure, present the item and ask the user which bucket.
6. **Always add wikilinks** — When a distilled item relates to a term, system, or concept that has (or should have) its own section elsewhere in the vault, link it with `[[Term]]`. This weaves the vault into a connected graph over time.

### Workflow

```
Step 1: Extract    →  Scan session for knowledge items
Step 2: Categorize →  Assign each item to a bucket
Step 3: Present    →  Show the user what was captured, grouped by bucket
Step 4: Approve    →  User reviews, edits, approves (or removes items)
Step 5: Merge      →  Read existing files, integrate approved items, add wikilinks
Step 6: Confirm    →  Show what was written and where
```

#### Step 1: Extract Knowledge

Scan the full conversation for knowledge gained during this session. Capture everything — let the user filter in Step 4.

**What to look for:**
- Concepts learned or clarified (mental models, frameworks, how systems relate)
- Facts discovered (URLs, metric names, system names, ownership, config values)
- Procedures established (steps taken to accomplish something, debugging flows, setup guides)
- Questions raised but not answered (or partially answered)
- Questions that WERE answered during the session (mark with the answer)
- References to external resources (docs, dashboards, Slack threads, PRs, presentations)
- Decisions made and their rationale
- Corrections or clarifications about how things work

**What to exclude:**
- Transient tool calls and file paths browsed (unless the path itself is a useful reference)
- Claude's internal reasoning or approach discussion
- Back-and-forth about how to use Claude Code itself
- Content that is already in the vault (check by reading files in Step 5)

#### Step 2: Categorize

For each extracted item, apply the bucket test:

1. "Is this actionable steps someone could follow?" → **Procedures**
2. "Is this a mental model, principle, or framework?" → **Concepts**
3. "Is this reference data I'd look up?" → **Facts**
4. "Is this still unanswered or partially answered?" → **Questions**

#### Step 3: Present to User

Display the captured knowledge grouped by bucket:

```
## Session Distillation

### Facts (→ Facts.md)
- [Item 1 — distilled to vault format, with [[wikilinks]]]
- [Item 2]

### Procedures (→ Procedures.md)
- [Item 1 — distilled to vault format]

### Concepts (→ Concepts.md)
- [Item 1 — distilled to vault format]

### Questions (→ Questions.md)
- [Item 1]

### No changes
[List any buckets with nothing to add]
```

**Formatting rules for presented items:**
- Show items ALREADY distilled to the format they'd appear in the vault
- For Facts: use tables if reference data, bullets if links/notes
- For Procedures: use numbered steps, include code blocks if relevant
- For Concepts: use bold for key terms, bullets for principles
- For Questions: prefix with `Q:` and note if partially answered
- Include where in the existing file structure the item would be merged (e.g., "under ## Deployments")
- Include `[[wikilinks]]` to related terms, systems, or concepts

After presenting, ask: **"Approve as-is, or would you like to edit/remove any items?"**

#### Step 4: Approve

Wait for user response.

| Response | Action |
|---|---|
| Approval ("looks good", "approve", "yes", "go ahead") | Proceed to Step 5 |
| Edits ("change X to Y", "remove item 3", "move X to Facts instead") | Apply edits, re-present, ask again |
| Rejection ("skip", "nothing to save", "cancel") | End — write nothing |

#### Step 5: Merge into Vault

For each bucket with approved items:

1. **Read** the existing bucket file to understand current structure and sections.
2. **Find the right section** — match by topic/header. If the topic already has a section, integrate there. If not, create a new section in the appropriate place.
3. **Merge intelligently:**
   - Add new bullets to existing lists (don't duplicate)
   - Add new rows to existing tables
   - Add new subsections under existing headers
   - Create new top-level sections only for genuinely new topics
4. **Add `[[wikilinks]]`** — link any term that has (or should eventually have) its own section in the vault. Prefer linking on first mention within a section.
5. **Use Edit tool** for surgical integration into existing sections.
6. **Use Write tool** only if the file doesn't exist yet.

**Merge rules:**
- Preserve existing formatting and style of each file
- Match indentation, bullet style, and header levels to surrounding content
- Add references as links with one-line descriptions, not full content
- For Questions.md: append new questions at the end; if answering an existing question, strike it through (`~~Q: ...~~`) and note where the answer was filed

#### Step 6: Confirm

After writing, display a summary:

```
## Distillation Complete

| Bucket | Items added | Section |
|---|---|---|
| Facts.md | N | [section name(s)] |
| Procedures.md | N | [section name(s)] |
| Concepts.md | N | [section name(s)] |
| Questions.md | N | [new / answered] |
```

### Error Handling

| Scenario | Action |
|---|---|
| Bucket file doesn't exist | Create it with a `# [Bucket Name]` header |
| No knowledge found in session | Tell the user: "Nothing to distill from this session." End gracefully. |
| User rejects all items | Acknowledge and end. Don't write anything. |
| Merge conflict (can't find right section) | Present the item and ask user where it should go |
| Item fits multiple buckets | Ask the user which bucket, or split into multiple items |

---

## Subcommand: `help`

Print the following help text exactly, formatted as a code block:

```
wiki — Obsidian knowledge vault management

USAGE
  /wiki distill-session    Distill this session's knowledge into the vault
  /wiki help               Show this help text

DESCRIPTION
  Manages an Obsidian-compatible knowledge vault organized into four buckets:
  Facts, Procedures, Concepts, and Questions.

  /wiki distill-session — Scans the conversation for reusable knowledge,
                          categorizes it, presents for approval, then merges
                          into the vault with [[wikilinks]] for cross-referencing.

FUTURE SUBCOMMANDS (not yet implemented)
  /wiki recall <topic>     Retrieve vault entries matching a topic
  /wiki organize           Re-link and re-tag vault entries
```
