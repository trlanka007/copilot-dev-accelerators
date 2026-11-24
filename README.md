# copilot-dev-accelerators

A GitHub Copilot plugin marketplace.

```shell
copilot plugin marketplace add trlanka007/copilot-dev-accelerators
copilot plugin install all@copilot-dev-accelerators
```

| Plugin | Contents |
| --- | --- |
| `all` | Everything below in one install |
| `pr-workflow` | Agents: pr-review-triage, pr-review-triage-cloud, review-classifier. Skills: fix-ci-failures, sync-pr-description, update-pr-metadata, watch-pr-checks, triage-observation, file-review-issue |
| `spec-driven-infra` | Agents: infra-spec, gate-spec-first. Skills: infra-bicep, infra-spec, workflow-tests |
| `guardrails` | Hook: asks before committing/pushing directly to `main` |

## Maintaining

Edit components under `plugins/pr-workflow`, `plugins/spec-driven-infra`, or `plugins/guardrails`, then run `scripts/sync-all.ps1` to regenerate `plugins/all`.
