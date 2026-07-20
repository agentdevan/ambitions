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

- [Visual System R1](design/VISUAL_SYSTEM_R1.md) is the selected cross-surface
  visual direction: stable anatomy, structure/semantics/atmosphere layers,
  typography, spatial rhythm, component grammar, appearance, motion, and
  accessibility.
- [Canonical UX Blueprint](migration/UX_BLUEPRINT.md) maps the full screen,
  presentation, state, command, recovery, privacy, and accessibility surface
  back to requirement IDs. Its `migration/` path is retained for link stability;
  it is a design reference, not a migration gate.
- [Visual Authority Rebaseline](migration/VISUAL_AUTHORITY_REBASELINE.md) and
  [Phase 2 Direction](migration/VISUAL_DIRECTION_PHASE_2.md) preserve the
  visual-reconciliation reasoning that led to Revision 1.
- [VSP design provenance](../design/provenance/README.md) preserves selected
  package decisions, component mappings, Figma nodes, and reference images.
- [Object Boundary Matrix](generated/object-boundary-matrix.md) is a compact
  projection of important object distinctions.

Design references do not override the Constitution or owning product
specification. Figma and screenshots guide implementation; the rendered app
must still pass the applicable build, behavioral, UI, accessibility, privacy,
data-safety, and performance checks.

## Research and architecture references

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
