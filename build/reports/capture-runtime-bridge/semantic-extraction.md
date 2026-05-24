# IOS26-T04D-B01 Semantic Extraction Report

## Scope
- Local deterministic semantic extraction attached to Smart Attachment routing.
- No cloud inference, no external analytics, no calendar mutation, no goal attachment mutation.
- Raw text remains preserved on the Smart Attachment result and in the extraction payload.

## Contract
- `CaptureSemanticExtraction`
- `CaptureTimeInterpretation`
- `CaptureActivityClassification`
- `CaptureSemanticUncertaintyFlag`
- `CaptureGoalDomainHint`

## Required Examples
- `play pickleball at 8 next Tuesday`
- `ran 2 miles today`
- `finished chest workout`
- `call coach Friday`
- `YMCA open court`
- `mountain bike trail closed`
- `ankle hurt after practice`
- `worked late again`
- `guitar lesson every Wednesday`
- `met Sarah for study group`

## Local Heuristics
- Time expressions are parsed deterministically from the capture text.
- Bare `8` is treated as ambiguous without AM/PM unless context resolves it.
- Proof, blocker, and recovery signals are detected locally from keywords.
- People hints are limited to explicit text evidence and do not infer sensitive identity facts.

## Proof Boundaries
- This report claims focused unit/runtime tests passed for the semantic extraction slice only.
- This report does not claim the extraction is exhaustive or natural-language complete.
- This report does not claim scheduling, attachment, or calendar side effects.
- This report does not claim UI-test proof, manual UI proof, accessibility verification, device proof, performance proof, privacy/legal approval, TestFlight readiness, App Store readiness, or release readiness.

## Validation
- Passed: `git diff --check -- <IOS26-T04D-B01 approved paths>`.
- Passed: `make xcode-focused-test BATCH=IOS26-T04D-B01 TEST=AmbitionsTests`.
  - Wrapper summary: `.codex/xcode-summaries/IOS26-T04D-B01/20260524T005725Z/validate-summary.json`.
  - Status: passed.
  - Duration: 324 seconds.
  - Slow validation: true.
- Yellow: `make xcode-focused-test BATCH=IOS26-T04D-B01 TEST=AmbitionsUITests`.
  - Result: no pass/fail summary was emitted.
  - Reason: the wrapper hung in an existing `TodayStartHereShowAnother` UI test path unrelated to the semantic extraction source slice and was terminated.
  - Owner: iOS validation/UI harness follow-up.
  - No-claim boundary: this batch does not claim UI-test coverage or visual/accessibility proof.

## Closeout
- Status: Yellow.
- Acceptance rationale: semantic extraction source contract, capture routing exposure, required examples, raw-text preservation, and AM/PM clarification behavior are covered by passing focused tests; required UI wrapper proof is blocked by an existing hung Today UI test path.
- Follow-up gate: repair or isolate the `TodayStartHereShowAnother` UI test lane before treating B01 as Green or using it as UI validation proof.
