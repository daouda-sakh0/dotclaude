# Step Implementation Patterns

Detailed patterns for Step 5: writing individual steps with tool calls, SQL queries, fallback chains, and interpretation tables.

---

## Step Anatomy

Every step follows a consistent skeleton:

```markdown
### Step N: [Action verb] [what]

[1-2 sentence narrative: what this step checks and why it matters.]

> **Requires**: [tool or prerequisite]. If unavailable, skip to Step [M].

#### Procedure

1. [First action — tool call or query]
2. [Second action]
3. [Interpretation]

#### Interpretation

| Result | Meaning | Next action |
|---|---|---|
| [Result A] | [What it means] | Proceed to Step [N+1] |
| [Result B] | [What it means] | **Root cause found** — go to Step [remediation] |
| No results | [What it means] | [Fallback action or next step] |
```

**Rules:**
- Every step starts with a narrative preamble (context for the agent)
- Requirements callout uses blockquote with bold **Requires**
- Procedure is an ordered list of concrete actions
- Interpretation table maps every possible result to a next action
- Every result row includes a routing decision (never leave routing ambiguous)

---

## Tool Call Patterns

### Search pattern (code search, grep):
```markdown
Search for [what] in [scope]:
`mcp__code-search__search_code(query="[pattern] -f:([Tt]est|BUILD)", lang="[language]", output_mode="files_with_matches")`

Exclude test files and BUILD manifests to reduce noise.
```

### Query pattern (BigQuery, API):
````markdown
Query [what]:
```sql
WITH config AS (
  SELECT '${PARAM_1}' AS filter_1,
         '${PARAM_2}' AS filter_2
),
raw_data AS (
  SELECT field_a, field_b, timestamp
  FROM `project.dataset.table`, config
  WHERE field_a = config.filter_1
    AND _TABLE_SUFFIX BETWEEN
      FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY))
      AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
),
parsed AS (
  SELECT *,
         JSON_EXTRACT_SCALAR(payload, '$.key') AS extracted_field
  FROM raw_data
)
SELECT * FROM parsed
WHERE extracted_field IS NOT NULL
ORDER BY timestamp DESC
```
````

### Two-step tool pattern (text2sql + execute):
```markdown
1. Generate SQL: `mcp__text2sql-mcp__text2sql(question="[natural language question]", cluster="[cluster]")`
2. Execute the returned SQL: `mcp__bigquery-mcp__execute_query(query=<SQL from step 1>)`
```

---

## SQL Embedding Rules

When embedding SQL queries in a skill:

1. **Always use CTEs** (`WITH ... AS`) for readability — never deeply nested subqueries
2. **Never use explicit `LIMIT`** if the BigQuery MCP auto-appends one — use `ROW_NUMBER()` in a CTE instead
3. **Parameter injection** via `${UPPERCASE}` placeholders — never hardcode values
4. **Date ranges** use `_TABLE_SUFFIX` with `FORMAT_DATE` for partition pruning
5. **JSON extraction** uses `JSON_EXTRACT_SCALAR` or `JSON_VALUE` (not regex on JSON strings)
6. **Array flattening** uses `CROSS JOIN UNNEST(array_field) AS alias`
7. **Comments** explain non-obvious logic inline (especially partition filters and CASE expressions)

---

## Fallback Chains

When a step depends on a tool that may be unavailable:

```markdown
#### Fallback chain for [what you're checking]:

1. **Primary** ([tool name] — authoritative): `[tool call]`
   → If unavailable or fails:
2. **Secondary** ([tool name] — discovery): `[tool call]`
   → If unavailable or fails:
3. **Tertiary** ([tool name] — scalable fallback): `[tool call]`

Use the first tool that succeeds. State which tool was used in the evidence.
```

**Rules:**
- Order from most authoritative to most available
- Each level explains why it's less preferred than the one above
- The agent must state which level it used (for evidence tracing)

---

## Interpretation Tables

After every tool call or query, provide a result → meaning → action table:

```markdown
| Result | Meaning | Action |
|---|---|---|
| Rows returned with [condition] | [Domain interpretation] | Proceed to Step [N] |
| Rows returned without [condition] | [Domain interpretation] | **Root cause**: [cause]. Go to remediation. |
| No rows returned | [What absence means] | [Next step or fallback] |
| Error: [specific error] | [What went wrong] | [Recovery action] |
```

**Rules:**
- Cover every realistic outcome (including "no results" and "error")
- Never leave a result without a routing decision
- Bold the text **Root cause** when a result is conclusive

---

## Cross-Step References

When a later step uses results from an earlier step:

```markdown
Using `${FIELD_NAME}` from Step [N] (extracted via [tool/query]):
```

This keeps the agent oriented and provides traceability.
