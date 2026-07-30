# Capability Authority Disposition Policy

Status: **non-normative authority audit**

## Purpose

This audit resolves the transient 112-item Capability Atlas v2 draft against the current Ambitions authority system. It does not create product authority, preserve the 112 count as a target, or modify the Constitution, manifest, normative specifications, source, tests, or release state.

## Authority reading order

1. **Constitution** — stable product and engineering invariants.
2. **Manifest-controlled owning specifications and standards** — detailed normative behavior and ownership.
3. **Generated canon graph and traceability** — deterministic projection of current authority.
4. **Source, builds, tests, and runtime evidence** — implementation and verification only.

## Primary dispositions

| Disposition | Meaning |
|---|---|
| `already_authoritative` | The capability is already clearly required by the Constitution and adequately owned by one or more normative specifications. |
| `authoritative_but_fragmented` | The capability exists across several specifications, but its complete person-facing promise is difficult to understand or trace. |
| `valid_subcapability` | The idea is real but is not a standalone top-level capability. |
| `duplicate_or_alias` | The proposal describes the same promise as another capability under different language. |
| `enabling_system_or_mechanism` | The item describes infrastructure, an algorithm, service, projection, adapter, or implementation strategy rather than a person-facing outcome. |
| `genuine_specification_gap` | The Constitution permits or implies the capability, but no normative specification adequately owns its behavior. |
| `genuine_constitutional_proposal` | The capability would materially broaden, narrow, or change Ambitions’ stable product promise. |
| `research_only_hypothesis` | The idea may be strategically useful but lacks enough product definition or evidence to become a promise. |
| `reject` | The proposal is redundant, incoherent, unsafe, category-drifting, dependent on prohibited architecture, or inconsistent with Ambitions. |

## Hard thresholds

A candidate is a **genuine constitutional proposal** only when it would change stable product category, mission, root information architecture, object meaning, privacy or user-control floors, the strategic naming stack, or another constitutional invariant.

A candidate is a **genuine specification gap** when current constitutional law permits or implies the outcome but no existing normative owner defines the complete person-facing contract.

Implementation and verification remain separate. This audit assigns neither.

## Audit invariants

- Exactly one primary disposition per candidate.
- Exact preservation of the nine previously owner-approved identities as ideas, while separating that approval from normative authority.
- No target count, symmetry requirement, or forced eight-per-domain shape.
- No capability label becomes a new object, store, mutation owner, root, or product center.
- Future-gated and inactive authority is reported explicitly.
