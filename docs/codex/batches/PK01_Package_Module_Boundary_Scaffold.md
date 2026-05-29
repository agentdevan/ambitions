# PK01 Package/Module Boundary Scaffold

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-file-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

Status: Complete / Accepted Yellow
Date: 2026-05-08
Owner train: PK00-PK41 Platform Kernel Train
Next eligible batch: PK02 Architecture Boundary Scanner

## Goal

Name package/module boundaries before extraction or project/package mutation.

## Work Completed

- Added `docs/codex/platform-kernel-module-boundary-scaffold.md`.
- Mapped current `Package.swift` and `project.yml` build shape.
- Named future Domain, Persistence, Runtime, Feature Engines, External
  Surfaces, and App Shell boundaries.
- Defined dependency direction and forbidden preconditions for later PK package
  moves.
- Defined PK02 scanner requirements.

## Decision Record

PK01 is docs-only. It intentionally does not edit `Package.swift`,
`project.yml`, production Swift, tests, targets, schemes, app extensions,
entitlements, signing, resources, or generated project files.

## Result

Accepted Yellow. The scaffold exists and is safe to use as source truth for
PK02, but package/module safety is not Green until PK02 adds scanner coverage
and later PK38-PK41 move code with focused build/test proof.

## Validation

Minimum validation:

```bash
git diff --check
python3 scripts/ai/acx_impact.py <changed files>
python3 scripts/ai/acx_local.py bundle docs
python3 scripts/ai/acx_local.py bundle batch-closeout
python3 scripts/ai/acx_repair.py diagnose
scripts/global-train-next-batch.sh
```

## Non-Claims

No production code change, package split, build-system refactor, module
extraction, backend completion, migration safety, sync readiness,
side-effect isolation, privacy compliance, CI green, release readiness,
physical-device proof, public accessibility conformance, or performance-budget
proof is claimed.

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
