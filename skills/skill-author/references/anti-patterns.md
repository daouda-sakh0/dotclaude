# Anti-Patterns

Common mistakes when writing skills, with Wrong/Right examples and explanations.

---

## 1. Pseudocode SQL

**Wrong:**
```sql
-- Query the lineage logs for recent entries
SELECT * FROM lineage_logs WHERE workflow = ?
```

**Right:**
```sql
WITH config AS (
  SELECT '${WORKFLOW_ID}' AS workflow_filter
)
SELECT log_timestamp, workflow_id, endpoint_id, status
FROM `project.dataset.lineage_publish_logs`, config
WHERE workflow_id = config.workflow_filter
  AND _TABLE_SUFFIX BETWEEN
    FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY))
    AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
ORDER BY log_timestamp DESC
```

**Why:** Pseudocode SQL forces the agent to improvise queries at runtime — violating the Rules zone. Real SQL with real table names, real column names, and real partition filters produces deterministic, reliable results.

---

## 2. Missing Fallbacks

**Wrong:**
```markdown
### Step 3: Check endpoint
Query the endpoint API for details.
```

**Right:**
```markdown
### Step 3: Check endpoint

#### Fallback chain:
1. **Primary**: `mcp__greg__get_dataset(id="${ENDPOINT_ID}")` — authoritative
2. **Secondary**: `mcp__bigquery__execute_query(...)` — mart_endpoints table
3. **Tertiary**: Ask user to provide endpoint details manually
```

**Why:** MCP tools fail (auth, timeout, server down). Without fallbacks, the skill halts at the first failure instead of gracefully degrading.

---

## 3. Ambiguous Routing

**Wrong:**
```markdown
If the results look concerning, investigate further.
```

**Right:**
```markdown
| Result | Meaning | Action |
|---|---|---|
| 0 rows returned | No lineage published | Root cause found — go to Step 5 |
| Rows with status = 'SUCCESS' | Lineage published successfully | Proceed to Step 4 |
| Rows with status = 'FAILED' | Publish attempted but failed | Check error message in payload column |
```

**Why:** "Look concerning" is subjective. The agent needs mechanical routing rules, not vibes. Every result must map to exactly one next action.

---

## 4. Skipping Evidence Requirements

**Wrong:**
```markdown
The workflow is probably missing the lineage hook. Add it.
```

**Right:**
```markdown
**Root cause**: Missing lineage hook. Evidence: Step 2a code search for `wrap_luigi` in `${REPO}` returned 0 matches (searched via `mcp__code-search__count_matches`). Step 2b confirmed `import luigi` is used directly without the wrapper.

**Fix**: Replace `import luigi` with `from spotify_luigi import wrap_luigi` and call `wrap_luigi()` before task execution.
```

**Why:** "Probably" isn't a diagnosis. Every root cause must cite the specific step, tool, and result that supports it. This is a constitutional rule for a reason.

---

## 5. Monolithic SKILL.md

**Wrong:** A 1,400-line SKILL.md with framework-specific troubleshooting guides, SQL queries, tool documentation, and external links all inline.

**Right:** A focused SKILL.md (~400-600 lines) with routing stubs and supporting material in `references/`:
- `references/queries.md` for SQL queries and tool call patterns
- `references/framework-detection.md` for code search patterns
- `references/common-issues.md` for framework-specific problems
- `references/documentation-links.md` for external URLs

**Extraction checklist:**
- [ ] No single section exceeds 50 lines of non-routing content inline
- [ ] Every SQL query > 10 lines is in `references/queries.md`
- [ ] Every extracted section has a 3-5 line routing stub with interpretation table + reference link
- [ ] All reference files are linked from the References section at the bottom of SKILL.md

**Why:** Agents load the entire SKILL.md into context. A 1,400-line skill wastes ~60% of tokens on implementation details. Move deep-dive content to references that are loaded on demand — each reference is only read when the agent reaches that step.

---

## 6. No Decision Zones

**Wrong:** Mixing hardcoded queries with instructions like "use your judgment to write a query."

**Right:** Explicitly separate Rules (SQL queries, search patterns, decision tables — never modify) from Interpretation (explaining results, selecting remediation, adapting to user context — always tailor).

**Why:** Without Decision Zones, agents either follow everything rigidly (bad UX) or improvise everything (unreliable). The separation gives agents freedom where it helps and constraints where it matters.

---

## 7. Generic Error Handling

**Wrong:**
```markdown
If something goes wrong, try again or ask the user.
```

**Right:**
```markdown
| Scenario | Likely cause | Action |
|---|---|---|
| BigQuery returns "Access Denied" | Service account lacks dataViewer role | BLOCKED — report missing permission |
| Code search returns 0 matches | Repo not indexed or wrong org | Try GHE search as fallback |
| Styx returns empty workflow list | Component doesn't use Styx | Ask user how workflow is triggered |
```

**Why:** Every tool has specific failure modes. Generic "try again" wastes time. Specific error → cause → action tables let the agent recover immediately.

---

## 8. Missing Output Template

**Wrong:** No output format section — agent decides how to present results each time.

**Right:** A mandatory output template with sections that must always appear (even if marked ⏭ for skipped steps).

**Why:** Consistent output format lets users know what to expect, makes results comparable across runs, and prevents agents from omitting inconvenient findings.
