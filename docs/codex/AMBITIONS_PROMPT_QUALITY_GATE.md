# Ambitions Prompt Quality Gate

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-26899932

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active Codex OS protocol for future Ambitions batches

## Purpose

Prevent future Codex prompts from becoming vague, overbroad, or claim-inflating. This gate applies to AOS, ME, CS, Release Evidence Closure, Product Depth, repair trains, and any post-F30 batch prompt.

## Required Fields For Every Future Batch Prompt

- Batch ID and name
- Status, including whether it is future-only, active, complete, or historical
- Purpose and product problem
- Source truth files to read first
- Explicit allowed files
- Explicit forbidden files
- Exact ownership target or a discovery command plus decision-record requirement
- Required preflight checks
- Implementation boundary
- Non-goals
- Validation commands
- Evidence outputs
- Audit/report path
- Registry/context/run-state update requirement
- Green / Yellow / Red criteria
- Stop conditions
- Rollback or repair path
- What this batch must not claim
- What this batch does not prove
- Commit message recommendation
- Next safe prompt or next gate

## Executability Standard

A prompt is not executable if it only says `selected by manifest`, `update as needed`, `run tests`, `preserve behavior`, `follow canon`, or `validate` without naming owners, commands, evidence, gates, and stop conditions. If the exact owner file is known, name it. If the owner file must be discovered, name the discovery command and require a decision record before edits.

## Release And Platform Claim Standard

Prompts touching release, evidence, privacy, accessibility, performance, external surfaces, platform capability, or source-sensitive claims must state the proof required and the proof not available. Simulator proof never implies physical-device proof, public accessibility conformance, TestFlight readiness, App Store submission readiness, final RC lock, signed archive validation, App Store Connect validation, rendered widget/App Intent/Live Activity proof, or production model behavior.

## Scope Rejection Rules

Reject prompts that mix broad refactor with product behavior, mix release claims with implementation, touch more primitives than named, lack validation, lack file boundaries, lack stop conditions, ask Codex to polish everything, silently choose product direction, imply release readiness without evidence, or start AOS/ME/CS/Product Depth/Release Evidence Closure without explicit train activation.

## Boundary

This protocol does not implement app behavior, add dependencies, change workflows, or create release claims.

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
