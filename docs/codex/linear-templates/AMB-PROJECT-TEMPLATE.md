# Ambitions Linear Project Template

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active workflow template.
Scope: Multi-issue Linear projects/trains that delegate bounded implementation to Codex.
Manifest: `docs/codex/linear-templates/AMB-LINEAR-TEMPLATE-MANIFEST.yml`

Use this for work that is too large for one issue but should still preserve the
same authority chain, proof gates, and one-issue/one-branch execution rule.

## Project Shell

```text
Project title
<AMB-TRAIN-ID>: <Outcome name>

Project brief
This project advances Ambitions by implementing <specific product/runtime/repo outcome>
through scoped, validation-gated Linear issues.

Repo
agentdevan/ambitions

Manifest
 docs/codex/linear-templates/AMB-LINEAR-TEMPLATE-MANIFEST.yml

Authority inspected
- docs/truth/README.md
- docs/truth/PRODUCT_DESIGN_TRUTH.md
- docs/truth/PRODUCT_MOAT_TRUTH.md
- docs/truth/IMPLEMENTATION_TRUTH.md
- docs/truth/RELEASE_TRUTH.md
- docs/truth/CODEX_PROCESS_TRUTH.md
- AGENTS.md
- docs/codex/LINEAR_CONTROL_PLANE.md
- docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json
- docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml
- <relevant prompt/source/test/proof paths>
```

## Project Rules

```text
Project rules
- Repo truth wins over Linear project status.
- One issue = one branch = one PR/review result.
- Codex may execute implementation issues only within issue scope.
- Main account owns architecture, canon, sequencing, final review, and merge readiness.
- No issue may change product law unless explicitly marked architecture-approved.
- No issue may claim build/test/accessibility/performance/privacy/release readiness without current proof.
- All Green claims require direct repo evidence, validation output, and proof artifacts.
- Linear Done is a workflow mirror only; it is not proof.
```

## Default Milestones

```text
Milestones
1. Planning locked
2. Issues generated from repo-backed templates
3. Implementation complete
4. Validation/proof pass
5. Main review
6. Merge ready
7. Post-merge audit
```

## Default Labels

```text
Default labels
- ambitions
- codex
- validation-required
- proof-required
- needs-main-review
- local-first
```

Add area labels when relevant:

```text
Area labels
- area: frontend
- area: runtime
- area: process
- area: canon
- area: batch-ledger
- area: release
- area: accessibility
- area: privacy
```

## Status Mapping

```text
Backlog
- Issue exists, not executed, no proof claim.

Ready for Codex
- Issue has template, scope, non-goals, validation, proof paths, and stop conditions.

In Progress
- Codex is inspecting or patching. Repo truth still wins.

Needs Review
- Codex returned a report or PR that requires main-account review.

Validation Green
- Required validation/proof passed for the issue scope only.

Merge Ready
- Main review accepted the diff, proof, and no-claim boundaries.

Done
- Workflow complete. Done is not product/release proof beyond linked repo evidence.
```

## Required Issues

Every project should include at least:

```text
1. AMB-REVIEW planning lock
   Purpose: confirm authority, scope, dependencies, proof roots, and train order.

2. AMB-BATCH / AMB-DESIGN / AMB-FIX implementation issues
   Purpose: bounded implementation.

3. AMB-REVIEW validation/proof review
   Purpose: check artifacts and no-claim boundaries.

4. AMB-REVIEW merge-readiness review
   Purpose: final Green/Yellow/Red recommendation before merge.
```

## Project Acceptance Gates

Green only if:

```text
- Every implementation issue has a final Codex report.
- Every Green issue has direct validation/proof evidence.
- No issue changed product law without architecture approval.
- No issue touched unrelated files without explanation and review.
- Proof artifacts are current and linked by exact repo path.
- Release/privacy/accessibility/performance/device/TestFlight/App Store claims are either proven or explicitly not claimed.
```

Yellow if:

```text
- Implementation appears complete but one or more validations are environment-blocked.
- Non-blocking risks remain with clear follow-up issues.
- Proof exists but needs main-account interpretation before merge.
```

Red if:

```text
- Build/test/proof fails.
- Scope expanded beyond issue/project contract.
- Product law or privacy/local-first boundaries were compromised.
- Linear status is used as proof.
- Required authority files were not inspected.
```

## Token-Efficient Project Brief

Use this when creating the project in Linear:

```text
This project uses the Ambitions repo-backed Linear template system.

Manifest: docs/codex/linear-templates/AMB-LINEAR-TEMPLATE-MANIFEST.yml
Project template: docs/codex/linear-templates/AMB-PROJECT-TEMPLATE.md
Issue templates: docs/codex/linear-templates/AMB-ISSUE-TEMPLATES.md
Control plane: docs/codex/LINEAR_CONTROL_PLANE.md

Repo truth wins. Linear is a queue/status mirror only. Codex executes bounded
implementation issues; main account owns architecture, sequencing, final review,
and merge readiness.
```

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
