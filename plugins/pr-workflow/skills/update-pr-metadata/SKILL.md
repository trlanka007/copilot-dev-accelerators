---
name: update-pr-metadata
description: "Update pull request title and description after pushing commits. Use when: pushing to a branch with an open PR, after committing work, when PR description is stale or outdated. Triggers: git push, commit, PR update."
---

# Update PR Metadata

Synchronize an open PR's title and description with the actual changes on the branch. Run this after every push to a branch that has an open PR.

## When to Use

- After `git push` to a branch with an open PR
- When the PR title/description no longer reflects the current scope of changes
- When significant new commits have been added to an existing PR branch

## Procedure

### 1. Detect Open PR

```bash
gh pr list --head "$(git branch --show-current)" --state open --json number,title,body,labels --limit 1
```

If no open PR exists for the current branch, **stop** — nothing to update.

### 2. Gather Change Context

Collect all context needed to write an accurate PR description:

1. **Commit log since base**:
   ```bash
   gh pr view <number> --json commits --jq '.commits[].messageHeadline'
   ```

2. **Changed files summary**:
   ```bash
   gh pr diff <number> --stat
   ```

3. **Spec context** (if spec directories were touched):
   - Read any modified `specs/*/spec.md` frontmatter for ID, title, status
   - Read any modified `specs/*/tasks.md` for completion counts
   - Count `[X]` vs `[ ]` in each tasks.md

4. **Bicep validation** (if `infra/bicep/` was touched):
   - Note whether `az bicep build` passes

### 3. Generate PR Metadata

**Title format**: `<type>: <concise summary of all changes>`

- Use conventional commit type: `feat`, `fix`, `chore`, `docs`
- If multiple specs are touched, list the spec IDs: `feat: 2605-001 + 2605-002 — <summary>`
- Keep under 72 characters

**Body format** (follow the repo's PR template):

```markdown
## Summary

<2-3 sentence overview of total scope>

### <Spec ID> — <Title> (**<status>** — N/M tasks)

- Bullet points of key deliverables
- Reference files created/modified

### <Repeat for each spec touched>

## Release note

<One paragraph for CHANGELOG — what a downstream consumer needs to know>
```

**Rules**:
- Include task completion counts from tasks.md
- List Bicep modules if IaC was modified
- List workflow files if CI/CD was modified
- Mention constitution/quality gate changes if applicable

### 4. Apply Update

Use the GitHub MCP tool or `gh` CLI:

```bash
gh pr edit <number> --title "<new title>" --body "<new body>"
```

### 5. Preserve Labels

Do NOT modify existing PR labels. Labels (`release:patch`, `release:minor`, `release:major`) are set deliberately and should only be changed if the user explicitly requests it.

### 6. Report

After updating, confirm:
- PR number and URL
- Old title → New title (if changed)
- Key sections added/updated in the description
