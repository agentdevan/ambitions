# AmbitionsOS Living Dream System Map

<!-- markdownlint-disable MD013 -->

Status: Active future source truth. Runtime implementation is not claimed.

## System Ownership Map

| # | System | Primary owner | Secondary owners | Data boundary | Surfaces allowed |
| --- | --- | --- | --- | --- | --- |
| 1 | Capture Understanding Engine | Control Plane, Universal Capture | SI, PD, AOS, LDI as sequenced by global train | Local-first; no user-data server; Outputs handling candidates only; no activation. | Capture, Today, Goals, Plan, You |
| 2 | Dream Seriousness Router | Control Plane, Universal Capture | SI, PD, AOS, LDI as sequenced by global train | Local-first; no user-data server; Routes seriousness without promising a plan. | Capture and review surfaces |
| 3 | Dream Safety, Legality, and Feasibility Triage | Privacy Safety, Experience Kernel, Control Plane | SI, PD, AOS, LDI as sequenced by global train | Local-first; no user-data server; Blocks unsafe operationalization and redirects safely. | Capture, Trust receipts, review surfaces |
| 4 | North Star Extraction Engine | Option Value, Alternate Path, Goal Path | SI, PD, AOS, LDI as sequenced by global train | Local-first; no user-data server; Never validates impossible or harmful literal plans. | Goals, Capture, Plan review surfaces |
| 5 | Source Claim Graph | Source Truth Kernel | SI, PD, AOS, LDI as sequenced by global train | Local-first; no user-data server; Plans depend on claim IDs, not hardcoded prose. | Trust, Plan, Goals, Capture receipts |
| 6 | Pack Registry + Pack Compiler | Source Truth, Goal Path, Governance | SI, PD, AOS, LDI as sequenced by global train | Local-first; no user-data server; Generated packs remain drafts until source/schema/review proof exists. | You controls, Capture review, Plan/Goals review |
| 7 | Pack Supply Chain Security | Governance, Source Truth, Privacy Safety | SI, PD, AOS, LDI as sequenced by global train | Local-first; no user-data server; No arbitrary untrusted pack execution. | You controls and governance evidence |
| 8 | Freshness Broker + Source Operations | Source Truth, Governance | SI, PD, AOS, LDI as sequenced by global train | Local-first; no user-data server; No user-data server; push is a hint, not source truth. | Plan/Goals source-stale reviews, You controls |
| 9 | Dream-to-Goal Compiler | Goal Path Kernel, Universal Capture | SI, PD, AOS, LDI as sequenced by global train | Local-first; no user-data server; Must not activate without user approval. | Capture to Goals review |
| 10 | Requirement Graph Engine | Goal Path Kernel | SI, PD, AOS, LDI as sequenced by global train | Local-first; no user-data server; Professional-boundary facts require verification boundaries. | Goal Detail, Plan review |
| 11 | Eligibility + Deadline Engine | Goal Path, Commitment Time | SI, PD, AOS, LDI as sequenced by global train | Local-first; no user-data server; Source freshness required before commitments. | Plan/Goals review |
| 12 | Path Portfolio Engine | Alternate Path Kernel | SI, PD, AOS, LDI as sequenced by global train | Local-first; no user-data server; Path generation never implies guarantee. | Goals and Plan drill-downs |
| 13 | Capacity + Commitment-Time Engine | Commitment Time, Reality Drift | SI, PD, AOS, LDI as sequenced by global train | Local-first; no user-data server; Rejects fantasy schedules and respects recovery. | Plan, Today, Goals |
| 14 | Today Bridge + Action Closure Mapper | Recommendation, Action Closure | SI, PD, AOS, LDI as sequenced by global train | Local-first; no user-data server; Keeps big dreams actionable without dashboard sprawl. | Today |
| 15 | Trust Review + Receipts | Proof Trust | SI, PD, AOS, LDI as sequenced by global train | Local-first; no user-data server; Receipts show assumptions, source state, privacy state, and approval needs. | Trust, You, Capture, Plan, Goals |
| 16 | Plan Governance + Mutation Permissions | Governance, Reality Drift | SI, PD, AOS, LDI as sequenced by global train | Local-first; no user-data server; Commitments never move without user review. | Plan, You, Trust |
| 17 | Living Plan Recompiler + Blast Radius Index | Reality Drift, Recommendation, Source Truth, Governance | SI, PD, AOS, LDI as sequenced by global train | Local-first; no user-data server; Recompile locally; ask approval before commitments move. | Plan, Today, Goals, Trust |
| 18 | Personal Data Vault + Sensitivity Modes | Privacy Safety, You | SI, PD, AOS, LDI as sequenced by global train | Local-first; no user-data server; Sensitive local data must not leak into logs, previews, notifications, widgets, or generic receipts. | You, Capture, Plan, receipts |
| 19 | Continuity Sync + Archive System | Longevity, Interoperability, Privacy Safety | SI, PD, AOS, LDI as sequenced by global train | Local-first; no user-data server; No Ambitions-owned user-data backend. | You, Archive/restore review |
| 20 | Multi-Device Merge Ledger | Longevity, Interoperability, Privacy Safety | SI, PD, AOS, LDI as sequenced by global train | Local-first; no user-data server; Scheduled commitments require conflict review. | You conflict review |
| 21 | Edge Case Simulation + Abuse-Resistance Suite | Evaluation Kernel | SI, PD, AOS, LDI as sequenced by global train | Local-first; no user-data server; Permanent abuse-resistance and edge-case fixture coverage. | Codex OS, Preview QA, governance |
| 22 | Governance, Evidence, and Maintenance Console | Governance Kernel | SI, PD, AOS, LDI as sequenced by global train | Local-first; no user-data server; No user personal data required. | Codex OS only unless later owned |


## Surface Boundaries

- Capture may collect raw user input and present handling candidates, clarification, safety redirects, source-check-first paths, and placement review when owned by the active batch.
- Goals may show dream-to-goal review, requirement graph, path portfolio, North Star, professional-boundary source state, proof, and decision history only after owned PD/AOS/LDI gates.
- Today may show source-check, proof, review, clarification, recovery, and action closure states as steps, not as a parallel task app.
- Plan may show source-change impact, recompile review, capacity fit, and no-silent-rearrangement review after owned gates.
- You may show source packs, sync/archive states, privacy controls, plan mutation permissions, continuity controls, and what Ambitions knows, without adding a new tab.

## Data Boundary Laws

1. Local-first is default.
2. User private state belongs on device and, if enabled, the user's private iCloud / CloudKit.
3. Ambitions server must not store user dreams, user goals, user plans, user receipts, source dependency index, memory, schedule, or identity.
4. Global source data is non-personal.
5. Source packs and claim graphs are compact, structured, signed, versioned, and optionally downloadable.
6. Apple-hosted Background Assets / managed asset packs are a future option where platform support permits; otherwise use a CDN/static manifest fallback.
7. Background push is a hint, not source truth.
8. iCloud sync degrades through Local only, Sync available, Sync paused, iCloud unavailable, iCloud full, Restoring, Conflict review needed, Archive backup available, and Sensitive goal excluded from sync.
9. Sensitive goals may be local-only and excluded from sync.
10. Privacy settings use most-restrictive merge behavior.

## Future Train Guardrail

If a queued SI, PD, or AOS batch cannot absorb an LDI requirement inside its explicit boundary, it must add a dependency note and defer runtime implementation to LDI01-LDI22.
