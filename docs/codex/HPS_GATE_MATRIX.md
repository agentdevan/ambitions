# HPS Gate Matrix

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-54746946, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Active gate matrix for HPS01-HPS12 and all later HPS-dependent work.
Date: 2026-05-06

## Purpose

This matrix closes missing quality gates before AOS, LDI, and remaining surface-maturity work. It exists to prevent a repeat of the bad Today-view scenario: a screen can compile, pass tests, and still fail because it renders as a surface, generic card stack, crowded KPI board, or visually unworthy flagship product.

## Universal hard Red gates

| Gate | Hard Red condition |
|---|---|
| Top-Level Tab Gate | Creates or implies a sixth top-level tab or parallel app mode. |
| surface Drift Gate | Turns a top-level surface into stacked cards, KPI panels, analytics grid, or all-at-once life summary. |
| One Primary Object Gate | A top-level screen lacks one dominant object or has multiple equal-weight modules competing. |
| Generic SwiftUI Gate | Work looks like generic cards/lists/chips with Ambitions labels pasted on. |
| AI Theater Gate | Uses fake confidence, vague AI copy, or recommendation without source/why/fallback. |
| Hidden Mutation Gate | Changes commitments, schedules, paths, memories, proof, or privacy without review/receipt. |
| Surveillance Gate | Memory/recall feels like monitoring rather than user-owned reviewable memory. |
| Shame Gate | Missed, parked, abandoned, blocked, or stale work is framed as failure. |
| Sensitive Surface Gate | Sensitive life content appears in widget, Live Activity, notification, log, analytics, or screenshot by default. |
| Unsupported Claim Gate | Claims legal, privacy, release, AI runtime, sync, hosted service, career/education certainty, or acquisition readiness without evidence. |
| Missing Rendered Proof Gate | UI-affecting batch closes Green without fresh rendered simulator/screenshot evidence or accepted Yellow owner. |
| Accessibility Equivalence Gate | Motion, color, icon, shape, or visual position is the only way meaning is communicated. |
| Performance Budget Gate | Adds expensive visual/runtime behavior without budget, fallback, and profiling plan. |
| Privacy Permission Gate | User cannot correct, reject, hide, forget, or review sensitive memory behavior. |
| Source Truth Gate | Requirement, path, proof, or recommendation claim lacks source/freshness/uncertainty/review path. |
| Vertical Sprawl Gate | Builds education/career/workforce/family/coaching/marketplace/API product instead of architecture-only strategy. |

## Required surface-quality gates

### Today / Start Here Gate

Must prove:

- Start Here remains the primary object.
- Reality Rail supports Start Here rather than becoming a second surface.
- Start Here includes why this, why now, source quality, time-fit proof, privacy state, and receipt seam where relevant.
- No morning surface of life metrics appears.
- Recovery/closure states remain non-shaming.
- Rendered proof includes at least normal, overloaded, private/sensitive, stale/source issue, recovery/blocked, and reduced-motion/Dynamic Type-adjacent states when UI is touched.

### Goals Gate

Must prove:

- Goals is a LifePath / proof / option-value system, not a project-management board.
- Mission Control remains a spine/lane object, not grid/dashboard cards.
- Proof, source, option value, and alternate path are progressively disclosed.
- No generic progress-bar wall, goal KPI surface, or task board appears.

### Capture Gate

Must prove:

- Capture remains text-first and minimal.
- Placement/resolution stays fold/shelf based, not inbox/feed based.
- Commitment/dream/open-loop detection is reviewable.
- No hidden promotion to goal, schedule, memory, or proof.

### Plan Gate

Must prove:

- Plan remains LifeShape/capacity/reflow, not calendar clone or analytics surface.
- Pressure, protected pockets, recovery, free time, and commitment fit are shown through one primary planning object.
- Reflow suggestions are reviewable and receipt-backed.
- No KPI board of life areas, productivity scores, or chart pile appears.

### You Gate

Must prove:

- You remains Personal System Center, not settings dump or admin surface.
- Memory, privacy, source, proof, appearance, schedule, and trust controls are grouped with native hierarchy.
- Sensitive controls are clear and correctable.
- No all-life database view becomes default.

## Required HPS primitive gates

### Human Progress Graph Gate

Must prove the graph is internal substrate, not visible surface by default. Nodes and edges must have privacy/source/freshness where relevant.

### Verified Proof Ledger Gate

Must prove proof is user-owned, source/requirement mapped, privacy-classed, correctable/revocable, and not a scoreboard.

### Source Truth / Requirement Graph Gate

Must prove claims are source-labeled, freshness-aware, uncertainty-aware, and never treated as official without official source.

### Commitment Memory / Recall Gate

Must prove confirmed and inferred commitments are distinct, recall is source/freshness/privacy labeled, and correction/deletion/rejection paths exist.

### Recommendation Quality Gate

Must prove candidate generation, candidate rejection, why-this, why-now, why-not, time-fit, source/freshness, privacy, recovery, and fallback. Fake confidence scores are forbidden.

### Option Value Gate

Must prove prior proof transfers only when requirement/source/evidence overlap supports it. Career/education certainty is forbidden.

### Living Dream Compiler Gate

Must prove dream handling uses seriousness ladder, domain classifier, safety/legal/professional triage, requirement graph, capacity fit, mutation permissions, and safe refusal/redirect where needed.

### Privacy / Memory Permission Gate

Must prove remember/private/hide/ask-later/reject/forget/correct/stale/source-backed/inferred states are defined where memory is touched.

### Local Intelligence Adapter Gate

Must prove deterministic fallback before model-dependent behavior, optional local/on-device adapter boundaries, performance budget, privacy boundary, and no hidden mutation.

### AI Governance / Evaluation Gate

Must prove golden scenarios, red-team families, recommendation regression, privacy leaks, professional-boundary, minor/student-data, source-stale, unsafe-dream, and no-claim tests are defined or owner-assigned.

### Vertical Expansion No-Build Gate

Must prove verticals are strategy/architecture only. No school/career/workforce/family/coaching product, role model, marketplace, API, or public credential launch may appear.

### Acquisition Readiness Claim Gate

Must prove acquisition documents are diligence-readiness strategy only. No bidding war, valuation, buyer interest, or acquisition certainty may be claimed.

## FVQ integration requirements

Every future UI-affecting batch must produce or update rendered proof for affected states. Compile/tests/docs alone cannot close Green for visible UI work.

Required rendered proof classes when touched:

- normal
- empty
- loading
- degraded/stale
- private/sensitive
- overloaded/high-pressure
- recovery/blocked
- reduced-motion equivalent
- Dynamic Type-adjacent or documented limitation
- dark-mode default
- external surfaces when widgets/Live Activities/App Intents/notifications are touched

## CQS integration requirements

Every HPS-dependent batch must invoke or map equivalent review for:

- human progress systems architecture
- no-sprawl / no-dashboard
- proof/source contract
- recommendation quality
- privacy memory permission
- AI governance/evaluation
- singular experience cohesion
- acquisition/no-claim boundary

## Yellow handling

Accepted Yellow is allowed only when:

- risk is documented
- owner is named
- repair path is explicit
- user-facing claim is blocked
- later batch is assigned
- no safety/privacy/legal/product-hard-Red exists

## Closeout standard

HPS12 cannot close until every missing quality gate is either implemented, integrated into a later train, or accepted Yellow with owner and explicit stop condition.

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
