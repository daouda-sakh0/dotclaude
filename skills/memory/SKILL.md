# Memory Management Skill

Persistent memory system with save, recall, maintain, and status operations.

## Instructions

You are managing a 3-tier persistent memory system. Parse the user's subcommand and execute the corresponding operation.

### Paths

- **Core Memory**: `~/.claude/projects/-Users-daoudasakho/memory/MEMORY.md`
- **Archival Root**: `~/.claude/projects/-Users-daoudasakho/memory/archival/`
- **Index**: `~/.claude/projects/-Users-daoudasakho/memory/archival/index.md`
- **Schema Reference**: Read `references/memory-schema.md` for memory unit format
- **Retrieval Reference**: Read `references/retrieval-patterns.md` for search algorithm
- **Maintenance Reference**: Read `references/maintenance-guide.md` for decay/merge/prune

### Subcommand: `save`

**Usage**: `/memory:save` or `/memory:save [brief description]`

1. Reflect on the current session. Identify insights worth persisting:
   - Stable user preferences or conventions
   - Architectural decisions or project structures
   - Debugging solutions with reusable patterns
   - Facts about codebases, tools, or workflows
2. For each insight, classify its type:
   - `episodic` — interaction histories, decisions made, context of events
   - `semantic` — project facts, codebase knowledge, domain concepts
   - `procedural` — debugging strategies, workflows, how-to knowledge
3. Read `references/memory-schema.md` for the exact file format.
4. Generate a unique ID: `mem_YYYYMMDD_HHMMSS_XXXX` (XXXX = 4 random hex chars).
5. Write the memory file to the appropriate subdirectory under `archival/`.
6. Update the index: read `archival/index.md`, add the new memory's tags and file path.
7. Consider whether Core Memory (MEMORY.md) needs updating — add a brief pointer if the new memory relates to an active project or convention.
8. Report what was saved, with the file path and tags.
9. Compact the session by running `/compact` to free up context space now that key insights have been persisted.

**Important**: Distill insights — don't dump raw conversation. Each memory should be a self-contained, reusable piece of knowledge.

### Subcommand: `recall`

**Usage**: `/memory:recall [topic]` or `/memory:recall [topic1, topic2]`

1. Read `references/retrieval-patterns.md` for the full algorithm.
2. Extract keywords from the topic query.
3. **Tag match**: Read `archival/index.md`. Find entries whose tags match query keywords. Rank by tag overlap count, then by importance.
4. **Full-text fallback**: If fewer than 3 tag matches, use Grep to search across all `.md` files in `archival/` for query keywords.
5. Read the top 3–5 candidate files.
6. For each retrieved memory, update its `last_accessed` timestamp and increment `access_count`.
7. Present the relevant memories to the user in a concise summary format, noting the source file for each.

### Subcommand: `maintain`

**Usage**: `/memory:maintain`

1. Read `references/maintenance-guide.md` for full procedures.
2. **Decay check**: For each memory file, compute effective importance:
   ```
   effective_importance = base_importance - (days_since_last_access / 30)
   ```
3. **Eviction candidates**: List memories with effective_importance <= 0. Ask user for confirmation before deleting.
4. **Merge candidates**: Identify memories with highly overlapping tags that could be consolidated. Suggest merges to the user.
5. **Rebuild index**: Scan all `.md` files in `archival/episodic/`, `archival/semantic/`, `archival/procedural/`. Parse frontmatter. Regenerate `archival/index.md` with:
   - Tag index (tag → file list)
   - By-type listings
   - Updated stats
6. **Core Memory audit**: Check MEMORY.md line count. If over 180 lines, suggest moving detailed sections to archival.
7. Report summary: memories checked, evicted, merged, index entries.

### Subcommand: `status`

**Usage**: `/memory:status`

1. Count files in each archival subdirectory (`episodic/`, `semantic/`, `procedural/`).
2. Count total lines in MEMORY.md, report usage vs 200-line limit.
3. Read `archival/index.md` and report unique tag count.
4. Find the most-accessed and least-accessed memories (by `access_count`).
5. Find memories at risk of eviction (effective_importance < 2).
6. Present a clean status report.

### Subcommand: `help`

**Usage**: `/memory:help`

Print the following help text exactly, formatted as a code block:

```
memory — Persistent memory management

USAGE
  /memory:save [description]   Save insights from this session to memory
  /memory:recall <topic>       Retrieve memories matching a topic
  /memory:maintain             Run decay, merge, and index maintenance
  /memory:status               Show memory system stats and health
  /memory:help                 Show this help text

DESCRIPTION
  Manages a 3-tier archival memory system (episodic, semantic, procedural).
  Memories persist across sessions and are indexed by tags for fast retrieval.

  /memory:save     — Reflects on the current session, distills reusable
                     insights, writes them to archival storage, updates the
                     index, and compacts the session context.

  /memory:recall   — Searches the tag index and full-text for matching
                     memories. Returns the top 3–5 results with source paths.

  /memory:maintain — Applies importance decay, suggests merges for overlapping
                     memories, and rebuilds the index. Audits MEMORY.md size.

  /memory:status   — Counts files per tier, reports MEMORY.md line usage,
                     lists most/least accessed memories and eviction risks.
```

## Argument Handling

- `/memory` or `/memory:status` → run status
- `/memory:save` or `/memory:save [description]` → run save
- `/memory:recall [topic]` → run recall
- `/memory:maintain` → run maintain
- `/memory:help` → run help
- Any unrecognized subcommand → run help
