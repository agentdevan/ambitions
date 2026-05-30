# PROOFMODE-001 App-Driving Proof Router

Status: Bounded source proof seam installed
Issue: AMB-307

## Purpose

This installs a deterministic, local-only proof-mode router for the Ambitions moat scenario: the same user intent plus different local contexts should produce different, inspectable recommendation outputs.

## Installed Source

- `Native/Ambitions/Domain/ProofMode/AppDrivingProofModeRouter.swift`
- `Native/AmbitionsTests/ProofMode/AppDrivingProofModeRouterTests.swift`

## Scenario

Intent: prepare for a certification exam without burning out.

Context A: protected-time heavy, low energy, closure residue present. Expected shape: short recovery-aware recommended step.

Context B: longer open window, medium energy, no closure residue. Expected shape: focused exam practice block.

## Boundaries

The router is pure and deterministic. It does not persist data, call a network, use cloud AI, or mutate production user data.

## Claims Not Made

- No full app-driving proof completion claim.
- No full Private Life Runtime completion claim.
- No build success claim without local logs.
- No UI test success claim.
- No accessibility validation claim.
- No device validation claim.
- No privacy/legal approval claim.
- No TestFlight claim.
- No App Store claim.
- No release readiness claim.
