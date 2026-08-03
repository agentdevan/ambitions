# Product Development Lifecycle Dual Ruthless Review

**Date:** 2026-08-02  
**Reviewed specification:** `docs/superpowers/specs/2026-08-02-ambitions-product-development-lifecycle-design.md`  
**Final approved specification commit:** `075670830fa32ab7f3f67373b6ef917b8b3781e8`  
**Final verdict:** `PASS`

## Review mandate

Perform two ruthless review passes before approving the lifecycle-system design.
The first pass evaluates the system from the ChatGPT document-producer
perspective. The second evaluates it from the Codex document-consumer and
implementation-grooming perspective. Approval is permitted only when the
committed document can operate without hidden conversation context or unresolved
implementation invention.

## Pass 1 — ChatGPT producer perspective

### Initial verdict

`NEEDS REVISION`

### Blocking findings

1. The design did not make ChatGPT-to-Codex transfer an explicit system boundary.
2. Repository-local Codex skill discovery was implicitly treated as sufficient
   for ChatGPT use.
3. A polished chat response could be mistaken for a persisted lifecycle artifact.
4. The documents lacked explicit authority classes distinguishing evidence,
   product commitment, and implementation design.
5. Upstream bindings used brittle parallel arrays.
6. Review pass claims were not bound to an exact revision and content hash.
7. The proposed semantic hash depended on unverifiable semantic equivalence.
8. The documents lacked a context-efficient consumer entry point.
9. External research could remain link-dependent and unusable offline by Codex.
10. Cross-product package and template identity were not verified.

### Repairs

- Established one canonical portable package with distinct Producer, Content
  Review, and Consumer modes.
- Made the committed repository file the canonical handoff.
- Added exact package and template identity.
- Added document authority classes.
- Replaced parallel arrays with typed input records.
- Added dual review lanes bound to one revision and contract hash.
- Replaced semantic-equivalence hashing with a deterministic contract hash.
- Added the bounded Agent handoff summary.
- Required evidence summaries and hashed local annexes.
- Added a verified ChatGPT deployment path and cross-product fixture.

### Corrective commits

- `c45e2909616c0946ad8766884304c0cdb324d0fb`
- Later review-driven refinements superseded this intermediate revision.

## Pass 2 — Codex consumer perspective

### Initial verdict

`NEEDS REVISION`

### Blocking findings

1. Repository-baseline drift was not attributable to structured paths.
2. Review outcomes were not durably persisted.
3. The contract-hash algorithm was underspecified.
4. Intentional source or canon change was treated the same as undeclared
   conflict.
5. No authoritative command stamped a reviewable document hash.
6. Failed review and stale states lacked a deterministic corrective-revision
   transition.
7. Package and template hashes were required but not reproducibly computed.
8. An author could weaken freshness by omitting a relied-on path.
9. Exact generated-canon dependencies were not named.
10. Historical passed documents could become unverifiable after package
    evolution.

### Repairs

- Added structured owner, dependency, input, and evidence paths.
- Made freshness a CLI-derived set that cannot be weakened manually.
- Added append-only review records with stable IDs.
- Specified the exact frontmatter projection, body normalization, canonical
  serialization, and SHA-256 contract-hash algorithm.
- Added explicit `CANON-DELTA-*` and current-source delta contracts.
- Added authoritative `seal` and deterministic `reconcile --reopen` transitions.
- Added a complete lifecycle state machine.
- Added a canonical package manifest and exact package/template hash algorithms.
- Named all generated canon-routing freshness paths.
- Added baseline-backed historical package verification and active compatibility
  declarations.

### Corrective commits

- `8d14184bf0f99069d16ef4fe4f03da8b7c70361c`
- `581fc28d8830e702e00ac76a9f15f11f57c05b80`
- `ee57f8fa65052d3361bee72442318a9034f60272`
- `cba4fc570f7c3ce4c728bed39343d031b6467207`
- `cb3ba85ef0cfe7e567d2963013f95baa2da0d6b6`

## Final cold-file verification

The final verification treated the approved specification as if Codex received
it in a new session with no access to the originating ChatGPT conversation.

Verified:

- ChatGPT and Codex use one package identity rather than divergent prompts.
- The canonical handoff is repository-persisted and self-contained.
- Research, Scope, and Design have non-overlapping authority classes.
- Every review binds to an authoritative seal, revision, and contract hash.
- All corrective edits pass through a deterministic reopen and revision
  transition.
- Upstream, evidence, repository, package, template, and canon drift are
  inspectable.
- Relevant drift blocks or requires reconciliation; unrelated drift does not.
- Historical package provenance remains verifiable from Git history.
- Codex receives summary-first context and can load deeper sections selectively.
- External evidence remains understandable without live network access.
- Intentional canon and source changes are declared and reconciled rather than
  silently conflicting.
- Design passage provides enough resolved behavior for implementation grooming
  without product invention.
- The system does not introduce merge authorization, owner receipts, or
  process-only branch gates.

## Final review output

```text
Verdict: PASS
Review lane: CONTENT + CONSUMER

Blocking findings
None.

Non-blocking improvements
None required before implementation planning.

Traceability gaps
None at design level.

Stale or conflicting inputs
None affecting implementation planning.

Required revisions
None.

Next permitted lifecycle phase
Detailed implementation planning.
```

## Approval

The specification is approved. The owner stated that assistant approval would
constitute owner approval, so the design has cleared its owner review gate.