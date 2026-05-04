# AmbitionsOS Living Dream Architecture Index

<!-- markdownlint-disable MD013 -->

Status: Active future implementation source truth and train governance. This document does not claim runtime implementation.

## Core Promise

AmbitionsOS Living Dream Architecture is the local-first intelligence layer that lets any user capture any dream, goal, task, worry, note, or life fragment and receive the safest useful handling path.

Ambitions does not promise that every dream becomes a complete plan.

Ambitions promises that every dream is classified, protected, routed, and handled honestly.

Supported and source-backed dreams may become living plans. Unsupported dreams become scaffolds or exploration paths. Impossible dreams become North Stars. Regulated dreams become professional-boundary plans. Unsafe dreams are blocked and redirected. Crisis-coded inputs receive support. Ambiguous inputs receive one-question clarification.

Source changes, user changes, life-context changes, jurisdiction changes, capacity changes, pack changes, and proof changes recompile affected plans locally with receipts and user approval before commitments move.

## Binding Product Boundaries

- Ambitions remains local-first and premium native iPhone in product posture.
- Today, Goals, Capture, Plan, and You remain the only canonical top-level destinations.
- LDI does not make Ambitions a chatbot, notes app, calendar clone, project-management system, dashboard, or AI-wrapper product.
- LDI does not introduce hosted AI, a user-data backend, account infrastructure, telemetry, signing, release, or production runtime behavior in this integration batch.
- Ambitions-owned infrastructure may only publish source freshness, pack updates, changed claim IDs, signed manifests, non-personal pack diffs, and source operation metadata.
- User dreams, goals, plans, receipts, schedule, memory, identity, source dependency index, and user analytics must not be stored on Ambitions-owned infrastructure by default.

## Canonical Handling Lanes

`parked_thought`, `clarification_needed`, `quick_step`, `project_plan`, `dream_scaffold`, `source_backed_plan`, `regulated_plan`, `professional_boundary_scaffold`, `north_star_extraction`, `unsafe_blocked`, `crisis_support`, `source_stale_review`, `source_conflict_review`, `impossible_timeline_review`, `conflict_review`, `privacy_sensitive_plan`, `sync_recovery`, `unsupported_domain_exploration`, `source_check_first`, `user_review_required`, `local_only_private_plan`.

Every capture/dream must land in exactly one primary lane and may have secondary lane flags.

## The 22 Systems

| # | System | Ownership | Kernel mapping | Surface relationship | Hard boundary |
| --- | --- | --- | --- | --- | --- |
| 1 | Capture Understanding Engine | Universal composer classification | Control Plane, Universal Capture | Capture, Today, Goals, Plan, You | Outputs handling candidates only; no activation. |
| 2 | Dream Seriousness Router | Intent seriousness and urgency routing | Control Plane, Universal Capture | Capture and review surfaces | Routes seriousness without promising a plan. |
| 3 | Dream Safety, Legality, and Feasibility Triage | Unsafe, illegal, crisis, regulated, fantasy, minor, and sensitive screening | Privacy Safety, Experience Kernel, Control Plane | Capture, Trust receipts, review surfaces | Blocks unsafe operationalization and redirects safely. |
| 4 | North Star Extraction Engine | Safe meaning extraction from impossible, fantasy, symbolic, or unsafe-literal dreams | Option Value, Alternate Path, Goal Path | Goals, Capture, Plan review surfaces | Never validates impossible or harmful literal plans. |
| 5 | Source Claim Graph | Atomic source-backed claims and claim states | Source Truth Kernel | Trust, Plan, Goals, Capture receipts | Plans depend on claim IDs, not hardcoded prose. |
| 6 | Pack Registry + Pack Compiler | Pack taxonomy, quality states, and review pipeline | Source Truth, Goal Path, Governance | You controls, Capture review, Plan/Goals review | Generated packs remain drafts until source/schema/review proof exists. |
| 7 | Pack Supply Chain Security | Signed checksums, provenance, rollback, corruption handling, no executable logic | Governance, Source Truth, Privacy Safety | You controls and governance evidence | No arbitrary untrusted pack execution. |
| 8 | Freshness Broker + Source Operations | Minimal non-personal manifest and source freshness surface | Source Truth, Governance | Plan/Goals source-stale reviews, You controls | No user-data server; push is a hint, not source truth. |
| 9 | Dream-to-Goal Compiler | Structured goal candidate from raw dream | Goal Path Kernel, Universal Capture | Capture to Goals review | Must not activate without user approval. |
| 10 | Requirement Graph Engine | Hard/soft requirements, blockers, assumptions, unknowns, proof needed | Goal Path Kernel | Goal Detail, Plan review | Professional-boundary facts require verification boundaries. |
| 11 | Eligibility + Deadline Engine | Age/date/window/deadline/minimum lead time logic | Goal Path, Commitment Time | Plan/Goals review | Source freshness required before commitments. |
| 12 | Path Portfolio Engine | Primary, conservative, aggressive, exploration, fallback, North Star paths | Alternate Path Kernel | Goals and Plan drill-downs | Path generation never implies guarantee. |
| 13 | Capacity + Commitment-Time Engine | Capacity fit and no fantasy schedules | Commitment Time, Reality Drift | Plan, Today, Goals | Rejects fantasy schedules and respects recovery. |
| 14 | Today Bridge + Action Closure Mapper | 1-3 useful next steps and closure states | Recommendation, Action Closure | Today | Keeps big dreams actionable without dashboard sprawl. |
| 15 | Trust Review + Receipts | Inference, route, source, activation, mutation, and refusal receipts | Proof Trust | Trust, You, Capture, Plan, Goals | Receipts show assumptions, source state, privacy state, and approval needs. |
| 16 | Plan Governance + Mutation Permissions | Permissions for source updates, suggestion recalculation, commitment movement, sync, archive | Governance, Reality Drift | Plan, You, Trust | Commitments never move without user review. |
| 17 | Living Plan Recompiler + Blast Radius Index | Dependency index and impact levels 0-5 | Reality Drift, Recommendation, Source Truth, Governance | Plan, Today, Goals, Trust | Recompile locally; ask approval before commitments move. |
| 18 | Personal Data Vault + Sensitivity Modes | Goal privacy modes and leak prevention | Privacy Safety, You | You, Capture, Plan, receipts | Sensitive local data must not leak into logs, previews, notifications, widgets, or generic receipts. |
| 19 | Continuity Sync + Archive System | Local-first storage, private iCloud intent, encrypted archive, schema migration ladder | Longevity, Interoperability, Privacy Safety | You, Archive/restore review | No Ambitions-owned user-data backend. |
| 20 | Multi-Device Merge Ledger | Merge policies and most-restrictive privacy wins | Longevity, Interoperability, Privacy Safety | You conflict review | Scheduled commitments require conflict review. |
| 21 | Edge Case Simulation + Abuse-Resistance Suite | 45 fixture families and red-team harness | Evaluation Kernel | Codex OS, Preview QA, governance | Permanent abuse-resistance and edge-case fixture coverage. |
| 22 | Governance, Evidence, and Maintenance Console | Internal metrics for pack/source/safety/sync/governance health | Governance Kernel | Codex OS only unless later owned | No user personal data required. |

## Relationships To Existing Trains

- SI owns reusable visual expression for handling lanes, source states, receipt states, privacy states, degraded states, and review primitives. SI does not own LDI runtime.
- PD owns drill-down homes inside existing destinations for dream review, handling receipt detail, source-stale review, source-conflict review, North Star review, professional-boundary review, plan mutation review, unsafe redirect review, and privacy-sensitive controls. PD must not create a sixth destination.
- AOS owns underlying local contracts and kernel boundaries where Capture Understanding, Source Claim Graph, Pack Registry, Requirement Graph, Eligibility, Path Portfolio, Commitment Time, Receipts, Recompiler, Continuity, Safety, Evaluation, and Governance naturally belong.
- LDI01-LDI22 deepens the implementation only after AOS30 by default, unless a future dependency review and explicit user decision insert a narrower LDI gate earlier.
- EB, DAV, CS, ME, REC, and PXOS remain source-truth or prerequisite systems. LDI extends them; it does not rewrite completed evidence.

## Claim Boundary

This index is future implementation source truth. It does not prove full Living Dream runtime behavior, source pack review, pack signing, CloudKit sync, device proof, public accessibility conformance, App Store readiness, TestFlight readiness, legal/privacy signoff, production AI, hosted AI, or release readiness.
