# AMB-1200 — Register Sync / Control Closeout

## Objective

Keep Linear, repo known-issues register, proof evidence, remediation dossiers, and project status synchronized through and after the remediation run.

## Covered Linear issues

- `AMB-1181` parent train
- `AMB-1200` execution/control bundle
- QA control-plane rows in `docs/qa/KNOWN_ISSUES.md`

## Product law

This is governance work. It does not fix product defects by itself and must not claim runtime or visual Green.

## Architecture law

The repo is the canonical source of remediation law and proof records. Linear is the operating tracker. ChatGPT project source is compact working memory. Evidence index is proof input, not implementation truth.

## Required implementation

- Keep `docs/qa/KNOWN_ISSUES.md` synchronized with Linear state.
- Ensure every bundle closeout links proof.
- Ensure every affected issue row has status, proof, and remaining risk.
- Maintain the remediation README/index if bundle order changes.
- Maintain ChatGPT project source file after major canon changes.
- Keep Linear project updates honest and Off Track/Red while P0s remain.

## Files likely in scope

- `docs/qa/KNOWN_ISSUES.md`
- `docs/qa/remediation/**`
- `docs/qa/evidence/**`
- `docs/project-source/CHATGPT_AMBITIONS_PROJECT_SOURCE.md`
- Linear project/comments/status updates

## Files forbidden unless justified

- app source implementation files
- product behavior changes

## Proof requirements

- Known issues register matches Linear issues.
- Remediation dossiers match execution bundles.
- Evidence paths are linked.
- Project status update posted.
- No issue is marked Done without owner proof acceptance.

## Status ceiling

Governance closure does not imply app readiness. App readiness remains governed by open P0 defects and final proof.

## Closeout template

Use the global closeout template and include a table of Linear bundle status vs repo known-issues status.
