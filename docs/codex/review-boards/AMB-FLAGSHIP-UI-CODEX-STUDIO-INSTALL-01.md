# AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01 Review Board

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: duplicate_stable_id, same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-duplicate_stable_id-99080861, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748, AMB28-stale_or_unknown_active_status-84945191

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, status-expedite, terminology-quarantine
> Dispositions: clarify-status-before-use, merge-or-sequence-authority, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: supporting review board
Authority: subordinate to `docs/truth/*`

This board records the review posture for the UI Studio installer. It is a control-plane artifact, not a source-truth or release artifact.

## Review Lanes

| Lane | Question | Evidence expected | Status |
| --- | --- | --- | --- |
| Authority | Does the install stay subordinate to truth files and the active frontend portal? | Links to the operating system doc and authority index | Pending |
| IA | Does it preserve `Today / Goals / Capture / Time / You` and keep Plan compatibility-only? | README and authority index updates | Pending |
| Prompt hygiene | Do all generated prompts carry the runner metadata header and batch ID? | `make prompt-audit` | Pending |
| State coverage | Do the prompt files cover the required empty/normal/dense/recovery/error states? | Screen-state matrix | Pending |
| Anti-generic | Does the install reject surface, chatbot, task-list, and calendar-clone defaults? | Operating system doc and red-team prompt | Pending |
| Proof posture | Does the install treat preview/screenshot matrices as proof requirements instead of proof claims? | Matrix and review board | Pending |

## Review Notes

- This board is intentionally narrow.
- It supports future UI work by defining the review questions up front.
- It does not authorize a broader redesign.

## Non-Claims

This review board does not claim app implementation, screenshot validation, accessibility conformance, or release readiness.

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
