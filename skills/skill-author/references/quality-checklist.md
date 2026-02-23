# Quality Checklist

Before considering a skill complete, verify each item:

## Frontmatter
- [ ] `name` matches directory name and is lowercase-hyphenated
- [ ] `description` includes both what the skill does and when to invoke it
- [ ] `allowed-tools` lists every tool referenced anywhere in the skill body
- [ ] Optional tools are marked as optional in Prerequisites

## Workflow
- [ ] Every step has: narrative preamble, procedure, interpretation table
- [ ] Every interpretation table row has a routing decision (no ambiguous results)
- [ ] Every tool call has at least one fallback (or is documented as optional)
- [ ] Parameter placeholders use `${UPPERCASE}` consistently
- [ ] SQL queries use real table names, real column names, CTEs, and no pseudocode
- [ ] Step numbering follows convention (integers for main, letters for sub-steps)

## Rules & Constraints
- [ ] Decision zones separate Rules from Interpretation (if score >= 8)
- [ ] Constitutional rules are 5-8 items, each with a reason (if score >= 8)
- [ ] Conflict resolution table exists (if multiple data sources used)
- [ ] Tool constraints documented for every tool with non-obvious behavior

## Output
- [ ] Output format section exists with a concrete template
- [ ] All template sections are mandatory (never omit, use ⏭ for skipped)
- [ ] Remediation includes immediate fix, long-term improvement, and verification steps
- [ ] Quick links and follow-up options are present

## Error Handling
- [ ] Error handling table covers every tool x major failure mode
- [ ] No error causes silent termination — all surface to the user
- [ ] Common issues quick reference exists (if domain-specific)
- [ ] Graceful degradation documented for optional tool failures

## Size & References
- [ ] SKILL.md is under 600 lines (target: 400-500 for advanced skills)
- [ ] No single section exceeds 50 lines of non-routing content inline
- [ ] Each extracted section has a routing stub with interpretation table + reference link
- [ ] Reference files exist for deep-dive content (SQL queries, code search patterns, examples)
- [ ] Reference links use relative paths: `./references/file.md`

## Examples & Docs
- [ ] 3-5 worked examples covering happy path, edge case, and "all clear" scenarios (inline or in `references/examples.md`)
- [ ] Known limitations section is honest about boundaries

## Agent (if applicable)
- [ ] Agent descriptor has YAML frontmatter with tools, model, hooks
- [ ] All 4 lifecycle hooks implemented (PostToolUse, PostToolUseFailure, PreCompact, Stop)
- [ ] Stop hook prevents premature termination (checks for conclusion keywords)
- [ ] PreCompact hook reconstructs state for context recovery
- [ ] Statistics schema documented with controlled enums
- [ ] Operating rules list binding constraints (one task per instance, evidence-only, etc.)
