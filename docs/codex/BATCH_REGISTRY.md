> Supporting note: This file supports current Ambitions runner/process work but does not override `docs/truth/`.

# Batch Registry

Status: Re-authorized process mirror
Re-authorized by: AMB-508 Packet 0R
Date: 2026-06-05
Base SHA: `dbeb081ab4bd8c913685fb99b8f0f61b9b61032a`

This registry exists because `.codex/state/active-batch.yml` references `docs/codex/BATCH_REGISTRY.md` as a process source of truth. It is runner/process routing support only. It is not product truth, implementation proof, validation proof, release proof, accessibility proof, performance proof, device proof, TestFlight proof, or App Store proof.

## Active Truth Boundary

Active authority starts in:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `AGENTS.md`

If this registry conflicts with those files, the truth files win.

## Current Re-authorized Packet

| Issue | Packet | Status | Routing Result | Claim Boundary |
|---|---|---|---|---|
| AMB-508 | Packet 0R - Preflight Reconciliation / Closeout Repair | Green-eligible after process validation | Repairs Packet 0 closeout so frontend maturity packets can proceed from corrected shell/process truth | Docs/process proof only |

## Root Shell Correction

Packet 0R records the runtime root chain as:

```text
AmbitionsApp -> LaunchGateView -> AmbitionsRootView -> SwiftUI TabView
```

`Native/Ambitions/App/AppMeridianShell.swift` is not the runtime root. It defines `AppMeridianDestinationRail` and preview/support behavior only.

Packet 4 is reframed as:

```text
Runtime Root Shell + Meridian Compatibility Audit
```

## Stale IA Gap Routing

| IA issue | Absorbed by packet(s) | Notes |
|---|---|---|
| AMB-478 | Packets 4/6 | Global Capture entry model; verify against runtime root and Capture access model. |
| AMB-479-481 | Packets 6/11 | Global Capture invocation/composer/top-level language cleanup. |
| AMB-482-485 | Packet 9 | Motion surface owner/projection/inspector/copy audit. |
| AMB-486-487 | Packet 8 or later | Goal timeline/simulation only if in scope; otherwise later candidates. |
| AMB-488-489 | Packet 7 | Time Texture / LifeShape Field routing. |
| AMB-490-492 | Packets 6/10/11 | Today-to-Motion proof handoff, Motion receipts, You governance. |
| AMB-493-494 | Later external/App Intent/widget feasibility packets | Do not force into core frontend maturity sequence. |
| AMB-495-500 | Packets 1/2/4/12/14 | Tokens, primitives, validation, accessibility/performance, final closeout. |
| AMB-501 | Packets 12/14 governance inconsistency | Linear Done does not prove final Motion anti-pattern audit if issue text says proof remains open. |

## Packet 1 Eligibility

Packet 1 is eligible only after Packet 0R returns Green, or after an explicitly accepted Yellow that does not affect packet sequencing, hard canon, or runner compatibility.

## Proof Boundaries

This process mirror does not prove app behavior changed, build success, test success, UI quality, accessibility, performance, device behavior, privacy/legal approval, release readiness, TestFlight readiness, or App Store readiness.
