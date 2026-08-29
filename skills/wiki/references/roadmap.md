# Wiki Skill Roadmap

Captured from `incubator/wiki/session-distiller-workflow.md` — the broader vision beyond distillation.

## Current: `distill-session`

Session-end workflow that extracts knowledge into the Obsidian vault with wikilinks for cross-referencing. User is always in the loop to approve/edit/reject.

## Planned: `organize`

An agent that reads recent vault additions and improves the graph:
- Links orphan sections to related notes
- Suggests merges for duplicate or near-duplicate content
- Adds missing tags or index entries
- Could run inline (end of same session) or as a scheduled background agent

## Planned: `recall`

Query the vault to surface relevant prior context:
- Manual invocation: `/wiki:recall <topic>` searches vault by keyword/wikilink
- Automatic context injection: session-start hook that pulls relevant vault entries based on the working directory or active project
- Open question: how much context to inject without overwhelming the session

## Design Decisions Still Open

- Should `organize` run inline after `distill-session` or as a separate pass?
- Should `recall` be automatic (session-start hook) or manual-only?
- What's the right granularity for tags — per-section, per-file, or per-item?
