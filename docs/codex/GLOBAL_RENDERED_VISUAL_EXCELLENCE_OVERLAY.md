# Global Rendered Visual Excellence Overlay

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Active global-order overlay for visual execution quality.
Date: 2026-05-05

## Purpose

This overlay exists because the global train can move quickly and the main global order file may be changing while Codex is running. This file gives Codex a stable instruction: visual excellence gates must run before broad continuation, even if the primary order has advanced.

## Live-State Rule

When Codex pulls this file:

1. Finish any active in-progress batch safely.
2. Do not discard uncommitted work.
3. Pull latest remote.
4. Read `GLOBAL_FULL_STACK_COMPLETION_ORDER.md`.
5. If FVQ01 has not run, run FVQ01 at the earliest safe point.
6. Then run FVQ02.
7. Then install FVQ04 recurring UI-batch proof into the operating protocol.
8. Run FVQ03/MEG01 as applicable.
9. Resume the global order only after no Hard Visual Red remains.

## Required FVQ Sequence

- FVQ01 Today rendered visual freshness and flagship proof.
- FVQ02 five top-level surface visual sweep.
- FVQ03 drill-down/external surface sweep where implemented.
- FVQ04 recurring UI-batch rendered proof protocol.
- MEG01 advanced rendering eligibility gate.
- FVQ05 final visual proof packet hook.

## Blocking Rule

No broad continuation into PFC external surfaces, AOS, LDI, or late handoff may proceed with known unresolved Hard Visual Red on a top-level surface.

## Repair Rule

If FVQ finds a failing surface, Codex must create and run a narrow repair batch before broad continuation:

- `FVQ-TODAY-REPAIR`
- `FVQ-GOALS-REPAIR`
- `FVQ-CAPTURE-REPAIR`
- `FVQ-PLAN-REPAIR`
- `FVQ-YOU-REPAIR`
- `FVQ-SHELL-REPAIR`

## No-Claim Boundary

This overlay does not claim visual issues are fixed. It requires them to be proven, repaired, or honestly classified before continuation.

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
