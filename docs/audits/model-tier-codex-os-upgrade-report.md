# Model Tier Codex OS Upgrade Report

Date: 2026-05-08
Result: Green as Codex OS governance evidence.
Scope: docs-only Codex OS upgrade for Mini/Senior autonomous batch-train routing.

## Summary

This pass upgrades Ambitions Codex OS so future runs can use a cost-efficient Mini Execution Tier while preserving a separate Senior Judgment Tier for proof-sensitive gates.

It adds model-tier policy, Mini/Senior resume aliases, a deferral ledger, a batch routing matrix, and wires the behavior into the normal Codex OS entry points.

No production Swift, app behavior, route/raw-value, persistence/schema, dependency, signing, entitlement, workflow, sync/cloud, hosted AI, user-data-server, device, release, legal/privacy, or public accessibility behavior changed.

## Files Added

- `docs/codex/MODEL_TIER_EXECUTION_POLICY.md`
- `docs/codex/MODEL_TIER_DEFERRAL_LEDGER.md`
- `docs/codex/RESUME_MINI_GLOBAL_BATCH_TRAIN.md`
- `docs/codex/RESUME_SENIOR_GLOBAL_BATCH_TRAIN.md`
- `docs/codex/MODEL_TIER_BATCH_MATRIX.md`

## Files Modified

- `AGENTS.md`
- `docs/codex/CODEX_OS_INDEX.md`
- `docs/codex/CODEX_BATCH_TRAIN_PROTOCOL.md`
- `docs/codex/RESUME_GLOBAL_BATCH_TRAIN.md`
- `docs/codex/CODEX_OS_PEAK_OPERATING_PROTOCOL.md`

## Behavior Added

### Mini Execution Tier

Mini may run bounded batches when source truth, allowed files, proof requirements, and validation are explicit.

Mini must not close senior-only gates Green. It must defer non-blocking senior-only work to the model-tier deferral ledger or stop Red when the gate is blocking.

### Senior Judgment Tier

Senior must inspect the deferral ledger, resolve blocking deferrals, and own final judgment-heavy gates such as founder acceptance, visual QA closeout, release-claim safety, legal/privacy wording, public accessibility wording, route/raw-value retirement, persistence/schema risk, sync/cloud/backend runtime, and final handoff.

### Deferral Ledger

Model-tier deferral is now a first-class state. It is not Green and not ordinary Yellow. It is a controlled Mini skip with a Senior obligation.

### Batch Matrix

Remaining batch families now have concrete model-tier routing:

- AFI09-AFI12: Mini-safe with proof lock.
- AFI13-AFI16: Senior-review / Senior-only.
- LDI15-LDI16: Mini-safe with proof lock.
- LDI20-LDI21: Mini-safe with proof lock / Senior-review.
- LDI17-LDI19: Senior-only unless explicitly scoped as docs-only or local value-model work.
- LDI22: Senior-review.
- AOS24-AOS26: Senior-review with Mini implementation slices.
- FCP27-FCP30: Senior-review / Senior-only.
- PFC31-PFC35: Senior-review with Mini implementation slices.
- PFC34 and PFC36-PFC40: Senior-only.
- AOS27-AOS30: Senior-only unless explicitly sliced.
- Conditional compatibility retirements: Senior-only.
- RHC01-RHC06: Mini-safe for non-destructive inventories; Senior-only for destructive cleanup.

## Validation

Verified through GitHub file reads after write:

- `docs/codex/MODEL_TIER_EXECUTION_POLICY.md` exists and includes model-tier detection, Mini Green rules, senior-only gates, deferral protocol, Senior responsibilities, alias behavior, batch report additions, Hard Red additions, and no-claim boundaries.
- `docs/codex/MODEL_TIER_BATCH_MATRIX.md` exists and includes routing for remaining known batch families.
- `docs/codex/CODEX_OS_INDEX.md` includes MTX as the seventh Codex OS subsystem and references model-tier policy, matrix, deferral ledger, and Mini/Senior aliases.

Local Mac validation was not run from this GitHub connector session. No build, test, simulator, screenshot, device, accessibility, performance, release, legal/privacy, or App Store/TestFlight proof is claimed.

## No-Claim Boundary

This upgrade does not claim that `gpt-5.4-mini` equals `gpt-5.5`. It creates rails so Mini can run fast without corrupting senior judgment gates.

This upgrade does not claim autonomous production readiness, release readiness, public accessibility conformance, legal/privacy approval, physical-device proof, signed archive proof, TestFlight readiness, App Store readiness, or human/founder acceptance.

## Recommended Use

Use:

```text
resume mini global batch train
```

for high-volume bounded execution.

Use:

```text
resume senior global batch train
```

for deferred gates, final visual/founder/release/legal/privacy/device/handoff judgment, or any Red caused by model-tier limits.

## Next Eligible Work

Resume from live repo evidence, not this report. At report creation, current operating docs indicate AFI09 Time LifeShape Field is the next eligible global batch unless newer repo evidence proves a dirty or half-complete batch, blocking prerequisite, or senior-only model-tier stop.
