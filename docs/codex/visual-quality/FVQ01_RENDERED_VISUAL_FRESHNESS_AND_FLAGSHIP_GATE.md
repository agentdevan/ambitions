# FVQ01 Rendered Visual Freshness And Flagship Gate
<!-- markdownlint-disable MD013 -->

Status: Active-scope Codex OS visual quality gate. Queued before the next safe global batch after the currently running batch completes.
Date: 2026-05-05
Gate code: FVQ01

## Purpose

FVQ01 prevents Ambitions from passing implementation batches that are structurally correct but visually prototype-level.

Codex is good at satisfying typed contracts, tests, and docs. A flagship iPhone app also requires rendered visual proof. FVQ01 makes visual execution evidence-bound, simulator-freshness-bound, and blocking when the rendered UI looks like a debug surface, scaffold, dashboard, or generic agent-built SwiftUI app.

This gate exists because FCP05/FCP07/FCP13A/FCP08 can all pass object/shell contracts while a local simulator can still show a Today view that looks like a component proof screen. That is not acceptable for Ambitions' final quality bar.

## Non-Negotiable Visual North Star

Ambitions must look and feel like a premium iPhone-native flagship app, not a generated prototype.

The visual bar is:

- 70% Apple quiet luxury
- 20% OpenAI intelligence
- 10% executive command surface
- familiar at the macro shell level
- invented at the object/chrome level
- native at the interaction level
- expensive at the material level
- adaptive at the state level
- emotionally mature at trust/recovery
- impossible to mistake for generic Codex output

Locked tagline:

> Find your life. Keep your promises. Build your future. Enjoy today.

## What FVQ01 Must Prove

FVQ01 must prove all of the following before later visual/product-object batches continue without a visual warning:

1. The simulator is running the latest repo HEAD or the report explicitly proves why it is not.
2. The app was clean-built or otherwise freshness-verified.
3. The screenshot evidence is durable and committed or referenced by durable audit paths, not only temporary simulator paths.
4. The rendered UI is scored against a concrete flagship visual rubric.
5. Any visual gap is classified as Green, Accepted Yellow, Recoverable Red, or Hard Red.
6. Scaffold/debug/proof language is treated as a visual failure, not an acceptable implementation detail.
7. Codex cannot call a flagship visual batch Green solely because code compiles and tests pass.

## Simulator Freshness Standard

Every rendered visual proof batch must record:

- repo HEAD SHA
- latest remote SHA after `git fetch origin`
- current branch
- selected simulator device
- simulator runtime
- build configuration
- scheme
- build timestamp
- app install status: fresh install, reset app data, or dirty install
- app build SHA if available
- app build number/version if available
- whether the screenshot came from the same HEAD as the batch report

If the app cannot expose build SHA yet, FVQ01 must add or specify a debug/test-only freshness proof mechanism before visual screenshots can be trusted.

Acceptable freshness mechanisms:

- generated `BuildInfo.swift` excluded from sensitive user-facing surfaces
- debug-only About row
- test-only accessibility value
- launch log captured in report
- screenshot metadata sidecar JSON
- app setting visible only in debug builds

Freshness proof must not expose private data, secrets, signing identifiers, or user content.

## Durable Visual Evidence Standard

Temporary screenshot paths are not enough.

Required destination:

`docs/audits/visual-evidence/fvq01/`

Required files where tooling permits:

- `today-default.png`
- `today-private.png`
- `today-overloaded.png`
- `today-stale-source.png`
- `today-recovery-closure.png`
- `today-dynamic-type.png`
- `today-reduce-motion.png`
- `today-accessibility-summary.md`
- `screenshot-freshness.json`

If a fixture state does not exist, FVQ01 must record that as Accepted Yellow with owner and required future fixture batch.

## FAANG Flagship Visual Rubric

Rendered Today must score at or above the pass bar in every category.

| Category | Pass bar | Red condition |
| --- | ---: | --- |
| Native iPhone believability | 9/10 | Looks like web/dashboard/prototype UI. |
| Premium material quality | 9/10 | Flat gray cards, muddy hierarchy, cheap gradients, generic glass. |
| Start Here dominance | 9/10 | Start Here is not the unmistakable daily decision object. |
| Reality Rail continuity | 9/10 | Rail reads as an explanatory card or disconnected module. |
| Ambition Meridian shell | 9/10 | Shell feels like generic tab bar or debug chrome. |
| Found Life alignment | 9/10 | Screen does not express life clarity, promises, future, and today. |
| Receipt/trust expression | 9/10 | Trust is hidden, noisy, toast-only, or generic status text. |
| Cognitive load | 9/10 | Too many equal-weight modules, metrics, pills, or labels. |
| No dashboard/card-stack drift | 10/10 | Multiple stacked dashboard panels or generic cards dominate. |
| No scaffold/debug language | 10/10 | Component labels/proof pills/debug copy are visible as primary UI. |
| Accessibility/readability | 9/10 | Meaning depends on color, small text, motion, or weak labels. |
| Reduced Motion equivalent | 9/10 | Motion carries meaning with no static equivalent. |
| Screenshot freshness proof | 10/10 | Cannot prove current build/HEAD. |

## Hard Visual Red

FVQ01 must classify Hard Visual Red if any of these persist after one focused repair attempt:

- Today looks like a component demo or proof screen.
- A giant explanatory Reality Rail card is the dominant visual object.
- Internal pills like `Start here`, `Now / Next / Later`, or `Close the loop` function as primary UI scaffolding rather than mature affordances.
- Start Here is not clearly the primary decision surface.
- The UI looks like a generic SwiftUI card stack.
- The UI looks like a dashboard.
- The Meridian shell feels like a rough prototype.
- The screenshot cannot be proven fresh against the current HEAD.
- Codex would need to weaken canon, delete tests, fake screenshots, or ignore source truth to pass.

## Recoverable Visual Red

Recoverable Red examples:

- stale simulator build likely but not proven
- screenshot captured only in temp path
- screenshot fixture missing
- visual hierarchy too flat but repairable in Today/AppShell scope
- scaffold labels visible but removable without architecture changes
- material depth weak but repairable through existing primitives
- Start Here and Reality Rail disconnected but repairable in Today composition

Recoverable Red must be repaired or split into a narrow repair batch. It cannot silently continue as Green.

## Accepted Yellow

Accepted Yellow is allowed only when:

- visual issue does not break flagship direction,
- future owner batch is explicit,
- screenshot evidence is still durable,
- no Hard Red condition remains,
- user-facing claims remain bounded.

Examples:

- physical-device proof not available
- human design review pending
- one fixture missing but default screenshot passes
- Dynamic Type screenshot unavailable due tooling, with static accessibility summary provided

## Required Repair Behavior

FVQ01 must prefer focused repairs before continuing:

- reduce scaffold/proof copy
- make Start Here visually primary
- transform Reality Rail from explanatory card into connected rail/spine
- reduce pill clutter
- improve premium material hierarchy
- improve header/tab/safe-area polish
- preserve five locked tabs
- preserve accessibility and reduced-motion equivalents
- preserve trust/source/privacy contracts
- avoid route/raw-value/persistence/schema/sync/legal/release changes

## Required Report

Write:

`docs/audits/fvq01-rendered-visual-freshness-and-flagship-report.md`

The report must include:

- result
- current batch state when inserted
- repo HEAD SHA
- remote SHA
- app build SHA/freshness proof
- simulator/device/runtime
- clean build/fresh install proof
- screenshots saved
- visual rubric table with numeric scores
- direct comparison to Ambitions canon
- visual issues found
- repairs made or deferred
- accepted Yellow items
- Red classification if any
- rollback path
- next eligible batch

## No-Claim Boundary

FVQ01 does not claim Apple Design Award readiness, public accessibility conformance, App Store readiness, TestFlight readiness, legal/privacy compliance, physical-device proof, or final visual signoff.

It proves whether current rendered simulator output is credible enough to continue the global train without hiding visual debt.
