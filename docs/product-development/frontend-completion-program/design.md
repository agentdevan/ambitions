+++
initiative = "frontend-completion-program"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

UFP turns the approved frontend direction into one staged reconstruction:
fixture-owned visual discovery first, explicit component disposition second,
real-runtime production reconstruction third, and complete legacy removal last.
The production system has three modules—Contracts, Foundation, UI. Native
Foundry is deliberately adjacent: it consumes fixture models and renders proof
but has no production import edge.

The owner has explicitly approved implementation of the unified plan. This
approval permits program execution; it does not collapse the individual visual,
runtime, device, or release gates described below.

## User flows

1. **Fixture review:** a reviewer selects the program fixture for Today R04,
   then Time and remaining roots/global journeys, chooses standard/dark/large
   type/offline/privacy variants, and inspects a deterministic state. The
   reviewer can return to its source fixture without a production mutation.
2. **Owner visual decision:** the complete cross-root fixture system is
   presented as one native system, not as individual component screenshots.
   Any hard-kill signal, failed state, or broken return path sends the work
   back to the responsible UFP milestone. Explicit owner approval unlocks
   production wiring; nothing else does.
3. **Production Today:** the user opens Today, receives its projection from
   local runtime, takes a typed action, sees a truthful pending/receipt/recovery
   state, leaves and restores the route without losing state, and uses native
   Back/focus behavior.
4. **Cross-root continuation:** Goals, Time, You, Search, Capture, and shell
   compose the same semantic foundation while retaining root-appropriate
   hierarchy. Search remains find → contextualize → act; Capture remains
   freeform → infer → clarify only what matters → settle into structure.
5. **Cutover/rollback:** on replacement parity a bounded rollback window uses
   the declared recovery path. Once UFP-7 cutover proof is accepted, all live legacy
   frontend authority is deleted; historical research and evidence stay.

## States and recovery

Each fixture and production surface has visible `loading`, `ready`, `empty`,
`offline`, `privacy`, `degraded`, `error`, `pending`, `settled`, and
`interrupted/restored` states where relevant. State copy names the condition,
preserves user input on indeterminate outcomes, and exposes only a valid typed
recovery action. Ready/pending/receipt/undo are never simulated as proof of a
mutation in production.

Fixture failures are isolated to a fixture key, render, or proof capture and
cannot modify product state. Production failures use the Contract-defined
projection/intent/receipt/recovery behavior and preserve local-first replay,
revision, and idempotency invariants. A component disposition failure at UFP-4
blocks promotion and returns the component to rebuild, fixture-only, historical,
or delete evaluation.

## Frontend experience specification

The following classifications exactly repeat Scope:

- Surface impact: existing
- IA/navigation: modified
- Assets/iconography: system-only
- Visual language: modified
- Motion: modified
- Copy/localization: real state copy and localization catalogs; no synthetic
  outcomes.
- Accessibility: required across system, states, and routes.
- Visual proof: required
- Visual gate: required
- Today R04 D-129 is approved as a contained direction; the complete fixture-system owner approval remains required before production wiring, and each production vertical slice/device proof has its own required visual gate.

### Hierarchy and composition

UI composes an integrated contextual canvas or continuous structured list
appropriate to the root. It makes one dominant focus, multiple legible layers,
and one unmistakable next action. It does not impose generic cards, dashboard
tiles, persistent trailing actions, universal pills, giant CTAs, or glass-led
composition. Navigation uses native `TabView`, `NavigationStack`, toolbars,
system presentations, focus, and restoration; application-specific identity
lives in route data and composition, not replacements for platform behavior.

Foundation supplies semantic tokens, state presentation roles, spacing/shape
roles, typography, motion roles, accessibility variants, and system-control
styling. UI owns root composition, object/relationship/temporal presentation,
and adaptation of projections and intents. Contracts owns routes, fixtures,
projection states, intent results, recovery actions, and versioned restoration.
No UI type becomes a Contract; no Foundation type imports UI.

Foundry renders named Contract fixture keys or Foundry-only fixture adapters.
It may share an approved Foundation only once UFP-4 marks that foundation API
`promote`; it never becomes a dependency of production UI. Foundry-only views,
previews, host targets, recordings, and synthetic fixture helpers stay
fixture-only or historical until their UFP-4 row says otherwise.

### Assets, copy, motion, accessibility, proof

Use SF Symbols and Apple-managed glyph behavior by default. A custom asset is
allowed only if an owner-approved semantic need and accessibility description
exist; UFP-7 removes unreferenced legacy assets. Motion uses native SwiftUI
roles—crisp damping/fast settle for ordinary continuity and soft spring only
when tactile causality earns it—plus Reduce Motion and opaque/contrast-aware
alternatives. Native haptics/sound remain sparse and never establish truth.

All actionable controls meet 44-point targets, expose concise VoiceOver labels,
traits and values, retain logical reading/focus order, and do not use color or
motion as sole meaning. Large text, localization expansion, RTL, Reduce Motion,
Reduce Transparency, keyboard, VoiceOver, and switch-control behavior are
fixture states and production proof lanes.

## Architecture and data

### Canonical module graph

```text
Native Foundry synthetic adapters -> UI -> Foundation
                                      | -> Contracts

Production runtime adapters --------> UI
                 |-------------------> Contracts
```

`Contracts` is pure, Sendable/Codable route, state, fixture, projection, intent,
receipt, recovery, and restoration vocabulary. `Foundation` contains no runtime
owner or surface route and depends only on platform frameworks. `UI` hosts
surface composition and adapter seams, reads
projection snapshots, sends typed intents, and does not mutate persistence
directly. The app target owns composition-root injection and runtime adapters;
it must not import Native Foundry. Foundry depends on canonical UI, not the
reverse, and supplies only synthetic adapters and proof tooling.

UFP-4 records each current component in a versioned inventory maintained in
the sole operational ledger's program artifacts. The row has: source path,
current imports, semantic role, users, state/accessibility behavior, fixture
coverage, target membership, one disposition, replacement owner, migration
strategy, and delete proof. The inventory is generated from final bytes at
each approval boundary; no file-count snapshot serves as proof.

No production data migration is invented for visual work. When a route needs a
new projection or restoration schema, it follows the existing versioned
Contracts/local-runtime migration protocol with idempotent/replay/rollback
tests. The UI only presents confirmed state from that protocol.

## Privacy and accessibility

The app remains local-first: fixture data is synthetic and cannot be exported
as user state; production views render only authorized local projections and
preserve privacy/offline states. No external UI package, telemetry, account,
or network capability is introduced by this design. Any later dependency
exception must clear REQ-009 before entering source.

Accessibility is a release condition, not a polish pass: semantic controls,
system navigation, dynamic type, focus/keyboard, VoiceOver, Switch Control,
contrast, transparency/motion reductions, RTL and localized text are designed
with every component state and verified independently on a physical iPhone.

## Requirement traceability

| Scope requirement | Design decision(s) |
| --- | --- |
| REQ-001 | Named UFP program; absolute-path sole operational ledger; repo docs are governance only. |
| REQ-002 | Owner Taste/owner decisions govern visual choice; hard boundaries are preserved. |
| REQ-003 | UFP-0…UFP-8 execution and exit model in the plan/tasks/verification. |
| REQ-004 | Foundry-only fixture/render/proof role and forbidden production dependency edge. |
| REQ-005 | Complete fixture-system owner approval is the production-wiring gate. |
| REQ-006 | Today R04 D-129 is retained; Time begins the next calibration step. |
| REQ-007 | Native controls/navigation/presentation/Charts/motion are the substrate. |
| REQ-008 | Earned semantic component test; prohibited generic defaults. |
| REQ-009 | Explicit third-party exception review and removal plan. |
| REQ-010 | Contracts/Foundation/UI graph and allowed dependency directions. |
| REQ-011 | Exhaustive UFP-4 disposition row and one-of-five state. |
| REQ-012 | Real-runtime adapter, typed intents, and truth-preserving recovery. |
| REQ-013 | Today-first vertical slice and no duplicate authority. |
| REQ-014 | Complete visible state/recovery model; no false transient success. |
| REQ-015 | Final parity/rollback/no-reference deletion condition. |
| REQ-016 | Owner-Taste hierarchy/composition/material/motion implementation rules. |
| REQ-017 | Built-in accessibility/localization states and physical-device proof. |
| REQ-018 | Verification matrix and independent release evidence. |

## Verification design

UFP-0 validates ledger/reference ownership and controls. UFP-1 completes
primary directions; UFP-2 proves the 47-screen/system-surface fixture matrix;
UFP-3 derives and approves shared grammar; and UFP-4 establishes the canonical
component source/dispositions. UFP-5 completes and gains owner approval for the
entire fixture frontend. UFP-6 then adds Contracts/Foundation/UI compilation,
dependency-edge scans, real-runtime unit/integration/UI tests, restoration,
mutation/receipt/recovery, migration/replay, privacy, performance, and
Simulator checks. UFP-7 performs the atomic cutover and zero-legacy
verification. UFP-8 adds physical-device accessibility/interaction/performance,
privacy, localization, migration, and release closure. Full commands and
evidence boundaries are in `implementation/verification.md`.

## Open decisions

None. Exact file inventories and API names are implementation discovery under
the locked UFP-4 disposition process, not unresolved product decisions. Any
proposal to add a third-party UI dependency, custom semantic asset, new root,
or new product behavior returns to Scope.

## Design self-review

**PASS.** This Design derives from approved Scope, exactly repeats the frontend
classifications, resolves flows/states/module/data/privacy/accessibility/
verification, maps every REQ, and leaves no product choice for grooming to
invent.
