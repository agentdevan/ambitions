# Ambitions Flagship Remediation Program

Created: 2026-05-30T04:21:44.656430+00:00
Project ID: `AMB-FLAGSHIP-REMEDIATION`

## Mission

Convert the Ambitions repo audit into a peak implementation process that hardens the app from flagship-in-progress to a durable native iPhone-first, local-first flagship.

Ambitions must remain native iPhone-first, local-first, privacy-safe, deterministic through the Private Life Runtime, and built around Today / Goals / Capture / Time / You.

## Linear setup

- Project name: `Ambitions Flagship Remediation Program`
- Status: Planned
- Target: Pre-launch flagship hardening
- Method: Sequential train execution
- Health rule: Green requires code, tests, validation, and proof artifacts.

## Milestones

### T-A — Shell & IA Lock

Objective: Make the executable app shell canonical, testable, and free of active legacy IA seams.

Issues:
- `AMB-FR-001` — Canonical root shell and app chrome integrity [P0 / Critical]
- `AMB-FR-002` — Slice AppContainer into bounded capabilities [P0 / High]
- `AMB-FR-003` — Retire active legacy IA route seams [P0 / High]
- `AMB-FR-004` — Shell visual QA and preview matrix [P1 / High]

### T-B — Local Data Foundation

Objective: Harden domain, SwiftData, repositories, migrations, and local data integrity.

Issues:
- `AMB-FR-005` — Decontaminate life-context domain fixtures [P0 / Critical]
- `AMB-FR-006` — SwiftData temporal and enum type-safety pass [P0 / Critical]
- `AMB-FR-007` — Normalize persistence away from blob-first reads [P0 / Critical]
- `AMB-FR-008` — Explicit schema migration and store recovery system [P0 / Critical]
- `AMB-FR-009` — Repository query performance and deterministic ordering gates [P1 / High]
- `AMB-FR-010` — Structured life context and Memory Lens data basis [P1 / High]

### T-C — Private Life Runtime Proof

Objective: Prove the local deterministic runtime moat with executable tests, replay, receipts, and correction loops.

Issues:
- `AMB-FR-011` — Same-intent different-context runtime proof harness [P0 / Critical]
- `AMB-FR-012` — Deterministic planner rule-engine upgrade [P0 / High]
- `AMB-FR-013` — Today runtime replay and receipt inspector [P1 / High]
- `AMB-FR-014` — User correction loop for runtime trust [P1 / High]

### T-D — Apple Platform Depth

Objective: Expand safe Apple-native depth through intents, search, Handoff, background maintenance, widgets, and continuity gates.

Issues:
- `AMB-FR-015` — Deep App Intents action surface [P1 / High]
- `AMB-FR-016` — Spotlight and Handoff object reopening [P1 / High]
- `AMB-FR-017` — Optional CloudKit continuity decision gate [P1 / High]
- `AMB-FR-018` — Background maintenance and notification reconciliation [P2 / High]
- `AMB-FR-019` — Widget and Live Activity flagship expansion [P2 / Medium]

### T-E — Trust, Accessibility, Release Lock

Objective: Lock accessibility, privacy, performance, release, and repo-governance gates with device proof.

Issues:
- `AMB-FR-020` — Accessibility proof matrix and gates [P0 / Critical]
- `AMB-FR-021` — Device-truth QA and release candidate packet [P0 / Critical]
- `AMB-FR-022` — Privacy manifest and App Store declaration alignment [P0 / High]
- `AMB-FR-023` — Local observability and performance baselines [P1 / High]
- `AMB-FR-024` — Repo authority collapse and Codex automation manifest [P1 / High]

## Execution rules

1. Work trains sequentially unless a blocker requires a bounded repair batch.
2. No train is Green without code changes, tests, validation commands, and proof artifacts.
3. Do not implement CloudKit, broad widget expansion, or App Store polish before shell and persistence are stable.
4. Do not rename canonical product objects.
5. Do not reintroduce top-level Habits, Plan, Profile, or Insights as product objects.
6. Preserve user-facing language: Start here, Recommended step, Start now, Open step, Step.
7. External/cloud LLMs are not part of core architecture.
8. Every closeout must report Green / Yellow / Red status and evidence.

## Required proof artifacts

- Shell screenshot matrix
- Navigation/canon lint
- SwiftData migration matrix
- Runtime same-intent/different-context proof
- Receipt/replay proof
- Accessibility proof matrix
- Privacy manifest/declaration packet
- Device-truth release candidate packet
- Codex train closeout report
