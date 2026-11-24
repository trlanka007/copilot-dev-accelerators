---
name: watch-pr-checks
description: "Watch CI checks on a PR after push or creation. Poll until all checks complete, then invoke fix-ci-failures if any check failed. Use after: creating a PR, pushing commits to a branch with an open PR. Loops until all checks pass or max iterations reached."
---

# Watch PR Checks and Auto-Fix Failures

After creating a PR or pushing to a branch, poll GitHub CI checks until they all complete. If any check fails, immediately invoke the `fix-ci-failures` skill to diagnose and fix the problem, then push a fix and repeat.

## When to Use

- Immediately after `gh pr create` or the first `git push` that opens a PR
- After any `git push` to a branch with an open PR (run *after* `update-pr-metadata`)
- When the user asks to "watch CI" or "fix any CI failures"

---

## Procedure

### Step 1 — Confirm a PR Exists

```bash
gh pr view --json number,url,headRefName
```

If no PR is open for the current branch, stop — there are no checks to watch.

---

### Step 2 — Wait for All Checks to Complete

Poll using `gh pr checks` until every check reaches a terminal state (`pass`, `fail`, `skipped`). Do **not** act on in-progress checks.

```bash
# Poll loop: repeat every ~15 seconds until no check is in a pending/queued state
gh pr checks --json name,state,link
```

States to treat as **terminal**: `SUCCESS`, `FAILURE`, `CANCELLED`, `SKIPPED`, `NEUTRAL`, `TIMED_OUT`, `ACTION_REQUIRED`.  
States to treat as **pending**: `IN_PROGRESS`, `QUEUED`, `WAITING`, `PENDING`, `REQUESTED`.

> Tip: `gh pr checks --watch` blocks until all checks complete, but can time out on slow CI. Prefer polling `gh pr checks --json name,state,link` with a sleep between calls and a maximum wait of 15 minutes (60 × 15 s polls).

```bash
# Convenience one-liner — blocks until all checks finish or 10 min timeout
gh pr checks --watch --interval 15 --fail-fast 2>&1 || true
# Then inspect final state:
gh pr checks --json name,state,link
```

---

### Step 3 — Classify Results

After all checks are terminal, classify:

```bash
# Count failures
gh pr checks --json name,state --jq '[.[] | select(.state == "FAILURE")] | length'

# List failing check names and log links
gh pr checks --json name,state,link --jq '.[] | select(.state == "FAILURE") | {name: .name, link: .link}'
```

**If zero failures**: all checks passed. Report success and stop.

**If one or more failures**: proceed to Step 4.

---

### Step 4 — Invoke fix-ci-failures

Read and follow the `fix-ci-failures` skill in full. That skill covers:

1. Identifying the run ID and job ID from the failing check link
2. Downloading failure logs via `gh run view <RUN_ID> --job <JOB_ID> --log-failed` or the API
3. Diagnosing the root cause (lint errors, test failures, build errors, etc.)
4. Applying a targeted fix to the source files
5. Committing and pushing the fix

After pushing the fix, loop back to **Step 2** — wait for CI to re-run and check again.

---

### Step 5 — Iteration Limit

Track the number of fix attempts. After **3 failed fix attempts on the same check**, stop iterating and report:

- Which check is still failing
- The last error extracted from the logs
- What fixes were attempted
- A recommendation for manual investigation

Do not attempt more than 3 iterations on a single failing check — this avoids infinite loops when a failure has a non-obvious root cause.

---

### Step 6 — Final Report

Once all checks pass (or iteration limit reached), report:

| Check | Status | Fix Applied |
|-------|--------|-------------|
| CI / Workflow Lint | ✅ Pass | Removed SC2034 unused shell vars |
| CI / Markdown Lint | ✅ Pass | — |
| … | … | … |

Include the PR URL and confirm whether the PR is ready to merge.

---

## Decision Tree

```
PR pushed / created
       │
       ▼
Wait for all checks to finish
       │
       ├─ All pass ──────────────────────────► Done ✅
       │
       └─ Any failed (attempt ≤ 3)
                │
                ▼
         invoke fix-ci-failures
                │
                ▼
         commit + push fix
                │
                ▼
         Wait for re-run
                │
                ├─ All pass ──────────────────► Done ✅
                │
                └─ Still failing (attempt > 3) ─► Report + stop ⚠️
```

---

## Notes

- Always run `update-pr-metadata` *before* this skill on the same push — checks are triggered by the push, and the PR description should be current.
- The `gh pr checks --watch` command requires the `gh` CLI v2.30+.
- `CANCELLED` checks that share a run with a re-triggered run are expected — ignore them and focus on the latest run per check name.
- If a check is `TIMED_OUT` or `ACTION_REQUIRED`, treat it as a failure and attempt the same fix-ci-failures flow.
