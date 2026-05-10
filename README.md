# Ambitions

> Active repo authority starts in [`docs/truth/README.md`](docs/truth/README.md). If this README conflicts with `docs/truth/*`, the truth files win. This README is orientation, not implementation proof, validation proof, or release proof.

Ambitions is a native iPhone app for turning long-term goals into grounded daily execution.

It helps you capture what is on your mind, place it into goals or time-shaping, choose what matters today, and close the loop with proof.

```text
Capture -> Place -> Shape Time -> Do Today -> Close / Recover -> Save Proof
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

The active flagship product model has five top-level surfaces:

- Today — what matters now
- Goals — long-term direction
- Capture — low-friction intake
- Time — capacity and shaping
- You — preferences, trust, privacy, and control

The active product and design truth starts in [`docs/truth/PRODUCT_DESIGN_TRUTH.md`](docs/truth/PRODUCT_DESIGN_TRUTH.md). Supporting canon lives under [`docs/AmbitionsCanon/README.md`](docs/AmbitionsCanon/README.md) where compatible with `docs/truth/*`.

Compatibility note: some internal source paths, route raw values, tests, and historical docs still use `Plan` / `.plan` naming. Those are compatibility seams, not active user-facing IA. The active top-level destination is `Time`.

## What is implemented today

The repo currently contains:

- a native SwiftUI app target
- local SwiftData-backed persistence foundations
- Today, Goals, Capture, Time, and You user-facing shell destinations
- internal Time-surface compatibility seams through `PlanScreen`, `.plan`, `planNavigation()`, and `Native/Ambitions/Features/Plan/`
- capture and goal creation flows
- time-shaping, proof, receipt, notification, external-routing, widget, Live Activity, share-extension, and calendar/reminder foundations where implemented
- local build and validation scripts
- unit and UI test targets

See [`docs/truth/IMPLEMENTATION_TRUTH.md`](docs/truth/IMPLEMENTATION_TRUTH.md) for implementation authority and [`docs/status/current-implementation-map.md`](docs/status/current-implementation-map.md) for the current evidence-based implementation map.

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

See [`docs/truth/RELEASE_TRUTH.md`](docs/truth/RELEASE_TRUTH.md) for release/proof authority and [`docs/status/release-evidence-packet.md`](docs/status/release-evidence-packet.md) for the current release evidence posture.

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
- `docs/truth/` — active repo authority for product/design, implementation/source, release/proof, Codex process, and historical policy
- `docs/AmbitionsCanon/` — supporting product and design canon retained below `docs/truth/*`
- `docs/status/` — supporting implementation, cleanup, and release evidence status
- `docs/` — full documentation index, historical context, release docs, audits, and Codex operating material
- `.codex/` and `.agents/` — AI/Codex operating material and retained automation context, not product source truth

## Documentation entry points

Start here:

1. [`docs/truth/README.md`](docs/truth/README.md) — active authority index and conflict rules
2. [`docs/truth/PRODUCT_DESIGN_TRUTH.md`](docs/truth/PRODUCT_DESIGN_TRUTH.md) — product/design authority
3. [`docs/truth/IMPLEMENTATION_TRUTH.md`](docs/truth/IMPLEMENTATION_TRUTH.md) — implementation/source authority
4. [`docs/truth/RELEASE_TRUTH.md`](docs/truth/RELEASE_TRUTH.md) — release/proof authority
5. [`docs/truth/CODEX_PROCESS_TRUTH.md`](docs/truth/CODEX_PROCESS_TRUTH.md) — Codex operating authority
6. [`docs/truth/HISTORICAL_POLICY.md`](docs/truth/HISTORICAL_POLICY.md) — historical cleanup policy
7. [`docs/status/current-implementation-map.md`](docs/status/current-implementation-map.md) — what is implemented, scaffolded, planned, or historical
8. [`docs/status/repo-cleanup-index.md`](docs/status/repo-cleanup-index.md) — cleanup and quarantine support index
9. [`docs/status/release-evidence-packet.md`](docs/status/release-evidence-packet.md) — build/test/release evidence posture
10. [`docs/native-build-and-release.md`](docs/native-build-and-release.md) — local validation workflow
11. [`AGENTS.md`](AGENTS.md) — AI/Codex contributor rules, subordinate to `docs/truth/*`
12. [`docs/README.md`](docs/README.md) — full docs map

## Contributor boundary

Production app work belongs in `Native/Ambitions/`, `Sources/`, `AppUI/Sources/`, native extension folders, tests, scripts, or `project.yml` as appropriate.

Historical docs, future-canon docs, batch-train records, audit reports, and Codex control-plane material are retained for traceability. They do not override `docs/truth/*` unless an active truth file explicitly says so.
