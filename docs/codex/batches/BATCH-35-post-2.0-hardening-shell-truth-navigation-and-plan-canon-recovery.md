# Batch 35 — Post-2.0 Hardening 01 / Shell Truth, Navigation, and Plan Canon Recovery

## Status

Completed

## Goal

Restore shell truth across the app and repo by reconciling top-level information architecture and navigation with canon, recovering Plan as a real canonical weekly-shaping surface, and eliminating top-level shell/product-spec disagreement.

This batch is the first step of the post-2.0 whole-repo/app hardening wave. It is foundational hardening and productization work, not a continuation of the Ambitions 2.0 intelligence buildout and not the later UI/UX excellence wave.

## In Scope

- top-level shell truth
- tab structure and navigation correction
- Plan canon recovery as a first-class weekly-shaping surface
- shell/product-spec alignment
- route and surface truth needed to stabilize the rest of the hardening wave

## Out Of Scope

- new intelligence engines or runtime capabilities
- speculative Ambitions 3.0 work
- broad visual redesign
- secondary-surface productization beyond what is required to stabilize shell truth
- release-readiness consolidation work that belongs in later hardening batches

## Dependency Rules

- treat Batch 34 as complete and preserved historical truth
- do not start Batch 36 implementation while Batch 35 is unstable
- settle shell truth before external-surface validation
- keep this work focused on hardening/productization rather than net-new capability
- keep the later UI/UX excellence wave out of this batch

## Exit Criteria

- shell truth is explicitly aligned with canon
- top-level IA and navigation no longer disagree with the product spec
- Plan is restored as a real canonical weekly-shaping surface
- the active shell no longer carries unresolved top-level product-truth disagreement
- Batch 36 can validate external/trust surfaces against a settled shell

## What Landed

- restored the canonical five-tab top-level shell:
  - Today
  - Goals
  - Plan
  - Insights
  - Profile
- added a real first-class Plan surface under `Native/Ambitions/Features/Plan/` as a narrow weekly-shaping surface built from existing goals, drafts, steps, captures, evidence, feedback, and habit-like semantics already present in the repo
- preserved legacy `.captures` and `.habits` tab values as compatibility inputs while normalizing them into subordinate navigation truth:
  - Captures routes under Today
  - Habits routes under Plan
- updated root navigation and shell consumers so the app no longer depends on a six-tab overflow model
- tightened deep-link, payload, and external-route truth so canonical `ambitions://tab/plan` is supported and older captures/goal/step routine surface payloads still resolve safely into the new shell map
- aligned preview wiring and profile copy with the settled shell truth
- added focused shell, routing, Plan, and UI coverage for:
  - canonical five-tab truth
  - legacy tab normalization
  - canonical Plan presence
  - Today to Captures subordinate reachability
  - Plan to Habits subordinate reachability

## What Did Not Land

- no Batch 36 external-surface validation or trust cleanup beyond the shell/routing compatibility needed to settle Batch 35 truth
- no premium redesign or later UI/UX excellence wave work
- no new intelligence-engine behavior, ranking changes, or planner heuristics
- no broad secondary-surface productization beyond the minimum needed to make Plan real and keep Captures/Habits intentionally reachable

## Validation That Actually Ran

- `xcodegen generate`
  - passed
- native simulator build:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
  - passed
- targeted shell, routing, and Plan coverage:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/AppShellNavigationTests -only-testing:AmbitionsTests/ExternalRoutingTests -only-testing:AmbitionsTests/PlanFeatureServiceTests test`
  - passed
  - result: 26 tests, 0 failures
- full native unit suite:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests test`
  - passed
  - result: 336 tests, 0 failures
- full native UI suite:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsUITests test`
  - passed
  - result: 4 tests, 0 failures
- manual simulator follow-up:
  - canonical five-tab shell confirmed
  - Plan confirmed visible as a first-class surface
  - Today subordinate Captures flow exercised
  - Plan subordinate Habits flow exercised
  - shell/product-spec drift no longer visible in the top-level navigation model

## Compatibility Notes

- stored preferred-tab values of `.captures` now normalize to Today on load/save
- stored preferred-tab values of `.habits` now normalize to Plan on load/save
- legacy `ambitions://tab/captures` and equivalent payloads route safely into Today-owned Captures navigation
- legacy `ambitions://tab/habits` and equivalent payloads route safely into Plan-owned Habits navigation
- explicit captures inbox routes remain supported
- Goal Detail routing remains owned by Goals and remains compatible with the settled shell

## Completion Notes

- Batch 35 delivered the shell correction the hardening wave depended on without pulling forward Batch 36 or the later UI/UX wave
- Plan now exists as a truthful first-class weekly-shaping surface rather than a missing canon role
- Captures and Habits remain intentionally reachable without continuing the old six-tab overflow drift
- no additional Batch 35 implementation bug was identified during wrap-up
- the checked-out branch remained `main` during implementation, validation, and wrap-up

## Completion Rule

Batch 35 is complete only when shell truth, navigation truth, and Plan canon recovery are landed and validated clearly enough to make external-surface validation in Batch 36 trustworthy.
