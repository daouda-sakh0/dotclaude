# Session Distiller → Wiki Workflow

## Goal

Build an end-of-session automation that captures knowledge from Claude Code sessions into a persistent, Obsidian-compatible wiki.

## Context

- **Memory system**: Currently saves to `~/.wiki/` (migrated from `~/.claude/projects/`)
- **Session distiller skill**: Lives on work computer's dotclaude — to be synced to this repo as a follow-up
- **Notes directory**: `~/notes/` — opened in Obsidian on work computer, serves as the knowledge base

## Desired Workflow

1. **Distill** — At session end, invoke the `session-distiller` skill. It reads the conversation, extracts key decisions, learnings, and context, and writes a structured note to `~/notes/`.
2. **Organize** — An agent reads the latest note and integrates it into the wiki: links it to related notes, updates an index, adds tags.
3. **Retrieve** — In future sessions, Claude can query the wiki to surface relevant prior context.

## Open Questions

- Should the distiller write directly to `~/notes/` or to a staging area (e.g., `~/notes/inbox/`) for the organizer agent to process?
- What structure should individual notes follow? (Zettelkasten-style, project-based, chronological?)
- Should the organizer run inline (end of same session) or as a background/scheduled agent?
- How does retrieval work? Manual invocation vs. automatic context injection at session start?

## Next Steps

- [ ] Add `session-distiller` skill from work computer to this repo under `skills/session-distiller/`
- [ ] Define note template/schema for distilled sessions
- [ ] Build organizer agent logic
- [ ] Wire retrieval into session start hook or a `/recall` command
