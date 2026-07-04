# AMB-1747 Stage / Shell Frontend Reality Audit

Status: Ready for review
Date: 2026-07-04
Scope: AMB-1747, Architecture Simplification + Flagship Readiness Remediation
Baseline SHA: `c1bb9823a2731141371f082e5c0d77cc9bda5227`
Linear status before audit: `Spec Ready`

## Purpose

AMB-1747 audits Stage, shell, routing, and overlays against the current source
and route-test graph before Stage is treated as aligned.

This packet is a control-plane and source-route audit only. It does not
implement UI, produce screenshots, prove visual quality, prove accessibility
conformance, prove device behavior, or prove release readiness.

## Linear Scope

AMB-1747 acceptance requires:

- root shell ownership evidence
- route reachability evidence for Today, Goals, Time, You, Capture, search, and
  inspection details
- dead or unclear route classification
- proof that Capture is global and Motion is not a persistent destination
- linked frontend repair or deletion work where route evidence is incomplete
- screenshot evidence, or explicit linkage to frontend work that must produce it

## Truth And Skill Inputs

Inspected inputs:

- `AGENTS.md`
- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md`
- `.agents/skills/ambitions-source-truth-authority/SKILL.md`
- `.agents/skills/ambitions-architecture-tree-enforcement/SKILL.md`
- `.agents/skills/ambitions-ios-quality-gate/SKILL.md`
- `.agents/skills/ambitions-release-proof-honesty/SKILL.md`
- `docs/audits/amb-1746-frontend-research-extension-gate.md`
- Linear issue `AMB-1747`

Controlling truth:

- Persistent surfaces are exactly Today, Goals, Time, You.
- Capture is the global composer/action layer, not a root tab.
- Motion is Stage/Motion behavior, not a root destination.
- Source and unit route evidence can support source-route readiness, but
  rendered frontend, visual, accessibility, device, TestFlight, App Store, and
  release claims require current proof artifacts outside this packet.

## Route Evidence Matrix

| Route / surface | Current source evidence | Current test evidence | AMB-1747 classification | Follow-up / proof ceiling |
| --- | --- | --- | --- | --- |
| Stage/root shell owner | `AmbitionsSurface` exposes only `.today`, `.goals`, `.time`, `.you` and rejects other raw values (`Native/Ambitions/Stage/AmbitionsSurface.swift:3`). `AmbitionsRootStageSurfaceHost` switches only those four roots (`Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift:11`). `StageDockDestination.all` derives dock entries from `AmbitionsSurface.allCases` (`Native/Ambitions/Stage/StageChrome.swift:23`). `StageDockRail` renders those destinations (`Native/Ambitions/Stage/Chrome/StageDockRail.swift:27`). | `AppShellNavigationTests` verifies canonical top-level tabs, raw-value rejection, root ownership, dock destinations, root dock policy, reselection, drilldown, and debug-launch rejection of legacy/Capture-like surfaces (`Native/AmbitionsTests/App/AppShellNavigationTests.swift:6`, `:18`, `:130`, `:190`, `:228`, `:510`). | Source-route evidence present for four-root shell ownership. | Rendered shell proof remains Yellow until AMB-1749 and AMB-1750 have current screenshots/journey artifacts. |
| Today root | `AmbitionsRootStageSurfaceHost.todayNavigation` presents `TodaySurface` inside the Stage shell (`Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift:27`). `StageReducer.selectToday` dismisses overlay and selects `.today` (`Native/Ambitions/Stage/StageReducer.swift:29`). | `AppShellNavigationTests` verifies Today is a canonical tab and Today re-entry context is consumed through the shell (`Native/AmbitionsTests/App/AppShellNavigationTests.swift:6`, `:596`). | Reachable source route. | Flagship rendered Today proof belongs to AMB-1737 and AMB-1749. |
| Goals root and Goal detail | `AmbitionsRootStageSurfaceHost.goalsNavigation` owns Goals root and `GoalRouteTarget` detail routing (`Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift:41`). `StageReducer.openGoalDetail` selects `.goals` and sets `goalsPath` (`Native/Ambitions/Stage/StageReducer.swift:38`). `ShellCommandRouter.route` and `execute(.openGoal)` route canonical goal targets to Goals (`Native/Ambitions/App/ShellCommandRouter.swift:111`, `:277`). | `AppShellNavigationTests` verifies goal-detail drilldown under Goals and demo Today/Goals routes opening in the Goals shell (`Native/AmbitionsTests/App/AppShellNavigationTests.swift:279`, `:607`, `:623`). `ShellCommandRouterTests` verifies canonical goal routing and trusted search handoff to Goals (`Native/AmbitionsTests/App/ShellCommandRouterTests.swift:165`, `:257`). | Reachable source route. | Root IA / app-spine runtime proof belongs to AMB-1735 and AMB-1749. |
| Time root, rituals, and weekly review | `AmbitionsRootStageSurfaceHost.timeNavigation` owns Time root plus `TimeRouteTarget.rituals` and `.weeklyReview` destinations (`Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift:74`). `StageReducer.openTimeRoute` selects `.time` and sets `timePath` (`Native/Ambitions/Stage/StageReducer.swift:53`). | `AppShellNavigationTests` verifies rituals stay under Time without a duplicate destination (`Native/AmbitionsTests/App/AppShellNavigationTests.swift:367`). `ShellCommandRouterTests` verifies time commands route to `.time` (`Native/AmbitionsTests/App/ShellCommandRouterTests.swift:247`). | Reachable source route. | Flagship rendered Time proof belongs to AMB-1739 and AMB-1749. |
| You root and inspection details | `AmbitionsRootStageSurfaceHost.youNavigation` owns You root and all `YouRouteTarget` detail destinations, including History and trust-related detail routes (`Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift:116`). `StageReducer.openYouRoute` selects `.you` and sets `youPath` (`Native/Ambitions/Stage/StageReducer.swift:67`). | `AppShellNavigationTests` verifies History stays under You (`Native/AmbitionsTests/App/AppShellNavigationTests.swift:382`). `TrustCanonicalOwnershipTests` verifies inspection states are owned by You and trust routes stay contextual (`Native/AmbitionsTests/TrustCanonicalOwnershipTests.swift:38`, `:90`, `:115`). | Reachable contextual detail route, not top-level. | You / Trust / Privacy rendered proof belongs to AMB-1740 and AMB-1749. |
| Capture | `SurfaceOwnershipRegistry.globalComposer` marks Capture as `globalComposer` with no canonical tab (`Native/Ambitions/Stage/SurfaceOwnershipRegistry.swift:33`). `ShellOverlayState` models command-sheet/typed Capture overlay state (`Native/Ambitions/Stage/Overlays/ShellOverlayState.swift:13`). `StageStore.openCaptureComposer`, `presentSurfaceCapture`, and `presentGlobalCaptureComposer` present command-sheet quick-capture overlays without selecting Capture (`Native/Ambitions/Stage/StageStore.swift:208`, `:245`, `:253`). `AmbitionsStage` renders activated Capture through the shell seam (`Native/Ambitions/Stage/AmbitionsStage.swift:161`). `ShellCommandRouter.execute(.quickCapture/.openCapture)` routes Capture through overlays (`Native/Ambitions/App/ShellCommandRouter.swift:176`, `:301`). | `AppShellNavigationTests` verifies Capture is not a raw top-level surface, Capture/Motion stay out of root chrome, global Capture overlay does not select Capture, contextual Capture entry sources exist for each canonical surface, and the activated Capture seam only appears after activation (`Native/AmbitionsTests/App/AppShellNavigationTests.swift:18`, `:139`, `:340`, `:425`, `:466`). `ShellCommandRouterTests` verifies quick capture and open Capture use the global overlay and keep the selected root in place (`Native/AmbitionsTests/App/ShellCommandRouterTests.swift:6`, `:82`, `:98`, `:114`, `:285`). | Global overlay/composer evidence present; no Capture root route found in the inspected source/test graph. | Capture-to-Today visible flow and rendered composer proof belong to AMB-1736, AMB-1743, and AMB-1749. |
| Search / Memory Lens | `ShellOverlayState.memoryLens` models search overlay state (`Native/Ambitions/Stage/Overlays/ShellOverlayState.swift:75`). `StageStore.presentMemoryLens` routes search as overlay (`Native/Ambitions/Stage/StageStore.swift:291`). `AmbitionsStage.shellSearchSeam` renders Memory Lens when active (`Native/Ambitions/Stage/AmbitionsStage.swift:125`). `ShellCommandRouter.route(searchResult:)` routes trusted handoffs or keeps untrusted results inside overlay state (`Native/Ambitions/App/ShellCommandRouter.swift:143`). | `AppShellNavigationTests` verifies shell overlay routes remain shell-owned (`Native/AmbitionsTests/App/AppShellNavigationTests.swift:396`). `ShellCommandRouterTests` verifies missing open-goal targets fall back to Memory Lens and trusted results route through canonical owners (`Native/AmbitionsTests/App/ShellCommandRouterTests.swift:147`, `:257`, `:285`). | Search is an overlay/inspection handoff, not a top-level root. | Screen and journey registry proof belongs to AMB-1734, AMB-1735, AMB-1751, and AMB-1749. |
| Motion | `SurfaceOwnershipRegistry.motionBehavior` marks Motion as behavior with no canonical tab (`Native/Ambitions/Stage/SurfaceOwnershipRegistry.swift:42`). `AmbitionsStage.routeStageMotionAction` routes Motion actions to Today, Goals, Time, You/History, or Memory Lens overlays (`Native/Ambitions/Stage/AmbitionsStage.swift:357`). | `StageMotionRoutingTests` verifies Stage Motion routes to canonical surfaces and Memory Lens overlays, with reduce-motion state recorded (`Native/AmbitionsTests/App/StageMotionRoutingTests.swift:27`, `:52`, `:69`, `:82`). `AppShellNavigationTests` verifies Motion is not a root raw value (`Native/AmbitionsTests/App/AppShellNavigationTests.swift:18`, `:130`, `:139`). | Behavior-layer evidence present; no Motion root route found in the inspected source/test graph. | Rendered motion behavior proof remains AMB-1750 scoped; no visual or accessibility claim here. |
| External surfaces and route markers | `AmbitionsStage.validateExternalNavigationGraph` asserts the external navigation graph contains no dead-end external route at runtime assertion level (`Native/Ambitions/Stage/AmbitionsStage.swift:327`). | `ScreenContractRegistryTests` keeps external surfaces `contractOnly` until D22 (`Native/AmbitionsTests/App/ScreenContractRegistryTests.swift:234`). `AppShellRouteMarkerTests` is retained as temporary route-marker evidence, not finished surface proof. | Evidence-limited / contract-only. Not eligible for broad frontend Green. | Link to AMB-1742 for deletion/quarantine, AMB-1744 for device proof, AMB-1749 for evidence harness, and D22/front-end owner work for external surfaces. |

## Dead And Unclear Route Classification

No dead canonical root route was found in the inspected source/test graph for
Today, Goals, Time, You, Capture overlay, Search/Memory Lens overlay, inspection
details under You, or Stage/Motion behavior routing.

Evidence-limited items:

- External surfaces are contract-only until D22 and are not finished runtime UI
  proof.
- Temporary route-marker tests are not finished surface proof.
- Current rendered journey proof is incomplete in this packet and remains owned
  by AMB-1734, AMB-1735, AMB-1751, AMB-1742, AMB-1749, and AMB-1750.
- Capture-to-Today visible flow proof remains owned by AMB-1736 and AMB-1749.
- Release-grade frontend QA and device/App Store proof remain owned by AMB-1743
  and AMB-1744, with architecture release gate coverage in AMB-1750.

## Acceptance Mapping

| AMB-1747 acceptance criterion | Current result |
| --- | --- |
| Stage/shell claims are backed by runtime route evidence. | Source-route and unit route-test evidence are present for shell ownership, canonical roots, overlays, and Motion behavior routing. Rendered route evidence is not produced here. |
| No inspection detail is promoted to top-level surface. | Present. Source maps inspection details under You/trust routes, and tests verify contextual You ownership. |
| Dead routes have linked repair or quarantine issues. | No dead canonical root route found in the inspected source/test graph. Evidence-limited or contract-only areas are linked to AMB-1734, AMB-1735, AMB-1751, AMB-1742, AMB-1743, AMB-1744, AMB-1749, and AMB-1750. |
| Screenshot evidence exists or is explicitly required by linked frontend work. | Explicitly required by linked frontend work. This packet does not produce screenshots. |

## Proof Ceiling

Claim status for AMB-1747: Implemented Yellow / Ready for review.

Allowed claim:

- Current source and unit route evidence support the Stage/shell route audit
  findings for the inspected source graph.

Forbidden claims from this packet:

- rendered frontend quality
- visual quality
- accessibility conformance
- physical-device behavior
- TestFlight readiness
- App Store readiness
- Release Green
- full product completion

## Validation

Commands run from `/Users/devan/Documents/GitHub/ambitions`:

- `git diff --check` - passed.
- `python3 scripts/ambitions-remediation-governance-check.py` - passed,
  `GREEN remediation governance guard passed`.
- `python3 scripts/ambitions-accepted-yellow-misuse-audit.py` - passed,
  `valid=true`, `invalidAcceptedYellowIssues=0`.
- `python3 scripts/ambitions-unsupported-claim-scan.py docs/audits/amb-1747-stage-shell-frontend-reality-audit.md`
  - passed, `GREEN: unsupported completion/readiness claim scan passed`.
- `python3 scripts/ambitions-copy-contract-lint.py docs/audits/amb-1747-stage-shell-frontend-reality-audit.md`
  - failed because the script does not accept a file argument.
- `python3 scripts/ambitions-copy-contract-lint.py` - passed,
  `Copy contract lint passed`.
- `scripts/ambitions-xcode-test-focused.sh --batch AMB_1747_STAGE_SHELL_ROUTE_AUDIT --test AmbitionsTests/AppShellNavigationTests --without-building --timeout 8m --kill-after 60s`
  - passed, `FAILURE_CLASS=passed`, `EXECUTED_TESTS=39`.

Focused route-test artifacts:

- Result bundle:
  `.codex/xcode-results/AMB_1747_STAGE_SHELL_ROUTE_AUDIT/20260704T111657Z-AmbitionsTests-AppShellNavigationTests-4543-25785/focused-test.xcresult`
- Extracted summary:
  `.codex/xcode-summaries/AMB_1747_STAGE_SHELL_ROUTE_AUDIT/20260704T111657Z-AmbitionsTests-AppShellNavigationTests-4543-25785/extract/summary.json`

Proof ceiling from validation:

- The route test class executed 39 tests with 0 failures.
- The test methods themselves took 13.985 seconds, but the bounded wrapper had
  a long pre-test Xcode/package-graph startup gap and repeated package graph
  resolves. This supports AMB-1747 route evidence only; it is not screenshot,
  visual, accessibility, device, TestFlight, App Store, or release proof.

## Closeout Notes

- Private Life Orchestration relationship: preserved. The audit protects the
  Today / Goals / Time / You root shell, global Capture, Search/inspection
  handoffs, and Motion behavior layer needed for the local life-orchestration
  loop.
- Final Architecture Tree inspected: yes.
- Canonical owners inspected: `App/`, `Stage/`, `Stage/Motion/`, `Trust/`,
  `Surfaces/Today`, `Surfaces/Goals`, `Surfaces/Time`, `Surfaces/You`,
  `Composer/Capture`, and relevant tests.
- Canonical owners touched: none in production source.
- Files created: `docs/audits/amb-1747-stage-shell-frontend-reality-audit.md`.
- Files moved: none.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Architecture debt: rendered route journey, screenshot, accessibility, and
  device proof remain outside this packet and must be produced by the linked
  frontend bridge issues before any frontend Green or release claim.
- Next repair/proof train: AMB-1748, then AMB-1749 and AMB-1750; sibling
  frontend proof remains AMB-1734 through AMB-1744 plus AMB-1751.
- No equivalent folder/path interpretation was used.
