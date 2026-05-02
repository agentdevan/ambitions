# Ambitionsos Architecture Review Board

## Members / Skills Invoked

Use the relevant AmbitionsOS skills for architecture, runtime contract, state/projector/view, kernel boundaries, large-file risk.

## Required Source Docs

- `docs/canon/AmbitionsOS_Index.md`
- `docs/canon/AmbitionsOS_Runtime_Contract.md`
- `docs/codex/AMBITIONSOS_AOS_TRAIN_CONTROL_SYSTEM.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/codex/BATCH_REGISTRY.md`

## Required Evidence

Allowed files, forbidden files, validation logs, traceability update, evidence ledger entry, test impact matrix, release-claim impact, rollback/repair plan.

## Questions To Answer

- What owns this?
- What does it affect?
- What must it not do?
- What evidence proves it?
- How do future Codex runs avoid damaging the app?

## Approval Criteria

Green only when source truth, scope, tests, privacy/accessibility/performance/compatibility/release implications, and rollback are explicit.

## Rejection Criteria

Reject broad vague implementation, unsupported release claims, hidden AI/model behavior, dependency drift, workflow changes, app widening, source-certification overreach, and compatibility deletion without proof.

## Yellow Conditions

Advisory backlog, classified validation issue, optional tool absence, or future-only gap with no current app change.

## Red Stop Conditions

Forbidden file touched, unclassified test/build failure, privacy leak, release overclaim, platform overclaim, dependency added, workflow touched, or train dependency violated.

## Required Report Section

Verdict, evidence, risks, accepted Yellow conditions, Red stops if any, and next gate.

## Board-Specific Focus

This board owns kernel boundaries, runtime contract, state/projector/view separation, dependency boundaries, and large-file risk. It is not a generic approval stamp; it must identify the exact owner, affected surfaces, proof required, proof missing, and consequence of proceeding.

## Board-Specific Rejection Examples

- Proceeding because a manifest exists but predecessor evidence is missing.
- Treating advisory simulator or doc proof as release readiness.
- Allowing source-sensitive, privacy-sensitive, compatibility-sensitive, or performance-sensitive changes without the matching ledger update.
- Accepting generated-looking docs or prompts that do not tell the next Codex run what to read, touch, test, report, and stop on.
