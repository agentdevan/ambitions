# Ambitions 2.0 Roadmap Merge Audit

Status: Historical supporting canon; subordinate to `docs/truth/*`
Date: 2026-04-27.

This audit maps the original Ambitions 2.0 Batches 89-120 against the newer D01-D26 Design Constitution delta/alignment backlog. It is planning documentation only. It does not implement features, mark D batches complete, erase completed batch history, or delete Batches 89-120.

## 1. Executive Summary

Batches 89-120 remain useful roadmap intent, but they are no longer safe to run as the next unchanged execution sequence. The Design Constitution and D01-D26 delta/alignment backlog now form the active dependency layer for all future implementation planning.

The correct merge posture is:

- D01-D26 take precedence wherever old Batch 89-120 scope conflicts with the Design Constitution.
- Batches 89-120 remain preserved future roadmap material only after their owning D-batch foundations are complete or explicitly absorbed.
- No Batch 89-120 work may run before the D batch that provides its required foundation.
- No Batch 89-120 wording may reintroduce Insights/Profile/Habits as top-level tabs, Task/Step ambiguity, a top-level Tasks tab, AI-wrapper language, onboarding permission prompts, non-Plan calendar permission, premature external surfaces, or user-facing accessibility claims without evidence.

After D01 and D02 completion, the next recommended implementation batch is D03 - GroupedNavigationList Foundation.

## 2. Non-Negotiable Precedence Statement

[design/Ambitions_Design_Constitution.md](design/Ambitions_Design_Constitution.md) and the D01-D26 delta/alignment backlog in [Ambitions_2_0_Batch_Plan.md](Ambitions_2_0_Batch_Plan.md) supersede Batches 89-120 wherever there is any conflict.

Batches 89-120 may only be retained when their future handling conforms to:

- `Today / Goals / Capture / Plan / You`.
- `You` as Personal System Center.
- Insights as contextual intelligence, not a top-level tab.
- Habits absorbed into Rituals / Plan / Today / You.
- `Task = standalone One-Step Goal`.
- `Step = contained action inside Goal / Path / Plan`.
- no top-level Tasks tab.
- Plan-owned calendar permission.
- no onboarding permission prompts.
- Smart Attachment with receipts and correction.
- Life Areas / North Stars.
- GroupedNavigationList.
- Panel Size + Display Density.
- accessibility, trust, privacy, receipt, and correction requirements.
- external surfaces gated by Now State, Command Pipeline, privacy snapshots, and verification evidence.

## 3. Whether Batches 89-120 Remain Active

Batches 89-120 remain preserved future roadmap work, but not as the next runnable unchanged sequence. They are active only as merged/resequenced roadmap intent after this audit.

Operationally:

- D01-D26 are the active next implementation sequence.
- Original Batch 89-120 rows remain historical/future roadmap records.
- Batch 89-120 execution must follow the handling in this audit and must not bypass D-batch foundations.
- `RETAIN_AS_PLANNED` is not used for any Batch 89-120 item in this audit because every original batch either depends on a D-batch foundation, overlaps D-batch work, needs Constitution rewrite, or needs a human decision.

## 4. Whether D01-D26 Supersede, Supplement, Resequence, Or Absorb Batches 89-120

D01-D26 mostly supplement and resequence Batches 89-120. Some old verification/release batches are absorbed into D26, and some external-surface and accessibility batches are partially superseded by specific D batches.

The D backlog does not delete old roadmap intent. It provides the missing Constitution-alignment layer needed before old roadmap work can safely resume.

## 5. Batch-By-Batch Mapping

| Original batch | Original name | Original purpose | Related D batch(es) | Classification | Reason | Unique original work not covered by D01-D26 | Conflicting original scope | Recommended final handling | Earliest safe timing |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 89 | Core Surface Integration QA and Performance Pass | Prove Today, Goals, Goal Detail, Plan, You, Reviews, Capture, Life Graph, Proof, Waiting, and Action Closure behave as one loop. | D10-D21, D26 | PARTIALLY_SUPERSEDED_BY_D_BATCH | D10-D21 own the Constitution screen/component/copy/accessibility alignment that must exist before a core integration pass is meaningful. | Representative scenarios for five goals, missed week, wrong recommendation, waiting, calendar denied. | Running now would validate pre-Constitution surfaces and could bless missing Life Areas, One-Step Goals, Smart Attachment, GroupedNavigationList, density, and accessibility work. | Retain as a focused core-loop QA slice after D21 or fold its scenario set into D26. | After D21; before or inside D26. |
| 90 | Export / Import Proof and Disaster Drill | Verify portable trust fallback, restore flow, export receipts, and new-phone scenario. | D05, D18-D19, D20, D26 | RETAIN_BUT_RESEQUENCE_AFTER_D_BATCHES | Export/import proof depends on receipt privacy/search rules and the You/Trust/What Ambitions Knows model. | Disaster drill and new-phone restore scenario. | Could overclaim trust fallback before receipts, Trust Center, and memory controls align. | Retain after D19 with D05 receipt redaction/search and D18-D19 trust/memory dependencies. | After D19; final proof in D26. |
| 91 | Apple-First Sync and Conflict Policy | Define local-first sync status, conflict handling, stale state, Trust Ledger entries, and no backend requirement. | D05, D18-D19, D26 | NEEDS_HUMAN_REVIEW | Sync is not fully owned by D01-D26 and carries product/business risk. A sync decision is required before implementation resumes. | Apple-first conflict policy and sync status model. | Could imply sync implementation or cloud/account capability before product decision and trust evidence. | Preserve as future candidate only after a human sync decision; keep no-backend/no-fake-sync language. | Not before D26 and explicit human decision. |
| 92 | App Intents and Shared Container Receipts | Productize external actions over shared commands, snapshots, receipts, and correction-safe results. | D22, D25, D05, D20-D21 | PARTIALLY_SUPERSEDED_BY_D_BATCH | D22 and D25 own external-surface and App Intent alignment; D05 owns receipts; D21 gates accessibility claims. | Shared-container receipt implementation proof. | Original scope could run before external contract alignment or receipt privacy/correction rules. | Retain only as D25 implementation hardening after D22 contract alignment. | After D25 prerequisites; no earlier than D22. |
| 93 | Widgets and Live Activity Ambient Continuity | Ship lightweight snapshots for Next Visible Step, Active Goal Timeline, portfolio, milestone, protected block, plan strip, proof action, stale state, and denied permission. | D22-D24, D05, D20-D21 | PARTIALLY_SUPERSEDED_BY_D_BATCH | D22-D24 split external contracts, widget alignment, and Live Activity alignment with privacy snapshots and verification gates. | Original combined snapshot family list. | Could ship widgets/Live Activities before Now State, Command Pipeline, privacy snapshots, and platform verification evidence. | Split into D23 Widgets and D24 Live Activities; preserve the useful snapshot list as future allowed content. | Widgets after D23; Live Activities after D24. |
| 94 | External Surface Platform Verification and Performance Pass | Apply external proof gates before production-ready claims. | D22-D26 | ABSORBED_INTO_D_BATCH | D22-D25 own external-surface contract and implementation alignment; D26 owns final validation. | Dedicated external platform performance proof. | None if rewritten, but unsafe before D22-D25 exist. | Absorb verification criteria into D22-D25 acceptance plus D26 release validation. | Inside D22-D26 only. |
| 95 | Path Intelligence Foundation / Life Path Simulation | Define path families, stages, prerequisites, dependencies, proof requirements, fallback paths, and Future Self Simulator contracts. | D07-D09, D13-D15, D20 | RETAIN_BUT_RESEQUENCE_AFTER_D_BATCHES | Path intelligence needs Life Areas, North Stars, One-Step Goals, Goals semantic zoom, Goal Detail lanes, and Plan timeline alignment first. | Future Self Simulator and qualitative path-family contracts. | Could bypass Life Areas/North Stars or blur Task/Step semantics. | Retain after core Life Area/North Star/One-Step and surface alignment; rewrite using Constitution object model. | After D15 and D20. |
| 96 | Domain Path Packs and Path Fork Simulator | Add broad coherent path packs and fork comparisons without template sprawl or fake certainty. | D07-D09, D13-D15, D20, Batch 95 | RETAIN_BUT_RESEQUENCE_AFTER_D_BATCHES | Domain path packs depend on Constitution object semantics and path foundation. | Domain pack catalog and fork comparison behavior. | Could become template sprawl or fake certainty if run before UX writing and object semantics. | Retain after rewritten Batch 95. | After Batch 95 and D20. |
| 97 | Path Builder UI / Long-Range Roadmap v1 | Let users inspect, compare, and adjust paths connected to daily action. | D13-D15, D20-D21, Batches 95-96 | PARTIALLY_SUPERSEDED_BY_D_BATCH | D13-D15 own Goals/Life Areas/North Stars, Goal Detail lanes, and Plan timeline alignment that Path Builder must consume. | Full Path Builder UI and long-range roadmap interactions. | Could create a parallel roadmap UI before Life Areas, North Stars, semantic zoom, and Plan timeline contracts. | Retain as post-D surface/UI expansion over D13-D15 and Batches 95-96. | After D21 and Batches 95-96. |
| 98 | Learning and Anticipation v1 | Add local pattern summaries and user-confirmed learning only. | D05, D18-D20, D21 | RETAIN_BUT_RESEQUENCE_AFTER_D_BATCHES | Learning must consume receipts, Trust Center, What Ambitions Knows, and UX writing cleanup. | Pattern summaries and user-confirmed learning loop. | Could sound like AI-wrapper behavior or produce opaque recommendations. | Retain with strict local/user-confirmed wording after memory/trust alignment. | After D20; accessibility proof in D21 where surfaced. |
| 99 | Memory Confidence, Correction Cards, and Narrative Memory Map | Surface confidence, corrections, and narrative memory calmly. | D18-D20, D05 | PARTIALLY_SUPERSEDED_BY_D_BATCH | D18-D19 own Trust Center and What Ambitions Knows; D20 owns copy cleanup. | Narrative Memory Map and confidence cards. | Original "confidence" language may need replacement with freshness/review labels where user-facing. | Retain unique narrative-memory work after D19, rewritten to Constitution memory/freshness/correction language. | After D20. |
| 100 | Strategy / Learning Integration QA and Performance Pass | Verify Path, learning, memory, proof, reviews, and daily decisions together. | D10-D21, Batches 95-99 | RETAIN_BUT_RESEQUENCE_AFTER_D_BATCHES | This is valuable QA, but only after D surface, trust, UX, and accessibility alignment plus Batches 95-99. | Strategy scenario suite. | Could validate pre-Constitution path/memory behavior. | Retain as strategy/learning QA after Batches 95-99 and D21. | After D21 and Batches 95-99. |
| 101 | Life Graph Mature Relationship Audit | Audit mature Life Graph support for breadcrumbs, lanes, proof, waiting, path forks, reviews, memory, trust, receipts, and Life OS Receipt. | D02, D07-D09, D13-D19 | PARTIALLY_SUPERSEDED_BY_D_BATCH | D02/D07-D09 own the missing object model terminology and Life Areas/North Stars/One-Step foundations. | Mature relationship audit across many inventions. | Could mature the old Life Graph without Life Areas/North Stars/Task semantics. | Retain as maturity audit after D19. | After D19. |
| 102 | Action Closure Mature Receipt / Undo / Trust Audit | Audit receipts, undo categories, safe failures, external receipts, and Trust Ledger integration. | D05-D06, D18-D19, D22-D25 | PARTIALLY_SUPERSEDED_BY_D_BATCH | D05 owns receipt search/privacy; D06 Smart Attachment receipts; D18-D19 trust/memory; D22-D25 external receipts. | Mature receipt/undo audit across calendar/export/sync/external surfaces. | Could mature receipts before search/privacy/redaction and correction are defined. | Retain after receipt/trust/external alignment. | After D25, or earlier internal slice after D19. |
| 103 | Proof-Weighted Progress and Momentum Integrity Maturity | Ensure progress uses proof and proof gaps are correctable. | D10, D13-D14, D18-D20 | RETAIN_BUT_RESEQUENCE_AFTER_D_BATCHES | Proof maturity depends on screen contracts, Goals/Goal Detail transformation, trust, and copy. | Momentum Integrity maturity. | Risk of fake precision or dashboard-like analytics if not rewritten. | Retain with qualitative, proof-first, no-fake-precision language. | After D20. |
| 104 | Commitments, Waiting, Promise Ledger, and Social Load Maturity | Mature waiting/commitments and private qualitative social load. | D10, D12, D15-D20 | RETAIN_BUT_RESEQUENCE_AFTER_D_BATCHES | Waiting/commitments intersect Capture, Plan, You, Trust, and UX writing alignment. | Promise Ledger and private social-load maturity. | Social-load wording could become inferred emotional judgment or analytics dashboard if not constrained. | Retain after Capture/Plan/You/trust/copy alignment with private/manual-first limits. | After D20. |
| 105 | Believability Kernel, Constraint Gravity, and Plan Treaty Maturity | Mature Plan believability and treaty behavior across surfaces. | D11, D15-D16, D20-D21 | PARTIALLY_SUPERSEDED_BY_D_BATCH | D15 owns Plan believability/timeline alignment; D16 owns Ritual split; D11 connects Today. | Constraint Gravity maturity. | Could preserve old Plan concepts before Ritual and calendar labels align. | Retain after D16/D20 as maturity pass over the aligned Plan loop. | After D21. |
| 106 | Reality Reflow, Recovery Gradient, and Save the Day Maturity | Mature safe, explainable, correctable recovery and Save the Day. | D11, D15-D16, D20-D21 | PARTIALLY_SUPERSEDED_BY_D_BATCH | Recovery must consume Today, Plan, Ritual split, UX writing, and accessibility alignment. | Mature Save the Day behavior. | Could silently reflow or use non-Constitution recovery wording. | Retain after Today/Plan/Ritual/copy alignment; require confirmation for broad reflows. | After D21. |
| 107 | Ambition Portfolio Manager, Goal Weather, and Goal Scope Maturity | Mature portfolio, Goal Weather, archive learning, stuck tasks, proof comparison, and scope maturity. | D07-D09, D13-D14, D20-D21 | PARTIALLY_SUPERSEDED_BY_D_BATCH | D13-D14 own Goals/Life Areas/North Stars, semantic zoom, and lanes; D09 owns One-Step Goals. | Mature portfolio and scope-maturity analysis. | Could use old Goal Atlas/Tasks semantics without Life Areas, North Stars, or Task/Step distinction. | Retain after D14/D20 as portfolio maturity over aligned Goals. | After D21. |
| 108 | Personal Operating Constitution and Calm Intervention Maturity | Mature constitution violations and calm interventions. | D17-D20, D21 | PARTIALLY_SUPERSEDED_BY_D_BATCH | D17-D19 own You/Trust/Memory foundations; D20 owns copy. | Mature calm intervention policy. | Could become punitive, generic settings, or opaque automation if run before You/Trust alignment. | Retain after You Personal System Center and trust/memory work. | After D21. |
| 109 | Reviews, Life OS Receipt, and Narrative Memory Maturity | Mature reviews, Life OS Receipt, and narrative memory. | D05, D18-D20, D21 | PARTIALLY_SUPERSEDED_BY_D_BATCH | Reviews depend on receipt search/privacy, Trust Center, What Ambitions Knows, and UX writing. | Mature Life OS Receipt and narrative memory feed. | Could restore Insights-like analytics or overclaim memory. | Retain after D20/D21 with You-owned Reviews and privacy-safe receipts. | After D21. |
| 110 | Path Forks, Future Self Simulation, and Domain Pack Maturity | Mature path forks, future-self simulation, and domain packs. | D07-D09, D13-D15, D20-D21, Batches 95-97 | RETAIN_BUT_RESEQUENCE_AFTER_D_BATCHES | Requires path foundations and aligned Life Area/North Star/Plan/Goal surfaces. | Future Self Simulation maturity. | Could overstate certainty or external-provider depth. | Retain after Batches 95-97 and D21. | After D21 and Batches 95-97. |
| 111 | Cross-Surface Continuity and Mode Lens Maturity | Mature Mode Lens, Continuity Ribbon, and ambient coherence across Today, Capture, Plan, Reviews, and You. | D10-D25 | PARTIALLY_SUPERSEDED_BY_D_BATCH | D10-D17 align screens; D22-D25 align external surfaces. | Continuity Ribbon and mode-lens maturity. | Could create hidden modes or clutter, or skip external privacy/snapshot contracts. | Retain after surface and external alignment, with visible alternatives and no hidden navigation. | After D25. |
| 112 | Mature Invention Performance Pass | Verify performance for screens, panels, graph/ledger/proof/trust queries, widgets, Live Activities, and navigation. | D03-D25, D26 | RETAIN_BUT_RESEQUENCE_AFTER_D_BATCHES | Performance budgets must measure the aligned component/surface/external implementation, not old surfaces. | Dedicated mature invention performance proof. | Could validate incomplete or pre-alignment surfaces. | Retain as pre-D26 performance proof after D25. | After D25; before or inside D26. |
| 113 | Onboarding, Empty States, and Returning User Continuity | Make first-run, degraded, empty, and re-entry states truthful after mature systems exist. | D20-D21, D26 | RETAIN_BUT_RESEQUENCE_AFTER_D_BATCHES | Constitution onboarding forbids upfront permissions and depends on final copy/accessibility truth. | Returning after a month and missed-week re-entry scenarios. | Could request permissions in onboarding or educate about unimplemented systems. | Retain after UX/accessibility alignment; keep no upfront permissions. | After D21; validate in D26. |
| 114 | Representative Scenario Fixtures and Indispensability QA v1 | Turn canon scenarios into reusable validation scripts/checklists. | D10-D26 | RETAIN_BUT_RESEQUENCE_AFTER_D_BATCHES | Scenario fixtures should test the aligned D surfaces and external contracts. | Broad scenario fixture catalog. | Could encode old IA or old object semantics if written too early. | Retain after D21 with final external scenarios after D25. | After D21; complete after D25. |
| 115 | Accessibility Verification and User-Facing Nutrition Facts | Verify accessibility before publishing user-facing claims. | D21, D26 | PARTIALLY_SUPERSEDED_BY_D_BATCH | D21 is the Accessibility Nutrition verification batch; D26 validates final claims. | User-facing Nutrition Facts publication. | Unsafe if it publishes claims before D21 evidence. | Fold verification into D21; retain user-facing publication only after D21 evidence and D26 claim audit. | D21 for verification; publication at D26. |
| 116 | Visual Polish, Appearance Studio, and Shell Regression | Protect premium identity, token discipline, Appearance Studio, top-level calmness, and no IA drift. | D01, D03-D04, D10, D17, D20-D21, D26 | PARTIALLY_SUPERSEDED_BY_D_BATCH | D01/D03/D04/D10/D17/D20-D21 own the foundations this polish pass must verify. | Appearance Studio polish and final shell regression. | Could polish old shell/profile/settings patterns or miss density/size requirements. | Retain as final visual/shell regression after D21 and inside D26. | After D21; final in D26. |
| 117 | Offline, Data Safety, Migration, and Reliability Hardening | Verify local/offline behavior, portable restore, sync conflict safety, migrations, Trust Ledger, and no lost data. | D05, D18-D19, D22-D26, Batch 90, Batch 91 decision | RETAIN_BUT_RESEQUENCE_AFTER_D_BATCHES | Data safety depends on receipts/trust/memory/external contracts and export/import proof; sync conflict safety needs human sync decision. | Migration/reliability hardening and no-lost-data proof. | Could imply sync readiness or conflict handling before decision/evidence. | Retain after export/import proof; split sync-conflict pieces behind Batch 91 human decision. | After D25 plus Batch 90; sync pieces after human decision. |
| 118 | Final Performance, Memory, and Responsiveness Pass | Verify launch/navigation/scroll/external snapshots/graph query responsiveness before RC audit. | D03-D26 | RETAIN_BUT_RESEQUENCE_AFTER_D_BATCHES | Final performance must measure aligned components, surfaces, memory, and external snapshots. | Final memory/responsiveness proof. | Could certify unaligned surfaces. | Retain as the last performance pass before D26 final validation. | After D25; inside D26 closeout. |
| 119 | Ambitions 2.0 RC Audit | Check every major invention against Gate 6 and produce blocker/deferral list. | D26 | ABSORBED_INTO_D_BATCH | D26 is the Release Candidate Validation batch and should include the RC audit. | Gate 6 blocker/deferral list. | None if absorbed; unsafe before D01-D25 are complete. | Absorb into D26 acceptance criteria. | D26 only. |
| 120 | Ambitions 2.0 Release Candidate Lock | Freeze RC truth after validation. | D26 | RETAIN_BUT_RESEQUENCE_AFTER_D_BATCHES | D26 validates; an RC lock can only happen after D26 evidence and any human blocker decisions. | Final freeze of docs, copy, registry, validation evidence, and release notes. | Unsafe if treated as automatic after old Batch 119 without D backlog validation. | Retain as post-D26 lock decision, not as automatic implementation batch. | After D26 and human approval. |

## 6. D01-D26 Coverage Table

| D batch | Coverage from D backlog | Batch 89-120 work it protects or resequences |
| --- | --- | --- |
| D01 | Shell IA / Tab Alignment Delta. | Prevents 89, 113, 116 from validating or polishing stale IA. |
| D02 | Shared Object Terminology Cleanup. | Protects 95, 97, 101, 107 from Task/Step and Life Area/North Star drift. |
| D03 | GroupedNavigationList Component. | Protects 87-derived You work, 108, 116, and settings/trust maturity. |
| D04 | Panel Size + Display Density. | Protects 89, 112, 116, 118 from measuring/polishing incomplete panel behavior. |
| D05 | Receipt / Action Closure Search and Privacy Contract. | Protects 90, 92, 98-99, 102, 109, 117. |
| D06 | Smart Attachment Foundation. | Protects 89, 92, 102 and all Capture/external receipt correction work. |
| D07 | Life Areas Overview / Atlas Object Model. | Protects 95-97, 101, 107, 110. |
| D08 | North Stars / Dormant Ambitions Object Model. | Protects 95-97, 101, 107, 110. |
| D09 | One-Step Goals Object Model. | Protects 89, 95, 97, 101, 107 from Task/Step ambiguity. |
| D10 | Screen Contract Matrix Implementation Pass. | Protects 89, 100, 111, 114 from validating old surfaces. |
| D11 | Today 2.0 Design Constitution Alignment. | Protects 89, 105-106, 111, 114. |
| D12 | Capture + Quiet Command Sheet Alignment. | Protects 89, 104, 111, 114. |
| D13 | Goals / Life Areas / North Stars Transformation and Semantic Zoom. | Protects 95, 97, 101, 103, 107, 110. |
| D14 | Goal Detail Mission Control Lanes Alignment. | Protects 95, 97, 101, 103, 107, 110. |
| D15 | Plan Believability + Timeline Widget Alignment. | Protects 95, 97, 105-106, 110. |
| D16 | Ritual Split Alignment. | Protects 89, 105-106 from restoring Habits as standalone. |
| D17 | You Personal System Center Alignment. | Protects 90, 98-99, 108-109, 116. |
| D18 | Trust Center Alignment. | Protects 90-92, 98-99, 101-102, 108-109, 117. |
| D19 | What Ambitions Knows. | Protects 90-91, 98-99, 101, 108-109, 117. |
| D20 | UX Writing Cleanup. | Protects 95-99, 103-109, 113, and external-surface copy. |
| D21 | Accessibility Nutrition Verification. | Protects 89, 92-94, 100, 105-116, 118, 120 from premature claims. |
| D22 | External Surfaces Contract Alignment. | Protects 92-94, 111, 117-118. |
| D23 | Widgets Alignment. | Protects widget portions of 93, 94, 112, 118. |
| D24 | Live Activities Alignment. | Protects Live Activity portions of 93, 94, 112, 118. |
| D25 | App Intents / Shortcuts Alignment. | Protects 92, 94, 111, 117-118. |
| D26 | Release Candidate Validation. | Absorbs 94/119 validation work and gates 120 RC lock. |

## 7. Work From Batches 89-120 Not Covered By D01-D26

The D backlog covers Constitution alignment, but these useful original roadmap items remain as future work to preserve:

- Batch 90 disaster drill and new-phone restore scenario.
- Batch 91 Apple-first sync/conflict-policy decision and implementation, pending human review.
- Batch 95 Future Self Simulator and qualitative Life Path Simulation contracts.
- Batch 96 domain path packs and path fork simulator.
- Batch 97 full Path Builder / long-range roadmap UI.
- Batch 100 strategy/learning scenario suite.
- Batch 104 Promise Ledger and private/manual-first social-load maturity.
- Batch 110 mature path forks, Future Self Simulation, and domain-pack maturity.
- Batch 114 reusable representative scenario fixtures.
- Batch 117 migration/reliability/no-lost-data hardening.
- Batch 120 final RC lock decision after validation.

## 8. Work From D01-D26 Not Represented In Batches 89-120

These D items are not sufficiently represented by old Batches 89-120 and must not be skipped:

- D01 current-tab tap behavior and shell compatibility cleanup.
- D02 explicit Task/Step terminology cleanup before surfaces.
- D03 GroupedNavigationList component and row taxonomy.
- D04 Panel Size + Display Density foundation.
- D05 searchable receipt history and privacy-safe display rules.
- D06 Smart Attachment with confidence behavior, editable receipts, and correction.
- D07 Life Areas Overview / Atlas object model.
- D08 North Stars / dormant Ambitions object model.
- D09 One-Step Goals as standalone Tasks with promotion/demotion/attachment.
- D10 screen-contract implementation pass.
- D12 Quiet Command Sheet alignment as non-chat, global action surface.
- D16 Habits absorption into Ritual split.
- D17 You Personal System Center categories.
- D18 Trust Center alignment.
- D19 What Ambitions Knows.
- D20 full UX writing/state-language cleanup.
- D22 external-surface contract alignment before platform-specific implementation.
- D23-D25 split widget, Live Activity, and App Intent alignment.
- D26 release validation after D01-D25.

## 9. Batch 89-120 Items That Must Be Rewritten To Conform

The following old batch scopes must be rewritten before implementation:

- 89: Core QA must validate Constitution screen contracts, not old completed-surface expectations.
- 91: Sync policy must remain a decision-gated, no-fake-sync future item.
- 92-94: External surfaces must follow D22-D25 privacy snapshots, receipts, confirmations, and verification gates.
- 95-97 and 110: Path work must consume Life Areas, North Stars, One-Step Goals, Goal Detail lanes, Plan timeline, and UX writing rules.
- 99 and 109: Memory confidence/narrative memory must use Constitution memory freshness, correction, privacy, and You-owned placement.
- 104: Social-load work must remain private, manual-first, qualitative, and non-punitive.
- 105-106: Plan/recovery maturity must preserve Plan-owned calendar permission and explicit confirmation for broad reflows.
- 107: Portfolio maturity must use Life Areas/North Stars and avoid a dashboard or top-level Tasks posture.
- 108: Calm interventions must remain correctable and non-punitive, with no hidden automation.
- 113: Onboarding must not request upfront calendar or notification permission.
- 115: Accessibility Nutrition may publish user-facing claims only after verification evidence.
- 116: Visual polish must preserve Today / Goals / Capture / Plan / You and cannot restore Insights/Profile/Habits top-level labels.
- 117: Offline/data/sync hardening must not imply sync readiness before the Batch 91 human decision.
- 120: RC lock requires D26 evidence and human approval; it is not automatic.

## 10. Unsafe To Run Before Specific D Batches

| Unsafe original batch | Must wait for | Why |
| --- | --- | --- |
| 89 | D10-D21 | Core QA must test aligned screen contracts, copy, trust, and accessibility posture. |
| 90 | D05, D18-D19 | Export/import receipts and trust/memory controls must exist first. |
| 91 | D26 plus human decision | Sync policy requires explicit product decision and trust proof. |
| 92 | D22 and D25 | App Intents require external-surface and Shortcuts alignment. |
| 93 | D22-D24 | Widgets/Live Activities require privacy snapshot contracts and platform-specific alignment. |
| 94 | D22-D26 | External verification has nothing reliable to verify before the external D batches. |
| 95-97 | D07-D15 and D20 | Path work depends on Life Areas, North Stars, One-Step Goals, surface contracts, and copy. |
| 98-100 | D18-D21 | Learning/memory work depends on trust, memory, copy, and accessibility evidence. |
| 101-112 | Relevant D foundations through D25 | Mature audits must audit the aligned implementation, not pre-Constitution surfaces. |
| 113-118 | D20-D25 as applicable | Release hardening depends on aligned copy, accessibility, external surfaces, and performance budgets. |
| 119 | D26 | RC audit is D26 work. |
| 120 | D26 plus human approval | RC lock follows validation evidence and explicit decision. |

## 11. Recommended Execution Order Going Forward

1. D01 Shell IA / Tab Alignment Delta.
2. D02 Shared Object Terminology Cleanup.
3. D03 GroupedNavigationList Component.
4. D04 Panel Size + Display Density.
5. D05 Receipt / Action Closure Search and Privacy Contract.
6. D06 Smart Attachment Foundation.
7. D07 Life Areas Overview / Atlas Object Model.
8. D08 North Stars / Dormant Ambitions Object Model.
9. D09 One-Step Goals Object Model.
10. D10 Screen Contract Matrix Implementation Pass.
11. D11 Today 2.0 Design Constitution Alignment.
12. D12 Capture + Quiet Command Sheet Alignment.
13. D13 Goals / Life Areas / North Stars Transformation and Semantic Zoom.
14. D14 Goal Detail Mission Control Lanes Alignment.
15. D15 Plan Believability + Timeline Widget Alignment.
16. D16 Ritual Split Alignment.
17. D17 You Personal System Center Alignment.
18. D18 Trust Center Alignment.
19. D19 What Ambitions Knows.
20. D20 UX Writing Cleanup.
21. D21 Accessibility Nutrition Verification.
22. D22 External Surfaces Contract Alignment.
23. D23 Widgets Alignment.
24. D24 Live Activities Alignment.
25. D25 App Intents / Shortcuts Alignment.
26. D26 Release Candidate Validation.
27. Post-D26 retained Batch 90 disaster drill if not already fully validated in D26.
28. Batch 91 sync/conflict-policy decision and future implementation only after human approval.
29. Retained path/learning/maturity roadmap work from Batches 95-118 in Constitution-conforming slices.
30. Batch 120 RC lock only after D26 evidence and human approval.

Batch 89 is no longer the next runnable implementation batch. Its core-surface QA intent should run after D21 or be folded into D26.

## 12. Human-Review Items

| Item | Decision needed |
| --- | --- |
| Batch 91 Apple-first sync/conflict policy | Decide whether Ambitions 2.0 includes sync implementation before RC, a post-RC policy-only document, or a deferred future product track. |
| Batch 120 RC lock | Decide when D26 validation evidence is sufficient to freeze RC truth. |
| Path intelligence scope from Batches 95-97/110 | Decide how much Future Self Simulation and Path Builder scope belongs before RC versus after D26. |
| Representative scenario depth from Batch 114 | Decide whether scenario fixtures are lightweight checklists, UI automation, service-level tests, or a staged combination. |

## 13. Next Recommended Batch

Next recommended implementation batch: D03 - GroupedNavigationList Foundation.

D03 should not start in this audit pass. It remains planned future implementation work after D02 closeout.

## 14. Validation

Required validation for this docs-only audit:

- `git diff --check`
  - Result: passed.
