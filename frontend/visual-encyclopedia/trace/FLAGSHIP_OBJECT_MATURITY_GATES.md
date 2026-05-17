# Flagship Object Maturity Gates

Status: Active validation gate spec
Installed: 2026-05-16
Authority: Supporting gate spec for `FLAGSHIP_OBJECT_SYSTEM_DOCTRINE.md` and `OBJECT_GRAPH_ARCHITECTURE.md`.
Implementation claim: Docs-only. These gates define readiness expectations but do not prove any object currently passes.

## Purpose

These maturity gates define what it means for an Ambitions object to progress from canon idea to flagship-ready implementation. The gates are intentionally strict because every object should be world-class, not merely styled.

## Maturity Ladder

| Level | Name | Meaning | Promotion Requirement |
| --- | --- | --- | --- |
| F0 | Canon Only | Object is defined in docs only. | Object has surface mapping and anatomy. |
| F1 | Source Bound | Object has source candidates. | Source binding names files and gaps. |
| F2 | Kernel Installed | Object has semantic Swift/domain kernel. | Kernel exposes identity, state, proof, actions, accessibility summary. |
| F3 | State Machine Installed | Object state transitions are explicit. | Allowed/forbidden transitions and receipts are defined. |
| F4 | Renderer Installed | SwiftUI renderer exists and consumes kernel/state. | Renderer does not invent object semantics. |
| F5 | Previewed | Scenario matrix exists. | Normal, empty, active, blocked/waiting/recovery, stale/proof states, Dynamic Type, Reduce Motion previews exist. |
| F6 | Tested | Unit/UI tests exist. | Object kernel, transitions, proof, accessibility, and copy drift tests pass. |
| F7 | Proof Complete | Visual/accessibility/motion proof artifacts exist. | Receipts and proof reports are present. |
| F8 | Flagship Ready | Object passes all gates. | No red gaps, rollback ready, still not release-ready unless release truth says so. |

## FO-P0 Gate Requirements

FO-P0 objects must satisfy all gates below.

### F0 Canon Gate

- Object appears in Primary Object Anatomy Canon or Flagship Object Surface Matrix.
- Object has surface IDs.
- Object has dominant role.
- Object has required anatomy zones.
- Object has anti-generic failure examples.

### F1 Source Binding Gate

- Object is listed in source binding ledger or object graph matrix.
- Source files are declared or explicitly marked missing.
- Missing source binding blocks implementation-ready status.
- Compatibility seams are named without pretending they are final.

### F2 Kernel Gate

- Kernel exposes stable identity.
- Kernel maps to destination and surface ID.
- Kernel has state enum or equivalent typed state.
- Kernel carries proof/source/receipt availability.
- Kernel carries primary and secondary actions.
- Kernel carries accessibility summary.
- Kernel exposes known gaps.
- Kernel is Equatable/Sendable where appropriate.

### F3 State Machine Gate

- All supported states are explicit.
- Allowed transitions are explicit.
- Forbidden transitions are explicit.
- Transition triggers are named.
- Each transition has visual consequence.
- Each meaningful transition has receipt or explicit no-receipt reason.
- Silent mutation is forbidden.

### F4 Renderer Gate

- Renderer consumes object kernel or view model generated from kernel.
- Renderer does not own business logic.
- Renderer preserves anatomy zones.
- Renderer uses semantic materials/tokens.
- Renderer supports accessibility modifiers.
- Renderer supports reduced motion and no color-only state.

### F5 Preview Matrix Gate

Minimum previews:

- normal
- empty
- active
- blocked
- waiting
- needs recovery
- stale source
- proof missing
- receipt available
- high pressure or overloaded where relevant
- protected or away where relevant
- Dynamic Type XL/AX
- Reduce Motion
- Increase Contrast or Differentiate Without Color

### F6 Test Gate

Minimum tests:

- kernel well-formed test
- forbidden copy/pattern test
- state transition test
- proof/receipt availability test
- accessibility summary test
- reduced-motion fallback test
- preview matrix completeness test

### F7 Proof Gate

Minimum artifacts:

- scenario matrix report
- accessibility report
- Dynamic Type report
- Reduce Motion report
- motion report
- visual proof report or screenshots
- tests-run record
- implementation receipt
- rollback notes

### F8 Flagship Ready Gate

A FO-P0 object is flagship-ready only when:

- all F0-F7 gates pass
- no red gaps remain
- anti-generic checks pass
- object is label-off recognizable
- accessibility has no known red gaps
- proof artifacts exist
- release truth is not contradicted

## FO-P1 Gate Requirements

FO-P1 objects may use targeted proof but must still have:

- canon mapping
- source binding
- semantic kernel
- state model where stateful
- renderer
- targeted previews
- accessibility proof
- interaction proof
- receipt/proof proof
- tests where stateful
- implementation receipt

## FO-P2 Gate Requirements

FO-P2 objects require:

- source binding or explicit canon-only status
- accessible label
- visual token discipline
- no generic pattern drift
- receipt if code changes

## Automatic Failure Conditions

Any object fails immediately if it:

- is just title/subtitle/icon/color without semantic kernel
- can be mistaken for a generic productivity card
- hides a plan mutation
- lacks user control over meaningful adaptation
- uses `Plan` as visible top-level destination
- uses chatbot-first framing
- uses AI confidence score as visible truth
- uses shame/failure/streak language
- relies only on color, glow, or motion for state
- lacks accessibility summary
- claims proof without proof artifact

## Design-Award Production Value Gate

This gate does not claim award readiness. It asks whether an object is building toward award-level production value.

Pass requires:

- label-off recognizability
- novel but native interaction
- visual polish under edge states
- reduced-motion equivalent that is still elegant
- Dynamic Type layouts that still feel designed
- VoiceOver that sounds intentional
- proof/recovery/undo that feels humane
- no generic productivity-app equivalent
- no decorative motion with no state purpose
- no local-first marketing claim without behavior

## Codex Review Checklist

Before final response, Codex must report:

- current maturity level before patch
- maturity level after patch
- files changed
- gates satisfied
- gates not satisfied
- tests run
- proof artifacts created
- known gaps
- rollback path
- explicit non-claim for release and award readiness

## Required Reports

Future object implementation batches must write:

```text
build/reports/object-proof/<object-id>/maturity-gate-report.json
build/reports/object-proof/<object-id>/implementation-receipt.md
```

If an object does not reach F8, the report must say so plainly.