# Output & Error Handling Patterns

Detailed patterns for Steps 6-7: output format, remediation, error handling, and graceful degradation.

---

## Status Overview Table Pattern

For diagnostic or analytical skills, start the output with a status table:

```markdown
## Output Format

Present results in this exact format. Never omit or reorder sections.

### Status Overview

| Check | Status | Finding |
|---|---|---|
| [Check from Step 1] | ✅ / ❌ / ⏭ | [One-line summary of finding] |
| [Check from Step 2] | ✅ / ❌ / ⏭ | [One-line summary of finding] |
| [Check from Step N] | ✅ / ❌ / ⏭ | [One-line summary of finding] |

Legend: ✅ = passed, ❌ = failed (root cause), ⏭ = skipped (not applicable or prerequisite not met)
```

---

## Three-Tier Remediation Pattern

When the skill identifies problems and recommends fixes:

```markdown
### Root Cause & Remediation

**Root cause**: [Evidence-backed statement citing step and data]

#### Immediate Fix

| Action | Rationale | Risks |
|---|---|---|
| [Concrete action] | [Why it works] | [What could break] |

#### Long-term Improvement

| Current state | Improvement | Migration path | Resources |
|---|---|---|---|
| [What exists today] | [Better approach] | [How to get there] | [Links/docs] |

If the immediate fix follows best practices, state: "No separate long-term action needed — the immediate fix follows current best practices."

#### Verification Steps

1. [Re-trigger / re-run the process]
2. [Re-run the diagnostic query from Step [N]]
3. [Check the downstream system]
4. [Confirm in the UI/dashboard — note propagation delays]
```

---

## Quick Links Template

```markdown
### Quick Links

- **[System 1]**: [URL with ${PARAM} substitution]
- **[System 2]**: [URL with ${PARAM} substitution]
- **[Documentation]**: [Relevant docs URL]
- **[Support channel]**: [Slack/email/office hours]
```

---

## Follow-Up Options Pattern

End with 2-4 concrete next steps the user can take:

```markdown
### Follow-up Options

1. [Action the user can request] (e.g., "Debug another workflow in the same component")
2. [Action the user can request] (e.g., "Generate a fix PR for this issue")
3. [Action the user can request] (e.g., "Check lineage health across all component workflows")
```

---

## Error Catalog Pattern

Create a comprehensive table of everything that can go wrong:

```markdown
## Error Handling

| Scenario | Likely cause | Action |
|---|---|---|
| [Tool] returns no rows | [Why this happens] | [What to do — fallback, ask user, or skip] |
| [Tool] returns error: [message] | [Root cause of error] | [Recovery or workaround] |
| [Query] times out | [Why — large table, missing partition filter] | [Narrower query or alternative] |
| User provides [ambiguous input] | [Why it's ambiguous] | [How to resolve — ask or infer] |
| [Step N] contradicts [Step M] | [Why sources disagree] | [Conflict resolution rule] |
```

**Rules:**
- One row per scenario (not per tool — a tool may have multiple failure modes)
- Every row must have a concrete action (never "investigate further" without specifics)
- Include both tool errors and logical contradictions
- No error should cause the skill to terminate silently — always surface to the user

---

## Common Issues Quick Reference

For domain-specific skills with known recurring problems:

```markdown
## Common Issues Quick Reference

| Issue | Symptom | Solution |
|---|---|---|
| [Known issue 1] | [How user experiences it] | [Fix in 1-2 sentences] |
| [Known issue 2] | [How user experiences it] | [Fix in 1-2 sentences] |
```

This is a compact lookup table — no rationale column. Designed for quick pattern matching, not deep diagnosis.

---

## Graceful Degradation

Document what happens when the skill can only partially complete:

```markdown
### Degraded Mode

If [critical tool/data] is unavailable:
1. Complete steps [X, Y, Z] which don't require it
2. Mark affected steps as ⏭ in the Status Overview
3. Note: "[Specific capability] requires [tool/data]. Results are partial."
4. Still provide the output format with available information
```
