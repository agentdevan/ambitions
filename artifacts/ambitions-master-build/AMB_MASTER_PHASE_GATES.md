# Ambitions Master Build Phase Gates

Status: Active phase-gate contract for `amb-master`
Updated: 2026-06-14

## Global Gates

Before any train closes Green:

- Read active truth files and `AGENTS.md`.
- Confirm branch is `main`.
- Resolve train label to an actual `AMB-*` issue.
- Run `scripts/codex/program-preflight.sh amb-master`.
- Run `scripts/codex/program-phase-gate.sh amb-master <phase>`.
- Confirm no forbidden source/project dirty paths unless the active issue explicitly authorizes them.
- For source-changing issues, prove source ownership and run required owner/parallel-implementation guards.
- Preserve local-first, privacy-first, deterministic runtime authority.
- Preserve `Today / Goals / Time / Motion / You` plus global Capture action layer unless source and truth are updated together.
- Preserve proof boundaries: no release, privacy/legal, accessibility certification, device, performance, App Review, TestFlight, or App Store claims without current evidence.

## Green / Yellow / Red Gate

Green means scoped work is complete, AMB-bound, validated, pushed when required, and no proof claim exceeds evidence.

Yellow means scoped work is structurally correct but a named external proof, owner/human proof, device proof, certification proof, or evidence refresh remains incomplete and owned.

Red means execution must stop or repair before push: synthetic issue drift, missing AMB binding, phase-order violation, private user data in public/R2 paths, required cloud LLM/core server dependency, silent user-data mutation, missing source/proof receipt for source-changing behavior, validation failure caused by the patch, or unproven readiness/release/accessibility/privacy claim.

## M00

Purpose: Linear Control Plane + Canon Lock.

Required before Green:

- `AMB-1126` is Done or explicitly non-blocking in live Linear.
- Local `amb-master` Goal Mode adapter exists and validates.
- Program registry includes `amb-master`.
- Queue/map/run-state bind train labels to `AMB-*` issues.
- Canon and IA authority checks can be executed.
- No app source behavior is changed by adapter installation.

## M01

Purpose: Data, Persistence, Privacy, and Source Boundary.

Required before Green:

- Local data, migration, replay, receipt, privacy, diagnostics, Source Atlas cache, source authority, and lifecycle changes extend existing owners.
- Private data remains local/user-iCloud only.
- R2/Source Atlas paths remain generic source/pathing/seed data only.
- Migration/reset/export failure behavior is validated.

## M02

Purpose: Runtime Moat Kernel.

Required before Green:

- Step Quality Firewall, Any Goal Runtime, path lattice, Step Graph Compiler, elasticity, schedule install, reflow, and high-risk safety are deterministic, inspectable, receipt-backed, and validated.
- Unsafe, generic, inaccessible, source-weak, high-risk, or uninspectable Steps fail closed or degrade safely.
- No hidden mutation or opaque reranking is introduced.

## M03

Purpose: Golden Slice + First-Run Proof.

Required before Green:

- One vertical slice proves intake, pathing, source, Step graph, schedule install, Today recommendation, action, proof, receipt, closure/recovery, reflow, optional share, and replay.
- First-run activation teaches the Personal Life OS model without generic onboarding or chatbot framing.

## M04

Purpose: Native Shell + Design System Foundation.

Required before Green:

- Five-surface shell is active.
- Global Capture is not a tab.
- Design system, motion grammar, search, navigation, and safe-area behavior support flagship iPhone quality.

## M05

Purpose: Today + Step Execution Surface.

Required before Green:

- Today, Start here, Recommended step, Step detail/session, closure, recovery, and proof paths are integrated and accessible.

## M06

Purpose: Goals, Paths, Capture, and Time.

Required before Green:

- Goals, path selection, Capture/Atmosphere Composer, Time/LifeShape, schedule preview, treaty, and rollback flows are source-aware and non-generic.

## M07

Purpose: Motion, Proof, Recovery, Sharing, Year.

Required before Green:

- Motion Current, proof/progress, recovery, share/export, and Year flows are local-first, private, non-social, and non-gamified.

## M08

Purpose: You, Privacy, Diagnostics, Export, Support.

Required before Green:

- User System Profile, trust controls, diagnostics, export/reset/delete, CloudKit controls, local learning controls, and support paths are inspectable and privacy-safe.

## M09

Purpose: Apple System Surfaces.

Required before Green:

- Widgets, App Intents, Spotlight, Live Activities, notifications, share extension, and background tasks preserve privacy, source trust, accessibility, and continuity.

## M10

Purpose: Commerce, Demo, Review, Compliance.

Required before Green:

- StoreKit, demo/review mode, screenshots, App Review notes, compliance, and claim boundaries align to actual source behavior.

## M11

Purpose: Accessibility, Performance, Polish, Certification.

Required before Green:

- Certification gauntlets pass for authority/IA, golden slice, Step Quality/Any Goal, Source Atlas/R2, runtime determinism/performance, CloudKit/migration, privacy/high-risk, accessibility/cognitive load, Apple system surfaces, and App Review readiness.
- Full-program Green is forbidden until this evidence exists.
