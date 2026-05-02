# Global Future Batch Execution Order

<!-- markdownlint-disable MD013 -->

Status: Global planning and Codex OS control; no future train started
Date: 2026-05-02

## Purpose

This document defines the global order for remaining formal future Ambitions work across Release Evidence Closure, PXOS, Maintainability Extraction, Compatibility Seam Retirement, AmbitionsOS, and Product Depth. It is an execution map, not execution approval.

Use this file to choose the next eligible batch only after the relevant approval phrase and gates pass. Keep canonical batch IDs stable; use the global order number for cross-train sequencing.

## Source Truth

- `README.md`
- `AGENTS.md`
- `docs/README.md`
- `docs/canon/README.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Documentation_System_Index.md`
- `docs/canon/Ambitions_Beyond_3_0_Roadmap.md`
- `docs/canon/Ambitions_Beyond_3_0_Continuity_Rules.md`
- `docs/canon/AmbitionsOS_Index.md`
- `docs/canon/Ambitions_Product_Experience_OS_Index.md`
- `docs/canon/PXOS_Surface_Hierarchy_And_Navigation.md`
- `docs/canon/PXOS_Product_Depth_And_Drilldown_Rules.md`
- `docs/canon/PXOS_Visual_Interaction_System.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- Future train manifests and batch prompts under `docs/codex/batch-trains/` and `docs/codex/batches/`

## Current State Summary

- Ambitions 3.0 is complete by F30 closeout evidence.
- F17-F30 is historical complete train evidence.
- Release Evidence Closure is active at REC01.
- REC02-REC06 are future continuation batches with standalone prompt files.
- PXOS is future user-facing canon only. PX01-PX20 are future/not started.
- ME01-ME12, CS01-CS10, and AOS01-AOS30 are future/not started.
- AmbitionsOS is future canon only, not implemented app behavior.
- Product Depth is blocked as a future lane. No formal PD batch prompts were found.
- Top-level surfaces remain `Today / Goals / Capture / Plan / You`.
- Top-level surfaces must be visual orientation surfaces, not vertical stacks of generic cards.

Prompt completeness note: REC02 is no longer blocked by a missing standalone
prompt file. It remains blocked by normal execution gates: REC01 acceptance,
the `Continue Release Evidence Closure` approval phrase, release-claim safety,
human-proof boundaries, and clean validation.

## Global Sequencing Principles

1. Evidence before claims: REC closes release evidence truth before messaging or readiness claims.
2. PXOS before major user-facing implementation: user-facing hierarchy, copy, trust, recovery, visual, and accessibility canon must exist before surface changes.
3. Top-level composition before UI implementation: every top-level surface change must pass glance, one-primary-object, and drill-down discipline tests.
4. ME before large UI expansion: known large/tangled owners must be mapped and extracted before major surface work in affected zones.
5. CS before renames/removals: routes, raw values, widgets, App Intents, import/export, and persistence seams must be proven before retirement.
6. AOS internal before AOS exposure: internal kernels may be built after contracts, but user-facing intelligence waits for PXOS expression and trust gates.
7. Product Depth waits for PXOS plus relevant ME/CS gates and must deepen existing surfaces, not widen the app.
8. Red blocks continuation. Yellow continues only when classified, owned, and safe.

## Master Ordered List

| Global | Batch | Train | Type | Dependency rationale | Required gates before start | Parallel safety | Blocked now | Validation expectation | Required skills/review boards | Continuation rule |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 001 | REC02 | REC | Evidence | Human-only proof plan must precede release-adjacent claims. | REC01 accepted, `Continue Release Evidence Closure`, Release Claim, Human Proof | Serial-only | Yes, needs approval | Adequate docs evidence | release evidence, claim boundary, human proof | Stop after REC02 unless REC train continuation is explicit and Green |
| 002 | REC03 | REC | Evidence | Log ledger follows proof plan. | REC02 Green, Validation Evidence | Serial-only | Yes | Adequate docs evidence | evidence gate, validation auditor | Continue only on Green |
| 003 | REC04 | REC | Evidence | Claim copy guard requires evidence ledger context. | REC03 Green, Release Claim, Copy/Language | Serial-only | Yes | Adequate docs evidence | release-claim-truth-enforcer, product-language-reviewer | Continue only on Green |
| 004 | REC05 | REC | Evidence | Human review packet follows claim guard. | REC04 Green, Human Proof, Handoff | Serial-only | Yes | Adequate docs evidence | manual-verification-blocker, release evidence reviewer | Stop if human review is required |
| 005 | REC06 | REC | Evidence | Closure handoff follows review packet. | REC05 Green, Handoff, Rollback | Serial-only | Yes | Adequate docs evidence | evidence-gate-reporter, release-claim-truth-enforcer | Stop after closure unless user selects next train |
| 006 | PX01 | PXOS | Docs/canon | PXOS parent canon and surface hierarchy block all later PXOS work. | `Start PXOS Future-Canon Train`, Source Truth, Product Decision Lock | Serial-only | Yes | Adequate docs evidence | source-truth-reconciler, product decision lock, surface hierarchy | Continue only if train control permits |
| 007 | PX02 | PXOS | Docs/canon | Today expression depends on PX01. | PX01 Green, PXOS, Top-Level Composition | Parallel-safe after PX01 with PX03-PX08 only if approved | Yes | Adequate docs evidence | top-level composition, premium visual, accessibility | Continue only on Green |
| 008 | PX03 | PXOS | Docs/canon | Goals/Mission Control depends on PX01 and top-level law. | PX01 Green, PXOS, Product Depth | Parallel-safe after PX01 with PX02/PX04-PX08 only if approved | Yes | Adequate docs evidence | product-depth-strategist, deep-not-wide reviewer | Continue only on Green |
| 009 | PX04 | PXOS | Docs/canon | Capture expression depends on PX01. | PX01 Green, PXOS, Trust/Privacy | Parallel-safe after PX01 with PX02/PX03/PX05-PX08 only if approved | Yes | Adequate docs evidence | privacy/trust, product language | Continue only on Green |
| 010 | PX05 | PXOS | Docs/canon | Plan/Life Shape depends on PX01. | PX01 Green, PXOS, Accessibility | Parallel-safe after PX01 with PX02-PX04/PX06-PX08 only if approved | Yes | Adequate docs evidence | plan UX, cognitive-load reviewer | Continue only on Green |
| 011 | PX06 | PXOS | Docs/canon | You/Personal System Center depends on PX01 and trust boundaries. | PX01 Green, PXOS, Trust/Proof | Parallel-safe after PX01 with PX02-PX05/PX07-PX08 only if approved | Yes | Adequate docs evidence | trust UX, privacy reviewer | Continue only on Green |
| 012 | PX07 | PXOS | Docs/canon | Action Closure and recovery expression depend on PX01 and 3.0 closure truth. | PX01 Green, Recovery, Trust/Proof | Parallel-safe after PX01 with PX02-PX06/PX08 only if approved | Yes | Adequate docs evidence | recovery reviewer, receipt/proof reviewer | Continue only on Green |
| 013 | PX08 | PXOS | Docs/canon | Trust/proof/receipts expression depends on PX01 and closure rules. | PX01 Green, Trust/Proof, Copy | Parallel-safe after PX01 with PX02-PX07 only if approved | Yes | Adequate docs evidence | trust/proof reviewer, receipt-copy-enforcer | Continue only on Green |
| 014 | PX09 | PXOS | Docs/canon | Cross-surface language should follow surface definitions. | PX02-PX08 Green or accepted Yellow, Copy/Language | Serial-preferred | Yes | Adequate docs evidence | product-language-reviewer, release-claim blocker | Continue only on Green |
| 015 | PX10 | PXOS | Docs/canon | Visual interaction system follows surface and language canon. | PX02-PX09 Green, Visual Quality, Top-Level Composition | Serial-preferred | Yes | Adequate docs evidence | premium-ios-visual-reviewer, accessibility reviewer | Continue only on Green |
| 016 | PX11 | PXOS | Docs/canon | Onboarding/setup needs surfaces, copy, visual, and REC claim boundaries. | PX02-PX10 Green, REC Release Claim | Serial-preferred | Yes | Adequate docs evidence | first-use reviewer, release-claim reviewer | Continue only on Green |
| 017 | PX12 | PXOS | Docs/canon | Accessibility/cognitive load must gate future UI. | PX02-PX11 Green, Accessibility | Serial-preferred | Yes | Adequate docs evidence | accessibility-cognitive-load-reviewer | Continue only on Green |
| 018 | PX13 | PXOS | Docs/canon | Degraded states depend on surface, copy, visual, and accessibility rules. | PX02-PX12 Green, Recovery, Trust | Serial-preferred | Yes | Adequate docs evidence | recovery reviewer, privacy/trust reviewer | Continue only on Green |
| 019 | PX14 | PXOS | Docs/canon | Product Depth architecture must be canon before PD formalization. | PX02-PX13 Green, Product Depth, Deep-Not-Wide | Serial-only | Yes | Adequate docs evidence | product-depth-strategist, drilldown-depth-reviewer | Does not start Product Depth |
| 020 | PX15 | PXOS | Docs/canon | Cross-surface continuity follows depth and degraded-state rules. | PX02-PX14 Green, Compatibility check | Serial-preferred | Yes | Adequate docs evidence | information architecture, compatibility reviewer | Continue only on Green |
| 021 | PX16 | PXOS | Docs/canon | User-facing intelligence expression waits for PXOS trust and AOS boundaries. | PX09/PX13/PX15 Green, AOS boundary check | Serial-only | Yes | Adequate docs evidence | recommendation/source-truth, privacy/trust | Does not expose intelligence |
| 022 | PX17 | PXOS | Docs/canon | Product messaging must wait for REC boundaries and PXOS language. | REC06 Green or accepted Yellow, PX09 Green, Release Claim | Serial-only | Yes | Adequate docs evidence | release-claim-truth-enforcer, copy reviewer | Stop on any claim ambiguity |
| 023 | PX18 | PXOS | Recurring gate | Implementation readiness reorder must run before any PXOS implementation lane. | PX01-PX17 Green, ME/CS/AOS cross-check | Serial-only | Yes | Adequate docs evidence | roadmap-sequencer, codex-train-integrity-lead | Convert to recurring gate before implementation |
| 024 | PX19 | PXOS | Handoff | Handoff follows readiness reorder. | PX18 Green, Handoff, Rollback | Serial-only | Yes | Adequate docs evidence | evidence-gate-reporter, post-run closeout | Stop unless user selects next lane |
| 025 | PX20 | PXOS | Roadmap | Beyond roadmap follows PXOS handoff. | PX19 Green or explicit decision | Serial-only | Yes | Adequate docs evidence | roadmap-sequencer, product strategy reviewer | Stop after roadmap |
| 026 | ME01 | ME | Audit | Maintainability baseline must precede affected extraction and UI expansion. | `Start ME Train`, Source Truth, ME Maintainability | Serial-only | Yes | Adequate audit evidence | large-file-extraction-architect, feature-file responsibility | Continue only on Green |
| 027 | ME08 | ME | Audit/standards | Shared standards should precede repeated extractions. | ME01 Green | Parallel-safe with no code edits only | Yes | Adequate audit evidence | component extraction, testability reviewer | Continue only on Green |
| 028 | ME10 | ME | Recurring gate | Architecture scan becomes a recurring gate before large code work. | ME01/ME08 Green | Serial-preferred | Yes | Adequate audit evidence | architecture review board, file-size reviewer | Convert to recurring gate |
| 029 | ME02 | ME | Extraction | Goals service extraction before Goals/Mission Control expansion. | ME01/ME08/ME10 Green, behavior preservation tests | Parallel-safe after baseline if disjoint | Yes | Strong implementation validation | large-file extraction, test-impact architect | Continue only on Green |
| 030 | ME03 | ME | Extraction | Today service extraction before Today expansion. | ME01/ME08/ME10 Green, behavior preservation tests | Parallel-safe after baseline if disjoint | Yes | Strong implementation validation | large-file extraction, test-impact architect | Continue only on Green |
| 031 | ME04 | ME | Extraction | TodayPanels extraction before more Today UI work. | ME03 Green or explicit safe owner map | Serial-preferred | Yes | Strong implementation validation | swiftui component extractor, visual regression | Continue only on Green |
| 032 | ME05 | ME | Extraction | Plan service extraction before Plan/Life Shape expansion. | ME01/ME08/ME10 Green, behavior preservation tests | Parallel-safe after baseline if disjoint | Yes | Strong implementation validation | large-file extraction, test-impact architect | Continue only on Green |
| 033 | ME06 | ME | Extraction | Profile/You extraction before You trust/depth expansion. | ME01/ME08/ME10 Green, behavior preservation tests | Parallel-safe after baseline if disjoint | Yes | Strong implementation validation | large-file extraction, You trust reviewer | Continue only on Green |
| 034 | ME07 | ME | Extraction | PlanScreen extraction before large Plan UI work. | ME05 Green or explicit safe owner map | Serial-preferred | Yes | Strong implementation validation | swiftui component extractor, file-size reviewer | Continue only on Green |
| 035 | ME09 | ME | Test rebaseline | Product contract tests follow extraction owners. | ME02-ME07 Green or accepted Yellow | Serial-only | Yes | Strong test validation | test-impact architect, ui-test contract | Continue only on Green |
| 036 | ME11 | ME | Repair | Repair only after classified ME evidence. | Failed/Yellow ME gate | Serial-only | Conditional | Strong repair validation | codex-repair-train-designer, maintainability board | Stop if repair cannot stay scoped |
| 037 | ME12 | ME | Handoff | ME handoff follows baseline, extraction, and repairs. | ME01-ME11 resolved | Serial-only | Yes | Adequate handoff evidence | evidence-gate-reporter, post-run closeout | Stop unless next train explicitly approved |
| 038 | CS01 | CS | Compatibility audit | Registry and risk map must precede retirement. | `Start CS Train`, Source Truth, CS Compatibility | Serial-only | Yes | Adequate audit evidence | compatibility-migration-architect, routing reviewer | Continue only on Green |
| 039 | CS07 | CS | Compatibility proof | External route/widget/App Intent proof must precede risky retirements. | CS01 Green | Serial-preferred | Yes | Strong compatibility validation | external surface safety, app intent reviewer | Continue only on Green |
| 040 | CS08 | CS | Compatibility proof | Import/export/persistence proof must precede seam deletion. | CS01 Green | Serial-preferred | Yes | Strong compatibility validation | export-import safety, swiftdata reviewer | Continue only on Green |
| 041 | CS02 | CS | Compatibility retirement | Profile-to-You retirement waits for compatibility map and proofs. | CS01/CS07/CS08 Green as relevant | Serial-only | Yes | Strong compatibility validation | compatibility migration, You trust reviewer | Continue only on Green |
| 042 | CS03 | CS | Compatibility retirement | Insights retirement waits for route/model compatibility proof. | CS01/CS07/CS08 Green as relevant | Serial-only | Yes | Strong compatibility validation | compatibility migration, routing reviewer | Continue only on Green |
| 043 | CS04 | CS | Compatibility retirement | Habits/Ritual/Plan retirement waits for map and proof. | CS01/CS07/CS08 Green as relevant | Serial-only | Yes | Strong compatibility validation | compatibility migration, persistence reviewer | Continue only on Green |
| 044 | CS05 | CS | Compatibility retirement | activeFocus/TodayFocus retirement waits for Today compatibility proof. | CS01/CS07 Green, ME Today gate if files touched | Serial-only | Yes | Strong compatibility validation | routing reviewer, Today state contract | Continue only on Green |
| 045 | CS06 | CS | Compatibility retirement | Internal failure taxonomy retirement waits for copy and compatibility gates. | CS01 Green, Copy/Language | Serial-only | Yes | Strong compatibility validation | product-language reviewer, compatibility reviewer | Continue only on Green |
| 046 | CS09 | CS | Repair | Repair only after classified CS evidence. | Failed/Yellow CS gate | Serial-only | Conditional | Strong repair validation | codex-repair-train-designer, compatibility board | Stop if repair cannot stay scoped |
| 047 | CS10 | CS | Handoff | CS handoff follows retirements/proofs/repairs. | CS01-CS09 resolved | Serial-only | Yes | Adequate handoff evidence | evidence-gate-reporter, compatibility board | Stop unless next train explicitly approved |
| 048 | AOS01 | AOS | Docs/contract | AmbitionsOS runtime contract blocks all AOS work. | `Start AOS Train`, Source Truth, Runtime Contract | Serial-only | Yes | Adequate docs evidence | runtime-contract-reviewer, AOS architecture board | Continue only on Green |
| 049 | AOS02 | AOS | Internal foundation | Life Graph event log follows AOS01. | AOS01 Green, Privacy | Serial-only | Yes | Strong implementation validation | event taxonomy, privacy reviewer | Continue only on Green |
| 050 | AOS03 | AOS | Internal foundation | Projection store depends on event log. | AOS02 Green | Serial-only | Yes | Strong implementation validation | runtime contract, testability reviewer | Continue only on Green |
| 051 | AOS04 | AOS | Internal foundation | Control plane classifier depends on contracts and projection store. | AOS01-AOS03 Green | Serial-only | Yes | Strong implementation validation | runtime contract, governance reviewer | Continue only on Green |
| 052 | AOS05 | AOS | Internal foundation | Starting Position depends on graph and control plane. | AOS02-AOS04 Green | Serial-only | Yes | Strong implementation validation | source truth, privacy reviewer | Continue only on Green |
| 053 | AOS06 | AOS | Internal foundation | Goal compiler depends on Starting Position. | AOS05 Green | Serial-only | Yes | Strong implementation validation | goal path reviewer, testability reviewer | Continue only on Green |
| 054 | AOS07 | AOS | Internal foundation | Local goal packs depend on goal compiler. | AOS06 Green | Serial-only | Yes | Strong implementation validation | source truth, local language boundary | Continue only on Green |
| 055 | AOS08 | AOS | Internal foundation | Alternate paths depend on starting position and goal path. | AOS05-AOS07 Green | Serial-only | Yes | Strong implementation validation | alternate path reviewer, proof/trust | Continue only on Green |
| 056 | AOS09 | AOS | Internal foundation | Option value depends on path portfolio. | AOS08 Green | Serial-only | Yes | Strong implementation validation | longevity reviewer, product identity | Continue only on Green |
| 057 | AOS10 | AOS | Internal foundation | Commitment time depends on graph/control plane. | AOS02-AOS04 Green | Parallel-safe after AOS04 if disjoint | Yes | Strong implementation validation | commitment/time reviewer, privacy | Continue only on Green |
| 058 | AOS12 | AOS | Internal foundation | Proof trust can proceed after graph/control plane and before recommendations. | AOS02-AOS04 Green | Parallel-safe after AOS04 if disjoint | Yes | Strong implementation validation | proof/trust, receipt models | Continue only on Green |
| 059 | AOS13 | AOS | Internal foundation | Source Truth must precede recommendation exposure. | AOS02-AOS04 Green | Parallel-safe after AOS04 if disjoint | Yes | Strong implementation validation | source-truth safety, privacy | Continue only on Green |
| 060 | AOS11 | AOS | Internal foundation | Reality Drift needs Commitment Time and Proof Trust. | AOS10/AOS12 Green | Serial-only | Yes | Strong implementation validation | reality drift, recovery reviewer | Continue only on Green |
| 061 | AOS14 | AOS | Internal foundation | Recommendation Start Here needs control plane, proof, and source truth. | AOS04/AOS12/AOS13 Green | Serial-only | Yes | Strong implementation validation | recommendation eligibility, source truth | No user-facing exposure yet |
| 062 | AOS15 | AOS | Planning boundary | Local Language planning needs deterministic fallback and source truth. | AOS04/AOS13/AOS14 Green | Serial-only | Yes | Adequate/Strong depending on scope | runtime contract, privacy/trust | No model runtime without approval |
| 063 | AOS16 | AOS | Runtime gate | Performance Energy must exist before runtime-heavy work. | AOS01-AOS15 classified | Serial-preferred | Yes | Adequate gate evidence | performance-energy reviewer | Convert to recurring runtime gate |
| 064 | AOS17 | AOS | Runtime gate | Privacy Safety must exist before sensitive/external projection. | AOS01-AOS16 classified | Serial-preferred | Yes | Adequate gate evidence | privacy safety board, projection reviewer | Convert to recurring privacy gate |
| 065 | AOS18 | AOS | Evaluation | Golden scenarios depend on kernel contracts. | AOS01-AOS17 Green | Serial-only | Yes | Strong validation evidence | AOS fixture architect, evaluation reviewer | Continue only on Green |
| 066 | AOS19 | AOS | Experience contract | Experience kernel follows fixtures and PXOS expression. | AOS18 Green, PXOS expression gates | Serial-only | Yes | Adequate/Strong | cognitive load, PXOS reviewer | No broad UI work by implication |
| 067 | AOS20 | AOS | Internal personalization | Local calibration depends on recommendation and evaluation. | AOS14/AOS18 Green, Privacy | Serial-only | Yes | Strong implementation validation | privacy/trust, memory consent | Continue only on Green |
| 068 | AOS21 | AOS | Planning/external | Interoperability planning waits for privacy/performance gates. | AOS16/AOS17 Green, CS external proof | Serial-only | Yes | Adequate planning evidence | app-intent, external-surface, privacy | No platform implementation by implication |
| 069 | AOS22 | AOS | Internal foundation | Longevity depends on graph, proof, and source truth. | AOS02/AOS12/AOS13 Green | Parallel-safe after dependencies if disjoint | Yes | Strong implementation validation | longevity, export/import safety | Continue only on Green |
| 070 | AOS23 | AOS | Governance | Registry follows all kernel contracts. | AOS01-AOS22 classified | Serial-only | Yes | Adequate governance evidence | governance, train integrity | Continue only on Green |
| 071 | AOS24 | AOS | UI integration | UI integration waits for contracts, fixtures, PXOS, ME, and CS gates. | AOS18-AOS23 Green, PXOS, ME, CS | Serial-only | Yes | Strong implementation plus UI evidence | PXOS surface, accessibility, visual, ME/CS | Stop on human proof or weak validation |
| 072 | AOS25 | AOS | Tests/fixtures | Fixture library follows UI integration and evaluation. | AOS18/AOS24 Green | Serial-only | Yes | Strong test evidence | fixture architect, test-impact architect | Continue only on Green |
| 073 | AOS26 | AOS | QA | Privacy/performance QA follows gates and fixtures. | AOS16/AOS17/AOS18/AOS25 Green | Serial-only | Yes | Strong QA evidence | privacy/performance boards | Continue only on Green |
| 074 | AOS27 | AOS | Claim truth | App Store claim truth follows QA but cannot claim readiness without human proof. | AOS26 Green, REC Release Claim | Serial-only | Yes | Adequate release evidence | release-claim-truth-enforcer, human proof | Stop on readiness ambiguity |
| 075 | AOS28 | AOS | Handoff | Handoff follows claim truth. | AOS27 Green | Serial-only | Yes | Adequate handoff evidence | evidence gate, FAANG handoff auditor | Stop unless explicit continuation |
| 076 | AOS29 | AOS | Repair | Repair train runs only after classified AOS Yellow/Red. | Failed/Yellow AOS gate | Serial-only | Conditional | Strong repair validation | repair train, AOS red-team reviewer | Stop if repair cannot stay scoped |
| 077 | AOS30 | AOS | Roadmap | Beyond roadmap follows handoff or explicit decision. | AOS28 Green or explicit user decision | Serial-only | Yes | Adequate docs evidence | roadmap-sequencer, governance | Stop after roadmap |

## Product Depth Lane

No formal `PD*.md` batch prompts were found. Product Depth is therefore not numbered as a batch train in this global order. It is a blocked future lane pending:

- PX14 Product Depth Drilldown Architecture Green.
- PX18 readiness reorder Green as a recurring gate.
- Affected ME gates Green for any owner files touched.
- Affected CS gates Green for routes, raw values, external surfaces, import/export, or persistence seams.
- PXOS Top-Level Surface Composition Gate Green.
- Explicit user approval with a formal Product Depth prompt.

Product Depth must deepen existing Today, Goals, Capture, Plan, and You surfaces through drill-downs and owned detail flows. It must not widen Ambitions with new top-level tabs, dashboards, chat-first surfaces, habit modes, notes areas, or calendar clones.

## Batch Classification Summary

- Keep order: REC02-REC06 after REC01; PX01-PX20 within PXOS canon sequence; most AOS kernel dependencies.
- Move earlier: REC evidence before product messaging; PXOS before user-facing implementation; ME baseline before expansion; CS registry and compatibility proofs before retirements.
- Move later: AOS user-facing exposure, Product Depth implementation, release readiness evidence, platform claims.
- Convert to recurring gate: PX18, ME10, AOS16, AOS17, and all global gate matrix checks.
- Block until dependency resolved: Product Depth; AOS24 UI integration; CS retirements before proof; release/App Store/TestFlight claims before human/platform proof.

## Human-Proof Stop Conditions

Stop and produce an operator checklist when a batch requires physical-device validation, App Store Connect, signed archive distribution, TestFlight, public accessibility conformance, external platform rendering, legal/privacy signoff, product-owner screenshot approval, or final release decision.
