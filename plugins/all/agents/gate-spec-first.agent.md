---
name: "gate-spec-first"
description: "Enforce QG-005: validate that all code changes trace to task IDs in specs/*/tasks.md. Run before creating PRs or after pushing commits."
---

# Spec-First Guard Agent (QG-005)

Enforces the spec-first guard: every code change must be traceable to a task ID in a spec's `tasks.md`.

## When to Invoke

- **Before creating a PR** — validates the branch has proper task traceability
- **After pushing commits** — checks that new changes reference task IDs
- **On demand** — audits a branch or set of files for compliance

## User Input

```text
$ARGUMENTS
```

Consider the user input before proceeding (if not empty). The user may specify a branch, file list, or ask to fix violations.

## Procedure

### 1. Identify Changed Files

Get the list of files changed on the current branch relative to `main`:

```bash
git diff --name-only origin/main...HEAD
```

If no changes, report "No changes to validate" and stop.

### 2. Classify Files as Exempt or Non-Exempt

**Exempt paths** (no task ID required):
- `.specify/*` — framework internals
- `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md` — generated instruction files
- `specs/*` — spec artifacts themselves (spec.md, design.md, tasks.md, etc.)
- `*.md` in repo root — project documentation (README, CONTRIBUTING, PLANS, etc.)
- `.github/pull_request_template.md` — PR template
- `.github/dependabot.yml` — dependency automation

Report the classification:
```
Exempt files (N):
  - path/to/file
Non-exempt files (M):
  - path/to/file
```

If all files are exempt, report **PASS** and stop.

### 3. Scan for Task ID References

Search for task IDs (`T###` pattern, e.g., T001, T031) in:
1. **Commit messages** on the branch: `git log --format='%B' origin/main..HEAD`
2. **PR body** (if an open PR exists): `gh pr view --json body`

Collect all unique task IDs found.

If no task IDs found, report **FAIL** with remediation instructions (see step 5).

### 4. Validate Task IDs Exist

For each referenced task ID, verify it exists in at least one `specs/*/tasks.md` file:

```bash
grep -r 'T031' specs/*/tasks.md
```

Classify each ID as:
- **Valid** — found in a tasks.md
- **Missing** — referenced but not in any tasks.md

If zero valid task IDs, report **FAIL**.

### 5. Report Results

**On PASS:**
```
✅ QG-005 Spec-First Check: PASS
   Valid task IDs: T022, T031
   Non-exempt files: 3
```

**On FAIL:**
```
❌ QG-005 Spec-First Check: FAIL

Non-exempt files changed without task traceability:
  - infra/bicep/modules/openai.bicep
  - infra/bicep/main.bicep

Remediation options:
  1. Add a task to the relevant spec's tasks.md BEFORE the change
  2. For hotfixes: add a retroactive task marked [X] immediately
  3. Reference the task ID in your commit message or PR body
     Example: "fix: remove gpt-realtime deployment (T031)"
```

### 6. Auto-Fix Mode (if user requests)

If the user asks to fix violations:

1. Identify the most relevant spec directory for the changed files
2. Determine the next available task ID (scan existing tasks.md for highest T### number)
3. Propose a retroactive task entry:
   ```
   - [X] T032 [P] <description of what was changed> (retroactive — PR #NN)
   ```
4. After user approval, append the task to `tasks.md`
5. Update the dependency notes if needed
6. Stage and commit the tasks.md change
7. Re-run validation to confirm PASS

## Rules

- Never skip validation for non-exempt files — QG-005 has no discretionary override
- Retroactive tasks (marked `[X]`) are acceptable for hotfixes but should be the exception
- Task IDs must actually exist in `specs/*/tasks.md` — referencing non-existent IDs is a FAIL
- The agent does NOT modify code files — it only validates and updates tasks.md
- Always use the update-pr-metadata skill after fixing violations on a PR branch
