# Codex Evidence Standard

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite
> Dispositions: rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active Codex OS evidence standard; not release or compliance proof.
Date: 2026-05-07

## Evidence Packet Required Fields

- task
- scope
- files touched
- files intentionally not touched
- commands run
- exit codes
- raw logs
- validation tier
- gates
- screenshots/rendered proof when UI is touched
- human/device proof when claimed
- claims not made
- Green / Yellow / Red result
- next eligible action

## Proof States

| State | Meaning | Required proof |
| --- | --- | --- |
| Planned | Future work is described. | Owner doc or roadmap entry. |
| Canonized | Source truth has accepted the concept. | Canon owner doc. |
| Scaffolded | Structural placeholder, prompt, model, or docs exist. | Files and boundaries. |
| Implemented | App/source behavior exists. | Source evidence and relevant tests/build as scoped. |
| Built | Build command completed. | Raw build log and exit code. |
| Tested | Test command completed. | Raw test log and exit code. |
| Device verified | Physical device proof exists. | Human/operator device evidence. |
| Accessible | Accessibility claim has proof. | Scope-specific accessibility evidence and limitations. |
| Privacy/legal reviewed | Human review completed. | Human/legal/privacy review artifact. |
| Release-ready | Release checklist and human approvals complete. | Matching release evidence; Codex cannot infer it. |

## Forbidden Claim Shortcuts

Do not say production-ready, release-ready, fully tested, fully accessible, App Store ready, TestFlight ready, device verified, privacy compliant, legally approved, or performance safe unless matching evidence exists.

## Raw Log Policy

Raw command output is the durable proof. Summaries help humans, but they do not replace raw logs. ACX Local logs are local-only under `.codex/logs/`; committed reports should reference paths when useful without committing noisy raw files.

## Green / Yellow / Red

- Green: required proof exists and claims are bounded.
- Yellow: gap is owned, safe, and nonblocking with no-claim boundary.
- Red: proof is missing for a required claim, scope is unsafe, source truth conflicts, or validation fails.
- Hard Red: Red that must stop continuation.

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
