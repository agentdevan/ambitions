<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04D-B01 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T04D-B01`

## Train ID and title
`TRAIN_04D` - Capture-to-Runtime Factoring & Future Proof Bridge

## Batch role in train
Batch 1 of 7 in TRAIN_04D

## Upstream dependencies
- `TRAIN_03`
- `TRAIN_04`
- `TRAIN_04A`
- `TRAIN_04B`
- `TRAIN_04C`

## Downstream dependencies
- `TRAIN_04E`
- `TRAIN_05`
- `TRAIN_06`
- `TRAIN_07`
- `TRAIN_08`

## Objective
Extract structured runtime meaning from capture text without cloud/LLM dependency.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, status board, chatbot, AI wrapper, SaaS admin panel, or ranking-based productivity framing.

## Local-first/privacy constraints
Extraction, raw text, traces, and ambiguity states remain local-first. Do not infer sensitive facts silently or write sensitive details to logs/external surfaces.

## Accessibility constraints
Clarification prompts must be VoiceOver-readable, Dynamic Type-safe, Reduce Motion-safe, and not color-only.

## Performance constraints when relevant
Do not regress launch, scrolling, persistence, or runtime responsiveness. Do not claim performance validation without measured proof.

## Champion Merge source boundary
- Champion Merge final status is accepted Yellow, not Red; IOS26 work may proceed only inside the no-claim boundaries below.
- Before source edits, inspect `docs/codex/canonical-owner-map.yml`, `docs/codex/concept-lock-registry.yml`, and `build/reports/intelligence-consolidation/TRAIN_04L_CLOSEOUT.md`.
- Extend the canonical owner for any touched concept. Do not create a new parallel owner or revive retired duplicate object names as active source/UI terms.
- Keep unresolved Yellow concepts locked against ordinary feature claims until their follow-up gate is Green or owner-accepted.
- `capture_root` owns Capture parser/routing/SmartAttachment work under `Native/Ambitions/Features/Capture`, `Native/Ambitions/Services/CaptureService.swift`, and `Native/Ambitions/Services/SmartAttachmentService.swift`.
- Champion Merge Yellow: broad Capture runtime gauntlet remains unproven; do not claim full Capture runtime consolidation until that gate is Green or owner-accepted.

## Allowed files/directories
- Extend current Smart Attachment routing with typed semantic extraction.
- Add or connect `CaptureSemanticExtraction`, `CaptureTimeInterpretation`, and activity classification models.
- Detect activity/action/time/location/people/equipment/facility/recurrence/proof/blocker/recovery signals.
- Identify ambiguity and ask compact clarification when needed.
- Preserve raw text and store extraction trace locally.
- Add deterministic tests and `build/reports/capture-runtime-bridge/semantic-extraction.md`.

## Forbidden files/directories
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

## Exact implementation steps
1. Re-read active truth files and confirm dependencies.
2. Inspect current Capture and Smart Attachment routing.
3. Define typed extraction and time interpretation contracts.
4. Implement local deterministic extraction for the required examples.
5. Preserve raw text and trace even when extraction is partial.
6. Route ambiguous captures to clarification and safe fallback.
7. Prove extraction does not schedule, attach, or mutate by itself.

## Validation commands
```bash
make xcode-focused-test BATCH=IOS26-T04D-B01 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04D-B01 TEST=AmbitionsUITests
```

## Proof artifacts to write
- `build/reports/capture-runtime-bridge/semantic-extraction.md`
- `build/reports/ios26-baseline/`
- `build/reports/ios26-migration/`
- `build/reports/ios26-shell/`
- `build/reports/private-life-runtime/`
- `build/reports/goal-intent-compiler/`
- `build/reports/life-context/`
- `build/reports/step-optionality/`
- `build/reports/source-atlas-runtime-bridge/`
- `build/reports/capture-runtime-bridge/`
- `build/reports/core-replacement-contracts/`
- `build/reports/core-life-object-store/`
- `build/reports/time-operations/`
- `build/reports/reminder-operations/`
- `build/reports/project-step-operations/`
- `build/reports/life-knowledge-operations/`
- `build/reports/life-command-search/`
- `build/reports/private-life-runtime-integration/`
- `build/reports/reality-meridian/`
- `build/reports/lifeshape-field/`
- `build/reports/constellation-atlas/`
- `build/reports/atmosphere-composer/`
- `build/reports/user-system-profile/`
- `build/reports/proof-receipts-replay/`
- `build/reports/data-safety/`
- `build/reports/external-surfaces/`
- `build/reports/accessibility-nutrition/`
- `build/reports/performance/`
- `build/reports/repo-hygiene/`
- `build/reports/release-candidate/`

## Green / Yellow / Red gates
Green: structured extraction exists for every required example; ambiguous 8 o'clock clarifies; raw text is preserved; no schedule/goal mutation occurs; no sensitive logs.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: capture text is lost, cloud/LLM dependency is added, sensitive data is inferred/used silently, or extraction mutates schedule/goals.

## Rollback behavior
Rollback only files touched by IOS26-T04D-B01 and preserve unrelated dirty work.

## Claims allowed
- This batch may claim only source, test, and proof outcomes directly demonstrated by current logs and artifacts.
- Docs-only or tooling-only changes must be described as docs-only or tooling-only.

## Claims forbidden
- No release readiness, TestFlight readiness, App Store readiness, CI proof, device proof, accessibility verification, performance validation, privacy/legal approval, or Private Life Runtime moat completion without matching current proof.

## Final report required fields
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

## STATUS placeholder
STATUS: <GREEN|YELLOW|RED>

## Original prompt intent retained
The original prompt text is retained below for intent preservation. The sealed sections above are the execution boundary.

----- BEGIN ORIGINAL PROMPT -----
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
----- END ORIGINAL PROMPT -----
