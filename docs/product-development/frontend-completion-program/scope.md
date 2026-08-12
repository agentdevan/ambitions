+++
initiative = "frontend-completion-program"
document_type = "scope"
status = "approved"
upstream = "research.md"
+++

## Outcome

Deliver one owner-approved, Apple-native production frontend for Ambitions.
The frontend has one canonical Contracts/Foundation/UI architecture, derives
from a complete fixture-driven approved design system, uses real local runtime
truth in production, and removes every superseded frontend implementation
artifact at final cutover.

## In scope

- UFP-0 through UFP-8 program execution, governed operationally by the sole
  ledger at `/Users/devan/.codex/output/Ambitions_Maximum_Polish_Program/PROGRAM.json`.
- Fixture-driven completion and owner approval of the frontend/design system;
  Today R04 D-129 is retained as approved and Time is the next surface.
- A component census and disposition of every in-scope frontend component.
- Canonical production modules: Contracts, Foundation, and UI.
- Real-runtime reconstruction of Today, then Goals, Time, You, Search, Capture,
  shell, receipts, recovery, and their shared routes/states.
- Migration, replacement-parity, and rollback evidence required before UFP-7
  cutover and deletion; final accessibility, localization, performance,
  physical-device, and release closure follows in UFP-8 against the cutover
  bytes.
- UFP-7 removal of legacy frontend files, dependencies, targets, assets, and
  wrappers; historical evidence and the absorbed component-sourcing research
  input remain preserved.

## Out of scope

- A third-party UI library as the default solution.
- Production use of Native Foundry or treating fixture proof as runtime proof.
- New cloud/account behavior, relaxation of local-first/privacy boundaries, or
  product behavior not already decided by canon and owner decisions.
- Deleting `docs/product-development/component-sourcing-and-system/`; it is a
  retained research input.
- iPad and Apple Watch frontend work.

## Requirements

### Program and authority

- **REQ-001 — Single program and ledger.** The program name is Ambitions
  Unified Maximum Polish Frontend Program. The sole operational ledger is the
  exact absolute-path `PROGRAM.json`; repository documents must link to it but
  must not create a competing ledger.
- **REQ-002 — Authority order.** Owner Taste and current owner surface
  decisions govern presentation; canon, product truth, privacy, correctness,
  accessibility, and Apple-platform requirements remain hard boundaries.
- **REQ-003 — Milestones.** The program has UFP-0, UFP-1, UFP-2, UFP-3,
  UFP-4, UFP-5, UFP-6, UFP-7, and UFP-8, each with entry, exit, owner, and
  proof conditions in the operational ledger.

### Foundry and fixture system

- **REQ-004 — Fixture-only Foundry.** Native Foundry may render deterministic
  fixtures and collect proof; it must not own production routes, runtime
  mutations, persistence, restoration, or final component APIs.
- **REQ-005 — Complete visual approval before wiring.** No production wiring
  to new frontend/design-system UI begins until all planned fixture surfaces,
  states, accessibility transformations, and cross-root behavior have passed
  their visual gates and the owner has explicitly approved the complete
  fixture-driven frontend/design system.
- **REQ-006 — Sequence.** Today R04 D-129 remains approved; Time is the next
  surface calibration. Later surface work may not contradict that order.

### Component and module system

- **REQ-007 — Apple-native substrate.** Use Apple controls, navigation,
  presentation, focus, system accessibility, Charts, and supported motion by
  default. Ambitions composition may style/compose them without replacing their
  behavioral contract.
- **REQ-008 — Earned custom ownership.** An Ambitions component is allowed
  only for recurring product semantics, state, accessibility, lifecycle, or
  continuity that native composition cannot express. Generic cards, bespoke
  replacement controls, custom navigation, universal shimmer, and decorative
  charts are prohibited defaults.
- **REQ-009 — Dependency exception.** No third-party UI library is adopted by
  default. An exception needs a demonstrated repeated gap plus versioned
  license, privacy, security, accessibility, performance, OS-support,
  maintenance, and removal review.
- **REQ-010 — Canonical modules.** Production frontend boundaries are
  Contracts (value types/protocols/routes), Foundation (tokens/styles/semantic
  primitives), and UI (surface composition and adapters). Dependency flow is
  UI → Foundation + Contracts; Foundation must not depend on UI; Contracts must
  not depend on either. Foundry is outside this production graph.
- **REQ-011 — Universal component disposition.** At UFP-4 every in-scope
  component receives exactly one disposition: `promote`, `rebuild`,
  `fixture-only`, `historical`, or `delete`, with source owner, replacement (if
  applicable), dependency edges, test/proof needs, and removal condition.

### Production and cutover

- **REQ-012 — Real-runtime production.** Production UI reads projections and
  sends typed intents through canonical local-runtime owners; it preserves
  privacy, persistence, migrations, replay, idempotency, revision conflict,
  restoration, receipt, undo, and recovery behavior.
- **REQ-013 — Vertical-slice order.** The first production reconstruction is
  Today. Goals, Time, You, Search, Capture, and shell follow only after the
  proven Today slice; shared UI never creates duplicate route/state/mutation
  authority.
- **REQ-014 — Truthful user states.** Loading, empty, ready, offline, privacy,
  degraded, error, settlement, and recovery states communicate real runtime
  truth. A transient notice cannot be sole evidence of a durable outcome.
- **REQ-015 — Complete legacy deletion.** UFP-7 removes every production
  frontend legacy file, dependency, target, asset, wrapper, and live reference
  after replacement parity and rollback evidence; no unused legacy remains.

### Quality and proof

- **REQ-016 — Visual language.** Surfaces use owner-approved contextual
  richness, native discipline, earned containment, restrained functional
  material, content-led chrome retreat, and purposeful motion; hard-kill
  signals invalidate the candidate.
- **REQ-017 — Inclusive and local proof.** Each affected state supports Dynamic
  Type, VoiceOver, contrast/Reduce Transparency, Reduce Motion, localization,
  RTL where applicable, keyboard/focus, and 44-point targets. Simulator proof
  does not substitute for physical iPhone proof.
- **REQ-018 — Cutover and release evidence.** UFP-7 cutover needs final-byte
  source/static checks, unit and UI tests, build/runtime/migration/privacy
  evidence, replacement parity, rollback rehearsal, and a final
  no-live-reference scan. UFP-8 then needs physical-device, manual
  accessibility, localization, performance/energy, archive, and release
  validation against those cutover bytes.

## Acceptance criteria

- `PROGRAM.json` has UFP-0…UFP-8 and is the only operational ledger (REQ-001–003).
- Foundry imports are absent from production targets and production wiring starts
  only after recorded complete fixture-system owner approval (REQ-004–006).
- The component disposition inventory is exhaustive and each row has one valid
  UFP-4 disposition (REQ-007–011).
- Production module dependency checks enforce the Contracts/Foundation/UI graph
  and block reverse or Foundry edges (REQ-010).
- Every reconstructed route demonstrates real local runtime state and failure
  recovery, beginning with Today (REQ-012–014).
- Final cutover removes all frontend legacy artifacts and scans clean while
  historical research/evidence persists (REQ-015).
- Each surface passes its named visual gate and accessibility/device proof; the
  release packet contains every REQ-018 proof lane (REQ-016–018).

## Frontend impact contract

- Surface impact: existing
- Existing roots and global journeys are reconstructed; no additional root is introduced.
- IA/navigation: modified
- One canonical shell and route/restoration ownership replace legacy frontend authority.
- Assets/iconography: system-only
- SF Symbols/system treatment are used unless a later owner-approved semantic asset proves necessary; migration includes removal of unused legacy assets.
- Visual language: modified
- The complete fixture-driven system realizes Owner Taste across shared and surface-specific composition.
- Motion: modified
- Typed native motion supports continuity/causality with reduced-motion behavior; decorative motion is excluded.
- Copy/localization: real state copy and catalogs are included; no synthetic
  success/recovery claims or English-only cutover.
- Accessibility: required across the component system and every state.
- Visual proof: required for fixture candidates and production changes; complete owner approval is required before production wiring, then simulator and physical-device proof serve their distinct roles.

## Canon impact

Implementation may require updates to owned canon only when the final approved
system changes a canonical behavior or ownership boundary. Before such a
change, its owner requirement must be queried and the canon compiler build and
check must pass. This packet does not itself amend canon.

## Risks and open decisions

The final exact legacy inventory, target names, migration aliases, and asset
manifest are UFP-4/UFP-6 implementation discoveries rather than product-open
decisions. A third-party exception and any new asset require a return to this
Scope. The owner has already approved implementation of this unified plan;
there are no unresolved product decisions that require Design to invent
behavior.

## Scope self-review

**PASS.** This Scope uses approved Research, has observable requirements and
acceptance criteria, locks all frontend classifications, and does not leave a
product decision for implementation to invent.
