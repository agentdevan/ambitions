# Ambitions Capability Atlas Program

This directory contains the non-normative discovery, reconciliation, and owner-review work used to build the Ambitions Capability Atlas.

The Capability Atlas answers a different question from implementation inventory or detailed canon:

> What durable, user-facing promises is Ambitions intended to fulfill, regardless of whether they are implemented today?

## Authority boundary

Nothing in `docs/capabilities/` is canonical product authority unless and until an owner-approved capability is installed beneath `docs/canon/product/`, registered in `docs/canon/MANIFEST.toml`, and accepted by the canon compiler.

Repository discovery must preserve ideas and evidence without silently declaring them valid, invalid, duplicated, obsolete, or implementation-ready.

Existing Constitution, specifications, ADRs, visual closure authority, requirement IDs, and local-first law remain controlling throughout discovery.

## Reading order

1. `CAPABILITY_MODEL.md` — capability identity, exclusions, lifecycle dimensions, evidence rules, and governance.
2. `seed-capabilities.json` — owner-originated capability seeds preserved before repository reconciliation.
3. `discovery-source-register.json` — source families and coverage requirements for repository archaeology.
4. `candidate-capabilities.json` — raw and qualified candidate inventory once discovery begins.
5. `CAPABILITY_TAXONOMY.md` — product-meaning ontology after extraction.
6. `CAPABILITY_RECONCILIATION.md` — duplicate, alias, conflict, and canonical-name proposals.
7. `DRAFT_CAPABILITY_ATLAS.md` — non-normative product promises.
8. `DRAFT_CAPABILITY_TRACEABILITY.md` — draft Product Genome links.
9. `DRAFT_CAPABILITY_GAP_REPORT.md` — missing specification, ownership, architecture, surface, test, proof, and governance links.
10. `OWNER_DECISION_PACKET.md` — bounded decisions required before canonical installation.

## Program gates

1. Foundation
2. Discovery and extraction
3. Taxonomy and reconciliation
4. Product-promise drafting
5. Traceability and gap analysis
6. Owner decisions
7. Canon installation and compiler integration
8. Validation and closeout

A later gate may not silently rewrite a decision from an earlier gate. New evidence must be recorded with provenance and routed through an explicit amendment.

## Current state

- Program branch: `codex/capability-atlas-foundation`
- Current gate: Foundation
- Canon impact: None
- Owner seeds preserved: Eight
- Implementation state: Deliberately not assessed during foundation
