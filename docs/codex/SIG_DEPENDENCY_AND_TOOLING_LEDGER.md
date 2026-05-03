# SIG Dependency And Tooling Ledger

Status: Active

## Policy

SIG uses native SwiftUI, existing Ambitions design-system primitives, XcodeGen,
and deterministic local scripts. Third-party runtime dependencies are not
allowed unless a future explicit dependency-policy exception is approved.

## Current Tooling

- XcodeGen for project source truth.
- `scripts/build-local.sh` for native build proof.
- DAV/PXEQ/SIG validation scripts for advisory and blocking scans.
- Existing preview fixtures and SwiftUI previews.

## Prohibited For SIG

- app asset catalog ingestion of reference images;
- workflow/signing/TestFlight/App Store changes;
- network/sync dependencies;
- runtime animation libraries;
- release or award claims from visual references.
