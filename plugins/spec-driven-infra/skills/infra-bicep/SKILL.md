---
name: infra-bicep
description: Reusable guidance for modular Azure IaC bundles with Bicep, emphasizing parameterized environment setup and repeatable deployment.
---

# Bicep Infrastructure Skill

Use this skill when designing or implementing reusable Azure environment setup using Bicep.

## Use for

- Creating a modular Bicep bundle for environment provisioning
- Defining parameter strategy for reusable deployments
- Standardizing naming and tagging inputs
- Creating validation and deployment guidance for multi-environment usage

## Do not use for

- Non-Azure infrastructure stacks
- Application-level feature requirements unrelated to infrastructure
- Replacing the spec lifecycle (`specify -> design -> tasks`)

## Required design decisions

1. Deployment scope and composition
   - Define target scope (`subscription` or `resourceGroup`) at the root.
   - Keep a single composition entry point that wires component modules.

2. Module boundaries
   - Split by capability or resource domain (network, identity, data, app hosting, observability).
   - Keep module contracts explicit via strongly typed parameters and outputs.

3. Parameterization model
   - Accept reusable inputs for: environment name, location, resource group name, naming prefix/suffix, tags, and SKU/class selections.
   - Avoid hardcoded environment-specific values in module logic.

4. Naming and metadata
   - Use deterministic naming conventions derived from parameters.
   - Apply required tags consistently from a shared tag object.

5. Secret handling
   - No secrets in committed Bicep or parameter files.
   - Use Key Vault references, managed identities, or deployment-time secure parameter injection.

## Suggested artifact layout

```text
infra/
  bicep/
    main.bicep
    modules/
      networking.bicep
      identity.bicep
      data.bicep
      app.bicep
      observability.bicep
    params/
      dev.bicepparam
      test.bicepparam
      prod.bicepparam
```

## Validation and quality checks

- `bicep build` for changed modules and root composition
- `az deployment ... validate` before deployment
- `az deployment ... what-if` before merge/release for shared environments
- Confirm required tags and naming outputs are present

## Output expectations

When this skill is applied, outputs should include:

- Clear module boundary rationale
- Parameter contract table
- Naming and tagging strategy
- Environment parameter-file strategy
- Deployment and validation commands
