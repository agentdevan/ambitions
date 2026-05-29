# Existing iOS 26 Batch Expansion Directives

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof, status-expedite, terminology-quarantine
> Dispositions: clarify-status-before-use, merge-before-proof, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Final working draft  
Purpose: Patch existing batch prompts instead of creating unnecessary duplicate B04 batches.

---

## IOS26-T05-B01 — Today / Reality Meridian

Add object-purity requirements directly into `IOS26-T05-B01-reality-meridian-recomposition.md`.

Required additions:
- install/infer `RealityMeridianSurface`
- Start here embedded in Meridian and collapsed by default
- Meridian scroll object: up = recent reality/proof history, center = now, down = soonest upcoming
- rename/rebuild `RealityMeridianView`
- rename/rebuild `TodayExecutionDepthDisclosure`
- remove top-level card/list/dashboard/task/agenda architecture
- run `scripts/ios26-anti-card-check.py --surface today --batch IOS26-T05-B01`

---

## IOS26-T06-B02 — Time / LifeShape Field

Add object-purity requirements directly into `IOS26-T06-B02-lifeshape-field-surface.md`.

Required additions:
- install/infer `LifeShapeFieldSurface`
- rename/rebuild `TimeLifeShapeField`
- remove calendar-grid/agenda/card/dashboard/equal-panel root
- verify Time replaces reasons to open Calendar for life-shaping work without becoming Calendar clone
- run `scripts/ios26-anti-card-check.py --surface time --batch IOS26-T06-B02`

---

## IOS26-T07-B01 — Goals / Constellation Atlas

Add object-purity requirements directly into `IOS26-T07-B01-constellation-atlas-root.md`.

Required additions:
- solar-system-like Atlas, life areas as planets/regions
- goals as adaptive bodies/thread origins/region markers
- visible first-class Goal Threads
- scrubbable timeline showing all steps for active goal thread
- remove goal-card/list/kanban/KPI/ring/dashboard root
- run `scripts/ios26-anti-card-check.py --surface goals --batch IOS26-T07-B01`

---

## IOS26-T08-B01 — Capture / Atmosphere Composer

Add object-purity requirements directly into `IOS26-T08-B01-atmosphere-composer-dominance.md`.

Required additions:
- install/infer `AtmosphereComposerSurface`
- rename/rebuild `CaptureAtmosphereComposer`
- rename/rebuild `CaptureDraftRoutePreviewCard` as `CaptureRouteLens`
- center-atmosphere empty state; practical thumb-zone behavior once input begins
- route preview above composer
- remove inbox/feed/notes/chat/task-list/card root
- run `scripts/ios26-anti-card-check.py --surface capture --batch IOS26-T08-B01`

---

## IOS26-T09-B01/B02 — You / User System Profile

Add object-purity requirements into both `IOS26-T09-B01-runtime-affecting-profile.md` and `IOS26-T09-B02-trust-memory-controls.md`.

Required additions:
- install/infer `UserSystemProfileSurface`
- Ambitions-themed iOS 26 Settings-style configuration hub
- rename/rebuild `YouRootSurface`
- native grouped rows/details allowed
- remove profile-card/admin-dashboard/AI-memory-dashboard/equal panel stacks
- run `scripts/ios26-anti-card-check.py --surface you --batch IOS26-T09-B02`

---

## IOS26-T10-B01/B02/B03 — Proof / receipts / closure / recovery

Add object-purity requirements into the existing T10 proof/receipt/recovery prompts.

Required additions:
- no receipt-card/proof-card/closure-card/audit-log-feed/analytics-dashboard root
- receipts for material actions only
- recovery tone: comforting, direct, supportive, no cheerleading, no fake AI personality
- replay is trust history, not debug console
- run `scripts/ios26-anti-card-check.py --surface proof --batch IOS26-T10-B03`

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
