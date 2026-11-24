---
name: triage-observation
description: "Triage GitHub issues labeled 'observation'. Use when: reviewing an observation issue, determining if it's a bug or enhancement, performing root cause analysis, proposing fix options, and producing a spec-kit design + implementation plan for the chosen option."
argument-hint: "Provide the issue number or URL to triage"
---

# Triage Observation

## When to Use

- A GitHub issue is tagged with the `observation` label
- You need to determine whether it's a `bug` or an `enhancement`
- You need root cause analysis and a design plan before implementation

## Procedure

### Phase 0: Branch Setup

> **Before making any file changes in the repo**, create a branch from the latest remote main.

0. Run `git checkout main && git pull origin main`
1. Create a branch:
   - Bug: `fix/<issue-slug>` (e.g., `fix/sync-candidate-push`)
   - Enhancement: `feat/<issue-slug>` (e.g., `feat/add-pagination`)
2. All subsequent file changes (specs, docs, code) happen on this branch

### Phase 1: Review

1. Read the issue fully (title, body, comments, labels, linked PRs)
2. Identify what was observed and under what conditions
3. Gather relevant code context — trace the behavior described in the observation to its source

### Phase 2: Root Cause Analysis

4. Determine the root cause:
   - What code/config/process produces this behavior?
   - Is it a defect (unintended behavior) or a gap (missing behavior / improvement opportunity)?
5. Present findings to the owner with a clear determination:
   - **Bug** — the system behaves contrary to its documented intent or acceptance criteria
   - **Enhancement** — the system behaves as designed but the design should evolve

### Phase 3: Classification (requires owner approval)

6. Propose the label change: `observation` → `bug` or `observation` → `enhancement`
7. **Wait for explicit owner approval** before applying the label via GitHub API
8. On approval, update the issue labels (remove `observation`, add `bug` or `enhancement`)

### Phase 4: Propose Fix Options

9. Present 2–3 high-level fix/implementation options conversationally:
   - Each option: one-sentence summary + trade-offs (effort, risk, scope)
   - Do NOT write these into the issue — present them in conversation only
10. **Wait for the owner to pick an option**

### Phase 5: Design (spec-kit style)

11. Once the owner selects an option, produce a `design.md` following the spec-kit design template:
    - Summary (requirement + chosen approach)
    - Technical Context
    - Existing System Findings (claim → evidence → verification)
    - Data Model changes (if any)
    - API Contract changes (if any)
    - Project Structure impact
    - Verification Strategy
    - Implementation Planning (risks, milestone shape)

### Phase 6: Implementation Plan (spec-kit style)

12. Produce an `implementation-plan.md` following the spec-kit template:
    - Purpose / Big Picture
    - Context and Orientation (files, modules, data flows)
    - Milestones (independently verifiable increments)
    - Concrete Steps (exact file changes, commands)
    - Validation and Acceptance (commands, expected signals)
    - Interfaces and Dependencies

### Phase 7: Summarize on Issue

13. Post a summary comment on the GitHub issue containing:
    - Root cause (1–2 sentences)
    - Classification applied (`bug` or `enhancement`)
    - Chosen fix option (1 sentence)
    - Link to the `specs/<issue-slug>/` folder on the feature branch
14. Present the design + plan to the owner for review in conversation
15. **Stop here.** Implementation is triggered separately by the owner saying "implement" or "execute the plan".

### Phase 8: Implementation (triggered by owner)

> Owner triggers this by saying "implement", "execute the plan", "go ahead", or similar.

16. Load implementation context:
    - **REQUIRED**: Read `specs/<issue-slug>/design.md` for tech decisions, verification strategy, project structure
    - **REQUIRED**: Read `specs/<issue-slug>/implementation-plan.md` for milestones and concrete steps
    - Cross-reference with workspace constitution rules (docs sync, shared scripts, candidate branch sync)

17. Execute implementation phase-by-phase:
    - **Phase-by-phase execution**: Complete each milestone before moving to the next
    - **Tests before code** (when applicable): Write/update tests for the behavior being changed
    - **Core changes**: Implement the fix/feature per the concrete steps
    - **Validation checkpoints**: After each milestone, verify expected success signals from the plan

18. Living plan maintenance:
    - Update `Progress` checkboxes as steps complete
    - Record unexpected findings in `Surprises & Discoveries`
    - Record approach changes in `Decision Log`
    - Keep the plan restartable by a new contributor from repo state alone

19. Review gates after each milestone:
    - **Spec compliance**: Confirm changes map to the design and don't introduce unrequested scope
    - **Code quality**: Check correctness, type safety, error handling, consistency with existing patterns
    - **Constitution compliance**: Enforce docs sync, shared scripts single-source-of-truth, candidate branch integrity

20. Completion validation:
    - Run the exact validation commands from the plan
    - Record evidence (command output, test results) in the plan's Evidence Ledger
    - Verify no breaking changes to existing behavior
    - Confirm all acceptance criteria from the original issue are satisfied

21. Commit and push:
    - Stage all changes (specs, code, docs)
    - Commit with conventional commit message referencing the issue (e.g., `fix: resolve sync failure #42`)
    - Push the feature branch

### Phase 9: Post-Implementation Documentation Update

> This phase runs immediately after implementation (Phase 8) completes.

22. Review the implementation diff to identify what changed (files, behavior, workflows, scripts)
23. Scan workspace documentation (`docs/`, `docs/how-to/`, `README.md`) for references that are now stale:
    - Script names, inline code blocks, manual commands, or workflow step names that no longer match
    - Architecture descriptions that no longer reflect reality
    - Operational guides with outdated procedures
24. Update all affected documentation to reflect the new implementation
25. If the change affects content classification (panel-only vs candidate-facing), verify `sync-candidate-branch.yml` still strips correctly

### Phase 10: PR

26. Create a pull request targeting `main`:
    - Title: conventional commit style (e.g., `fix: resolve candidate branch sync failure`)
    - Body: reference the issue, summarize the change, link to the spec folder
    - Apply relevant labels
27. **Wait for CI and owner approval before merging**

## Output Artifacts

| Artifact | Location | Purpose |
|----------|----------|---------|
| `design.md` | `specs/<issue-slug>/design.md` on feature branch | Technical design for the change |
| `implementation-plan.md` | `specs/<issue-slug>/implementation-plan.md` on feature branch | Living execution plan |
| Issue comment | Posted on the GitHub issue | Summary of root cause, classification, and plan status |

## Decision Points (requires human input)

- Phase 3: Bug vs Enhancement classification → wait for approval
- Phase 4: Fix option selection → wait for owner's pick
- Phase 7: Plan approval → wait before implementing
- Phase 8: Triggered explicitly by owner ("implement", "execute the plan", "go ahead")
- Phase 10: PR merge → wait for CI green + owner confirmation

## References

- Design template: [spec-kit design-template](https://github.com/github/spec-kit/blob/main/templates/plan-template.md)
- Implementation plan template: [spec-kit tasks-template](https://github.com/github/spec-kit/blob/main/templates/tasks-template.md)
