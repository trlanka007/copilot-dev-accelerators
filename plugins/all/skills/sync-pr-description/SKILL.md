---
name: sync-pr-description
description: "Analyze PR commits to detect title/description drift and generate updated title and description that accurately reflect final implementation. Use when invoked by agent orchestration or explicitly requested."
argument-hint: "PR number (optional — defaults to active PR)"
---

# Sync PR Title & Description

## Purpose

Updates PR titles and descriptions to match the actual implementation in the commit history. Detects pivots, approach changes, and missing context that would confuse reviewers.

## Procedure

### 1. Identify Target PR

- If PR number provided, use it
- Otherwise, use the active/current PR from workspace context
- Confirm PR is still OPEN (don't update closed/merged PRs)

### 2. Gather Current State

Fetch from GitHub API (not local git history):
- Current PR description (title + body)
- All commits on the PR (chronological order, not squashed)
- Changed files (additions, modifications, deletions)
- PR labels and metadata

**Why API, not local?** The PR may have been force-pushed, rebased, or amended. API shows the actual PR state, not local branch history.

### 3. Analyze Commit Evolution

Read commit messages and changed files to understand the implementation journey:

**Look for pivot signals:**
- Reverted changes (commits that undo earlier work)
- Refactor commits that change approach without changing functionality
- "fix:" commits addressing issues introduced earlier in the PR
- Comments like "actually implement X" or "correct approach for Y"
- Pattern: early commits try approach A, later commits switch to approach B

**Extract current reality:**
- What files were ultimately changed?
- What approach is the *final* implementation using? (last commit wins)
- Were any claims in the original description invalidated by later commits?

### 4. Compare Title & Description to Implementation

**Common title mismatches:**
- Title references an approach that was changed (e.g., "Add retry logic" but final implementation uses circuit breaker)
- Title scope is narrower than actual changes (e.g., "Fix API bug" but also refactored database layer)
- Title mentions files/features that were removed in later commits
- Title doesn't follow conventional commit format when it should (e.g., lacks `feat:`, `fix:`, `docs:` prefix)

**Common description mismatches:**
- Description says "throws on failure" but code uses best-effort + warnings
- Description references files/functions that were removed in later commits
- Description claims X is critical but final implementation makes X optional
- Description missing context added in later commits (new checks, fallback paths, related changes)

**Flag these contradictions:**
- Approach claims (hard-fail vs best-effort, critical vs optional, required vs nice-to-have)
- File/line references that are stale
- Behavioral claims that don't match final code
- Missing rationale for non-obvious choices made in later commits
- Title not reflecting the actual scope or approach of the final implementation

### 5. Generate Updated Title & Description

**Title guidelines:**
- Use conventional commit format if the repo uses it (e.g., `feat:`, `fix:`, `docs:`, `chore:`)
- Capture the *actual* scope and approach of the final implementation
- Keep concise (50-72 characters ideal, max ~80)
- If the PR pivoted from the original approach, use the final approach in the title
- Examples:
  - Original: "Add retry logic to API" → Final: "feat: add circuit breaker pattern to API"
  - Original: "Fix database bug" → Final: "fix(db): resolve connection leak and add health checks"

**Description updates:**

**Keep from original:**
- Problem statement (unless invalidated)
- Root cause analysis (unless corrected)
- Testing instructions (unless changed)
- Issue references and links

**Update/add:**
- Solution section: reflect *current* approach, not original attempt
- Changes section: list files/areas that *actually* changed in final form
- Rationale: explain any pivots ("Initially tried X, switched to Y because...")
- Testing/validation: update if approach changed
- Impact: revise if scope changed

**Structure (adapt to context):**
```markdown
## Problem
[Keep original unless invalidated]

## Root Cause
[Keep original unless corrected by later commits]

## Solution
[CRITICAL: Must match final implementation, not first attempt]
- Describe current approach (as of HEAD commit)
- If pivoted from original plan, explain why ("[Initially X, changed to Y because...]")
- Highlight non-obvious choices made during implementation

## Changes
- List files/modules that *actually* changed
- Reference commit SHAs for significant pivots
- Include related changes (docs, workflows, config)

## Testing
[Update if approach changed]

## Impact
[Update if scope changed]
```

### 6. Apply Update

**Validation before applying:**
- Read the generated title and description back to yourself — do they contradict any commit?
- Check every "X is Y" claim against final code — is it true?
- Verify file/line references point to code that exists
- Ensure title accurately summarizes the final implementation scope

**Apply via GitHub CLI:**
```bash
# Write new description to temp file (BOM-less UTF-8 for gh CLI)
$tempFile = "$env:TEMP\pr-body-update.txt"
[System.IO.File]::WriteAllText($tempFile, $newDescription, (New-Object System.Text.UTF8Encoding($false)))

# Update PR title and description
gh pr edit <number> --title "new title here" --body-file $tempFile
```

**Confirm success:**
- Verify the PR page shows the updated title and description
- Spot-check a few claims from the new description against the code
- Confirm title matches conventional commit format (if applicable)

### 7. Document Change

If the title/description update addressed specific review comments:
- Reply to those review comments: "Fixed — PR title/description updated to reflect [X]"
- Resolve the review threads if the mismatch was the only issue

**Note:** PR titles and descriptions are ephemeral metadata (not tech-debt). Never create a GitHub issue for "update PR title/description" — fix it immediately instead.

## Anti-Patterns to Avoid

❌ **Don't create an issue for "update PR title/description"** — it's not tech-debt, fix it now  
❌ **Don't just append to the description** — replace outdated sections wholesale  
❌ **Don't rely on local git log** — use GitHub API to see actual PR commits  
❌ **Don't preserve claims that were invalidated** — remove/correct them  
❌ **Don't update titles/descriptions on closed/merged PRs** — they're historical artifacts
❌ **Don't skip title updates if only description changed** — check both every time

## Output

**Conversational update:**
- "Updated PR #X title and description to reflect [key change]" (or just "description" if title was unchanged)
- Summarize what was corrected (1-2 sentences)

**GitHub evidence:**
- PR title and description show the update timestamp
- Title and description match final implementation
- No contradictions between title/description and code
