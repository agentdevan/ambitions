# AMB-CHATGPT-REVIEW-BOARD-STANDARD

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: stale_or_unknown_active_status
> Prior recommended actions: Expedite
> Candidate references: AMB28-stale_or_unknown_active_status-98267778

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, status-expedite
> Dispositions: clarify-status-before-use, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: supporting review-board standard

This standard defines the review boards that ChatGPT should reference when it
prepares a Codex review prompt. It does not create a new operational review
board path. Existing `.codex/review-boards/` usage remains the operational
precedent.

## Required review boards

### Ambitions Flagship Product Review

Use for product truth, object model, one-primary-object discipline, and
generic-product drift.

### Ambitions Local-First Backend Review

Use for durability, local storage, receipts, and server-dependency claims.

### Ambitions Frontend Visual Quality Review

Use for composition, native feel, material use, and rendered polish.

### Ambitions Apple Continuity Review

Use for iCloud/CloudKit continuity, restore paths, device handoff, and offline
state honesty.

### Ambitions Privacy Claim Review

Use for privacy manifest honesty, data handling claims, and hidden-collection
risk.

### Ambitions Data Durability Review

Use for persistence, recovery, receipts, and proof trail continuity.

### Ambitions Accessibility Review

Use for Dynamic Type, VoiceOver, Reduce Motion, contrast, and gesture
redundancy.

### Ambitions Launch Believability Review

Use for store-facing claims, release posture, and what is still fake.

## Required questions

Every review board prompt should answer:

- Would this make a user trust Ambitions with their real life system?
- Would this feel like a flagship app?
- Would this feel like a new category?
- Would this feel generic?
- Would this feel early?
- What proof exists?
- What is still fake?
- What should be Red?

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
