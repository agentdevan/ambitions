<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04D-B01 - Capture semantic extraction

## Objective
Extract structured runtime meaning from capture text without cloud/LLM dependency.

## Why this exists
Capture must preserve raw user intent while producing a local, typed extraction trace that can safely feed later review, goal relevance, plan insertion candidates, future context, receipts, and replay.

## Dependencies
TRAIN_03, TRAIN_04, TRAIN_04A, TRAIN_04B, TRAIN_04C, TRAIN_04D, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.

## Truth files to read
- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `project.yml`
- `Package.swift`

## Exact source areas to inspect
- `Native/Ambitions/Features/Capture/`
- `Native/Ambitions/Features/Captures/`
- `Native/Ambitions/Services/SmartAttachmentService.swift`
- `Native/Ambitions/Domain/SmartAttachmentPlacementPreview.swift`
- Runtime
- Goal compiler
- Recommendation engine
- Source Atlas runtime bridge
- Life Context
- Time
- Goals
- Today
- You
- Persistence
- Receipts
- Replay
- `Native/AmbitionsTests`
- `Native/AmbitionsUITests`
- Preview fixtures

## Exact changes allowed
- Extend current Smart Attachment routing with typed semantic extraction.
- Add or connect `CaptureSemanticExtraction`, `CaptureTimeInterpretation`, and activity classification models.
- Detect activity/action/time/location/people/equipment/facility/recurrence/proof/blocker/recovery signals.
- Identify ambiguity and ask compact clarification when needed.
- Preserve raw text and store extraction trace locally.
- Add deterministic tests and `build/reports/capture-runtime-bridge/semantic-extraction.md`.

## Exact changes forbidden
- no cloud dependency
- no LLM dependency
- no hidden profiling
- no sensitive inference without review
- no silent calendar mutation
- no silent goal attachment
- no top-level IA changes
- no generic capture inbox dashboard
- no sensitive logs
- no external analytics dependency
- no App Store/privacy/accessibility overclaims

## Required runtime objects
`CaptureSemanticExtraction` fields:
- rawText
- normalizedText
- activity
- actionVerb
- object
- dateTimeExpression
- interpretedDateTime
- durationEstimate
- locationHint
- peopleHint
- recurrenceHint
- equipmentHint
- facilityHint
- goalDomainHints
- proofSignal
- blockerSignal
- recoverySignal
- uncertaintyFlags
- needsClarification

`CaptureTimeInterpretation` fields:
- originalExpression
- interpretedStart
- interpretedEnd
- timezone
- ambiguity: none / amPm / date / duration / recurrence / location / other
- requiresUserConfirmation
- confidenceBand
- explanation

## Implementation steps
1. Re-read active truth files and confirm dependencies.
2. Inspect current Capture and Smart Attachment routing.
3. Define typed extraction and time interpretation contracts.
4. Implement local deterministic extraction for the required examples.
5. Preserve raw text and trace even when extraction is partial.
6. Route ambiguous captures to clarification and safe fallback.
7. Prove extraction does not schedule, attach, or mutate by itself.

## Tests to add/update
- "play pickleball at 8 next Tuesday"
- "ran 2 miles today"
- "finished chest workout"
- "call coach Friday"
- "YMCA has open court"
- "mountain bike trail closed"
- "ankle hurt after practice"
- "worked late again"
- "guitar lesson every Wednesday"
- "met Sarah for study group"
- Ambiguous 8 o'clock requires AM/PM clarification unless context resolves it.
- Raw text remains preserved.
- Extraction does not schedule or attach by itself.
- No sensitive logs.

## Commands to run
```bash
make xcode-focused-test BATCH=IOS26-T04D-B01 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04D-B01 TEST=AmbitionsUITests
```

## Required proof artifacts
- `build/reports/capture-runtime-bridge/semantic-extraction.md`

## Accessibility requirements
Clarification prompts must be VoiceOver-readable, Dynamic Type-safe, Reduce Motion-safe, and not color-only.

## Privacy/local-first requirements
Extraction, raw text, traces, and ambiguity states remain local-first. Do not infer sensitive facts silently or write sensitive details to logs/external surfaces.

## iOS 26 API verification requirements
Any iOS 26 API use must be verified against the deployment target and recorded in the proof artifact.

## Green / Yellow / Red closeout rules
Green: structured extraction exists for every required example; ambiguous 8 o'clock clarifies; raw text is preserved; no schedule/goal mutation occurs; no sensitive logs.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: capture text is lost, cloud/LLM dependency is added, sensitive data is inferred/used silently, or extraction mutates schedule/goals.

## Rollback strategy
Rollback only files touched by IOS26-T04D-B01 and preserve unrelated dirty work.

## Final report format
```text
Status:
Files changed:
Extraction proof:
Ambiguity proof:
Tests run:
Validation not run:
Claims allowed:
Claims forbidden:
Yellow/Red items:
Next batch:
```
