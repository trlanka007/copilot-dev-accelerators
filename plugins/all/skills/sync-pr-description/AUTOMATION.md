# PR Title & Description Automation Options

This repository provides multiple ways to ensure PR titles and descriptions stay in sync with implementation changes.

## Quick Comparison

| Approach | Runs On | Enforcement | Setup Effort | Team-Wide |
|----------|---------|-------------|--------------|-----------|
| **GitHub Actions - Warning** | Every push to PR | Soft (comment) | Low (enable workflow) | ✅ Yes |
| **GitHub Actions - Auto-update** | Every push to PR | Automatic | Low (enable workflow) | ✅ Yes |
| **Git Hook (pre-push)** | Before local push | Soft (prompt) | Medium (each dev) | ❌ No |
| **Manual (skill only)** | On demand | Manual | None | ✅ Yes (skill shared) |

## Option 1: GitHub Actions - Warning (Recommended)

**File:** `.github/workflows/check-pr-description.yml`

**How it works:**
- Triggers on every push to a PR
- Analyzes commit history for pivot signals (`fix: actually`, `refactor:`, `best-effort`, etc.)
- Posts a warning comment if description may be stale
- Non-blocking (doesn't prevent merge)

**Enable:**
```bash
# Already enabled if workflow file exists
git add .github/workflows/check-pr-description.yml
git commit -m "feat: add PR description staleness checker"
```

**Pros:**
- ✅ Team-wide (no local setup)
- ✅ Visible (comment on PR)
- ✅ Non-disruptive (warning only)

**Cons:**
- ⚠️ Not enforced (can be ignored)
- ⚠️ Basic heuristics (may miss subtle mismatches)

---

## Option 2: GitHub Actions - Auto-Update

**File:** `.github/workflows/auto-update-pr-description.yml.example`

**How it works:**
- Same trigger as Option 1
- Automatically appends commit summary to PR description
- Overwrites description without asking

**Enable:**
```bash
# Rename to enable
mv .github/workflows/auto-update-pr-description.yml.example \
   .github/workflows/auto-update-pr-description.yml

git add .github/workflows/auto-update-pr-description.yml
git commit -m "feat: enable auto PR description updates"
```

**Pros:**
- ✅ Zero friction (fully automatic)
- ✅ Always up-to-date

**Cons:**
- ⚠️ Can overwrite manual edits
- ⚠️ May append noise if commits are messy
- ⚠️ Less control over final description

**When to use:** Small teams with trust in commit messages, or ephemeral PRs.

---

## Option 3: Git Hook (Pre-Push)

**File:** `.github/hooks/pre-push.ps1`

**How it works:**
- Runs locally before `git push`
- Checks for pivot signals in recent commits
- Prompts developer to update PR or continue

**Enable (each developer):**
```bash
# Copy to git hooks
cp .github/hooks/pre-push.ps1 .git/hooks/pre-push

# Make executable (Unix/macOS)
chmod +x .git/hooks/pre-push

# Windows: PowerShell Core required, or set execution policy
```

**Pros:**
- ✅ Immediate feedback (before push)
- ✅ Developer owns decision

**Cons:**
- ⚠️ Not team-wide (each dev must set up)
- ⚠️ Easy to bypass (`git push --no-verify`)
- ⚠️ Requires PowerShell 7+ on all platforms

**When to use:** Developers who prefer local checks, or as a complement to GitHub Actions.

---

## Option 4: Manual (Skill Only)

**File:** `.github/skills/sync-pr-description/SKILL.md`

**How it works:**
- Invoked manually by developer or during PR review triage
- Full analysis and title/description rewrite

**Use:**
```
# In Copilot chat
@github Use the sync-pr-description skill on PR #123

# Or during review triage (automatic if mismatch detected)
```

**Pros:**
- ✅ High quality (full analysis, not heuristics)
- ✅ Team-shared (in repo)
- ✅ Non-invasive (on demand)

**Cons:**
- ⚠️ Not automatic (must remember to invoke)
- ⚠️ Relies on human discipline

**When to use:** Always available as a fallback; complements automated checks.

---

## Recommendation

**For this repo:** Start with **Option 3** (pre-push hook) + **Option 4** (manual skill).

**Why:**
- Low friction: hook prompts only when needed, manual skill available on demand
- Developer control: each dev decides when to update
- High quality: manual skill does thorough analysis, not heuristics
- No noise: no automated comments on PRs

**Enable now (each developer):**
```bash
# Copy pre-push hook to git hooks
cp .github/hooks/pre-push.ps1 .git/hooks/pre-push

# Make executable (Unix/macOS)
chmod +x .git/hooks/pre-push

# Windows: PowerShell Core required for .ps1 scripts
# Or convert to batch/bash if needed
```

**Future consideration:**
If manual discipline isn't working and PR descriptions are frequently stale, see **issue #200** for instructions on enabling automated workflows (warning mode or auto-update mode).

---

## Maintenance

**Tuning heuristics:**
Edit `.github/workflows/check-pr-description.yml` line 39:
```yaml
PIVOT_SIGNALS="fix: actually|refactor:|revert|best-effort|make.*optional"
```

Add or remove patterns to match your team's commit conventions.

**Disabling:**
```bash
# Rename to disable
mv .github/workflows/check-pr-description.yml \
   .github/workflows/check-pr-description.yml.disabled
```
