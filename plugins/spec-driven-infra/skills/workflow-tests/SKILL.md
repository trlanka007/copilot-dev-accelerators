---
name: workflow-tests
description: Add and enforce workflow regression tests and path-aware mock gates for GitHub Actions workflows. Use when adding/modifying workflows or workflow-related scripts to ensure each workflow has corresponding tests and CI runs only relevant tests.
---

# Workflow Tests Skill

## Purpose

Ensure every workflow/action change has appropriate regression tests and that PR checks run only relevant workflow tests based on changed files.

## When to use

- New workflow is added under `.github/workflows/`
- Existing workflow is modified
- Scripts or source paths consumed by workflows are modified
- CI policy needs stronger gate coverage for workflow contracts

## Required artifacts

1. Add/update workflow test file under `tests/workflow_gates/`.
2. Add/update mapping in `tests/workflow_gates/workflow_test_registry.json`:
   - `workflows`: workflow file -> test file(s)
   - `code_to_tests`: source path pattern -> relevant test file(s)
3. Ensure CI includes:
   - workflow coverage validation (`validate_workflow_test_coverage.py`)
   - selective test selection (`select_workflow_tests.py`)

## Rules

- No workflow in `.github/workflows/*.yml` may exist without mapped tests.
- Workflow tests must validate behavior contracts (triggers, job dependencies, gating steps, safety conditions).
- Selective execution should run only relevant tests for changed workflow/code paths in PRs.
- If no relevant workflow changes are detected, skip workflow regression tests cleanly.

## Validation commands

```bash
python .specify/scripts/python/validate_workflow_test_coverage.py
python .specify/scripts/python/select_workflow_tests.py
pytest -q tests/workflow_gates
```

## Checklist

- [ ] Workflow tests created/updated
- [ ] Registry mappings updated
- [ ] CI gate still passes
- [ ] Spec task IDs recorded for traceability (QG-005)
