# Refinement Playbook

When a run is weak, update the smallest layer that would have prevented it.

## Step 1: Review The Run

- capture what the user asked for
- capture what Codex actually did
- classify the failure
- decide whether it was one-off or systemic

## Step 2: Pick The Fix Layer

- repo-wide durable rule: update `AGENTS.md`
- local code-area rule: update nested `AGENTS.md`
- repeatable workflow mistake: update a `SKILL.md`
- weak output structure: update a template
- untested failure pattern: add or refine an eval
- profile confusion: update `.codex/README.md` or config comments
- intake or release confusion: update `.codex/operations/`

## Step 3: Keep The Fix Narrow

- prefer one concrete file update over many vague edits
- do not rewrite multiple layers if one layer is enough
- add an eval when you are not confident the issue is fully covered

## Ambitions Examples

- notification capture asks for full runtime support but the repo lacks an ingestion seam:
  update `capture-flow-implementer`, blocked-work templates, and the eval prompt
- share extension work keeps skipping `project.yml` wiring:
  update `ios-extension-builder`, `xcodegen-target-writer`, and the extension eval
- release passes keep overstating readiness:
  update `release-hardening`, `validation-summary.md`, and release-flow docs
