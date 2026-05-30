# Harness Artifact Hygiene

Status: Active support protocol
Issue: AMB-301

Runtime-generated harness packets belong under `build/reports/harness/**` and are ignored by default. Committed proof packets belong under `docs/proof/harness/**` only when a slice explicitly promotes them as durable evidence.

## Rules

- Do not commit generated `build/reports/**` output.
- Commit small durable proof summaries under `docs/proof/harness/**` when a slice requires evidence.
- Docs/tooling slices must not stage app source, `project.yml`, `Package.swift`, Xcode project output, or `docs/truth/*`.
- Cleanup tools must be main-only and path-limited.

## Claims Not Made

This protocol does not prove app behavior, build success, tests, accessibility, privacy/legal, device validation, TestFlight, App Store, or release readiness.
