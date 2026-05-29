# FAANG Frontend Implementation Team Operating System

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-21672468, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

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

Status: Active Codex OS frontend implementation protocol
Date: 2026-05-08
Owner: Codex OS / Ambitions Signature Interface
Scope: All visible SwiftUI, shell/chrome, top-level surfaces, visual primitives, screenshots, previews, onboarding, widgets, Live Activities, App Intents confirmations, notifications, and accessibility presentation work

## Purpose

This protocol upgrades Codex OS from a batch executor into a senior frontend implementation team. It exists because Ambitions can pass build, accessibility identifiers, route coverage, source-truth citations, and batch registry updates while still producing simulator output that looks like stacked compliance panels instead of a flagship native iPhone app.

A frontend batch is not successful because it implemented every named concept. It is successful only when the rendered app communicates the product through hierarchy, restraint, interaction, accessibility, and proof.

## Core Failure This Prevents

Codex must not render canon literally as visible inventory.

Common failure pattern:

1. Canon names many product concepts.
2. Codex adds each concept as a visible panel, chip, row, badge, or explanatory block.
3. Build passes.
4. Accessibility IDs pass.
5. Docs claim source-truth alignment.
6. Screenshot still looks generic, dense, and unshipped.

This protocol blocks that outcome.

## Team Model

Every UI-affecting batch must simulate these roles before implementation and again before closure.

### 1. Staff iOS Frontend Lead

Owns SwiftUI architecture, state flow, file boundaries, preview/test strategy, performance, and maintainable implementation seams.

Required questions:

- What is the one primary object on this screen?
- What state drives it?
- What should be local to the view versus a shared primitive?
- What can be deleted, collapsed, or deferred instead of added?
- What is the smallest implementation that materially improves the rendered screen?

### 2. Product Composition Director

Owns visual hierarchy, first viewport calm, object identity, interaction posture, and Ambitions-native expression.

Required questions:

- Does the user understand the screen in two seconds?
- Is the screen showing product intelligence or explaining implementation architecture?
- Is the top-level surface one living composition or a stack of modules?
- Does the surface feel native, premium, restrained, and useful?
- Are supporting facts subordinate to the primary object?

### 3. Signature Interface Creative Director

Owns Ambitions-specific object language: Start Here, Reality Meridian/Rail, LifeShape, Capture composer, Personal System Center, receipt/trust layer, proof spine, and continuity chrome.

Required questions:

- Is this an Ambitions object, or a renamed generic card?
- Does the object have silhouette, role, state, motion posture, and receipt path?
- Does the object avoid surface, kanban, analytics-widget, settings-card, and generic productivity-app drift?
- Is the celestial/luxury atmosphere structural rather than decorative?

### 4. Accessibility And Human Factors Lead

Owns VoiceOver meaning, Dynamic Type, motor access, Reduce Motion, contrast, copy clarity, and cognitive load.

Required questions:

- Does the visual simplification preserve semantic access?
- Does the first viewport remain usable at larger Dynamic Type sizes?
- Are non-color cues present for status and priority?
- Does Reduce Motion preserve state continuity without animation?
- Does the screen avoid forcing the user to read internal product logic?

### 5. Performance And Rendering Lead

Owns frame budget, overdraw, material cost, animation cost, preview freshness, simulator proof, and device risk.

Required questions:

- Did the batch add expensive blur/material/animation layers without proof?
- Is the view recomposition bounded?
- Is the new primitive isolated enough to profile and roll back?
- Is there a static fallback for advanced visual effects?

### 6. Visual QA Red Team

Owns ruthless screenshot review. This role can fail a batch even when build/tests pass.

Required questions:

- Would this screenshot embarrass a senior iOS team review?
- Does it look like production software or a prototype/report?
- Are there too many panels, chips, icons, labels, or explanations?
- Does bottom chrome look intentional and singular?
- Does the screen visually improve versus the baseline screenshot?

## Mandatory Frontend Batch Phases

### Phase 0 — Screenshot Baseline

Before touching UI, capture or identify the freshest available screenshot/preview for each touched surface.

Record:

- device/simulator target
- appearance mode
- surface name
- commit/ref or artifact source
- known visual defects
- first viewport object count
- visible chip count
- visible body-copy line count
- bottom chrome count

If screenshot capture is unavailable, the batch starts Yellow and cannot close Green unless the change is non-rendering or a current durable artifact directly covers the touched surface.

### Phase 1 — Screen Contract

Write a compact screen contract before implementation:

- Primary object
- Secondary objects, maximum two
- One primary action
- One collapsed detail path
- Visible copy budget
- Visible chip budget
- Bottom chrome ownership
- Accessibility equivalent
- Reduce Motion equivalent
- Deletion/collapse targets

No UI-affecting implementation may proceed without this contract.

### Phase 2 — Delete / Collapse Before Add

For existing screens, Codex must remove, collapse, merge, or demote visible content before adding new visible content.

Preferred repairs:

- collapse details behind disclosure
- move diagnostic proof into receipt drawer
- merge repeated chips into one proof line
- demote support rows below first viewport
- replace generic panels with one custom object silhouette
- remove architecture copy from top-level UI
- remove duplicate bottom controls

### Phase 3 — Implement With Bounded Primitives

A hero/top-level primitive must not expose an unbounded `contentSlot` by default. If a generic slot exists for compatibility, the screen implementation must enforce a visible budget.

Top-level surfaces should be built from bounded role slots:

- primary object
- primary fact/proof
- secondary signal
- primary action
- collapsed detail
- receipt path

### Phase 4 — Rendered Proof

Every UI-affecting batch must produce or reference rendered proof.

Minimum proof for a top-level surface touch:

- before screenshot or named durable baseline
- after screenshot
- first viewport budget table
- visual red-team verdict
- accessibility/readability note
- Reduce Motion note when motion/state changes
- privacy-sensitive rendering note when user content is visible

### Phase 5 — Closure Classification

Frontend closure is based on rendered outcome, not implementation effort.

Green requires:

- build/tests relevant to changed files pass or are explicitly not applicable
- rendered proof exists
- first viewport budget passes
- no hard visual red exists
- visible UI improves or preserves flagship quality
- no generic dashboard/card-stack/prototype drift

Accepted Yellow requires:

- rendered proof is partial but durable enough for the surface risk
- issue does not affect primary object identity
- explicit owner batch and repair path
- no privacy leak
- no hard visual red

Recoverable Red:

- too dense
- wrong hierarchy
- generic stacked panels
- duplicate chrome
- visual regression
- missing screenshot for visible change
- first viewport budget failure that can be repaired in scope

Hard Red:

- batch tries to close Green from build/tests/docs alone after visible UI change
- primary object identity is broken
- top-level tab becomes dashboard/card-stack/prototype/generic
- navigation/chrome conflict confuses primary interaction
- repair requires weakening canon, accessibility, privacy, or validation gates

## First Viewport Budget

Default top-level surface budget:

- Maximum one primary surface/object
- Maximum two support surfaces/objects
- Maximum four visible chips total
- Maximum twelve visible body-copy lines
- Maximum one floating control
- Maximum one bottom navigation system
- No nested card-on-card structure inside the primary object
- No internal architecture copy above the fold
- One obvious visual thesis within two seconds

The screen may exceed a budget only when the batch report explains why the user task requires it and the Visual QA Red Team accepts the tradeoff.

## Surface-Specific Rules

### Today

- Start Here owns the first viewport.
- Reality Meridian/Rail supports Start Here; it must not compete as a second surface.
- One recommended step is prominent.
- One primary CTA is visible.
- `Why this?` is collapsed by default.
- Recovery, closure, plan-layer, one-step goals, and trust details cannot all be visible in the default hero viewport.

### Goals

- The top level is an equal-weight goal atlas, not a KPI surface.
- Categories/goals must be drillable without turning the first viewport into a grid of metrics.
- Proof and path detail belong behind object interaction.

### Capture

- The composer owns the screen.
- Input alternatives and routing proof must be calm, secondary, and editable.
- Capture must not become an inbox/dashboard by default.

### Time

- LifeShape owns the screen.
- It must not regress into a calendar clone, analytics chart, or list of panels.
- Capacity/pressure/protected time should read as one shape, not separate cards.

### You

- Personal System Center owns the screen.
- It may use iOS Settings familiarity, but the top viewport must not become a generic settings card stack.
- Planning Setup, Trust, Memory, Receipts, and Appearance are grouped by user control, not implementation category.

### Shell / Chrome

- Native tab bar and custom Meridian rail cannot both read as separate active navigation systems.
- Floating global controls must be contextual or visually integrated.
- Repeated headers must be compact and justified by the tab task.
- Search/memory controls must not dominate every screen by default.

## Anti-Slop Static Smells

A frontend batch must search touched files for these patterns and justify or repair them:

- `VStack` containing three or more surface/panel components above the fold
- repeated `AmbitionChip` in primary object scope
- `contentSlot` used as an unlimited vertical dump in a hero/top-level primitive
- more than one `.overlay(alignment: .bottom)` in shell/chrome without a clear owner
- generic copy such as `Available when needed`, `One agreement for the day`, `keeps ... visible`, or internal architecture explanations above the fold
- top-level screen title/subtitle/header repeated where selected tab already provides location context
- button/action labels that expose implementation concepts instead of user intent

## Deliverables Required In Batch Report

Every UI-affecting batch report must include:

| Field | Required content |
| --- | --- |
| Surfaces touched | Exact screens/components |
| Primary object contract | One sentence per touched surface |
| Deleted/collapsed UI | What visible inventory was removed or demoted |
| Before proof | Screenshot/artifact/ref or Yellow limitation |
| After proof | Screenshot/artifact/ref or Red/Yellow limitation |
| First viewport budget | pass/fail counts |
| Visual QA verdict | Green / Accepted Yellow / Recoverable Red / Hard Red |
| Accessibility verdict | VoiceOver/Dynamic Type/Reduce Motion impact |
| Performance verdict | material/motion/rendering risk |
| Remaining gaps | owner batch and severity |

## Codex Behavior Rules

Codex must:

- prefer fewer stronger objects over more complete visible inventory
- treat screenshots as product evidence, not decoration
- reject its own work when rendered hierarchy is weak
- stop on hard visual red even if build passes
- keep implementation claims narrower than evidence
- avoid generic dashboard/productivity UI even when canon terms are present
- preserve local-first/privacy/trust boundaries while simplifying UI

Codex must not:

- add more panels to solve unclear hierarchy
- expose source-truth architecture as user-facing copy
- call a screen flagship without rendered proof
- hide visual regressions in Yellow unless primary identity is preserved
- use accessibility compliance as an excuse for dense visual design
- use build success as visual success

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
