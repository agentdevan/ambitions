# PLOS-014 Stale Artifact And Duplicate Map

Status: Green for AMB-650 mapping scope; Yellow for broad raw-log volume and future cleanup decisions
Linear issue: AMB-650
Parent issue: AMB-609
Program phase: PLOS-M01 live runtime truth map
Updated: 2026-06-12
Branch: main

## Closeout Header

- PLOS child closeout: yes
- Linear issue: AMB-650
- Parent issue: AMB-609
- Green/Yellow/Red status: Green for stale/duplicate classification scope; Yellow for material cleanup, owner decisions, and fixture-vs-production proof owned by later issues.
- Pushed to main: pending at report creation
- Push hash: pending at report creation
- App source changed: no
- Runtime features implemented: no
- PLOS-M00 executed: no
- Linear identifiers used: AMB issue identifiers only
- Validation run: see Validation
- Red blockers: none
- Yellow limits: raw stale-term search is intentionally broad; top-level `tests` is absent in the literal required commands; this issue maps and quarantines risk but does not delete, rename, or clean source/docs.
- Owner approval claimed: no
- Release/TestFlight/App Store readiness claimed: no
- Next recommended action: after AMB-650 commit, push, and Linear closeout, continue AMB-651 only.

## Scope

AMB-650 identifies stale, duplicate, preview-only, fixture-only, superseded, and drift-risk artifacts that can mislead future PLOS work. It does not delete artifacts, rename types, edit active Swift code, rewrite old docs, implement runtime behavior, run UIQL, or execute PLOS-M02+.

Existing-first proof artifacts:

- `artifacts/personal-life-os/validation/PLOS-014-stale-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-014-duplicate-type-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-014-stale-file-candidate-list.txt`
- `artifacts/personal-life-os/validation/PLOS-014-stale-term-counts.tsv`
- `artifacts/personal-life-os/validation/PLOS-014-material-stale-candidates.txt`
- `artifacts/personal-life-os/validation/PLOS-014-required-stale-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-014-required-stale-search-stderr.txt`
- `artifacts/personal-life-os/validation/PLOS-014-required-stale-search-exit-code.txt`
- `artifacts/personal-life-os/validation/PLOS-014-required-duplicate-type-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-014-required-duplicate-type-search-stderr.txt`
- `artifacts/personal-life-os/validation/PLOS-014-required-duplicate-type-search-exit-code.txt`

The literal required searches over `Native Sources docs tests scripts` and `Native Sources tests` exited `2` because this repo has `Native/AmbitionsTests` rather than a top-level `tests` directory. The stderr and exit codes are preserved as Yellow evidence. Adapted searches include `Native/AmbitionsTests`.

## Stale IA And Copy Map

The raw log contains the full per-line match set. This table classifies the material term families and representative high-risk instances.

| Term family | Representative path / line | Current context | Classification | Risk | Recommended handling | Owner phase |
|---|---|---|---|---|---|---|
| Plan | `Native/Ambitions/App/AppTab.swift:199`, `:216`, `:242`; `Native/Ambitions/Features/Time/TimeReflowDecisionState.swift`; `Native/Ambitions/Domain/Planning/*`. | Legacy route compatibility maps `plan` to Time; Time/reflow use contextual plan language; planning domain models remain source-present. | Active compatibility / contextual language, not top-level IA. | Red if treated as `Plan` tab or source-changing owner. | Leave source alone; future edits must translate top-level IA to Time and only use plan as contextual action/state. | M15/M16 plus AMB-651 classification. |
| Pulse | `Native/Ambitions/App/AppTab.swift:197`, `:218`, `:244`; `Sources/Components/*ProofPulse*`; truth/historical docs. | Legacy route compatibility maps `pulse` to Motion; `ProofPulse` is primitive naming, not current tab. | Compatibility / historical / primitive name. | Red if used as current surface or tab. | Leave compatibility mapping; classify old Pulse docs as historical; do not delete primitives without UIQL/source owner. | AMB-651, M17. |
| Habits | `Native/Ambitions/Features/Habits/*`; `Native/Ambitions/App/AppNavigation.swift:29`, `:187`; `FeatureEnginePackageBoundaryModels.swift:36`. | Source-present compatibility/support feature routed through Time as Rituals/Habits support, not top-level IA. | Active support route / compatibility root. | Yellow/Red if used as root product category or streak/shame proof. | Leave alone; future product work should translate to routines/rituals inside Time/Goal/Step flows. | AMB-651, M15/M16. |
| Insights | `Native/Ambitions/Features/Insights/*`; `Native/Ambitions/App/AppTab.swift:201`, `:224`, `:250`; `YouRouteTarget` monthly review/history. | Source-present review/history support route under You; not a top-level destination. | Active support route / compatibility root. | Yellow if treated as analytics dashboard owner. | Leave alone; future Motion/You proof surfaces must avoid analytics/dashboard framing. | AMB-651, M17/M21. |
| Profile | `Native/Ambitions/App/AppTab.swift:201`, `:222`, `:248`; `Native/Ambitions/Features/You/*profileProjection*`; truth docs. | Legacy route maps Profile to You; You uses internal profile projection names. | Compatibility/internal source naming. | Red if revived as top-level Profile tab. | Leave internal naming unless scoped UIQL/PLOS issue renames; report as compatibility. | AMB-651, M17/M22. |
| task | Broad docs/truth mentions; tests and legacy wording. | Mostly anti-commodity guardrails or generic historical/supporting text. | Guardrail/doc-only or generic local variable context. | Yellow if future PLOS copy adopts generic task framing. | Do not clean globally here; future active UI copy gates should block new generic task wording. | UIQL copy gates / M09. |
| next best move | Truth docs around banned terms and historical examples. | Active truth forbids this phrase; not current UI proof. | Guardrail/historical. | Red if used in active UI or closeout as current language. | Leave guardrails; future source copy must use `Recommended step`. | M09/UIQL. |
| Begin Focus | Truth docs and old/banned copy references. | Active truth forbids; not current active UI proof from this issue. | Guardrail/historical. | Red if used for launch/execution copy. | Leave guardrails; future source copy must use `Start now` or `Open step`. | M09/UIQL. |
| AI-branded recommendation copy | Truth docs ban external/cloud AI and AI chrome; some support docs mention OpenAI as benchmark/context. | Mostly active guardrail or historical context, not product implementation proof. | Guardrail/doc-only. | Red if used to justify cloud AI or AI-branded UI. | Leave guardrails; future runtime work must preserve local deterministic language. | M02/M03/M07/M17. |
| dashboard / KPI / score / streak / XP / productivity | Truth docs, historical policy, Habits/Insights source, accessibility/support primitives, and legacy reports. | Mostly anti-dashboard guardrails plus support routes. Habits source includes streak mechanics that are not root IA. | Mixed: guardrail/doc-only, active support route, stale risk. | Red if Motion/Goals/Time/You become dashboard/score/streak surfaces. | Leave source untouched; AMB-651 must classify production-vs-support; future UIQL/PLOS issues must block active root use. | AMB-651, M09, M17, M20/M21. |

## Preview-Only And Fixture-Only Map

| Artifact family | Representative paths | Classification | Risk | Recommendation | Owner phase |
|---|---|---|---|---|---|
| Shell preview/support | `Native/Ambitions/App/AppMeridianShell.swift`; `Sources/Previews/*Shell*`; `ShellPreviewMatrix`. | Preview/support. `AppMeridianShell.swift` defines `AppMeridianDestinationRail`, not runtime root. | Red if edited as root shell. | Leave alone; runtime root remains `AmbitionsRootView` unless live source proof changes. | AMB-646/AMB-651. |
| Preview data/container | `Native/Ambitions/PreviewSupport/*`; `Sources/Previews/*`. | Safe preview/test support. | Yellow if used as production runtime proof. | Leave alone; future source changes must verify runtime path before editing. | AMB-651. |
| Fixture packs | `GoalEngineFixtures.swift`, `SourceAtlasCoverageRuntimeFixtureModels.swift`, runtime gauntlet fixtures. | Test/support fixture. | Red if fixture coverage is treated as product Source Atlas coverage. | Leave alone; AMB-651 must mark fixture/test-only in production-vs-fixture map. | AMB-651, M04/M05/M06. |
| Demo/seed/migration support | `DemoSeedPipeline.swift`, `LegacyImportService.swift`, `StorageMigrationPlanScaffold.swift`. | Tooling/support/migration. | Yellow if demo/migration paths become launch proof. | Leave alone; M02/M24 own data lifecycle and migration proof. | M02/M24. |
| Screenshot/baseline/proof artifacts | `artifacts/ui-quality-lockdown/screenshots/*`; `docs/audits/screenshots/*`; proof reports. | Proof artifact or historical screenshot evidence. | Red if screenshot paths are treated as visual approval without inspection. | Leave alone; use only with matching current proof boundary. | UIQL/M26. |
| Deprecated language logs | `docs/audits/doc-qa/*deprecated-language.log`. | Historical/supporting audit logs. | Yellow if stale logs drive current canon. | Leave alone; historical policy controls cleanup. | Historical cleanup owner, not M01. |

## Duplicate Type And Model Map

| Group | Candidate canonical owner | Duplicate/similar families | Risk | Do-not-edit note / phase owner |
|---|---|---|---|---|
| Goal-like | `Native/Ambitions/Domain/GoalEngine/GoalEngineContracts.swift` plus `SwiftDataModels.swift` records. | `GoalsFeatureModels`, `OneStepGoalModels`, `AmbitionGraphModels`, GoalEngine teaching/energy/resource/contradiction models, local goal packs, tests. | Red if feature projection or pack model becomes canonical Goal owner. | Do not rename or collapse in AMB-650. M12/M13 own path/step graph maturation; AMB-651 classifies production/test. |
| Step-like | `Step` in GoalEngine plus `StepRecord`; `CompiledStep` and `StepCandidate` are lifecycle stages. | `ProjectStepOperationModels`, `StepCandidateFieldModels`, widget `NextStep*`, App Intents Step intents, test gauntlets. | Red if compiled/candidate/widget/test step is treated as persisted canonical Step. | Preserve lifecycle boundaries from AMB-649. M13/M14 own compiler/elasticity. |
| Path-like | `GoalCompiledPath` / path compiler models. | `PathIntelligenceModels`, `AmbitionsOSAlternatePathModels`, `PlanInsertionCandidate`, Planning/* living-plan models. | Yellow/Red if old planning domain drives new PLOS path architecture. | Leave planning models; M12 owns Multi-Path Lattice and must decide reuse/translation. |
| Receipt-like | `ActionReceipt` and `ActionReceiptHistoryRecord`. | `CompiledStepReceipt`, `SourceAtlasBridgeReceipt`, `CaptureRuntimeReceipt`, `CorrectionFoldReceipt`, `SafeAutomationReceiptRecommendation`, supply-chain receipts. | Red if receipts are merged or substituted without source/stage boundary. | M17 owns trust/receipt disclosure; M24 owns export/diagnostic receipt lifecycle. |
| Proof-like | `ProgressEvidence`, `Proof`, `ProofReference`, proof ledger models. | Accessibility proof, tail-gate proofs, vertical-slice proof, proof primitives, UIQL proof artifacts. | Red if process proof or UI proof is mistaken for product proof. | Keep proof-type stage explicit. M17/M26 own proof UI/certification gates. |
| Source-like | `SourceAtlasSourceRecord` and Source Atlas claim/requirement models. | Source truth models, import candidates, source containers, SourceAtlas query/pack/mini-pack/freshness models. | Red if imported/test source data is runtime-eligible without authority. | M04/M05/M06 own Source Atlas public pack/source authority; M18 high-risk source safety. |
| Schedule-like | `RealityModels` schedule/calendar types plus Time projections. | Planning domain, Reschedule engine, Time reflow decision models, EventKit integration, notification scheduling. | Red if schedule mutation is silent or calendar clone logic becomes source truth. | M08/M15/M16 own native context, schedule install, and reflow. |
| Store/manager-like | SwiftData repositories and local service protocols. | `SourceAtlasStore`, `SharedExternalSnapshotStore`, preview repositories, in-memory stores, import stores, migration stores. | Yellow if preview/in-memory stores are treated as production persistence. | M02/M23/M24 own local data, sync, export, and lifecycle proof. AMB-651 classifies stores by production/test/tool. |

## Superseded Linear And Docs Map

| Material | Current role | Risk | Recommendation |
|---|---|---|---|
| UIQL artifacts and AMB-956 through AMB-970 reports | Active/recent UI quality proof for UIQL scope only; not PLOS runtime proof. | Red if used to claim PLOS runtime implementation or release readiness. | Leave; cross-link only as supporting UI evidence where phase scope matches. |
| AMB-508/AMB-520/AMB-521 packet reports | Historical/supporting shell/canon/rename context. | Yellow if older Direction Atlas/User System Profile or shell conclusions override current PLOS/truth. | Leave; cite only through current truth and PLOS M01 maps. |
| AOR/AESP/AFRI docs and reports | Historical/supporting prior programs. | Red if treated as current owner approval, runtime proof, or active execution queue. | Leave; AMB-652 should cross-link and classify older Linear/docs. |
| Deprecated language audit logs | Historical audit evidence. | Yellow if stale logs drive current implementation. | Leave; cleanup requires historical-policy pass. |
| Prompts/batches and legacy runner files | Historical/supporting unless active issue explicitly requests legacy runner. | Red if used as Goal Mode authority for PLOS. | Leave; CODEX_PROCESS_TRUTH and PLOS artifacts are current authority. |

## Deletion Vs Quarantine Recommendation

| Artifact class | Recommendation | Reason |
|---|---|---|
| Active compatibility mappings (`plan`, `pulse`, `profile`, `insights`, `habits`) | Leave alone. | They preserve deep-link/route compatibility and are explicitly mapped away from current top-level IA. |
| Active support routes (`Habits`, `Insights`) | Leave alone; classify in AMB-651. | They are source-present support features, not top-level PLOS authority. |
| Preview/fixture/test harnesses | Leave alone; classify production-vs-fixture in AMB-651. | They are useful evidence and test support but not runtime proof. |
| Historical docs/reports/audit logs | Leave alone or mark stale in future historical cleanup. | HISTORICAL_POLICY forbids opportunistic deletion. |
| Source names with compatibility terms | Needs human or active-issue decision before rename. | Renaming can break routes/tests and is out of AMB-650 scope. |
| Truly dead generated artifacts | Archive/delete later only after dedicated cleanup issue. | AMB-650 has no delete authority. |

## Validation

Commands run for AMB-650:

- `git status --short --branch --ahead-behind`
- `git pull --ff-only`
- Linear issue fetch for `AMB-650`
- Linear status update for `AMB-650` to In Progress
- `rg -n "Plan|Pulse|Habits|Insights|Profile|task|next best move|Begin Focus|AI|dashboard|KPI|score|streak|XP|productivity|AppMeridianShell|preview|fixture|mock|demo|sample|legacy|deprecated|superseded|TODO|FIXME|stale" Native Sources docs tests scripts --glob "*.swift" --glob "*.md" --glob "*.json" --glob "*.yml" --glob "*.yaml" > artifacts/personal-life-os/validation/PLOS-014-required-stale-search-log.txt 2> artifacts/personal-life-os/validation/PLOS-014-required-stale-search-stderr.txt`
- `rg -n "Plan|Pulse|Habits|Insights|Profile|task|next best move|Begin Focus|AI|dashboard|KPI|score|streak|XP|productivity|AppMeridianShell|preview|fixture|mock|demo|sample|legacy|deprecated|superseded|TODO|FIXME|stale" Native Sources Native/AmbitionsTests docs scripts --glob "*.swift" --glob "*.md" --glob "*.json" --glob "*.yml" --glob "*.yaml" > artifacts/personal-life-os/validation/PLOS-014-stale-search-log.txt`
- `rg -n "struct .*Goal|struct .*Step|struct .*Receipt|struct .*Proof|struct .*Source|struct .*Path|class .*Store|class .*Manager|enum .*Tab" Native Sources tests --glob "*.swift" > artifacts/personal-life-os/validation/PLOS-014-required-duplicate-type-search-log.txt 2> artifacts/personal-life-os/validation/PLOS-014-required-duplicate-type-search-stderr.txt`
- `rg -n "struct .*Goal|struct .*Step|struct .*Receipt|struct .*Proof|struct .*Source|struct .*Path|class .*Store|class .*Manager|enum .*Tab" Native Sources Native/AmbitionsTests --glob "*.swift" > artifacts/personal-life-os/validation/PLOS-014-duplicate-type-search-log.txt`
- `find Native Sources docs scripts -type f | rg -i "preview|fixture|mock|demo|sample|legacy|deprecated|superseded|stale|screenshot|baseline|AppMeridianShell|Pulse|Habits|Insights|Profile|Plan" > artifacts/personal-life-os/validation/PLOS-014-stale-file-candidate-list.txt`
- Focused inspection over `AppTab`, `AppNavigation`, `AppExternalRouting`, `AmbitionsRootView`, `AppMeridianShell`, `FeatureEnginePackageBoundaryModels`, Habits, Insights, preview support, duplicate type families, truth files, historical policy, and prior UIQL/AOR/AESP/AFRI artifacts.

Closeout validation run before commit:

- `git diff --check`
- `python3 -m json.tool artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.json`
- `scripts/codex/program-preflight.sh plos`
- `scripts/codex/program-phase-gate.sh plos M01`
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-014-stale-artifact-duplicate-map.md`
- `bash scripts/codex/program-proof-index.sh plos`

Validation still to run after staging:

- `git diff --cached --check`

Not run:

- Build/test/screenshot/accessibility/performance validation was not run because AMB-650 is a read-only classification/proof artifact child and no app source, project, UI, runtime, or test source files were changed. No runtime behavior, UI quality, release, accessibility, privacy/legal, or performance claim is made.

## Verdict

Green for AMB-650 scope: stale IA/copy terms, preview/fixture/test support, duplicate model families, superseded docs/Linear materials, and deletion/quarantine recommendations are mapped from live source and raw validation logs without destructive cleanup.

Yellow limits remain: raw search volume is broad and future cleanup decisions are not made here; literal required commands record the absent top-level `tests` path; AMB-651 still owns production-vs-fixture/test/script classification; UIQL/historical cleanup/source rename work remains out of scope.

Red blockers: none.
