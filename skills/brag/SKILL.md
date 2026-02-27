# Weekly Brag Doc Generator

Generate a weekly brag doc entry from archival memories. Run on Fridays to capture the work week's highlights and impact.

## Instructions

You are generating a weekly brag document entry for Daouda Sakho. The entry should emphasize **impact** — what was achieved, what it unblocked, what problem it solved — not just activity.

### Paths

- **Core Memory**: `~/.claude/projects/-Users-daoudasakho/memory/MEMORY.md`
- **Archival Root**: `~/.claude/projects/-Users-daoudasakho/memory/archival/`
- **Archival Index**: `~/.claude/projects/-Users-daoudasakho/memory/archival/index.md`
- **Brag Doc**: Google Doc ID `1NVES2t2mGkXpJmc13UBMfRyDa1rDDCTWLduNn5azLXw`

### Step 1: Determine the Work Week

Calculate the current week's Monday and Friday dates. Use the ISO week number for the "Week N" label.

- If today is Friday, use this week (Monday through today).
- If today is not Friday, use the most recent completed work week.

### Step 2: Gather Memories from This Week

1. Read `MEMORY.md` to understand active projects and recent context.
2. Read `archival/index.md` to get the full list of memory files.
3. Read every memory file in `archival/episodic/`, `archival/semantic/`, and `archival/procedural/`.
4. Filter to memories whose `created` date in frontmatter falls within the Monday-Friday window from Step 1.
5. If no memories match the date range, tell the user and stop.

### Step 3: Extract Highlights

For each matching memory, extract:

- **What was done**: The concrete action or deliverable.
- **Impact**: Why it mattered — what it unblocked, fixed, improved, or de-risked.
- **Project context**: Which project or initiative it relates to.
- **Status**: Whether the work has shipped/landed or is still in progress. Distinguish between "done and deployed" vs "code written, not yet shipped". Frame unshipped work accurately (e.g., "Developed..." or "Prepared..." rather than "Resolved..." or "Reduced...").

**Filtering rules:**
- **Exclude personal tooling work**: This brag doc is for the user's manager. Omit work on personal developer environment setup, dotclaude config, Claude Code skills/memory system, local tooling, or MCP auth diagnostics — unless it directly produced a team-visible deliverable.
- **Exclude purely procedural memories**: Memories about "how to do X" (e.g., GHE token setup, build commands) are reference material, not accomplishments.

Group highlights by theme if there are 4+ items. Suggested themes:
- Incident Response
- Engineering / Code Changes
- Tooling & Infrastructure
- Data & Analytics
- Support & Collaboration
- Investigation & Root Cause Analysis

If fewer than 4 items, skip theming and present as a flat list.

### Step 4: Format the Entry

Produce a brag doc entry matching this exact format:

```
## Week {N}: Monday {Month} {day}{ordinal} - Friday {Month} {day}{ordinal}

* {Highlight 1}
* {Highlight 2}
* {Highlight 3}
```

**Writing guidelines:**
- Aim for 3-5 bullets total per week. Consolidate related work into single bullets.
- Each bullet should be ONE line — short and punchy. No sub-bullets unless linking a PR.
- Lead with impact or outcome, not the activity.
- Be honest about shipped vs. unshipped work. Use "Developed..." or "Prepared..." for unshipped code, not "Resolved..." or "Reduced..." which imply production impact.
- Use active voice and specific nouns (service names, ticket IDs).
- Include PR links inline when available, not as sub-bullets.

### Step 5: Present to User

Output the formatted entry to the terminal. Prefix it with:

```
--- Brag Doc Entry (copy to your brag doc) ---
```

And suffix with:

```
---
Brag doc: https://docs.google.com/document/d/1NVES2t2mGkXpJmc13UBMfRyDa1rDDCTWLduNn5azLXw/edit
```

## Known Limitations

- Only captures work that was saved to archival memory during the week. Sessions where `/memory save` was not run will have gaps.
- Cannot access external systems (PRs, Jira, Slack) directly — relies on what was captured in memories.
- Date filtering uses the `created` field in memory frontmatter, which reflects when the memory was saved, not necessarily when the work happened.
