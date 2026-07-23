# Ambitions canon

This directory contains the durable product and engineering truth for
Ambitions. It defines what the product is, how its four surfaces and global
systems fit together, what its canonical objects mean, how the private local
runtime behaves, and what native iPhone quality requires.

Canon is product direction, not repository authorization. Ordinary edits do
not require a signed task start, intake pack, attestation, owner self-approval,
or finalization receipt.

## Reading order

1. [CONSTITUTION.md](CONSTITUTION.md) — mission, product category, root IA,
   user control, object and runtime invariants, privacy, accessibility, and
   native-platform law.
2. [Surface specifications](specifications/surfaces/) — Today, Goals, Time,
   and You.
3. [Global specifications](specifications/global/) — Capture, Search, Motion,
   and contextual Trust inspection.
4. [Object specifications](specifications/objects/) — the canonical local
   object graph and lifecycle semantics.
5. [System specifications](specifications/systems/) — Private Life Runtime,
   persistence/replay, scheduling, privacy, notifications, Apple integration,
   Source Atlas, sync, diagnostics, and repair.
6. [Journey specifications](specifications/journeys/) — end-to-end behavior,
   interruption, recovery, and durable consequences.
7. [Engineering standards](standards/) — native iOS, SwiftUI/design system,
   accessibility, testing, security/privacy, performance, language, and
   validation/release.

[MANIFEST.toml](MANIFEST.toml) is the deterministic inventory of normative
files and durable references.

The generated [Codex Start Here](generated/CODEX_START_HERE.md),
[Canon Index](generated/INDEX.md),
[machine index](generated/canon-index.json), and
[requirement graph](generated/requirement-graph.json) provide fast entry points
for implementation agents and repository tooling.

## Design canon and references

- [Visual System R1](design/VISUAL_SYSTEM_R1.md) records the reconciled
  provisional cross-surface direction and historical Revision 1 provenance.
  Figma authorization, SwiftUI approval, and implementation authorization are
  false.
- [VC-01–VC-14 Visual Closure Input Contract](design/VISUAL_CLOSURE_INPUT_CONTRACT.md)
  and its JSON peer are the sole active visual-closure baseline. The compiler
  projects that source into the generated visual-authority manifest.
- [Wave 1 Foundation Closure](design/VC_WAVE_1_FOUNDATION_CLOSURE.md) and its
  JSON peer install the closed VC-01 through VC-06 decisions beneath the input
  contract.
- [Wave 2 Surface and Journey Closure](design/VC_WAVE_2_SURFACE_JOURNEY_CLOSURE.md)
  and its JSON peer install the closed VC-07 through VC-12 decisions beneath the
  input contract and closed Wave 1 foundation. VC-14 remains not started, and
  every Figma, SwiftUI, and implementation authorization remains false.
- [Wave 3 Accessibility and Content Stress Closure](design/VC_WAVE_3_ACCESSIBILITY_STRESS_CLOSURE.md)
  and its JSON peer install the closed VC-13 validation beneath the Wave 1 and
  Wave 2 authority. VC-14 remains not started; Figma, SwiftUI, and
  implementation remain unauthorized.
- [Canonical UX Blueprint](migration/UX_BLUEPRINT.md) maps the full screen,
  presentation, state, command, recovery, privacy, and accessibility surface
  back to requirement IDs. Its `migration/` path is retained for link stability;
  it is a design reference, not a migration gate.
- [Visual Authority Rebaseline](migration/VISUAL_AUTHORITY_REBASELINE.md) and
  [Phase 2 Direction](migration/VISUAL_DIRECTION_PHASE_2.md) are historical
  references preserving the reasoning that led to Revision 1; they do not
  control the current VC baseline.
- [VSP design provenance](../design/provenance/README.md) preserves selected
  package decisions, component mappings, Figma nodes, and reference images.
- [Object Boundary Matrix](generated/object-boundary-matrix.md) is a compact
  projection of important object distinctions.

Design references do not override the Constitution or owning product
specification. Figma and screenshots guide implementation; the rendered app
must still pass the applicable build, behavioral, UI, accessibility, privacy,
data-safety, and performance checks.

## Research and architecture references

- The accepted 2026-07-22 reconciliation ADRs define
  [shell/navigation/restoration](../adr/ADR-2026-07-22-shell-navigation-restoration-reconciliation.md),
  [canonical identity and projection](../adr/ADR-2026-07-22-canonical-identity-ownership-projection.md),
  [truth/mutation/global authority](../adr/ADR-2026-07-22-truth-mutation-and-global-authority.md),
  and [local-first recovery/accessibility/platform scope](../adr/ADR-2026-07-22-local-first-recovery-accessibility-platform.md).
- The [reconciled flagship reconstruction plan](../qa/frontend-flagship-shippability-remediation/RECONCILED_FLAGSHIP_RECONSTRUCTION_PLAN.md)
  owns dependency sequencing; the adjacent traceability and supersession
  registers preserve the authority graph and historical evidence.

- [CEBR-01 research package](references/research/cebr-01/README.md) preserves
  the product invention and technical design behind certified executable
  branch reconciliation.
- [Source Atlas scope ADR](../adr/ADR-2026-07-02-source-atlas-scope-freeze.md)
  preserves the public/reference-only boundary and forbids private-life-graph
  egress.

## Maintenance

The product-canon compiler has four commands:

```sh
python3 scripts/ambitions-canon.py build
python3 scripts/ambitions-canon.py check
python3 scripts/ambitions-canon.py query --id LAW-LOCAL-AUTHORITY-001
python3 scripts/ambitions-canon.py query "Today first viewport"
```

`build` validates source canon and regenerates deterministic indexes and the
object-boundary matrix. `check` rejects parse, identity, dependency, concept,
link, structured-data, or generated-output drift. `query` searches exact IDs,
concepts, specifications, or text and reports source locations and ownership.

The compiler intentionally has no task, pack, signing, approval, attestation,
receipt-ledger, status-policing, or merge-authorization command.
