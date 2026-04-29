# Post-D26 Maturity Roadmap

Status: Active planning roadmap for Layer 2 and Layer 3 after the D01-D26 Design Constitution alignment track.

Purpose: Rewrite, rename, resequence, and rescope original Batches 89-120 against the newer canon docs and the D01-D26 Design Constitution delta/alignment backlog.

This document does not independently mark D01-D26 complete. Operational status remains owned by `docs/codex/BATCH_REGISTRY.md`, which now records D01-D26 complete for planning purposes after D26 release-candidate validation. M01 is the next runnable maturity batch.

## Planning Layers

Ambitions now uses three planning layers:

```text
Layer 1: D01-D26
Canon alignment and launch-loop coherence.

Layer 2: Re-optimized 89-120
Maturity, advanced systems, integration QA, reliability, path intelligence, external surfaces, memory/reviews maturity.

Layer 3: RC Lock / TestFlight / App Store path
Final validation, screenshots, release notes, metadata, device testing, privacy review.
```

Layer 1 execution remains locked. This document only plans Layer 2 and Layer 3.

## Source Inputs

This roadmap rewrites original Batches 89-120 using:

- `docs/canon/Ambitions_2_0_Roadmap_Merge_Audit.md`
- `docs/canon/GOLDEN_LAUNCH_LOOP.md`
- `docs/canon/HUMAN_LANGUAGE_REVIEW.md`
- `docs/canon/ROADMAP_BATCH_CLASSIFICATION.md`
- `docs/canon/Ambitions_2_0_Object_Terminology.md`
- `docs/canon/design/Ambitions_Design_Constitution.md`
- `docs/canon/IMPLEMENTATION_ACCEPTANCE_GATES.md`
- the final implemented state of D01-D26 once available

## Non-Negotiable Constraints

Layer 2 must preserve:

- Top-level shell: `Today / Goals / Capture / Plan / You`.
- Deep, not wide.
- No top-level Tasks tab.
- No top-level Insights tab.
- No top-level Habits tab.
- No top-level Calendar tab.
- `Task = standalone One-Step Goal`.
- `Step = contained action inside Goal / Path / Plan`.
- Capture uses Smart Attachment with receipts and correction.
- Plan owns calendar permission and planning context.
- You owns trust, controls, history, memory, reviews, export, and privacy.
- External surfaces consume shared commands, privacy snapshots, stale-state truth, and receipt boundaries.
- Normal UI sounds human and plain, not AI/producty.
- No fake sync, account, accessibility, privacy, AI, or platform claims.
- User-facing accessibility claims require evidence.
- RC lock requires D26 evidence and explicit human approval.

## Why Original 89-120 Needed Rewrite

Original Batches 89-120 remain useful roadmap intent, but they were authored before the Design Constitution and D01-D26 dependency layer. Running them unchanged would risk:

- validating pre-Constitution surfaces,
- restoring old top-level IA,
- mixing Task and Step semantics,
- shipping external surfaces before privacy snapshot contracts,
- maturing memory before trust controls,
- publishing accessibility claims before verification,
- overclaiming sync/export/data safety,
- or locking an RC before D26 evidence.

The re-optimized M-roadmap retains the useful ambition of 89-120 while forcing every batch through the newer canon.

## Layer 2: Re-Optimized 89-120 Maturity Batches

The M-series is the recommended post-D26 maturity execution plan. It assumes D01-D26 are already implemented and validated for planning purposes only.

### M01 — Core Surface Integration QA and Indispensability Scenarios

Original sources: 89, 114.

Purpose: Prove the aligned app behaves as one coherent daily life system across Today, Goals, Goal Detail, Capture, Plan, You, reviews, proof, receipts, waiting, recovery, and trust.

Scope:

- Build representative scenario fixtures for the aligned app.
- Validate the Golden Launch Loop end to end.
- Test at least these scenarios:
  - create a meaningful goal,
  - capture a loose thought and place it,
  - recover from a missed day,
  - resolve an overloaded week,
  - review proof and receipts,
  - inspect What Ambitions knows,
  - use no-calendar or denied-calendar fallback,
  - start with a one-step goal,
  - park/defer/drop noncritical work,
  - return after a week away.
- Identify product friction, not just test failures.
- Produce a blocker list for M02-M12 and Layer 3.

Do not:

- add new major systems,
- redesign major surfaces,
- relitigate the five-tab shell,
- claim release readiness.

Acceptance:

- scenario fixture catalog exists,
- manual QA checklist exists,
- automated or service-level coverage is added where practical,
- blockers are classified by severity,
- no old IA or old terminology reappears.

Earliest timing: after D26.

### M02 — Export / Import Proof and Disaster Drill

Original sources: 90.

Purpose: Make local-first trust practical by proving the user can export, import, and recover important Ambitions data without feeling hostage.

Scope:

- Define portable export package contents.
- Include receipts/proof/history where safe.
- Include privacy/redaction rules from D05.
- Add import validation and safe failure states.
- Test restore into a fresh install / new-phone scenario where practical.
- Add disaster drill evidence.
- Keep sync out of scope.

Do not:

- implement cloud sync,
- require account creation,
- imply Apple-first sync is complete,
- silently overwrite local data,
- hide export behind paid features.

Acceptance:

- export/import contract is documented and tested,
- failure states are calm and recoverable,
- receipts/proof survive where appropriate,
- user can understand what was exported and imported,
- no data-hostage posture.

Earliest timing: after M01, D05, D18-D19 foundations.

### M03 — Data Safety, Migration, Offline Reliability, and No-Lost-Data Hardening

Original sources: 117 plus pieces of 90, 118.

Purpose: Prove Ambitions is safe with local data, migrations, offline behavior, restore flows, and reliability boundaries.

Scope:

- Verify local/offline behavior.
- Harden schema migrations.
- Test corrupt/missing/partial data fallback.
- Verify receipt/history/proof data integrity.
- Add no-lost-data checks around key actions.
- Validate export/import interactions from M02.
- Document unsupported sync states honestly.

Decision-gated scope:

- Sync conflict safety remains gated behind a future human sync decision.

Do not:

- implement sync by accident,
- claim cloud reliability,
- require account systems,
- silently discard user records.

Acceptance:

- migration tests exist,
- offline behavior is explicit,
- key local data survives expected app lifecycle scenarios,
- failure states are documented,
- known data-risk blockers are listed before external testing.

Earliest timing: after M02.

### M04 — External Surface Verification and Continuity Hardening

Original sources: 92, 93, 94 plus relevant pieces of 111, 112, 118.

Purpose: Verify widgets, Live Activities, App Intents, Shortcuts, notifications, and shared-container receipts only after D22-D25 external-surface alignment exists.

Scope:

- Verify external surfaces consume shared command/receipt/privacy contracts.
- Test stale-state labels.
- Test privacy-safe projections.
- Test open routes and fallback routes.
- Test no silent destructive/external writes.
- Verify widget snapshots and Live Activity state where implemented.
- Verify App Intents/Shortcuts behavior and dialogs.
- Add external platform verification checklist.

Do not:

- add external-surface scope before D22-D25,
- show sensitive details on lock screen/widgets by default,
- implement new external product surfaces without privacy snapshots,
- claim full platform readiness without device evidence.

Acceptance:

- external surfaces have stale/private/failure states,
- shared receipts work where actions occur,
- platform/device checks are documented,
- unverified claims are removed or softened,
- external surface blockers are listed for Layer 3.

Earliest timing: after D22-D25 and M01.

### M05 — Path Intelligence Foundation and Future Self Simulation

Original sources: 95.

Purpose: Rebuild path intelligence on top of D07-D15 object/surface foundations: Life Areas, North Stars, One-Step Goals, Goals, Goal Detail, and Plan.

Scope:

- Define qualitative path families.
- Define path stages, prerequisites, dependencies, proof requirements, risk, fallback paths, and waiting states.
- Define Future Self Simulation as scenario exploration, not prediction.
- Connect path outputs to daily next steps and proof.
- Ground suggestions in user-owned data and explicit assumptions.

Do not:

- imply certainty,
- use black-box AI language,
- create a separate Path tab,
- bypass Goals/Plan/Today,
- produce domain advice without source/freshness boundaries.

Acceptance:

- path intelligence contract exists,
- path assumptions are visible/correctable,
- next-step connection is clear,
- fallback paths exist,
- proof requirements are represented,
- human copy avoids prediction/AI-wrapper posture.

Earliest timing: after D15, D20, and M01.

### M06 — Domain Path Packs and Path Fork Simulator

Original sources: 96.

Purpose: Add reusable domain path packs and fork comparison without turning Ambitions into a template library or fake expert system.

Scope:

- Define broad domain packs such as career, education, creative project, health, finance, relationship/family, and home/life admin.
- Add path fork comparison.
- Support prerequisites, risks, proof requirements, timeline ranges, and fallback options.
- Keep pack assumptions visible and editable.
- Use source/freshness boundaries when external or static knowledge is involved.

Do not:

- create narrow template sprawl,
- imply professional advice,
- silently decide the best path,
- override user intent,
- create hidden scoring.

Acceptance:

- pack framework exists,
- fork comparison is explainable,
- assumptions are visible,
- domain limits are clear,
- output connects to Goals/Plan/Today.

Earliest timing: after M05.

### M07 — Path Builder and Long-Range Roadmap UI

Original sources: 97, 110.

Purpose: Give users a premium long-range roadmap view that connects life direction, phases, milestones, path forks, and daily action.

Scope:

- Build Path Builder over M05-M06 contracts.
- Show phases, milestones, dependencies, forks, proof requirements, and decisions.
- Connect to Goal Detail, Plan, Today, and proof.
- Provide accessible list fallback for any visual/zoom/map surface.
- Include clear breadcrumbs and no hidden navigation.

Do not:

- create a new top-level tab,
- force semantic zoom without fallback,
- make a project-management board,
- hide current next action,
- over-render large maps without performance budgets.

Acceptance:

- roadmap UI is understandable and drilldown-safe,
- long-range path connects to today,
- path changes leave decision/proof receipts,
- accessibility fallback exists,
- performance budget is measured.

Earliest timing: after M06 and D21.

### M08 — Learning, Anticipation, Memory Correction, and Narrative Memory Maturity

Original sources: 98, 99, 101.

Purpose: Mature local learning and memory so Ambitions can become more helpful without feeling creepy or AI-like.

Scope:

- Use explicit evidence, receipts, corrections, reviews, and user confirmations.
- Mature What Ambitions Knows and correction flows.
- Add memory freshness/review signals instead of user-facing confidence jargon.
- Add narrative memory only where source, edit, delete, and pause controls exist.
- Detect patterns conservatively.

Do not:

- infer sensitive identity without confirmation,
- expose raw memory graph language,
- use confidence-score UI,
- make black-box recommendations,
- learn invisibly without controls.

Acceptance:

- memory claims show source/freshness,
- user can correct/delete/pause,
- sensitive memory is gated,
- learning is local-first and explainable,
- user-facing language is human.

Earliest timing: after D18-D20 and M01.

### M09 — Reviews, Life OS Receipt, and Narrative Progress Maturity

Original sources: 109 plus pieces of 88, 100, 114.

Purpose: Mature reviews into a meaningful reflection/proof system without restoring a top-level Insights dashboard.

Scope:

- Mature Weekly/Monthly/Recovery reviews under You/Plan/Goal contexts.
- Strengthen Life OS Receipt as a human-readable progress artifact.
- Summarize proof, decisions, recovery, carry-forward, and what changed.
- Avoid fake precision and report-card tone.
- Connect reviews to next week/day planning.

Do not:

- reintroduce Insights as a top-level tab,
- create analytics dashboard creep,
- shame missed work,
- overstate memory or prediction.

Acceptance:

- reviews help the user decide what to keep, change, carry forward, or drop,
- receipts/proof are visible and privacy-safe,
- review copy is calm and human,
- review output affects Plan/Today only through confirmed/safe paths.

Earliest timing: after D19-D21, M08 optional.

### M10 — Portfolio, Goal Weather, Goal Scope, and Momentum Maturity

Original sources: 103, 107.

Purpose: Mature Goals into a premium ambition portfolio that shows health, scope, proof, stuck work, archive learning, and momentum without becoming a dashboard.

Scope:

- Mature Goal Weather using proof, blockers, plan fit, waiting, and scope.
- Mature Completion Archive and cancelled/dropped learning summaries.
- Compare proof maturity qualitatively.
- Detect too many stuck tasks / one-step goals.
- Add goal scope maturity checks.
- Keep current next step visually obvious.

Do not:

- create fake numerical certainty,
- make Goals a kanban/productivity board,
- hide next action under analysis,
- restore top-level Tasks.

Acceptance:

- portfolio view helps users choose attention,
- proof matters more than checkboxes,
- archive learning is useful and not punitive,
- scope signals are actionable,
- Goals remains calm and visually obvious.

Earliest timing: after D13-D14, D20-D21, M01.

### M11 — Plan, Recovery, Commitment, Waiting, and Save-the-Day Maturity

Original sources: 104, 105, 106.

Purpose: Mature Plan and recovery into a trustworthy system for constraints, waiting, commitments, social load, and overloaded days.

Scope:

- Mature Plan believability using current plain language.
- Mature Reality Reflow and Save the Day with explicit confirmation boundaries.
- Mature waiting/commitment/promise ledger behavior.
- Keep social load private, manual-first, qualitative, and non-punitive.
- Strengthen undo/receipt behavior for plan changes.

Do not:

- silently reflow broad plans,
- write calendar changes without confirmation,
- infer social obligations aggressively,
- use old `believability` jargon in normal UI,
- restore Habits as standalone.

Acceptance:

- overloaded days become actionable without shame,
- recovery changes explain what moved and what stayed,
- commitments/waiting are visible where useful,
- plan changes have receipts/undo status,
- user remains in control.

Earliest timing: after D11, D15-D16, D20-D21, and M01.

### M12 — Cross-Surface Continuity, Mode Lens, Mature Invention Performance

Original sources: 111, 112, 116, 118.

Purpose: Make the whole app feel like one polished operating system, then measure responsiveness and invention maturity before Layer 3.

Scope:

- Mature continuity ribbon behavior.
- Mature mode/context lens behavior without hidden navigation.
- Verify cross-surface handoffs between Today, Capture, Goals, Plan, You, Reviews, external surfaces, and Path Builder if present.
- Run mature invention performance checks for graph/ledger/proof/trust queries, panels, navigation, widgets, and Live Activities where implemented.
- Run visual/shell regression with D03/D04 components and D20 language.

Do not:

- create hidden global modes that confuse users,
- add new top-level surfaces,
- overanimate or overload the shell,
- certify unverified external surfaces.

Acceptance:

- cross-surface continuity is understandable,
- mode/lens behavior is visible and reversible,
- performance budgets are measured,
- visual shell remains premium/calm,
- Layer 3 blockers are explicit.

Earliest timing: after M01-M11 as relevant; final version after D22-D25 if external surfaces ship.

## Layer 3: RC Lock / TestFlight / App Store Path

Layer 3 should begin only after D26 and the chosen Layer 2 maturity slices have enough evidence.

### R01 — Final Accessibility Verification and Claims Lock

Original sources: 115.

Purpose: Verify accessibility before any user-facing Accessibility Nutrition or App Store claim.

Scope:

- VoiceOver review.
- Dynamic Type review.
- Reduce Motion review.
- Contrast review.
- Motor/tap-target review.
- External-surface accessibility review where applicable.
- Claims audit.

Acceptance:

- claims map to evidence,
- unsupported claims are removed,
- blockers are listed and owned.

### R02 — Final Performance, Memory, and Responsiveness Pass

Original sources: 112, 118.

Purpose: Verify performance on realistic data and device scenarios.

Scope:

- app launch,
- tab switching,
- Today load,
- Goal Detail load,
- Plan load,
- receipt/history queries,
- memory/review queries,
- path/portfolio queries if implemented,
- external snapshots if implemented.

Acceptance:

- performance is measured,
- regressions are fixed or deferred explicitly,
- user-facing surfaces feel fast enough for testing.

### R03 — Device QA, TestFlight Readiness, and Scenario Review

Original sources: 113, 114, 119.

Purpose: Validate the app outside the simulator with representative user journeys.

Scope:

- real-device smoke,
- fresh install,
- returning user,
- denied permissions,
- no data / lots of data,
- missed week,
- export/import if implemented,
- external surfaces if implemented,
- pregnancy/family/career/creative/finance-style representative scenarios only as fixtures, not hardcoded domains unless productized.

Acceptance:

- TestFlight candidate is justified by evidence,
- blockers are owned,
- screenshots/demo states are accurate.

### R04 — App Store, Privacy, Marketing, and Investor Demo Readiness

Original sources: 116, 117, 120 plus release docs.

Purpose: Prepare external-facing truth.

Scope:

- App Store copy,
- screenshots,
- privacy labels,
- reviewer notes,
- support/contact flow,
- release notes,
- investor demo script,
- marketing one-pager alignment,
- no fake claims.

Acceptance:

- marketing matches shipped behavior,
- privacy disclosures match data behavior,
- screenshots are current,
- investor/demo story proves the Golden Launch Loop.

### R05 — RC Lock Decision

Original sources: 119, 120.

Purpose: Freeze release-candidate truth only after evidence and human approval.

Scope:

- blocker/deferral list,
- final registry state,
- final docs status,
- release notes,
- known limitations,
- human approval gate.

Acceptance:

- RC lock is explicit,
- no automatic lock after D26,
- deferred items are named honestly,
- next roadmap layer is chosen.

## Original 89-120 To New Roadmap Mapping

| Original batch | New handling |
| --- | --- |
| 89 Core Surface Integration QA | M01, M12, R03 |
| 90 Export / Import Proof | M02, M03 |
| 91 Apple-First Sync and Conflict Policy | Human decision gate after M03/R05; not automatic. |
| 92 App Intents and Shared Container Receipts | M04 after D22/D25; receipt pieces depend on D05. |
| 93 Widgets and Live Activity Ambient Continuity | M04 after D22-D24. |
| 94 External Surface Platform Verification | M04 and R03. |
| 95 Path Intelligence Foundation | M05. |
| 96 Domain Path Packs and Fork Simulator | M06. |
| 97 Path Builder UI / Long-Range Roadmap | M07. |
| 98 Learning and Anticipation | M08. |
| 99 Memory Confidence, Correction Cards, Narrative Memory Map | M08, rewritten to source/freshness/review language. |
| 100 Strategy / Learning Integration QA | M01, M08, M09, M12. |
| 101 Life Graph Mature Relationship Audit | M08, M10, M12. |
| 102 Action Closure Mature Receipt / Undo / Trust Audit | M02, M03, M04, M11. |
| 103 Proof-Weighted Progress and Momentum Maturity | M09, M10. |
| 104 Commitments, Waiting, Promise Ledger, Social Load Maturity | M11. |
| 105 Believability Kernel / Constraint Gravity / Plan Treaty Maturity | M11. |
| 106 Reality Reflow / Recovery Gradient / Save the Day Maturity | M11. |
| 107 Ambition Portfolio / Goal Weather / Goal Scope Maturity | M10. |
| 108 Personal Operating Constitution / Calm Intervention Maturity | M08, M11, M12. |
| 109 Reviews / Life OS Receipt / Narrative Memory Maturity | M09. |
| 110 Path Forks / Future Self / Domain Pack Maturity | M06, M07. |
| 111 Cross-Surface Continuity / Mode Lens Maturity | M12. |
| 112 Mature Invention Performance Pass | M12, R02. |
| 113 Onboarding / Empty States / Returning User Continuity | M01, R03. |
| 114 Representative Scenario Fixtures / Indispensability QA | M01, R03. |
| 115 Accessibility Verification / Nutrition Facts | R01. |
| 116 Visual Polish / Appearance Studio / Shell Regression | M12, R04. |
| 117 Offline / Data Safety / Migration / Reliability | M03, R04. |
| 118 Final Performance / Memory / Responsiveness | R02. |
| 119 Ambitions 2.0 RC Audit | R03, R05. |
| 120 Ambitions 2.0 RC Lock | R05 only after human approval. |

## Recommended Execution Order

Default post-D26 sequence:

```text
M01 Core Surface Integration QA and Indispensability Scenarios
M02 Export / Import Proof and Disaster Drill
M03 Data Safety, Migration, Offline Reliability, and No-Lost-Data Hardening
M04 External Surface Verification and Continuity Hardening
M05 Path Intelligence Foundation and Future Self Simulation
M06 Domain Path Packs and Path Fork Simulator
M07 Path Builder and Long-Range Roadmap UI
M08 Learning, Anticipation, Memory Correction, and Narrative Memory Maturity
M09 Reviews, Life OS Receipt, and Narrative Progress Maturity
M10 Portfolio, Goal Weather, Goal Scope, and Momentum Maturity
M11 Plan, Recovery, Commitment, Waiting, and Save-the-Day Maturity
M12 Cross-Surface Continuity, Mode Lens, Mature Invention Performance
R01 Final Accessibility Verification and Claims Lock
R02 Final Performance, Memory, and Responsiveness Pass
R03 Device QA, TestFlight Readiness, and Scenario Review
R04 App Store, Privacy, Marketing, and Investor Demo Readiness
R05 RC Lock Decision
```

## Alternative Execution Modes

### Fast TestFlight Mode

If the goal after D26 is the fastest credible TestFlight:

```text
M01
M02
M03
M12 limited to current shipped surfaces
R01
R02
R03
R04
R05
```

Defer M05-M11 until after initial outside testing.

### Full Ambitions 2.0 Maturity Mode

If the goal after D26 is to maximize product depth before TestFlight:

```text
M01-M12
R01-R05
```

This is slower but best aligned with the full life-OS ambition.

### Investor Demo Mode

If the goal is a premium investor/demo build before wider testing:

```text
M01
M05
M07 limited demo slice
M09
M10
M12
R04
```

This should not be confused with App Store readiness.

## Human Decisions Required After D26

| Decision | Options |
| --- | --- |
| Sync posture | Defer sync; policy-only; Apple-first sync implementation; account-backed sync later. |
| Maturity depth before TestFlight | Fast TestFlight Mode; Full Ambitions 2.0 Maturity Mode; Investor Demo Mode. |
| Path intelligence scope | Contract only; demo slice; full M05-M07 sequence. |
| External surfaces scope | Verify only existing surfaces; expand widgets/Live Activities; defer after TestFlight. |
| RC lock criteria | Testing-ready; investor-ready; App Store-submission-ready. |

## Codex Prompt Rule For M-Batches

Every M-batch prompt should include:

```text
D01-D26 are assumed complete for this planning/execution layer only. Do not alter D-batch completion history unless the registry already says they are complete. Preserve the five-tab shell, Golden Launch Loop, Human Language Review, Object Terminology, Design Constitution, local-first trust posture, receipt/privacy boundaries, and accessibility evidence requirements. Do not restore old 89-120 scope that conflicts with the newer canon.
```

## Next Update Needed

After D26 validation, use this roadmap as the active M/R execution sequence. M01 should begin with the actual D01-D26 implementation evidence, validation results, known blockers, and device/platform constraints now recorded in the registry and context index:

- actual D01-D26 implementation evidence,
- actual validation results,
- product feel from manual review when available,
- user/investor priorities when explicitly supplied,
- known blockers,
- and device/platform constraints.

M01 is now the next dependency-safe implementation batch. Preserve the D01-D26 completion history and do not skip ahead to M02 or R-gates until M01 is implemented, validated, documented, committed, and pushed.
