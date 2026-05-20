# Installed Canon

Status: Source-backed installed frontend canon
Authority: subordinate to `docs/truth/*`

This file records what the current repo source and tests actually support today.

## Installed now

- The native iPhone app has a five-surface shell wired through [`Native/Ambitions/App/AppTab.swift`](../Native/Ambitions/App/AppTab.swift), [`Native/Ambitions/App/AmbitionsRootView.swift`](../Native/Ambitions/App/AmbitionsRootView.swift), and [`Native/Ambitions/App/AmbitionsApp.swift`](../Native/Ambitions/App/AmbitionsApp.swift).
- The user-facing surfaces are wired as Today, Goals, Capture, Time, and You through the current feature source under [`Native/Ambitions/Features/`](../Native/Ambitions/Features/).
- Time remains the active user-facing surface while `Plan` survives only as an internal compatibility seam in source.
- Local persistence, routing, and shell composition are source-present through [`Native/Ambitions/Persistence/`](../Native/Ambitions/Persistence/) and the app container/bootstrapper files.
- Validation and regression coverage exist through the unit and UI test targets, including [`Native/AmbitionsUITests/AmbitionsUITests.swift`](../Native/AmbitionsUITests/AmbitionsUITests.swift).

## Installed anchors

- [`project.yml`](../project.yml)
- [`Package.swift`](../Package.swift)
- [`Native/Ambitions/App/`](../Native/Ambitions/App/)
- [`Native/Ambitions/Features/Today/`](../Native/Ambitions/Features/Today/)
- [`Native/Ambitions/Features/Goals/`](../Native/Ambitions/Features/Goals/)
- [`Native/Ambitions/Features/Capture/`](../Native/Ambitions/Features/Capture/)
- [`Native/Ambitions/Features/Plan/`](../Native/Ambitions/Features/Plan/)
- [`Native/Ambitions/Features/Profile/`](../Native/Ambitions/Features/Profile/)
- [`Native/Ambitions/Persistence/`](../Native/Ambitions/Persistence/)
- [`scripts/build-local.sh`](../scripts/build-local.sh)
- [`docs/truth/IMPLEMENTATION_TRUTH.md`](../docs/truth/IMPLEMENTATION_TRUTH.md)

## Not proved by installed canon

- Release readiness
- Physical-device validation
- Accessibility conformance
- Performance proof
- TestFlight/App Store readiness
- Any hosted backend or account-sync architecture
