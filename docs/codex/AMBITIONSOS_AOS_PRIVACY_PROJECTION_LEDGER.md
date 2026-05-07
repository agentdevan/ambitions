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

## AOS18 Evaluation Golden Scenarios

Owner: Evaluation Kernel.
Status: Green value-contract proof.

Projection rules now represented in code:

- privacy-leak scenarios are first-class evaluation inputs
- sensitive or delete-pending scenarios are privacy-sensitive
- external scenarios require `externalRedacted` or `hidden` projection posture
- fixture families can require external-surface redaction coverage
- passed scenarios require evidence links or proof receipts
- hidden mutation and runtime-store behavior are invalid

Evidence:

- `Native/Ambitions/Domain/AmbitionsOSEvaluationModels.swift`
- `Native/AmbitionsTests/Domain/AmbitionsOSEvaluationModelsTests.swift`
- `docs/audits/aos18-evaluation-golden-scenarios-report.md`

Not proven:

- external projection runtime
- redaction engine
- privacy leak scanner
- generated fixture library
- UI disclosure
- legal/privacy compliance
- physical-device proof

## AOS21 Interoperability Kernel App Intents EventKit Planning

Owner: Interoperability Kernel.
Status: Green value-contract proof.

Projection rules now represented in code:

- external interoperability plans require redacted projection for sensitive
  payloads
- source-sensitive calendar/reminder/external suggestions require ready source,
  freshness, and review state before use
- raw sensitive external payloads are blocked
- user-reviewed receipts, performance budgets, and compatibility review are
  required before the plan can pass
- platform writes, permission prompts, external invocation, hosted dependencies,
  hidden mutation, and runtime-store behavior are invalid

Evidence:

- `Native/Ambitions/Domain/AmbitionsOSInteroperabilityModels.swift`
- `Native/AmbitionsTests/Domain/AmbitionsOSInteroperabilityModelsTests.swift`
- `docs/audits/aos21-interoperability-kernel-app-intents-eventkit-planning-report.md`

Not proven:

- App Intent implementation
- EventKit or Reminders implementation
- platform permission prompt behavior
- external writes or invocation
- external projection runtime
- legal/privacy compliance
- physical-device proof

## AOS19 Experience Kernel Celestial Cognitive Load

Owner: Experience Kernel.
Status: Green value-contract proof.

Projection rules now represented in code:

- sensitive or private experience copy requires privacy-safe labels
- canonical user surfaces remain Today, Goals, Capture, Plan, and You
- experience contracts reject hidden mutation and runtime-store behavior
- recovery copy must stay non-shaming before later surface projection
- forbidden release/device/platform and AI/productivity overclaim language is
  rejected before presentation proof

Evidence:

- `Native/Ambitions/Domain/AmbitionsOSExperienceModels.swift`
- `Native/AmbitionsTests/Domain/AmbitionsOSExperienceModelsTests.swift`
- `docs/audits/aos19-experience-kernel-celestial-cognitive-load-report.md`

Not proven:

- UI integration
- rendered simulator proof
- public accessibility conformance
- legal/privacy compliance
- external projection runtime
- physical-device proof

## AOS20 Adaptation Kernel Local Personalization

Owner: Adaptation Kernel.
Status: Green value-contract proof.

Projection rules now represented in code:

- local adaptation requires explicit user controls
- inferred, rejected, hidden, or delete-pending personalization cannot drive use
- rejected, unreviewed, or invisible assumptions are blocked
- sensitive adaptation requires privacy review and user-reviewed receipts
- seriousness changes require user-reviewed receipts
- hidden mutation and runtime-store behavior are invalid

Evidence:

- `Native/Ambitions/Domain/AmbitionsOSAdaptationModels.swift`
- `Native/AmbitionsTests/Domain/AmbitionsOSAdaptationModelsTests.swift`
- `docs/audits/aos20-adaptation-kernel-local-personalization-report.md`

Not proven:

- personalization runtime
- durable memory store
- hidden learning behavior
- privacy-state persistence
- UI disclosure
- legal/privacy compliance
- physical-device proof
