---
name: infra-spec
description: Orchestrate a reusable Azure environment IaC spec workflow (Bicep): discovery -> specify -> design -> tasks.
---


## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

Use this command when the user asks for reusable Azure infrastructure setup using Bicep.

### Step 1: Discovery First (mandatory)

Before creating or modifying any spec artifact:

1. Inspect the repository for existing infrastructure conventions and constraints.
2. Identify expected environment topology (dev/test/prod or equivalent), naming patterns, and shared tag requirements.
3. Identify target deployment scope assumptions (`subscription` or `resourceGroup`) and major Azure dependency expectations.
4. Summarize known constraints and unresolved gaps.

If critical context is missing, continue with explicit assumptions and mark only high-impact unknowns as `[NEEDS CLARIFICATION: ...]`.

### Step 2: Run spec lifecycle in order

Execute these commands in sequence:

1. `/spec.specify`
2. `/spec.design`
3. `/spec.tasks`

Do not skip steps. Treat this command as an orchestrator for the existing lifecycle.

### Step 3: Scope and quality guardrails

Ensure generated artifacts cover all of the following:

- Modular Bicep component boundaries and composition root
- Parameterized environment setup inputs:
  - resource group name
  - location
  - environment name
  - naming prefix/suffix
  - tag object
  - SKU/class inputs where applicable
- Reusability across environments without hardcoded environment values
- Secret-safe configuration approach (no secrets committed)
- Validation plan including `bicep build`, deployment `validate`, and `what-if` checks

### Step 4: Implementation trigger policy

Default behavior ends at spec/design/tasks.

Only proceed to `/spec.implement` when the user explicitly asks to implement infrastructure changes.

### Step 5: Reporting requirements

At the end, provide:

1. Paths to produced/updated artifacts
2. Key assumptions and unresolved clarifications
3. Validation expectations for implementation phase
4. Suggested MVP milestone (smallest deployable environment slice)
