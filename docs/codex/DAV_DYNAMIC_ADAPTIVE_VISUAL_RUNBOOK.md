# DAV Dynamic Adaptive Visual Runbook

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, rewrite-authority-before-proof
> Dispositions: rewrite-authority-before-proof, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

Status: Active DAV operator runbook.
Date: 2026-05-03

## Run Order

Run DAV01 through DAV15 in order. Continue automatically through Green and accepted Yellow. Stop only on unrecoverable Red: persistence/schema requirement, route/raw value change, dependency addition without approval, privacy/security uncertainty, accessibility blocker, release-claim falsehood, destructive overwrite, or repeated same-root Red.

## Implementation Rules

- Name files before production Swift edits.
- Prefer shared design-system primitives in `Sources/Components` when reusable across surfaces.
- Keep surface work inside the existing feature owner folders.
- Preserve existing accessibility identifiers unless a batch explicitly maps and proves changes.
- Use previews/fixtures for normal, empty, overloaded, recovery, Reduce Motion, and high Dynamic Type states where relevant.
- Run `xcodegen generate` after project-shape changes; for source-only additions under existing source roots, run the narrowest useful build/test lane.

## Required Validation

Use the DAV scripts, `git diff --check`, implementation-boundary scans, PXEQ scans, focused xcodebuild build/test lane when Swift changes, docs QA, and batch-train gate check.

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
