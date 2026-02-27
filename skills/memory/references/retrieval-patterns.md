# Memory Retrieval Patterns

How to find and rank relevant memories without embeddings.

## Retrieval Algorithm

### Step 1: Parse Query

Extract keywords from the user's recall topic. Normalize to lowercase.

```
Input: "styx workflow debugging"
Keywords: ["styx", "workflow", "debugging"]
```

### Step 2: Tag Match (Primary)

1. Read `archival/index.md`.
2. For each tag in the index, check if any query keyword matches or is a substring.
3. Collect all files referenced by matching tags.
4. Score each file: `tag_overlap_count * 10 + importance`.
5. Sort descending by score.

### Step 3: Full-Text Fallback

If Step 2 yields fewer than 3 results:

1. Use Grep to search all `.md` files in `archival/` for each keyword.
2. Score files by number of keyword hits.
3. Merge with tag match results, deduplicating by file path.

### Step 4: Read Candidates

1. Select top 3–5 files by combined score.
2. Read each file's full content.
3. Verify relevance — discard false positives.

### Step 5: Update Access Metadata

For each retrieved (actually used) memory:

1. Update `last_accessed` to current UTC timestamp.
2. Increment `access_count` by 1.
3. Write the updated frontmatter back to the file.

### Step 6: Present Results

Format output as:

```
## Recalled Memories

### [Title] (importance: X, type: Y)
Source: archival/type/filename.md
Tags: tag1, tag2, tag3

[Content summary or full content if short]
```

## Scoring Examples

Query: "styx debugging"

| File | Tag matches | Importance | Score |
|---|---|---|---|
| mem_001.md | styx, debugging (2) | 7 | 27 |
| mem_002.md | styx (1) | 5 | 15 |
| mem_003.md | debugging (1) | 8 | 18 |

Result order: mem_001, mem_003, mem_002

## Edge Cases

- **No matches at all**: Report "No relevant memories found for [topic]." Suggest saving relevant knowledge with `/memory save`.
- **Too many matches**: Cap at 5 files. Prefer higher importance.
- **Ambiguous query**: Ask the user to narrow the topic, or show top 3 with brief summaries.
