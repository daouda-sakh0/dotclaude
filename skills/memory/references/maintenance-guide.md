# Memory Maintenance Guide

Procedures for decay, merge, prune, and index rebuild.

## Decay Formula

```
effective_importance = base_importance - (days_since_last_access / 30)
```

- `base_importance`: The `importance` field in frontmatter (1-10)
- `days_since_last_access`: Days between now and `last_accessed` timestamp
- A memory with importance 7 last accessed 210 days ago: `7 - (210/30) = 0` → eviction candidate

## Eviction

### Criteria
- `effective_importance <= 0`

### Procedure
1. List all eviction candidates with their title, type, tags, and effective importance.
2. Present the list to the user.
3. For each candidate, the user can:
   - **Delete**: Remove the file and its index entries.
   - **Boost**: Increase `importance` to keep it alive.
   - **Skip**: Leave it for next maintenance cycle.
4. Never auto-delete without user confirmation.

## Merging

### When to Merge
- Two or more memories share 3+ tags
- Memories cover the same topic from different sessions
- One memory is a superset of another

### Procedure
1. Identify merge candidates (high tag overlap).
2. Present pairs/groups to the user with content previews.
3. If approved:
   - Create a new merged memory with combined content (distilled, not concatenated).
   - Use the higher `importance` of the two.
   - Union the tag sets.
   - Set `created` to the earlier date, `last_accessed` to now.
   - Delete the original files.
   - Update the index.

## Index Rebuild

### When to Rebuild
- After any save, delete, or merge operation (the skill does this automatically)
- During `/memory maintain` as a consistency check
- If the index seems out of sync

### Procedure
1. Scan all `.md` files in `archival/episodic/`, `archival/semantic/`, `archival/procedural/`.
2. Parse YAML frontmatter from each file.
3. Build data structures:
   - `tag_map`: tag → list of (file_path, importance)
   - `type_map`: type → list of (file_path, title)
4. Generate `archival/index.md`:

```markdown
# Archival Memory Index

> Auto-generated tag-to-file lookup. Rebuilt by `/memory maintain`.

## Tag Index

- **tag-name**: [title](type/filename.md) (importance: X), [title2](type/filename2.md) (importance: Y)

## By Type

### Episodic
- [Title](episodic/filename.md) — importance: X, tags: a, b, c

### Semantic
- [Title](semantic/filename.md) — importance: X, tags: a, b, c

### Procedural
- [Title](procedural/filename.md) — importance: X, tags: a, b, c

## Stats
- Total memories: N
- Last rebuilt: YYYY-MM-DDTHH:MM:SSZ
```

## Core Memory Audit

### Line Count Check
1. Count lines in MEMORY.md.
2. If over 180 lines:
   - Identify sections that could move to archival.
   - Create archival memories for detailed content.
   - Replace detailed sections in MEMORY.md with brief pointers.
3. Target: keep MEMORY.md at 100-150 lines for healthy headroom.

### Staleness Check
- Review "Active Projects" — remove completed ones.
- Review "Conventions" — verify they're still accurate.
- Review "Key Paths" — verify paths still exist.

## Maintenance Report Format

```
## Memory Maintenance Report

### Decay Analysis
- Memories checked: N
- Healthy (importance > 5): N
- At risk (importance 1-5): N
- Eviction candidates (importance <= 0): N

### Actions Taken
- Evicted: N memories (with titles)
- Merged: N pairs (with titles)
- Index rebuilt: yes/no

### Core Memory
- MEMORY.md: N/200 lines (X% used)
- Status: healthy / needs trimming

### Recommendations
- [Any suggested actions]
```
