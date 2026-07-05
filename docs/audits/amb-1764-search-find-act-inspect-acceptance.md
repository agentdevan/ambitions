# AMB-1764 Search / Find / Act / Inspect Acceptance

Status: Implemented Yellow / completion authorized without runtime testing
Date: 2026-07-05
Scope: AMB-1764, Search as local-only Find / Act / Inspect
Baseline SHA: `486ee75b2bfabfd26c137c132b9dc8bc767d18fe`
Linear status before closeout: `In Progress`

## Purpose

AMB-1764 accepts the current Search implementation as a local-only Find / Act /
Inspect source contract. Search remains a cross-surface recall and action layer,
not a persistent root surface, chatbot, cloud search surface, activity feed, or
generic text-search panel.

The current user instruction authorizes issue completion without running tests.
This packet therefore completes AMB-1764 as Implemented Yellow from source,
static contract, and retained test-symbol evidence only. It does not provide
current screenshot proof, manual accessibility proof, simulator/device proof,
offline/no-account runtime proof, or rendered mutation proof.

## Product Law Inputs

- `docs/truth/2026-06-22-runtime-remediation-decision-register.md` defines
  Search as unified Find / Act / Inspect, not chatbot, shallow sheet, or generic
  text search.
- `docs/audits/frontend-product-law-drift-scan.md` records that AMB-1768 clears
  Search product-law routing for AMB-1764 while leaving screenshot,
  accessibility, offline, no-account, device, and runtime UI proof as Green
  blockers.
- `docs/linear/reconciliation/2026-07-01-phase-3-hierarchy-repair-packet.md`
  is treated as historical input only where it references `SearchRecall`; live
  source ownership has moved to `Native/Ambitions/Core/LocalRuntimeOS/Search/`.

## Current Source Evidence

| Acceptance area | Current evidence | Current result |
| --- | --- | --- |
| Local-only query boundary | `SearchQuery.requiresLocalOnly` defaults to `true`; `FTSIndex.search` and `SemanticLocalIndex.search` filter non-local results when local-only is required. | Source contract present. |
| Find | `DefaultMemoryLensService.search` builds local results from repositories, ranks through `LocalSearchIndex`, and returns `MemoryLensResult` rows. `RepositoryBackedYouService.makeEverythingSearchState` presents "Find anything local" and local candidate budgets. | Source contract present. |
| Act | `FindActInspectResult.primaryAction` creates local `SearchAction` values; `SearchActionValidator` denies private, wrong-family, non-local, invalid-command, and missing-target actions. `DefaultShellCommandRouter.route(searchResult:)` routes only trusted Search handoffs. | Source contract present. |
| Inspect | `FindActInspectResult.inspectAction`, `SearchProvenance`, `SearchExplanation`, `SearchLens.trustBoundary`, and Memory Lens inspect glyph/action titles preserve source-tied inspection. | Source contract present. |
| No chatbot or cloud framing | Targeted source scan of Search, Memory Lens overlay, and You Search projection found no `chatbot`, `cloud search`, hosted model, network, or URLSession path. You Search footer says no external service is used. | Source copy and boundary present. |
| Safe fallback | Empty Memory Lens results show "No local match." and offer "Capture this". Missing goal targets fall back to the Memory Lens overlay instead of pretending to mutate runtime. Stale IA destination blockers hold non-canonical handoffs. | Source fallback present. |
| Visible mutation when action is supported | `DefaultShellCommandRouter.route(searchResult:)` routes to the destination, records route history, and sets a visible `Search opened` continuity receipt; `AmbitionsStage.shellContinuityReceipt` renders that receipt. | Source-supported; not rendered at runtime in this packet. |
| Accessibility surface | Memory Lens search field, result rows, close control, loading/status, empty state, and receipt have accessibility labels/identifiers/hints. | Source contract present; no manual/runtime proof. |
| Offline and no-account posture | Search sources are local repositories, local runtime Search projection, FTS store, and local semantic overlap. No account or network owner is introduced by this packet. | Source contract present; no offline/no-account runtime proof. |

## Search Path Map

| Layer | Owner | Evidence |
| --- | --- | --- |
| Runtime contract | `Core/LocalRuntimeOS/Search/FindActInspectContract.swift` | Query, provenance, explanation, actions, result schema. |
| Validation | `Core/LocalRuntimeOS/Search/SearchActionValidator.swift` | Blocks privacy, family, non-local, invalid command, and missing target. |
| Indexing | `Core/LocalRuntimeOS/Search/FTSIndex.swift` and `SearchRebuildPipeline.swift` | Builds from Search projection, validates actions, records local rebuild receipt. |
| Semantic matching | `Core/LocalRuntimeOS/Search/SemanticLocalIndex.swift` | Deterministic local overlap; `externalModelUsed` defaults false. |
| Cross-surface recall | `Core/LocalRuntimeOS/Search/MemoryLensService.swift` | Repository-backed local results with trusted handoff owner mapping. |
| UI overlay | `Stage/Overlays/QuietCommandMemoryLensOverlay.swift` | Local search copy, result rows, empty fallback, Capture fallback, trusted result filtering. |
| Routing | `App/ShellCommandRouter.swift` and `App/ShellCommandDestination.swift` | Trusted handoffs, stale destination blockers, canonical owner routing, continuity receipt. |
| You projection | `Surfaces/You/Projection/SearchLens.swift` and `YouFeatureServiceEverythingSearchProjection.swift` | Local Search results lens, local candidate budgets, no external service footer. |

## Retained Test Symbols

These are retained source evidence only. They were not executed for this packet.

- `SearchTests.testFTSIndexReturnsFindActInspectResultsWithPrivacyProvenanceAndValidatedActions`
- `SearchTests.testSearchActionValidatorDeniesPrivateFamilyAndMissingTargetResults`
- `SearchTests.testSemanticLocalIndexIsDeterministicLocalOnlyAndUsesNoExternalModel`
- `SearchTests.testSearchRebuildPipelineMaterializesSearchProjectionStoresCursorAndIndexesEvents`
- `MemoryLensServiceTests.testAMB1196SearchResultsExposeValidDestinationsWithoutInternalLabels`
- `ShellCommandRouterTests.testAMB1059RoutesMemoryLensGoalResultWithTrustedHandoffContext`
- `ShellCommandRouterTests.testAMB1196RoutesSearchCaptureResultToCaptureOverlayNotCaptureTab`
- `YouFeatureServiceTests.testEverythingSearchBuildsLocalFindActInspectStateFromRepositories`

## Acceptance Mapping

| AMB-1764 criterion | Current result |
| --- | --- |
| Local-only find, act, and inspect behavior. | Implemented Yellow from source contract: query boundary, local indexes, action validation, provenance, explanation, and inspect action are present. |
| No chatbot framing. | Source copy and targeted scan show no chatbot/cloud-search framing in active Search owners. |
| Safe fallback and visible mutation when action is supported. | Source fallback and route/receipt mutation paths are present. Runtime/rendered proof was not run. |
| Screenshot proof and accessibility proof where UI changes. | Not produced under current no-testing instruction. Source accessibility labels and identifiers are present but not runtime proof. |
| Offline and no-account behavior proven where applicable. | Not runtime-proven. Source boundary stays local and accountless, but offline/no-account proof remains required before Green claims. |
| Rollback plan required. | Present below. |

## Rollback Plan

- Revert this AMB-1764 audit packet commit if the acceptance mapping is later
  found stale or too broad.
- If a Search route leaks to a non-canonical owner, block the route with
  `staleIADestinationBlockers` before adding new UI.
- If a Search action lacks privacy, family, local-only, command-validation, or
  target proof, deny it through `SearchActionValidator` and keep the result
  visible only as a blocked/inspectable item.
- If rendered proof later contradicts the source contract, move AMB-1764 or the
  affected follow-up to Needs Repair and retain artifacts.

## Proof Ceiling

Allowed claim:

- Current `main` contains a local-only Search Find / Act / Inspect source
  contract with local indexes, source-tied actions, action validation, trusted
  canonical handoffs, fallback Capture path, and inspectable source/provenance
  metadata.

Forbidden claims from this packet:

- current screenshot proof
- rendered Search behavior
- manual accessibility conformance
- simulator or device behavior
- offline/no-account runtime behavior
- runtime UI mutation proof
- final visual approval
- TestFlight readiness
- App Store readiness
- frontend Visual Green
- Release Green

## Validation

Commands run from `/Users/devan/Documents/GitHub/ambitions`:

- `git diff --check` - passed.
- `jq . docs/audits/amb-1764-search-find-act-inspect-acceptance.json` - passed.
- `npx markdownlint-cli2 --no-globs docs/audits/amb-1764-search-find-act-inspect-acceptance.md`
  - passed, `Summary: 0 error(s)`.
- `python3 scripts/ambitions-unsupported-claim-scan.py docs/audits/amb-1764-search-find-act-inspect-acceptance.md docs/audits/amb-1764-search-find-act-inspect-acceptance.json`
  - passed, `GREEN: unsupported completion/readiness claim scan passed`.
- `scripts/release-claim-safety-scan.sh docs/audits/amb-1764-search-find-act-inspect-acceptance.md docs/audits/amb-1764-search-find-act-inspect-acceptance.json`
  - passed, `GREEN proof-sensitive release terms are framed as non-claims,
  boundaries, or future proof`.
- `python3 scripts/ambitions-remediation-governance-check.py` - passed,
  `GREEN remediation governance guard passed`.
- `python3 scripts/ambitions-architecture-inventory.py` - passed,
  `GREEN final-tree parity achieved`.
- `python3 scripts/ambitions-vocabulary-drift-scan.py` - passed,
  `GREEN: canonical and active vocabulary terms are present and explicit ban
  terms are absent`.
- `python3 scripts/ambitions-truth-path-vocabulary-audit.py` - passed,
  `GREEN: truth paths resolve or are explicitly planned/internal, and active
  stale terms are quarantined`.
- `python3 scripts/ambitions-green-standard-audit.py` - passed,
  `GREEN: no disallowed architecture-as-UI strings found in active primary UI
  source`.
- `python3 scripts/ambitions-local-first-boundary-scan.py` - passed,
  `GREEN: local-first/account/R2/hosted-AI boundary checks passed in active
  authority files`.
- `python3 scripts/ambitions-accepted-yellow-misuse-audit.py` - passed,
  `valid=true`, `invalidAcceptedYellowIssues=0`.
- `scripts/no-unsupported-ai-claim-scan.sh docs/audits/amb-1764-search-find-act-inspect-acceptance.md docs/audits/amb-1764-search-find-act-inspect-acceptance.json`
  - advisory Yellow; review showed truth-file context and explicit non-claims.
- `scripts/privacy-boundary-scan.sh docs/audits/amb-1764-search-find-act-inspect-acceptance.md docs/audits/amb-1764-search-find-act-inspect-acceptance.json`
  - advisory Yellow; review showed broad truth-file privacy/local-first context
  and explicit AMB-1764 non-claims.
- `xcodegen generate --spec project.yml` - passed.
- `scripts/ambitions-xcodegen-needed.sh` - passed, `XCODEGEN_NEEDED=0`.

Commands not run:

- XCTest, UI test, simulator, screenshot, manual accessibility, performance
  walkthrough, physical-device, signed archive, and App Store Connect validation
  lanes - skipped under the current no-testing instruction.

## Closeout Notes

- Private Life Orchestration relationship: preserved. Search remains local,
  inspectable, object-led, source-tied, and action-bounded.
- Final Architecture Tree inspected: yes.
- Canonical owners inspected: `Core/LocalRuntimeOS/Search`, `Stage/Overlays`,
  `App`, `Surfaces/You/Projection`, retained test source, truth, and audit docs.
- Canonical owners touched: none in production source.
- Files created: `docs/audits/amb-1764-search-find-act-inspect-acceptance.md`
  and `docs/audits/amb-1764-search-find-act-inspect-acceptance.json`.
- Files moved: none.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Architecture debt: no production path change was made; live source ownership
  is already under `Core/LocalRuntimeOS/Search`. Screenshot, accessibility,
  simulator/device, offline/no-account runtime, rendered receipt, and
  performance proof remain absent.
- Next proof train: AMB-1765, AMB-1766, AMB-1767, AMB-1770, AMB-1774, and
  AMB-1775 when testing/device proof is re-enabled.
- No equivalent folder/path interpretation was used.
