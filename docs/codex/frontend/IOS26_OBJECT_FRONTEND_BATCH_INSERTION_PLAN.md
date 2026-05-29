# iOS 26 Object Frontend Batch Insertion Plan

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Final working draft  
Scope: Extend iOS 26 frontend trains with object-first, no-card architecture requirements  
Authority: Subordinate to `docs/truth/PRODUCT_DESIGN_TRUTH.md`, `docs/truth/IMPLEMENTATION_TRUTH.md`, and live source evidence

---

## 1. Purpose

This plan converts the object frontend specification into concrete Codex train changes.

It does not replace the existing iOS 26 train. It expands and extends the existing train so frontend implementation cannot close Green while preserving generic card architecture, dashboard/list/feed/chat/calendar roots, or weak object composition.

---

## 2. New train insertion

Add a new pre-T05 train:

```yaml
TRAIN_04L:
  title: Object Frontend Living Chrome Foundation
  dependencies:
    - TRAIN_02
    - TRAIN_04J
    - TRAIN_04K
  downstream:
    - TRAIN_05
    - TRAIN_06
    - TRAIN_07
    - TRAIN_08
    - TRAIN_09
    - TRAIN_10
  batches:
    - IOS26-T04L-B01
```

Recommended manifest placement:

```text
TRAIN_04K -> TRAIN_04L -> TRAIN_05
```

If the repo already uses `TRAIN_04L` in active manifests, Codex must inspect the collision and either extend the existing 04L frontend boundary or create an owner-approved non-conflicting ID. Build report filenames that mention `TRAIN_04L` do not prove manifest ownership.

---

## 3. New batch: T04L-B01

```text
prompts/batches/IOS26-T04L-B01-living-chrome-object-purity.md
```

Purpose:

- install/use object frontend spec as implementation authority
- install `scripts/ios26-anti-card-check.py`
- clean shell/Living Chrome object-purity
- remove generic global plus dominance
- prevent chat/search/dashboard command surface drift
- update tests/previews/proof for shell object purity

Required proof root:

```text
build/reports/frontend-object-purity/
```

---

## 4. Existing batch expansions

Codex must update/expand existing batch prompts rather than adding unnecessary new B04s.

### T05 — Today / Reality Meridian

Expand:

```text
IOS26-T05-B01-reality-meridian-recomposition.md
```

Add:

- Today card architecture removal
- `RealityMeridianSurface` target/inferred root
- Start here collapsed by default
- Meridian scroll object behavior
- `RealityMeridianView` rename/rebuild
- `TodayExecutionDepthDisclosure` rename/rebuild
- anti-card validator required
- preview/test/proof gates

No default T05-B04.

### T06 — Time / LifeShape Field

Expand:

```text
IOS26-T06-B02-lifeshape-field-surface.md
```

Add:

- LifeShape Field object-purity
- anti-calendar-clone root gate
- `TimeLifeShapeField` rename/rebuild
- no agenda/list/card/dashboard roots
- anti-card validator required
- preview/test/proof gates

No default T06-B04.

### T07 — Goals / Constellation Atlas

Expand:

```text
IOS26-T07-B01-constellation-atlas-root.md
```

Add:

- solar-system / life-area planet object concept
- goal nodes/threads/orbits/regions
- scrubbable goal-thread timeline
- no goal-card/list/kanban/KPI root
- anti-card validator required
- preview/test/proof gates

No default T07-B04 after Wave 10 final decision.

### T08 — Capture / Atmosphere Composer

Expand:

```text
IOS26-T08-B01-atmosphere-composer-dominance.md
```

Add:

- `AtmosphereComposerSurface` target/inferred root
- `CaptureAtmosphereComposer` rename/rebuild
- `CaptureDraftRoutePreviewCard` -> `CaptureRouteLens`
- no inbox/feed/notes/chat/task-list/card root
- anti-card validator required
- preview/test/proof gates

No default T08-B04.

### T09 — You / User System Profile

Expand:

```text
IOS26-T09-B01-runtime-affecting-profile.md
IOS26-T09-B02-trust-memory-controls.md
```

Add:

- Ambitions-themed iOS 26 Settings-style configuration hub
- `UserSystemProfileSurface` target/inferred root
- `YouRootSurface` rename/rebuild
- avoid profile cards/admin/AI memory dashboard/equal panel stacks
- native grouped rows allowed where appropriate
- anti-card validator required
- preview/test/proof gates

No default T09-B04.

### T10 — Proof / receipts / closure / recovery

Expand:

```text
IOS26-T10-B01-receipt-lineage-service.md
IOS26-T10-B02-cross-surface-proof-drawer.md
IOS26-T10-B03-recovery-replay.md
```

Add:

- receipt/proof object-purity
- no receipt-card/log-feed/audit-dashboard root
- closure/recovery not task-completion framing
- proof transfer and replay inspection gates
- anti-card validator required

---

## 5. New final sweep batch

Add after `IOS26-T10-B03`:

```text
prompts/batches/IOS26-T10-B04-global-object-purity-sweep.md
```

Purpose:

- run global anti-card validator
- run all surface modes
- verify no active top-level card/list/dashboard/feed/chat/calendar root remains
- require final screenshot/manual proof
- prove Green/Yellow/Red object frontend posture before T11–T16 continue

---

## 6. Generated files and manifest updates

Codex must create or update prompts first, then update generated train/order artifacts using repo scripts where possible.

Expected updates:

- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/codex/ios26/IOS26_IMPLEMENTATION_ORDER.md`
- `docs/codex/ios26/IOS26_BATCH_MATRIX.yml`
- `docs/codex/ios26/IOS26_PROMPT_FREEZE_HASHES.json`
- `docs/codex/IOS26_FLAGSHIP_SEQUENTIAL_RUNBOOK.md`
- prompt freeze reports
- planning/freeze reports

Do not hand-edit generated files if a repo script owns them.

---

## 7. Count impact

Do not make final batch-count claims until manifest/order artifacts are regenerated.

Planning estimate from the earlier `T04J-B03` checkpoint:

```text
+ IOS26-T04L-B01
+ IOS26-T10-B04
```

Estimated net addition: +2 source-changing implementation batches.

Final count must be recalculated by the repo scripts after installation.

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
