# AQOS Batch Impact Classifier

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-50973887, AMB28-same_source_file_targeted_by_multiple_active_batches-78130534, AMB28-same_surface_multiple_active_batches-66075429, AMB28-stale_or_unknown_active_status-5113371

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, status-expedite
> Dispositions: clarify-status-before-use, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Active Codex OS classifier.
Date: 2026-05-05

## Purpose

The Batch Impact Classifier prevents Codex from picking convenient proof. It identifies what a batch touches and therefore which evidence gates are mandatory.

## Required Classifier Step

Before every batch execution, Codex must classify:

1. files likely to be read
2. files likely to be changed
3. domains affected
4. user-facing surfaces affected
5. sensitive data affected
6. runtime/platform claims affected
7. required proof gates
8. stop conditions

## Domain Detection Rules

### Visual UI

Trigger when changed paths include:

- `Native/Ambitions/Features/**/**View.swift`
- `Native/Ambitions/App/AppMeridianShell.swift`
- `Native/Ambitions/App/AmbitionsRootView.swift`
- visual primitives
- design system components
- PreviewSupport visual fixtures
- widgets / Live Activities / notification UI

Required: FVQ, AXQ, Copy where user-facing.

### Accessibility

Trigger when:

- UI changed
- text labels changed
- controls changed
- motion/haptics changed
- privacy labels/accessibility values changed

Required: AXQ.

### Privacy / Sensitive Data

Trigger when:

- Found Life, memory, receipts, commitments, family, relationship, work, money, career, health-adjacent content appears
- widgets/Live Activities/notifications/App Intents/Spotlight/logs/previews are touched
- storage/shared storage/sync/accounts touched

Required: PVQ.

### Persistence / Schema

Trigger when:

- model/schema/repository/migration/storage/export/import/delete code touched

Required: DIQ.

### Performance / Battery

Trigger when:

- animations, Canvas, Metal, effects, widgets, Live Activities, sync, background work, large lists, rendering loops touched

Required: PERQ.

### Architecture

Trigger when:

- Swift files added/renamed/extracted
- shared primitives touched
- services/repositories/domain files touched
- files approach size thresholds

Required: ARQ.

### Copy

Trigger when:

- user-facing strings changed
- accessibility labels changed
- onboarding/explanatory copy changed
- recommendation/receipt/trust copy changed

Required: UXW.

### External Surface

Trigger when:

- WidgetKit
- ActivityKit
- App Intents
- notifications
- Spotlight
- Calendar/Reminders integration

Required: ESQ, PVQ, AXQ, FVQ external proof.

### Monetization

Trigger when:

- StoreKit
- entitlements
- paywall
- subscription copy
- restore/cancel/plan state

Required: MQ.

### Release / Legal / App Store

Trigger when:

- privacy labels
- manifests
- required-reason APIs
- release notes
- App Store copy/screenshots
- TestFlight/build/signing/release docs

Required: RQ.

### AI / AOS / LDI Runtime

Trigger when:

- recommendation engine
- source truth claim state
- Life Graph
- proof ledger
- commitment time
- option value
- dream/path compiler
- mutation permissions

Required: RIQ, Golden Scenarios, PVQ.

## Output Format

Every batch report must include:

```text
Impact classifier:
- Domains touched:
- User-facing surfaces touched:
- Sensitive data touched:
- Runtime/platform claims touched:
- Required gates:
- Evidence required:
- Evidence produced:
- Missing evidence:
- Green taxonomy achieved:
```

## Failure Rules

If a required domain is omitted from the classifier and discovered during review:

- Recoverable Red if it can be added and proven in scope.
- Hard Red if the missing domain hides privacy, data-loss, legal, release, or severe visual/product failure.

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
