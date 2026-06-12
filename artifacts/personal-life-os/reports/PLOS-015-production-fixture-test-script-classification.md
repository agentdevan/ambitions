# PLOS-015 Production Fixture Test Script Classification

Status: Green for AMB-651 classification scope; Yellow for bounded raw-log replacement and future build/project introspection
Linear issue: AMB-651
Parent issue: AMB-609
Program phase: PLOS-M01 live runtime truth map
Updated: 2026-06-12
Branch: main

## Closeout Header

- PLOS child closeout: yes
- Linear issue: AMB-651
- Parent issue: AMB-609
- Green/Yellow/Red status: Green for classification bucket definitions, Source Atlas fixture/test separation, script/tooling classification, and generated-artifact source-truth boundaries; Yellow for raw search volume, top-level `tests` absence in the literal required search, and future build/project introspection.
- Pushed to main: pending at report creation
- Push hash: pending at report creation
- App source changed: no
- Runtime features implemented: no
- PLOS-M00 executed: no
- Linear identifiers used: AMB issue identifiers only
- Validation run: see Validation
- Red blockers: none
- Yellow limits: the literal `find .` and `rg ... artifacts ...` commands produced unsafe multi-gigabyte generated outputs because prior artifacts and `.xcresult` bundles are part of the workspace; bounded manifests and raw byte counts are committed instead of gigabyte logs.
- Owner approval claimed: no
- Release/TestFlight/App Store readiness claimed: no
- Next recommended action: after AMB-651 commit, push, and Linear closeout, continue AMB-652 only.

## Existing-First Evidence

Artifacts created for AMB-651:

- `artifacts/personal-life-os/validation/PLOS-015-all-files.txt`
- `artifacts/personal-life-os/validation/PLOS-015-relevant-files.txt`
- `artifacts/personal-life-os/validation/PLOS-015-classification-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-015-classification-search-exit-code.txt`
- `artifacts/personal-life-os/validation/PLOS-015-classification-search-stderr.txt`
- `artifacts/personal-life-os/validation/PLOS-015-required-classification-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-015-required-classification-search-exit-code.txt`
- `artifacts/personal-life-os/validation/PLOS-015-required-classification-search-stderr.txt`
- `artifacts/personal-life-os/validation/PLOS-015-large-output-metadata.tsv`
- `artifacts/personal-life-os/validation/PLOS-015-bucket-summary.tsv`
- `artifacts/personal-life-os/validation/PLOS-015-term-counts.tsv`

The literal required `rg` over `Native Sources tests scripts tools docs artifacts prompts .github` exited `2` because the repo has `Native/AmbitionsTests` instead of a top-level `tests` directory. The adapted search over `Native/AmbitionsTests` exited `0`.

The raw output sizes are preserved in `PLOS-015-large-output-metadata.tsv`:

| Raw output | Bytes |
|---|---:|
| Literal `find .` all-files output | 189,732,277 |
| Relevant file inventory | 7,628,322 |
| Literal required search log | 1,337,854,387 |
| Adapted classification search log | 2,972,512,996 |

The multi-gigabyte logs were bounded before commit. This is a Yellow evidence-handling limit, not a production classification failure.

## Classification Buckets

| Bucket | Path pattern | Examples | Runtime risk | Can Codex edit? | Owner / validation phase |
|---|---|---|---|---|---|
| Production Swift source | `Native/Ambitions/**`, `Sources/**`, `AppUI/Sources/**` excluding tests and preview-only folders. | `Native/Ambitions/App/AmbitionsApp.swift`, `Native/Ambitions/App/AmbitionsRootView.swift`, `Native/Ambitions/App/AppTab.swift`, `Native/Ambitions/Domain/GoalEngine/*`, `Native/Ambitions/Services/*`, `Sources/Components/*`. | Red if source is edited during read-only M01 or if preview/test code is mistaken for live runtime. | No for AMB-651. Future edits only under active source-changing AMB issue after runtime owner proof. | M02-M24 depending area; M10 for golden slice; AMB-646/648/649 maps govern ownership. |
| Production resources/assets | `Native/Ambitions/Resources/**`, `Native/Ambitions/Support/**`, extension resources. | app icon assets, `Native/Ambitions/Support/Info.plist`, `Native/Ambitions/Support/Ambitions.entitlements`, widget/share extension plist and entitlements. | Red if changed without release/privacy/signing scope; Yellow if used as runtime behavior proof. | No for AMB-651. | M23-M26 and release/privacy owners. |
| Production app config/targets | `project.yml`, `Package.swift`, generated Xcode target definitions. | `Ambitions`, `AmbitionsWidgetExtension`, `AmbitionsShareExtension`, `AmbitionsTests`, `AmbitionsUITests`, local packages. | Red if project config changes are smuggled into mapping work; Yellow if target membership is inferred without XcodeGen/build proof. | No for AMB-651. | M01 can classify; source-changing target edits require explicit issue and build validation. |
| Unit test source | `Native/AmbitionsTests/**`. | GoalEngine tests, Source Atlas tests, runtime tail-gate tests, accessibility/design system tests, service tests. | Red if tests/fixtures are treated as shipped runtime; Yellow if tests are ignored as owner evidence. | No for AMB-651 except future test-only issues. | M01 classification; relevant future phase owns focused test proof. |
| UI/screenshot tests | `Native/AmbitionsUITests/**`, UIQL proof test paths. | `Native/AmbitionsUITests/AmbitionsUITests.swift`. | Red if screenshot paths are treated as visual approval; Yellow if UI proof is stale. | No for AMB-651. | UIQL/M26 visual/accessibility certification owners. |
| Fixture/generated/sample support | files containing fixture/demo/sample/generated/preview naming under `Native/Ambitions`, `Native/AmbitionsTests`, `Sources/Previews`, and artifacts. | `SourceAtlasCoverageRuntimeFixtureModels.swift`, `GoalEngineFixtures.swift`, `Native/Ambitions/PreviewSupport/*`, `Sources/Previews/*`, generated screenshot/proof outputs. | Red if fixture coverage, demo packs, generated screenshots, or preview shells become production truth. | No for AMB-651; classify only. | M04-M06 for Source Atlas fixtures, M10/M26 for proof screenshots, M01 for map updates. |
| Scripts/tooling | `scripts/**`, `tools/**`, `.github/**`. | `scripts/codex/program-preflight.sh`, `scripts/codex/linear-closeout-validate.py`, `tools/source-atlas/coverage-*.py`, MCP tools, visual QA scripts, governance workflow. | Red if tooling output is mistaken for runtime implementation or if tools gain unsafe write/network/secrets scope without approval. | Yes only when active issue is scripts/tooling-scoped; not app source. | M00/M01 for PLOS validators; M04-M06 for Source Atlas tooling; M26 for certification tooling. |
| Docs/authority | `docs/truth/**`, `AGENTS.md`, `docs/codex/**`, `docs/codex-os/**`, `.agents/skills/**`, `prompts/**`. | truth files, PLOS laws, Goal Mode standards, skill instructions, legacy prompts. | Red if historical prompts override truth/PLOS; Yellow if supporting docs are treated as source proof. | Yes only under docs/governance issues; truth-file edits require explicit authority. | M00 for governance laws; M01/M02+ consume them as authority. |
| PLOS/proof artifacts | `artifacts/plos-runtime/**`, `artifacts/personal-life-os/**`, `artifacts/proof-ledger/**`. | PLOS run-state, execution queue, reports, validation logs, proof ledger/index. | Red if artifacts are treated as runtime implementation; Yellow if generated logs recurse into later searches. | Yes for active PLOS control-plane child only. | PLOS phase owner and proof-ledger owner. |
| UIQL/reconstruction artifacts | `artifacts/ui-quality-lockdown/**`, `artifacts/ambitions-ui-reconstruction/**`. | screenshot boards, `.xcresult` bundles, UIQL reports, reconstruction proof. | Red if UIQL artifacts are used as PLOS runtime proof or release readiness. | No in AMB-651 except classification references. | UIQL/M26 owners. |
| Source Atlas artifacts/tools | `artifacts/source-atlas-factory/**`, `tools/source-atlas/**`, Source Atlas domain/test paths. | SAF goal/hardening plan, coverage tools, pack crypto/diff/validate, Source Atlas tests. | Red if coverage tooling/fixtures are treated as shipped Source Atlas Factory. | No production work in AMB-651; future tooling edits require M04-M06 issue. | M04/M05/M06; AMB-647 map remains source. |

## Source Atlas Fixture And Runtime Separation

| Artifact family | Classification | Do not confuse with | Owner phase |
|---|---|---|---|
| `Native/Ambitions/Domain/SourceAtlas*Models.swift` | Production/model-source candidates where target membership and AMB-647 classify as source/runtime-shaped domain models. | Complete Source Atlas Factory implementation. | M04/M05/M06. |
| `SourceAtlasCoverageRuntimeFixtureModels.swift` and matching tests | Fixture/test support. | Product coverage or source-pack eligibility. | M04-M06 plus M01 classification. |
| `tools/source-atlas/coverage-*.py` | Tooling. | Runtime app source or shipped pack store. | M04/M05/M06 tooling validation. |
| `artifacts/source-atlas-factory/**` | Governance/proof artifacts. | Source Atlas runtime behavior or R2 distribution. | SAF/PLOS control-plane owners. |

## Required Do-Not-Confuse List

| Looks important | Actual classification | Boundary |
|---|---|---|
| Fixtures that simulate full coverage | Fixture/test support | Cannot prove product Source Atlas coverage, pack availability, or runtime eligibility. |
| Preview-only shells | Preview/support | Cannot prove launch path or active shell root; use AMB-646 source path proof. |
| Generated reports | Proof artifacts | Cannot be edited as source truth; use them only with freshness and scope boundaries. |
| Stale screenshots | Historical/visual proof artifacts | Screenshot paths are not visual approval without current inspection. |
| Test-only packs | Test/fixture | Not shipped source packs and not user-visible source authority. |
| Old prompt packets | Historical/supporting docs | Do not override truth files, PLOS GOAL, run-state, or active AMB issue. |
| Archived project docs | Historical/supporting docs | Use only when current truth/PLOS maps cite them as evidence. |
| `.xcresult` bundles under artifacts | Generated validation output | Not source; not release proof; do not re-search as product text without bounding. |

## Unknowns And Yellow Owners

| Unknown / Yellow item | Why Yellow | Owner |
|---|---|---|
| Full target membership without current XcodeGen/build introspection | AMB-651 read source/project files and `project.yml`, but did not regenerate/build. | Future source-changing phase or M26 certification. |
| Multi-gigabyte raw logs | Required broad searches recurse into prior artifacts; bounded manifests are committed instead. | M01 mapping; future validators should exclude generated artifacts or cap output. |
| Ambiguous fixture status in feature support routes | Some support routes are source-present but not root product proof. | AMB-648/650 maps plus future scoped UI/runtime issue. |
| Generated artifact provenance | Some historical proof artifacts have old generation paths. | AMB-652 cross-link/docs control-plane map and future historical cleanup owner. |

## Validation

Commands run for AMB-651:

- `git status --short --branch --ahead-behind`
- `git pull --ff-only`
- Linear issue fetch for `AMB-651`
- Linear status update for `AMB-651` to In Progress
- `find . -type f | sort > artifacts/personal-life-os/validation/PLOS-015-all-files.txt`
- `find Native Sources tests scripts tools docs artifacts prompts .github -type f 2>/dev/null | sort > artifacts/personal-life-os/validation/PLOS-015-relevant-files.txt`
- literal required `rg -n "fixture|mock|demo|sample|test|coverage|generated|artifact|script|tool|preview|production|runtime|staging|release" Native Sources tests scripts tools docs artifacts prompts .github --glob "*.*"`
- adapted `rg` with `Native/AmbitionsTests`
- tracked-file bucket summary over `git ls-files`
- term-count summary over adapted roots

Closeout validation run before commit:

- `git diff --check`
- `python3 -m json.tool artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.json`
- `scripts/codex/program-preflight.sh plos`
- `scripts/codex/program-phase-gate.sh plos M01`
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-015-production-fixture-test-script-classification.md`
- `bash scripts/codex/program-proof-index.sh plos`

Validation still to run after staging:

- `git diff --cached --check`

Not run:

- Build/test/screenshot/accessibility/performance validation was not run because AMB-651 is a read-only classification/proof artifact child and no app source, project, UI, runtime, or test source files were changed. No runtime behavior, UI quality, release, accessibility, privacy/legal, or performance claim is made.

## Verdict

Green for AMB-651 scope: relevant file categories are defined, Source Atlas fixtures/tests are separated from product runtime, scripts/tooling are classified, generated artifacts are not treated as source truth, and unknowns have owner phases.

Yellow limits remain: literal required search records absent top-level `tests`; raw generated outputs were too large to commit safely and were replaced with bounded manifests plus metadata; target membership/build provenance is not claimed; AMB-652 still owns Linear/docs cross-links.

Red blockers: none.
