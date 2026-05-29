# DAV Product Experience Scorecard

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

Status: Active DAV scorecard; scores require implementation evidence.
Date: 2026-05-03

## Required Dimensions

Each implemented surface must score 4/5 or higher on Ambitions-specific product
quality, not generic UI quality:

- Premium iPhone-native feel.
- One primary visual object.
- No generic card stack.
- No SaaS surface drift.
- Calm hierarchy.
- Trust/proof clarity.
- Recovery without shame.
- Ambitions terminology compliance.
- Touch target and accessibility awareness.
- Reduce Motion awareness.
- Dark-mode visual believability.
- Settings-style grouped list correctness where relevant.
- Living statefulness without decorative busyness.
- Photo-reference fidelity where DAV visual work is in scope.

## Current Scores

| Surface | Status | Score | Notes |
| --- | --- | --- | --- |
| Shared primitives | Complete DAV02 | 4/5 | Native SwiftUI, state-driven, evidence labels, Reduce Motion-aware motion helpers, VoiceOver labels, and high Dynamic Type preview evidence. Surface-specific scoring waits for DAV03-DAV09. |
| Today | Complete DAV03 | 4/5 | Existing Reality Rail became DayTimelineRail, with DAV living background, pressure glow, evidence label, proof pulse, hero transition, Reduce Motion-aware animation, stable accessibility identifiers, and no route or persistence change. |
| Capture | Complete DAV04 | 4/5 | Capture remains composer-first with DAV atmosphere, named CaptureAtmosphereComposer, editable route-preview evidence, receipt pulse, no-shame empty copy, and no routing or persistence change. |
| Plan | Complete DAV05 | 4/5 | Plan gained a DAV background, Day/Week/Month scope chip strip, LifeShapeMap, pressure glow, capacity evidence label, and preserved suggestion-only calendar boundaries with no permission or routing change. |
| Goals | Complete DAV06 | 4/5 | Goals gained a photo-matched Mission Control first visual object with Proof, Blockers, Next Step, and Momentum lanes, DAV background, proof pulse, pressure glow, Reduce Motion-aware reveal, large type preview evidence, focused Goals test proof, and no route/persistence/schema change. |
| You | Complete DAV07 | 4/5 | You gained a photo-matched SystemProfilePanel, DAV background, tappable grouped navigation system, trust/memory/accessibility evidence labels, route-compatible disclosure flow, high Dynamic Type and Reduce Motion preview names, focused You/Profile and shell-navigation test proof, and no route/persistence/schema change. |
| Memory | Complete DAV08 | 4/5 | Memory gained `ContextRecallCard`, bounded `MemoryConstellation`, source/confidence/control labels, stale/rejected/private/corrected/no-result preview states, DAV material depth, no hidden inference, no durable memory behavior, and no route/persistence/schema change. |
| Trust/Receipts | Complete DAV09 | 4/5 | Trust Center gained `TrustReceiptStack`, source/freshness evidence labels, proof pulse, correction/undo affordance copy, no-receipts/proof/correction/undo/stale-source preview states, audit clarity, and no export/delete, legal/privacy, route/persistence/schema change. |
| Motion / Reduce Motion | Complete DAV10 | 4/5 | DAV motion presets now carry state-meaning and Reduce Motion equivalent metadata, DAV03-DAV09 transitions are classified, and no infinite decorative motion or motion-only meaning was introduced. |
| Visual Accessibility | Complete DAV11 | 4/5 | DAV03-DAV10 now have documented Dynamic Type, VoiceOver, non-color meaning, tap/gesture, Reduce Motion, and visual accessibility evidence; human/device proof remains Yellow and no public accessibility claim is made. |
| Preview Fixtures / Scenario Gallery | Complete DAV12 | 4/5 | DAV12 adds a named preview gallery for calm normal day, overloaded day, recovery day, empty/routed capture, blocked step, Still Counts, goal proof/blocker, stale/rejected/private memory, high Dynamic Type, and Reduce Motion. Screenshot export remains deferred Yellow for DAV14/human visual QA. |
| Visual Performance / Battery Risk | Complete DAV13 | 4/5 | DAV13 classifies DAV rendering and battery risks across blur/material layers, TimelineView/Canvas, animation, shimmer, preview gallery cost, and Reduce Motion fallbacks. Instruments/device energy proof remains deferred Yellow. |
| Visual Regression / Product Experience QA | Complete DAV14 | 4/5 | DAV14 records visual regression and PXEQ evidence for DAV03-DAV13. The system remains PASS WITH YELLOW because rendered screenshots, human visual review, physical-device proof, manual VoiceOver traversal, and contrast measurement are not claimed. |
| DAV train closeout | Complete DAV15 | 4/5 | DAV15 closes DAV01-DAV15 with accepted Yellow for unperformed screenshot, human visual, physical-device, manual VoiceOver, contrast, and Instruments/battery proof. It authorizes EB UI lanes to use DAV/PXEQ/SIG gates but makes no release, App Store, Apple Award, full accessibility, or device-proof claim. |

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
