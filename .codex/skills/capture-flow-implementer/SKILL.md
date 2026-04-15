---
name: capture-flow-implementer
description: Implement or modify Ambitions capture flows end-to-end across capture models, persistence, services, routing, screens, and tests. Use when building the captures inbox, wiring capture ingestion, expanding `CaptureSourceType`, or connecting quick capture, Share extension text/URL capture, App Intent capture, and captures-tab routing; for risky or multi-file capture work, start with `phase-executor`, and finish with `ios-qa-regression-checker`; do not use for unrelated generic inbox features that ignore Ambitions capture terminology.
---

# Capture Flow Implementer

## Purpose

Build or change Ambitions capture behavior without collapsing it into a generic task inbox or losing the current capture-domain model.

## When To Use

- `build captures inbox`
- `wire capture service`
- `expand CaptureSourceType`
- implement capture ingestion from Today, Share extension, App Intents, or future routing surfaces

## When Not To Use

- The task is only UI polish with no capture-domain behavior change.
- The request is about general goal planning or Today logic unrelated to captures.
- The user wants a generic inbox redesign that discards current Ambitions capture concepts.

## Required Inputs

- Current capture models and services.
- Current capture screen and routing state.
- Relevant persistence repositories and tests.
- Any requested new source surface such as share or App Intents.

## Execution Steps

0. If the request is risky or crosses multiple layers, require a plan first. Use `phase-executor` or a relevant plan template before editing.
1. Inspect the current capture domain first:
   - `Native/Ambitions/Domain/CaptureModels.swift`
   - `Native/Ambitions/Services/CaptureService.swift`
   - capture repository contracts and implementations in `Native/Ambitions/Persistence/`
   - `Native/Ambitions/Features/Captures/`
2. Verify whether the requested source already exists in some form:
   - Today quick capture
   - Share extension text
   - Share extension URL
   - App Intent
3. Trace the full flow before editing:
   - model type
   - repository persistence
   - service API
   - container exposure
   - screen/tab routing
   - external routing or extension handoff if relevant
4. Choose the first safe slice and keep it bounded. Start with the narrowest change that can land truthfully, such as the model contract before UI copy or tests before routing.
5. Make end-to-end edits for that slice instead of leaving partial stubs. If a new capture source is added, update the layers that should already understand that slice.
6. Self-check after each slice:
   - did the requested seam already exist
   - is the next slice still grounded
   - would the remaining work require a new runtime path
7. Preserve Ambitions capture semantics. Captures are local ingestion records that may later connect to goals or other actions; do not rewrite them into a generic enterprise backlog.
8. Add or update tests around capture creation, listing, status changes, and route wiring.
9. Retry only with a narrower grounded correction when a slice fails. Stop when the remaining work would require inventing a new capture ingestion seam or unsupported runtime flow.
10. Hand off to `ios-qa-regression-checker` after implementation for validation reporting.

Use the checklists in `templates/` when scoping or reviewing the change:

- `templates/capture-model-checklist.md`
- `templates/capture-routing-checklist.md`
- `templates/capture-screen-checklist.md`

## Output Format Expectations

Summaries should cover:

1. capture source or behavior changed
2. layers touched
3. routing/container implications
4. tests added or updated
5. build/manual validation run

## Validation Requirements

- Update or add repository/service tests when capture behavior changes.
- Check that the captures tab still compiles and loads.
- Verify external routing or handoff behavior when the change adds share or intent-driven capture entry.
- Report any manual validation that could not be run.
- Use `templates/execution-report.md`, `templates/retry-decision.md`, and `templates/blocked-work-summary.md` when the work lands in slices instead of one pass.

## Ambitions-Specific Guardrails

- Keep the capture domain in `Native/Ambitions/Domain`, `Services`, `Persistence`, and `Features/Captures`.
- Reuse `CaptureSourceType`, `CaptureStatus`, and current service boundaries instead of inventing a second ingestion model.
- Preserve app-container wiring through `AppContainerFactory`, `AppContainer`, and `AppServices`.
- Re-check `AppExternalRouting` if the change adds deep-link or extension entry points.
- Avoid changing unrelated planning or goal logic unless the capture flow truly requires it.

## Skill Chaining

- Use `phase-executor` first when capture work is risky, multi-file, or seam-uncertain.
- Use `planner-domain-safe-editor` if the request spills into Today/planner behavior.
- Use `ios-qa-regression-checker` after implementation.

## Failure Recovery

- If the requested capture feature would require a runtime seam the repo does not currently have, say so and implement only the supported domain/service/UI portions.
- If the request is really an extension or target-wiring task, switch to `ios-extension-builder` or `xcodegen-target-writer`.
- If validation cannot run, report that explicitly instead of implying runtime support.
- If a narrow slice fails validation for the same grounded reason more than once or twice, stop and report the remaining unsupported portion.

## Trigger Phrases

- `build captures inbox`
- `wire capture service`
- `expand CaptureSourceType`
- `add share extension text capture`
