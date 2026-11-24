---
name: file-review-issue
description: "Generate a standardized GitHub issue (title + body) for a deferred PR review finding (non-critical OR critical when stopping at safety cap). Use when filing tech-debt, functional, or critical issues from Copilot review comments during PR triage."
---
Create a GitHub issue for a finding that came out of a pull request review, using the exact structure below. Keep it concise and factual — one finding per issue (group only tightly-related findings).

## Steps
1. Classify the finding as **tech-debt**, **functional**, or **critical**:
   - **tech-debt** — internal quality, no user-visible behavior change (refactor, naming, duplication, coverage, style).
   - **functional** — extends or changes user-visible behavior beyond the PR's scope (enhancement, extra validation not needed for correctness, UX, out-of-scope edge cases).
   - **critical** — correctness, regression, security vulnerability, data loss risk, or severe bug that was deferred due to safety cap / user decision at human gate.
2. Ensure labels exist (create if missing):
   - For **tech-debt**: `tech-debt` + `pr-review`
   - For **functional**: `enhancement` + `pr-review`
   - For **critical**: `enhancement` + `pr-review`, plus `critical` label if the finding is a security vulnerability, data loss risk, or severe correctness bug
3. Create the issue with this shape:

**Title:** `tech-debt: <short summary>`  _or_  `functional: <short summary>`  _or_  `enhancement: <short summary>` (for critical findings)

**Body:**
```markdown
## Finding
{{what the review flagged, in one or two sentences}}

## Location
`{{path}}`:{{line(s)}}

## Why deferred
Non-critical (tech-debt|functional) — does not affect the correctness or introduce a regression in PR #{{N}}, so it is tracked separately for future work.
_OR (for critical findings):_
Critical finding from PR #{{N}}. Safety cap reached (10 review rounds) / user chose to defer at human gate. Requires follow-up to address correctness/regression/security concern.

## Source
- PR: #{{N}} ({{PR URL}})
- Review comment: {{permalink to the Copilot review comment}}
```

4. **Relate the issue** to the base work item (if provided) and the PR:
   - If a base work item # is provided, add a comment to the base work item: "Related: #{{new-issue}} — {{one-line summary from review finding}}."
   - Add a comment to the PR: "Related: #{{new-issue}} — {{one-line summary from review finding}}."
   - If no base work item is found, relate only to the PR.

## Output
Return the created issue number and URL, plus confirmation of the relation comments posted. Do not modify code or the PR in this prompt — issue creation and relation only.
