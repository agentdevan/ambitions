# Ambitions

Ambitions is a native iPhone app for turning long-term goals into grounded daily execution.

It helps you capture what is on your mind, place it into goals or plans, choose what matters today, and close the loop with proof.

```text
Capture -> Place -> Plan -> Do Today -> Close / Recover -> Save Proof
```

## Current status

Ambitions is under active native iOS development.

- Platform: iOS 17+
- UI: SwiftUI
- Project generation: XcodeGen
- Data posture: local-first / on-device first
- Validation posture: local VM/Mac validation only
- Release posture: not App Store-ready, not TestFlight-claimed, not physical-device validated

## Product model

Ambitions has five top-level surfaces:

- Today — what matters now
- Goals — long-term direction
- Capture — low-friction intake
- Plan — capacity and shaping
- You — preferences, trust, privacy, and control

The active product and design source truth starts in [`docs/AmbitionsCanon/README.md`](docs/AmbitionsCanon/README.md).

## What is implemented today

The repo currently contains:

- a native SwiftUI app target
- local SwiftData-backed persistence foundations
- Today, Goals, Capture, Plan, and You surfaces
- capture and goal creation flows
- planning, proof, receipt, notification, external-routing, widget, Live Activity, share-extension, and calendar/reminder foundations where implemented
- local build and validation scripts
- unit and UI test targets

See [`docs/status/current-implementation-map.md`](docs/status/current-implementation-map.md) for the current evidence-based implementation map.

## What is not claimed yet

This repo does not currently claim:

- account sync
- production cloud backend behavior
- hosted CI proof
- signed release archive proof
- TestFlight readiness
- App Store readiness
- physical-device validation
- public accessibility conformance
- legal/privacy compliance signoff
- human release approval

See [`docs/status/release-evidence-packet.md`](docs/status/release-evidence-packet.md) for the current release evidence posture.

## Run locally

Prerequisites:

- macOS
- Xcode 16+
- XcodeGen

Generate the project:

```bash
xcodegen generate
open Ambitions.xcodeproj
```

Or run the local unsigned simulator build script:

```bash
./scripts/build-local.sh
```

Full local build, test, archive, and release-validation guidance lives in [`docs/native-build-and-release.md`](docs/native-build-and-release.md).

## Validation

Ambitions uses local VM/Mac validation as the source of truth.

Primary local evidence paths:

- `./scripts/build-local.sh`
- `xcodegen generate`
- `xcodebuild` simulator build
- `xcodebuild` unit tests
- `xcodebuild` UI tests
- unsigned archive sanity checks
- terminal logs saved under `output/logs/` or equivalent local proof packets

There is no active hosted CI workflow in this repo. Add hosted CI only after an explicit cost/billing decision.

Local simulator validation is useful engineering evidence. It is not signed archive proof, TestFlight proof, App Store proof, physical-device proof, public accessibility proof, legal/privacy signoff, or human release approval.

## Repo map

- `Native/Ambitions/` — native app source
- `Native/AmbitionsTests/` — unit tests
- `Native/AmbitionsUITests/` — UI tests
- `Native/AmbitionsWidgetExtension/` — widget extension target
- `Native/AmbitionsShareExtension/` — share extension target
- `Sources/` — `AmbitionsDesignSystem` Swift package target
- `AppUI/Sources/` — `AmbitionsWidgetUI` Swift package target
- `project.yml` — XcodeGen source of truth
- `scripts/` — local setup/build/validation helpers
- `docs/AmbitionsCanon/` — active product and design canon
- `docs/status/` — current implementation, cleanup, and release evidence status
- `docs/` — full documentation index, historical context, release docs, audits, and Codex operating material
- `.codex/` and `.agents/` — AI/Codex operating material and retained automation context, not product source truth

## Documentation entry points

Start here:

1. [`docs/AmbitionsCanon/README.md`](docs/AmbitionsCanon/README.md) — active product/design source truth
2. [`docs/status/current-implementation-map.md`](docs/status/current-implementation-map.md) — what is implemented, scaffolded, planned, or historical
3. [`docs/status/repo-cleanup-index.md`](docs/status/repo-cleanup-index.md) — cleanup and quarantine policy
4. [`docs/status/release-evidence-packet.md`](docs/status/release-evidence-packet.md) — build/test/release evidence posture
5. [`docs/native-build-and-release.md`](docs/native-build-and-release.md) — local validation workflow
6. [`AGENTS.md`](AGENTS.md) — AI/Codex contributor rules
7. [`docs/README.md`](docs/README.md) — full docs map

## Contributor boundary

Production app work belongs in `Native/Ambitions/`, `Sources/`, `AppUI/Sources/`, native extension folders, tests, scripts, or `project.yml` as appropriate.

Historical docs, future-canon docs, batch-train records, audit reports, and Codex control-plane material are retained for traceability. They do not override the active canon or current implementation map unless an active source-truth document explicitly says so.
