# AmbitionsOS AOS Privacy Projection Ledger

Status: Active privacy projection ledger

Every external or sensitive projection records source object, projected fields, redacted fields, surface, consent state, fallback, tests, and what is not proven.

## AOS17 Privacy Safety Kernel

Owner: Privacy Safety Kernel.
Status: Green value-contract proof.

Projection rules now represented in code:

- sensitive areas require review before projection
- delete-pending content stays hidden
- blocked external permission cannot use a visible projection policy
- external projection of sensitive/private material requires redaction posture
- external projection requires a redaction summary
- approved projection requires a privacy receipt
- tool-driven projection requires explicit approval and deterministic fallback
- hidden mutation and runtime-store behavior are invalid

Evidence:

- `Native/Ambitions/Domain/AmbitionsOSPrivacySafetyModels.swift`
- `Native/AmbitionsTests/Domain/AmbitionsOSPrivacySafetyModelsTests.swift`
- `docs/audits/aos17-privacy-safety-kernel-report.md`

Not proven:

- external projection runtime
- memory permission persistence
- redaction engine
- source ingestion
- UI disclosure
- physical-device proof
