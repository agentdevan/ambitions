# Ambitions Known Issues — Live Register

**Status:** Runtime device review, AMB-1199 final proof, and LocalRuntimeOS proof-gate reconciliation are current. Current proof ceiling is **LocalRuntimeProof Gate Green / Runtime device Yellow / Visual Yellow-Red / Accessibility Yellow / Release Red-Yellow**.

**Last source reconciliation:** 2026-07-01 (`79b4a0101b0675e08c0658ba06b7e78a27b59dca`, `docs/qa/local-runtime-proof/current-local-runtime-proof.{json,md}`)
**Last final-proof evidence pass:** 2026-06-23 (`docs/qa/evidence/2026-06-23-final-proof/`)
**Last risk-register import evidence:** 2026-06-24 (`docs/qa/risk-register-imports/2026-06-24-risk-register-synthesis.md`, `.json`)
**Last device/runtime review:** 2026-06-22  
**Runtime evidence set:** `More issues.zip`, screenshots `IMG_8475.PNG` through `IMG_8499.PNG`, plus tester notes from the same review.  
**Baseline source context:** `ce75bb77122350fcab9500806e5ff26f8ee02e58` (`AMB-1180 rebuild LifeShape field object`) plus current `main` docs commits.
**LocalRuntimeOS evidence set:** `docs/qa/local-runtime-proof/current-local-runtime-proof.json`, `docs/qa/local-runtime-proof/current-local-runtime-proof.md`, `docs/qa/local-runtime-proof/amb-1597-local-runtime-proof.json`, `docs/qa/local-runtime-proof/amb-1597-local-runtime-proof.md`, `docs/qa/local-runtime-proof/amb-1599-local-runtime-proof.json`, `docs/qa/local-runtime-proof/amb-1599-local-runtime-proof.md`.

## Register rules

- Preserve issue IDs and dedupe keys.
- Historical screenshot evidence remains useful, but current closure requires current proof.
- Source-repaired means **candidate resolved**, not closed.
- Device-observed failures are **runtime verified**.
- Do not mark `Closed - verified` without proof artifacts in `docs/validation`, current screenshot/video evidence, audit output, or an explicit current testing report.
- Visual Green, Runtime Green, and Release Green are impossible while this file has open P0 issues.

## Codex remediation dossiers

Runtime issue closure is governed by:

- `docs/qa/remediation/2026-06-22-codex-remediation-law.md`
- `docs/qa/remediation/dossiers/*.md`

Execution bundles:

| Linear bundle | Dossier | Scope |
| -- | -- | -- |
| AMB-1191 | `AMB-1191-theme-design-system.md` | Theme / design system |
| AMB-1194 | `AMB-1194-shell-stage-os.md` | Shell / Stage OS |
| AMB-1192 | `AMB-1192-capture-routing-composer.md` | Capture |
| AMB-1193 | `AMB-1193-goals-root-detail.md` | Goals |
| AMB-1195 | `AMB-1195-today-reality-window.md` | Today |
| AMB-1196 | `AMB-1196-search-find-act-inspect.md` | Search |
| AMB-1197 | `AMB-1197-time-native-life-calendar.md` | Time |
| AMB-1198 | `AMB-1198-you-settings-privacy.md` | You |
| AMB-1199 | `AMB-1199-final-proof-accessibility.md` | Final proof |
| AMB-1200 | `AMB-1200-register-sync-control-closeout.md` | Register sync |

Rule:

Do not mark any issue `Closed - verified` unless the relevant dossier proof matrix is satisfied and owner acceptance is recorded.

## Current release verdict

The current build is materially improved in source architecture, Time foundation, and some shell behavior, but the runtime device review still shows a shallow, prototype-feeling app. The app is not ready for TestFlight-quality dogfooding. The most severe remaining blockers are:

1. **Goals is Red / unusable and has a crash on the `+` button.**
2. **Capture is not a full-screen global composer; it opens as a half-screen bottom sheet and has a dead microphone button.**
3. **Light mode has AMB-1191 source repairs for theme preference, semantic foundation tokens, dock material, and live appearance propagation, but current Light/System/Dark device proof is still missing.**
4. **Search exists visually but is not functionally useful and needs a complete rebuild.**
5. **Today still contains confusing toggles, status phrases, and context actions that do not belong in the primary Today object.**
6. **Time has AMB-1197 source/test repairs for native Life Calendar semantics and real-step-only placement, but current device screenshot proof is still missing.**
7. **Shell chrome has AMB-1194 source repairs for icon-only floating root buttons, root header subtitle cleanup, invisible rail coordination, and reduced root dock clearance, but current screenshot/device proof is still missing.**
8. **The app is still shallow: most drilldowns are slide-up cards rather than mature full-screen surfaces.**

AMB-1199 added a current simulator-only final-proof package on 2026-06-23. It produced dark-mode root screenshots for Today / Goals / Time / You, one passing Goal Detail route-depth UI test, passing automated accessibility evidence-contract tests, and Green local-first/privacy/release-claim scans. It does not close device, manual accessibility, Light/System screenshot, full drilldown, global shell completion, or owner-review gaps. Visual status remains Yellow/Red rather than Green because current screenshots still show dock/content overlap and clipped Goals text.

## 2026-07-01 LocalRuntimeOS post-refactor proof ceiling

Commit `79b4a0101b0675e08c0658ba06b7e78a27b59dca` records the current LocalRuntimeOS proof-gate state. The checked-in artifacts `docs/qa/local-runtime-proof/current-local-runtime-proof.json` and `docs/qa/local-runtime-proof/current-local-runtime-proof.md` show `20` checks, `20` passed, `0` warnings, and `0` blockers for the runtime law:

```text
Command -> Event -> Projection -> Receipt -> Replay
```

This evidence supports these exact claims only:

- **Architecture source proof:** `Native/Ambitions/Core/LocalRuntimeOS/` has source-present owner coverage for the tracked runtime owners and final architecture inventory source parity.
- **Runtime-law gate proof:** the repo-local LocalRuntimeProof gate is Green for the current 20-item LRO-100 semantic/fail-closed checklist, including live SQLite event-store authority, command/event reconciliation, fail-closed mutation commit policy, transaction-coordinator ownership, projection/search read gates, sanitized external-surface reads, PrivacySecurity egress/export/snapshot gates, Source Atlas/R2 public-only gates, SyncContinuity non-authority, durable Capture intake, side-effect commit-receipt gating, TrustSystem lineage, mutation-context boundaries, RuntimeDoctor local drift repair previews, mutation-bypass scan, feature-service mutation classification, and Known Issues/truth/CI proof-ceiling evidence.
- **Runtime behavior proof:** focused simulator XCTest evidence exists for the AMB-1581 through AMB-1597 runtime leaves, with the AMB-1597 closeout covering RuntimeDoctor redacted local drift readers and receipt-backed preview repair plans. This is source/runtime-gate proof, not broad rendered-device proof.
- **Device proof ceiling:** no current physical-device pass is recorded for this LocalRuntimeOS reconciliation. Simulator/focused XCTest evidence does not close physical-device rows.
- **Visual proof ceiling:** this reconciliation does not change the AMB-1199 visual ceiling. Dock/content overlap, clipped Goals text, missing Light/System screenshots, incomplete Capture/Search/full-drilldown screenshots, and owner visual review remain open.
- **Release proof ceiling:** this reconciliation does not prove release readiness, TestFlight readiness, App Store readiness, production CloudKit continuity, production R2 deployment, performance readiness, or archive/signing readiness.
- **Privacy/legal proof ceiling:** PrivacySecurity and Source Atlas/R2 scanner gates are source/runtime gates only. They do not prove privacy/legal approval, public privacy conformance, account launch readiness, or production data-handling review.

Rows below that were stale only because they said runtime source proof was missing are downgraded to source/runtime-gate repaired with remaining proof requirements kept explicit. Rows requiring rendered UI, device behavior, account launch, production CloudKit/R2, accessibility, privacy/legal, or owner acceptance remain open.

AMB-1200 reconciles that proof ceiling without implementing app fixes. The following AMB-1199 findings remain open and mapped to existing rows:

SCG-009B / AMB-1303 domain model repair mapping note: domain source/test repair is mapped to existing rows only and does not close runtime/device/visual/release evidence gaps. `GoalThread` authority remains explicitly projected from persisted Goals without adding a dedicated thread record, mapped to Goals rows `AMB-ISSUE-1301`-`AMB-ISSUE-1304`, `AMB-ISSUE-1309`, and Today coupling rows `AMB-ISSUE-0004`, `AMB-ISSUE-0005`. `UserSystemProfile` is Codable but classified as derived from local context/settings, with no dedicated profile record or private graph backend, mapped to `AMB-ISSUE-0014`, `AMB-ISSUE-0807`, `AMB-ISSUE-1801`, and `AMB-ISSUE-1802`. `ClosureOutcome` now exposes typed proof/receipt/undo classification consumed by closure stage mutation, mapped to Today/Closure rows `AMB-ISSUE-0004`, `AMB-ISSUE-0005`, `AMB-ISSUE-1001`-`AMB-ISSUE-1007`, plus proof rows `AMB-ISSUE-0014`, `AMB-ISSUE-0807`, `AMB-ISSUE-1801`, and `AMB-ISSUE-1802`. Runtime/device proof remains pending.

| Finding | Register mapping | Current status |
|---|---|---|
| `python3 scripts/ambitions-global-shell-completion-gate.py` remains Red. | `AMB-ISSUE-0014`, `AMB-ISSUE-0806`, `AMB-ISSUE-1709` | Still present / visual and release proof blocked. |
| Broad UI proof bundle hit AX timeout before complete Capture/Search/full drilldown screenshots. | `AMB-ISSUE-0014`, `AMB-ISSUE-0807`, `AMB-ISSUE-1801`, `AMB-ISSUE-1802` | Evidence gap / accessibility Yellow. |
| Dark simulator root screenshots exist only for Today, Goals, Time, You. | `AMB-ISSUE-0014`, surface rows below | Simulator-only proof; no device or Light/System proof. |
| Goals clipped/split `Quiet` text remains visible. | `AMB-ISSUE-0401`, `AMB-ISSUE-0402`, `AMB-ISSUE-1302` | Visual proof failed. |
| Dock/content overlap remains visible on Goals, Time, You. | `AMB-ISSUE-0806`, `AMB-ISSUE-1011`, `AMB-ISSUE-1706`, `AMB-ISSUE-1709` | Still present / shell proof failed. |
| Capture screenshot/proposal/receipt proof missing. | Capture rows `AMB-ISSUE-0003`, `0008`, `0012`, `0201`-`0205`, `1101`-`1111` | Evidence gap. |
| Search screenshot/route proof missing. | Search rows `AMB-ISSUE-0701`, `1601`-`1605` | Evidence gap. |
| Light/System screenshot proof missing. | Light rows `AMB-ISSUE-1901`-`1906`, `1503`, `0802` | Evidence gap. |
| Device proof and owner acceptance missing. | `AMB-ISSUE-0014`, `AMB-ISSUE-0015`, `AMB-ISSUE-0016`, `AMB-ISSUE-0807` | Release Red/Yellow; no Done. |
| Valid/no-step Today proof, Time placement variants proof, You Appearance before/after proof, and full drilldown proof missing. | Today, Time, You, Shell, and final-proof rows | Runtime proof pending. |
| Privacy scan remains advisory Yellow for reviewed context/non-claim hits. | `AMB-ISSUE-0014`, final-proof packet | Advisory Yellow; no private-data upload claim. |

## 2026-06-24 risk register import reconciliation

`Ambitions_Synthesized_Risk_Register.md` was imported as evidence only. It is not source of truth, not a third project, and not a parallel risk database. Canonical status remains owned by this register, QA remediation dossiers, SCG artifacts, and `docs/truth/*`. The import itself is a planning register and does not certify runtime behavior, device behavior, App Store posture, CloudKit behavior, accessibility, privacy, account readiness, R2 readiness, release posture, or owner acceptance.

The import reinforces existing product law and proof law:

- Persistent surfaces remain Today / Goals / Time / You.
- Capture remains the global composer, not a root tab.
- Motion remains behavior, not a destination.
- Core value remains local-first/offline with no account required.
- R2/Source Atlas remain public/reference/freshness infrastructure only and must not receive the private life graph.
- Every meaningful action requires runtime mutation, visible stage mutation, accessible state change, safe fallback, and proof artifact.

The import also matches the prior device-review failure pattern already represented here: Capture crash and composer proof gaps, non-mutating closure and Today recompute gaps, internal runtime jargon, duplicate shell chrome and dock overlap, Time layout/mutation weakness, weak native quality, and frontend/runtime validation blockers.

Existing row groups strengthened by this import:

| Existing row group | Imported evidence | Required proof addition |
|---|---|---|
| `AMB-ISSUE-0014` | `IR-2026-06-24-001`, `002`, `003`, `018`, `040`, `055`, `056` | Exact-SHA live persistent runtime proof, device proof, archive/privacy proof, and owner acceptance. |
| `AMB-ISSUE-0010` | `IR-2026-06-24-017`, `041`, `044`, `045`, `052` | Forbidden-language scan plus rendered screenshot review; string scan alone cannot close. |
| Today / Closure rows | `IR-2026-06-24-005`, `028`, `033` | Restart-proof Today mutation, proof/undo artifact IDs, before/action/after evidence. |
| Capture rows | `IR-2026-06-24-006`, `007`, `008`, `034`, `048` | Composer, keyboard, offline save, direct-ID lookup, external queue ack, proposal, and receipt proof. |
| Time rows | `IR-2026-06-24-004`, `024`, `026`, `029`, `033`, `038`, `048` | Durable-vs-preview distinction, injected clock, restart proof, Today recompute, undo, and permission-denied fallback. |
| Goals rows | `IR-2026-06-24-023`, `030` | Graph invariants, persistence reload, Today feed, Goal/Area detail, and step-chain proof. |
| You rows | `IR-2026-06-24-031`, `044` | Account/R2/settings actionability proof and no unsupported account/sync claims. |
| Search rows | `IR-2026-06-24-032`, `035` | Local-only bounded index, route/action proof, target validation, and no network proof. |
| Shell rows | `IR-2026-06-24-014`, `016`, `042`, `047`, `053` | Root/drilldown/overlay matrix, no overlap, no stale external state, no Motion root. |
| Accessibility/final-proof rows | `IR-2026-06-24-018`, `019`, `037`, `050`, `055` | Manual/device accessibility, privacy-trust, and archive/security proof; automated contracts are insufficient. |

## Build graph governance issues

| Finding ID | Severity | Source | Area | Evidence | Existing Issue / Duplicate | Owner Train | Required Proof | Status |
|---|---|---|---|---|---|---|---|---|
| `SCG-BG-001` | Red / Build graph blocker | SCG-002 / BUILD_GRAPH_INVENTORY | Packages/AmbitionsExperienceKernel | Package.swift declares `Resources/Tokens`, `Resources/Manifests`, and `Resources/AmbitionsExperienceTokens.xcassets`. SCG-002 initially flagged those as absent at the package root. SCG-002A verified SwiftPM resolves those paths relative to target path `Sources/AmbitionsExperienceKernel`; `swift package describe --type json` lists `Resources/Tokens/tokens.json` and `Resources/Manifests/*.json` as processed resources, and filesystem inspection confirms `Sources/AmbitionsExperienceKernel/Resources/AmbitionsExperienceTokens.xcassets` exists and is excluded. | None | SCG-002A | package manifest/resource-path audit, build graph validation, JSON inventory refresh | Resolved by package-relative path audit; no `Package.swift` change required. |

## Imported P0 launch-proof and control-plane rows

These rows are live after the 2026-06-24 evidence import. They do not close or downgrade existing rows. They add missing canonical QA/proof rows for imported P0 risks that were not represented with enough specificity in this register.

| ID | Surface | Status | Issue | Evidence | Required closure proof |
|---|---|---|---|---|---|
| `AMB-ISSUE-2001` | Runtime / Commands / Persistence | **Runtime source-gate repaired / device-release proof pending** | LocalRuntimeProof now covers canonical command path, validation-before-mutation markers, durable command journal/runtime event linkage, idempotency, fail-closed commit policy, rollback/replay evidence, and scanner-clean high-risk mutation seams. | `IR-2026-06-24-001`-`003`, `022`, `046`; `AMB-ISSUE-0014`; AMB-1301/1304; SCG-007C/L; `79b4a0101b0675e08c0658ba06b7e78a27b59dca`; `docs/qa/local-runtime-proof/current-local-runtime-proof.md`. | Visible rendered mutation, accessibility, physical-device proof, owner acceptance, and release proof remain required. |
| `AMB-ISSUE-2002` | External intake / Capture | **Runtime source-gate repaired / no-data-loss proof pending** | LocalRuntimeProof now covers durable Capture intake before classification, attachment staging, promotion, and restart lookup evidence for the source/runtime gate. | `IR-2026-06-24-007`, `027`, `051`; AMB-1097/1034/1093/1100; Capture device-review gaps; `79b4a0101b0675e08c0658ba06b7e78a27b59dca`; `docs/qa/local-runtime-proof/current-local-runtime-proof.md`. | External intake race tests, failure UI, rendered composer proof, device proof, and owner no-data-loss acceptance remain required. |
| `AMB-ISSUE-2003` | Capture / Persistence / Search | **Open / imported risk** | Capture direct-ID persistence lookup is not proven for older captures. | `IR-2026-06-24-008`; AMB-1192/1304; Capture proof remains missing after AMB-1199. | Direct ID fetch, more than 500 captures, restart, search/detail/open proof. |
| `AMB-ISSUE-2004` | Account / Auth / Offline core | **Open / imported risk** | Optional Ambitions Account launch architecture is not proof-ready. | `IR-2026-06-24-009`, `043`, `056`; AMB-1178/1039; product truth requires offline no-account core. | Sign in with Apple/Google, Keychain, session recovery, deletion, logged-out/offline routing, offline Capture/Start flow. |
| `AMB-ISSUE-2005` | Account / Storage / Erasure | **Open / imported risk** | Account-scoped storage, sign-out, delete-account, and erasure proof are missing. | `IR-2026-06-24-010`; AMB-1178/632; local-first/account boundary evidence. | Account-scope matrix, delete/export/reset/sign-out proof across local store, app group, widgets, notifications, and credentials. |
| `AMB-ISSUE-2006` | CloudKit / Sync / Migration | **Open / imported risk** | CloudKit sync engine is not launch-proof. | `IR-2026-06-24-011`, `056`; AMB-632; implementation truth keeps CloudKit sync unproven. | Zones/schema, stable IDs, tombstones, conflict policy, retry/backoff, migration, multi-device proof. |
| `AMB-ISSUE-2007` | Privacy / Account / R2 | **Runtime source-gate repaired / privacy-release proof pending** | LocalRuntimeProof now covers PrivacySecurity egress/export/diagnostics/snapshot gates and Source Atlas/R2 public-reference-only gates for the source/runtime boundary. | `IR-2026-06-24-012`; AMB-1178/610; product/process truth forbids private graph egress; `79b4a0101b0675e08c0658ba06b7e78a27b59dca`; `docs/qa/local-runtime-proof/current-local-runtime-proof.md`. | Account launch proof, You/Privacy rendered copy proof, physical-device proof, and privacy/legal approval remain required. |
| `AMB-ISSUE-2008` | EventKit / Reminders / Notifications | **Runtime source-gate repaired / external-device proof pending** | LocalRuntimeProof now covers local runtime commit receipt evidence before external side-effect attempts. | `IR-2026-06-24-013`, `025`, `026`; AMB-1033/1095/1096/1142; `79b4a0101b0675e08c0658ba06b7e78a27b59dca`; `docs/qa/local-runtime-proof/current-local-runtime-proof.md`. | Real EventKit/notification permission fallback, external write, rollback/recovery, sign-out cleanup, device proof, and owner acceptance remain required. |
| `AMB-ISSUE-2009` | Widgets / App Intents / Deep links | **Runtime source-gate repaired / external-surface proof pending** | LocalRuntimeProof now covers sanitized App Group projection snapshots plus App Intent/share bridge gating for source/runtime reads and intake. | `IR-2026-06-24-014`, `027`, `035`, `047`; AMB-1092/1093/994/1028/1029; `79b4a0101b0675e08c0658ba06b7e78a27b59dca`; `docs/qa/local-runtime-proof/current-local-runtime-proof.md`. | Rendered safe-failure UI, stale-target handling, parser safety, widget/App Intent runtime proof, and device proof remain required. |
| `AMB-ISSUE-2010` | Persistence / Import-export / Store health | **Runtime source-gate repaired / data-safety proof pending** | LocalRuntimeProof now covers SQLite event authority, projection/search stores, mutation-context boundaries, store-health diagnostics, and RuntimeDoctor receipt-backed local drift repair previews. | `IR-2026-06-24-015`, `021`, `039`, `054`; AMB-1295/1178; SCG-012; `79b4a0101b0675e08c0658ba06b7e78a27b59dca`; `docs/qa/local-runtime-proof/current-local-runtime-proof.md`. | Transactional import/export, reset, duplicate validation at scale, destructive recovery, restart replay consistency, device proof, and owner data-safety acceptance remain required. |
| `AMB-ISSUE-2011` | Security / Privacy / Local auth | **Runtime source-gate partially repaired / privacy-release proof pending** | LocalRuntimeProof and focused PrivacySecurity coverage now cover runtime redaction, file protection, local-auth gating markers, app-group snapshot gating, and external boundary checks at source/runtime-gate scope. | `IR-2026-06-24-019`, `050`, `056`; AMB-1294/1295/1178/634; `79b4a0101b0675e08c0658ba06b7e78a27b59dca`; `docs/qa/local-runtime-proof/current-local-runtime-proof.md`. | Archive privacy manifest audit, real `evaluatePolicy` device proof, least-privilege prompt proof, sensitive-scenario matrix, and privacy/legal approval remain required. |
| `AMB-ISSUE-2012` | Source Atlas / R2 | **Runtime source-gate repaired / production R2 proof pending** | LocalRuntimeProof now covers Source Atlas/R2 public-only request, gateway, endpoint, manifest/cache/last-known-good, and projection paths as public-reference-only. | `IR-2026-06-24-020`, `034`; AMB-1178/1036/658/668; R2/private graph boundary law; `79b4a0101b0675e08c0658ba06b7e78a27b59dca`; `docs/qa/local-runtime-proof/current-local-runtime-proof.md`. | Production R2 deployment, production signing, transparency/freshness operations, app-wide consumption, rendered user proof, and release proof remain required. |

Proposal-only:

| Proposed ID | Disposition | Reason |
|---|---|---|
| `AMB-ISSUE-2013` | Proposal-only / folded | App-group and multi-process storage race/corruption proof remains folded into `AMB-ISSUE-2002` and `AMB-ISSUE-2009` unless launch-scope app-group evidence proves a distinct row is required. |

## Verified improvements from this device review

| Issue | Runtime status | Evidence |
|---|---|---|
| Old hardcoded Today time | **Improved / device observed** | Today now showed real current time in screenshots and tester notes. Keep a regression test requirement. |
| Motion as root surface | **Resolved in source and not observed as root** | Dock shows Today / Goals / Time / You only. |
| Capture as root tab | **Resolved in source and not observed as root** | Capture appears through shell/action overlay, but current overlay behavior is still poor. |
| Duplicate native/custom bottom shelf | **Source-repaired candidate / runtime proof pending** | AMB-1194 removes the allocated bottom shelf/backdrop and renders the root dock as an overlayed invisible rail with separate icon buttons; current screenshot proof still required. |
| Root dock in drilldowns | **Improved / device observed** | Tester notes: root dock hides on drilldowns. |
| Old Time vertical-letter wrapping | **Improved / not observed in current Time screenshots** | Current Time no longer shows the severe source/receipt vertical wrap. |
| Closure visual quality | **Source-repaired candidate / runtime proof pending** | AMB-1195 gates the Today root Record Outcome action behind a current closure-eligible Step; device before/after closure proof remains pending. |

## Active P0 issues

| ID | Surface | Status | Issue | Evidence | Required closure proof |
|---|---|---|---|---|---|
| `AMB-ISSUE-0003` | Capture | **Source-repaired candidate / runtime proof pending** | AMB-1192 removes the dead mic affordance from the primary Capture composer and keeps dictation honest through the native iOS keyboard input path. | `IMG_8477`; tester notes; AMB-1192 source/test proof. | Device proof that no dead mic appears and keyboard dictation fallback remains understandable. |
| `AMB-ISSUE-0004` | Today / Closure | **Source-repaired candidate / runtime proof pending** | AMB-1195 removes no-step root closure access and keeps Record Outcome visible only for a current closure-eligible Step; AMB-1300 adds typed before/action/after proof, receipt, motion, and undo references for closure Stage mutations. Runtime/device proof remains pending. | Closure screenshots `IMG_8478`, `IMG_8493`–`IMG_8495`; AMB-1195 source/action-gating proof; AMB-1300 focused closure mutation source/test proof. | Current runtime/device before/action/after screenshots and proof/undo artifact. |
| `AMB-ISSUE-0005` | Today / Navigation | **Source-repaired candidate / runtime proof pending** | AMB-1195 removes the no-step CTA menu and routes Shape Time / Protect Window into focused Today-scoped flows instead of root Time. | `IMG_8475`, `IMG_8476`; tester notes; AMB-1195 source/action-gating proof. | Contextual route map and screenshots for each action. |
| `AMB-ISSUE-0008` | Capture / Keyboard | **Source-repaired candidate / runtime proof pending** | AMB-1192 routes activated Capture through a full-screen Stage seam, hides root dock chrome, and removes primary route taxonomy while composing; current device keyboard screenshots are still required. | `IMG_8477`; tester notes; AMB-1192 source/test proof. | Full-screen composer screenshots across blank/focused/proposal/receipt states. |
| `AMB-ISSUE-0010` | Language | **Still present — runtime verified** | Primary UI exposes internal/architecture/trust language. | `IMG_8475`–`IMG_8499`. | ForbiddenLanguageAudit + screenshot review. |
| `AMB-ISSUE-0012` | Capture | **Source-repaired candidate / runtime proof pending** | AMB-1192 makes activated Capture a global full-screen Stage composer path instead of a root tab or half-sheet; device proof remains pending. | `IMG_8477`; AMB-1192 source/test proof. | Full-screen composer device proof. |
| `AMB-ISSUE-0014` | Quality | **Still open / AMB-1199 proof failed-capped** | Proof artifacts remain insufficient for release-quality closure. AMB-1199 added a simulator/source evidence package, but the global shell completion gate remains Red, broad UI proof timed out before Capture/Search/full drilldown screenshots, and device/Light/System/owner proof is missing. | 2026-06-22 device review; AMB-1199 final-proof packet; `docs/qa/evidence/2026-06-23-final-proof/manifest.json`; `boundary-scan-results.md`. | ShellChrome, SafeArea, ForbiddenLanguage, DynamicType, MotionReduction, VisualRegression, RealDevice outputs, full screenshot matrix, and owner acceptance. |
| `AMB-ISSUE-0016` | Whole app | **Source-repaired candidate for Today slice / runtime proof pending** | AMB-1195 repairs Today root action gating, removes no-step CTA menu behavior, and adds focused Today flow contracts; whole-app runtime proof remains pending. | Tester notes across Today, Goals, Time, You, Search; AMB-1195 source/action-gating proof. | Current scenario matrix plus before/after mutation proof. |
| `AMB-ISSUE-0806` | Shell | **Source-repaired candidate / visual proof failed** | AMB-1194 removes the visible dock container/backdrop, overlays the root rail on the full-bleed Stage, reserves content clearance through `StageSafeAreaPolicy`, and removes root shell subtitles exposing internal object names. AMB-1199 still shows dock/content overlap on Goals, Time, and You, so shell visual proof remains failed/capped. | Prior runtime evidence: `IMG_8475`-`IMG_8499`; AMB-1194 source/test proof; AMB-1199 `screenshot-index.md` and `route-depth-matrix.md`. | Full-bleed shell screenshot matrix with no overlap, route-depth/safe-area proof, global shell completion gate Green, device proof. |
| `AMB-ISSUE-0913` | Time / Trust | **Source-repaired candidate / runtime proof pending** | AMB-1197 removes raw proof/receipt/haptic metadata from root Time mutation feedback and blocks fake Place Step when no real eligible Step exists. | `IMG_8481`, `IMG_8482`, `IMG_8490`; AMB-1197 source/test proof. | Current device mutation proof and screenshot review showing no fake success or internal metadata. |
| `AMB-ISSUE-1001` | Today | **Source-repaired candidate / runtime proof pending** | AMB-1195 removes the nonfunctional `Start Here` / `Meridian` segmented toggle from Today root. | `IMG_8475`, `IMG_8476`, `IMG_8492`; AMB-1195 source/action-gating proof. | Before/after screenshots. |
| `AMB-ISSUE-1002` | Today | **Source-repaired candidate / runtime proof pending** | AMB-1195 removes the touched Today root rail/status copy including `No source change yet` and keeps no-step copy sparse and state-derived. | `IMG_8475`, `IMG_8476`, `IMG_8492`; AMB-1195 forbidden-copy source proof. | Root Today screenshot with no internal rail copy. |
| `AMB-ISSUE-1003` | Today / Capture | **Source-repaired candidate / runtime proof pending** | AMB-1195 removes embedded Today root Capture CTAs and the Today navigation Capture button; global Capture remains outside Today root. | `IMG_8475`, `IMG_8476`; AMB-1195 source/action-gating proof. | Today root without embedded Capture CTA. |
| `AMB-ISSUE-1004` | Today / Time | **Source-repaired candidate / runtime proof pending** | AMB-1195 routes Shape Time to a focused Today-scoped contextual/unavailable flow instead of top-level Time. | Tester notes; AMB-1195 source/action-gating proof. | Flow screenshot from a valid Start Here token. |
| `AMB-ISSUE-1005` | Today | **Source-repaired candidate / runtime proof pending** | AMB-1195 removes the dead root `Review context` action from the no-step Today object. | `IMG_8475`, `IMG_8476`; tester notes; AMB-1195 forbidden-copy source proof. | Today root screenshot with the button absent. |
| `AMB-ISSUE-1006` | Today / Closure | **Source-repaired candidate / runtime proof pending** | AMB-1195 hides Record Outcome when no current Step exists and gates it to closure-eligible Start Here state. | `IMG_8475`, `IMG_8476`; tester notes; AMB-1195 action-gating proof. | No-step Today screenshot without outcome action. |
| `AMB-ISSUE-1007` | Today / Time / Capture | **Source-repaired candidate / runtime proof pending** | AMB-1195 routes Protect Window to a focused Today protection flow instead of top-level Time; full Time placement remains deferred. | Tester notes; AMB-1195 source/action-gating proof. | Protection flow screenshot from Today context. |
| `AMB-ISSUE-1101` | Capture | **Source-repaired candidate / runtime proof pending** | AMB-1192 moves activated Capture out of the sheet path into a full-screen Stage seam. | `IMG_8477`; AMB-1192 source/test proof. | Full-screen Capture screenshots. |
| `AMB-ISSUE-1102` | Capture | **Source-repaired candidate / runtime proof pending** | AMB-1192 removes visible input-alternative explainer UI from the primary composer while retaining accessibility/dictation state through non-primary labels. | `IMG_8477`; AMB-1192 source/test proof. | Composer screenshot without visible input-alternative explainer block. |
| `AMB-ISSUE-1103` | Capture | **Source-repaired candidate / runtime proof pending** | AMB-1192 removes the `Open Field` / `Today - review before save` header from activated Capture. | `IMG_8477`; AMB-1192 source/test proof. | Header removal screenshot proof. |
| `AMB-ISSUE-1104` | Capture | **Source-repaired candidate / runtime proof pending** | AMB-1192 removes `Activated`, `Keyboard`, and `Local read` chips from the primary Capture composer. | `IMG_8477`; AMB-1192 source/test proof. | Primary composer screenshot with no internal state chips. |
| `AMB-ISSUE-1105` | Capture | **Source-repaired candidate / runtime proof pending** | AMB-1192 replaces visible self-descriptive composer copy with a field-first input, spatial teaching, and proposal/receipt flow. | `IMG_8477`; AMB-1192 source/test proof. | Composer screenshot showing direct input affordance. |
| `AMB-ISSUE-1106` | Capture | **Source-repaired candidate / runtime proof pending** | AMB-1192 removes root composer placeholder text entirely; spatial cursor/iconography/first-run teaching replaces placeholder copy. | `IMG_8477`; tester notes; AMB-1192 source/test proof. | Blank composer screenshot proving no placeholder text. |
| `AMB-ISSUE-1107` | Capture | **Source-repaired candidate / runtime proof pending** | AMB-1192 keeps route proposals out of the primary composing state and opens route choices only in the proposal step. | Tester notes; visible routing block in `IMG_8477`; AMB-1192 source/test proof. | Composer and proposal screenshots proving input stays dominant. |
| `AMB-ISSUE-1108` | Capture / Language | **Source-repaired candidate / runtime proof pending** | AMB-1192 changes touched Capture route/object labels from Task to Step in primary Capture, proposal, attachment, and route-preview surfaces. | Tester notes; AMB-1192 source/test proof. | String audit and screenshots. |
| `AMB-ISSUE-1109` | Capture / Language | **Source-repaired candidate / runtime proof pending** | AMB-1192 removes `Route needs your choice` and `Inspectable route` from the touched Capture route/proposal path. | Tester notes; AMB-1192 source/test proof. | Capture routing screenshot plus forbidden-language scan. |
| `AMB-ISSUE-1301` | Goals | **Source-repaired candidate / runtime proof pending** | AMB-1193 routes Goals `+` through typed Capture goal context and adds focused no-crash route tests; device crash-log proof remains pending. | Tester notes; AMB-1193 source/test proof. | Current device no-crash proof for Goals `+`. |
| `AMB-ISSUE-1302` | Goals | **Source-repaired candidate / visual proof failed** | AMB-1193 replaces the diagnostic Goals root with Life Area Atlas, full-screen Area Detail, and path/journal-first Goal Detail source; AMB-1199 dark simulator proof still shows clipped/split `Quiet` text and dock overlap, so visual/device acceptance remains pending. | `IMG_8479`, `IMG_8480`, `IMG_8491`, `IMG_8498`, `IMG_8499`; tester notes; AMB-1193 source/test proof; AMB-1199 `screenshot-index.md`. | Goals root text-fit proof, area detail, goal detail, creation-entry screenshot proof, and device proof. |
| `AMB-ISSUE-1601` | Search | **Source-repaired / candidate resolved / runtime proof pending** | AMB-1196 replaces the shallow Search path with a Stage-owned local Find / Act / Inspect overlay, deterministic local index, typed result routing, and no network search path. Device visual acceptance is still pending. | Source/tests: AMB-1196 focused Search/router/Stage suites, architecture inventory, quality gate, build-local. Prior screenshots: `IMG_8496`, `IMG_8497`; tester notes. | Runtime/device screenshot matrix and owner acceptance. |
| `AMB-ISSUE-1901` | Light mode | **Source-repaired candidate / runtime proof pending** | AMB-1191 centralizes System/Light/Dark theme preference resolution and adds semantic foundation token coverage, but current Light/System/Dark screenshot proof is still required. | Prior runtime evidence: `IMG_8488`–`IMG_8492`; AMB-1191 source/test proof. | Light-mode screenshot matrix. |
| `AMB-ISSUE-1902` | Theme / Design system | **Source-repaired candidate / runtime proof pending** | AMB-1191 adds semantic color/material/typography/spacing/motion/haptics/glyph audit coverage and routes the touched dock material through `AmbitionTheme`; full visual hard-coded-dark purge remains proof-gated. | Prior runtime evidence: `IMG_8488`–`IMG_8492`; tester notes; AMB-1191 token/source tests. | Token audit + light-mode screenshot proof. |

## Active P1/P2 issues by surface

### Today

| ID | Status | Issue | Evidence |
|---|---|---|---|
| `AMB-ISSUE-0101` | Source-repaired candidate / runtime proof pending | AMB-1195 moves Today root toward a single Start Here token/no-current-fit window and removes the no-step menu controls; visual maturity still needs screenshot review. | `IMG_8475`, `IMG_8476`, `IMG_8492`; AMB-1195 source/action-gating proof |
| `AMB-ISSUE-0102` | Source-repaired candidate / runtime proof pending | AMB-1195 removes the Start Here/Meridian toggle and no-step action stack from Today root. | `IMG_8475`, `IMG_8476`; AMB-1195 source/action-gating proof |
| `AMB-ISSUE-0103` | Source-repaired candidate / runtime proof pending | AMB-1195 removes the no-step CTA stack; valid-step actions are gated icon affordances tied to the Start Here token. | `IMG_8475`, `IMG_8476`; AMB-1195 action-gating proof |
| `AMB-ISSUE-0106` | Source-repaired candidate / runtime proof pending | AMB-1195 removes decorative fallback timeline icons from the touched Today rail path and uses semantic state-backed nodes. | `IMG_8475`, `IMG_8476`, `IMG_8492`; AMB-1195 source proof |
| `AMB-ISSUE-1008` | Source-repaired candidate / runtime proof pending | AMB-1195 keeps the active indicator tied to the current time node while removing redundant copy; visual alignment still needs screenshot review. | `IMG_8475`, `IMG_8476`; AMB-1195 source proof |
| `AMB-ISSUE-1009` | Source-repaired candidate / runtime proof pending | AMB-1195 removes `Live now` copy from the touched Today current-time node. | `IMG_8475`, `IMG_8476`, `IMG_8492`; AMB-1195 forbidden-copy source proof |
| `AMB-ISSUE-1010` | Source-repaired candidate / runtime proof pending | AMB-1195 removes decorative/random fallback timeline icons from the touched Today root rail. | `IMG_8475`, `IMG_8476`, `IMG_8492`; AMB-1195 source proof |
| `AMB-ISSUE-1011` | Source-repaired candidate / runtime proof pending | AMB-1194 moves the dock out of a bottom shelf; AMB-1195 removes Today-specific no-step menu actions, mode toggle, and redundant root copy. | `IMG_8475`, `IMG_8476`; AMB-1194 source/test proof; AMB-1195 source/action-gating proof |

### Capture

| ID | Status | Issue | Evidence |
|---|---|---|---|
| `AMB-ISSUE-0201` | Source-repaired candidate / runtime proof pending | AMB-1192 rebuilds activated Capture as a field-first full-screen Stage composer with proposal and receipt states; visual/device review still required. | `IMG_8477`; AMB-1192 source/test proof |
| `AMB-ISSUE-0202` | Source-repaired candidate / runtime proof pending | AMB-1192 removes generic/internal routing copy from the primary composer and hides resolver explanation behind disclosure in the proposal state. | `IMG_8477`; notes; AMB-1192 source/test proof |
| `AMB-ISSUE-0205` | Source-repaired candidate / runtime proof pending | AMB-1192 implements full-screen activated Capture plus blank/focused/proposal/receipt source/test coverage; device state-machine screenshots remain pending. | `IMG_8477`; AMB-1192 source/test proof |
| `AMB-ISSUE-1110` | Source-repaired candidate / runtime proof pending | AMB-1192 removes the competing mic/accessory affordance from the primary composer; attachment/context roles remain model-backed, not cloud-backed. | `IMG_8477`; AMB-1192 source/test proof |
| `AMB-ISSUE-1111` | Source-repaired candidate / runtime proof pending | AMB-1192 removes keyboard/local-state chips and keeps keyboard/dictation state honest through the text input path and accessibility labels. | `IMG_8477`; AMB-1192 source/test proof |

### Closure

| ID | Status | Issue | Evidence |
|---|---|---|---|
| `AMB-ISSUE-0301` | Improved but open | Closure looks acceptable for v1, but current Step identity/state gating still needs proof. | `IMG_8478`, `IMG_8493` |
| `AMB-ISSUE-0305` | Still open | Closure proof stitch, undo, and Today mutation still need before/after evidence. | `IMG_8494`, `IMG_8495` |
| `AMB-ISSUE-1201` | Source-repaired candidate / runtime proof pending | AMB-1195 removes no-step Today closure access and gates Record Outcome to a current closure-eligible Step. | `IMG_8475`, `IMG_8478`; notes; AMB-1195 action-gating proof |

### Goals

| ID | Status | Issue | Evidence |
|---|---|---|---|
| `AMB-ISSUE-0401` | Source-repaired candidate / runtime proof pending | AMB-1193 reframes Goals root as Life Area Atlas with active goal marks and area drilldowns instead of the old diagnostic Constellation report; device proof remains pending. | `IMG_8479`, `IMG_8480`, `IMG_8491`, `IMG_8498`, `IMG_8499`; AMB-1193 source/test proof |
| `AMB-ISSUE-0402` | Source-repaired candidate / runtime proof pending | AMB-1193 keeps default Life Areas visible as quiet regions, removes repeated Today status copy from root, and exposes contextual Capture entry; visual proof remains pending. | `IMG_8479`, `IMG_8491`; AMB-1193 source/test proof |
| `AMB-ISSUE-0403` | Source-repaired candidate / runtime proof pending | AMB-1193 stages goal profile, path field, journal, area detail, and honest unavailable path-edit copy; full runtime proof for every operation remains pending. | Goals screenshots; AMB-1193 source/test proof |
| `AMB-ISSUE-0404` | Still open / outside AMB-1193 runtime proof | Today pull behavior is intentionally deferred; AMB-1193 only leaves a minimal current-step lift hook when Goals already has a target. | `IMG_8498`, `IMG_8499`; AMB-1193 source/test proof |
| `AMB-ISSUE-0405` | Source-repaired candidate / runtime proof pending | AMB-1193 opens areas and goals through full-screen drilldowns, hides the root dock by route depth, and keeps available operations explicit; device proof remains pending. | Goals screenshots; AMB-1193 source/test proof |
| `AMB-ISSUE-1303` | Source-repaired candidate / runtime proof pending | AMB-1193 removes architecture/explainer dominance from the rendered Goals root and replaces it with Life Area Atlas object language. | `IMG_8479`, `IMG_8480`, `IMG_8498`; AMB-1193 source/test proof |
| `AMB-ISSUE-1304` | Source-repaired candidate / runtime proof pending | AMB-1193 de-routes the report/card diagnostic root in favor of life-area regions, contextual marks, and full-screen detail paths. | All Goals screenshots; AMB-1193 source/test proof |
| `AMB-ISSUE-1305` | Source-repaired candidate / runtime proof pending | AMB-1193 removes the rendered `GOALS · Constellation Atlas` root header from Goals root source. | `IMG_8479`, `IMG_8480`, `IMG_8491`, `IMG_8498`; AMB-1193 forbidden-language audit |
| `AMB-ISSUE-1306` | Source-repaired candidate / runtime proof pending | AMB-1193 de-routes the diagnostic Thread Focus console from rendered root and removes the stale Goal Detail mission-control surface. | `IMG_8480`, `IMG_8498`, `IMG_8499`; AMB-1193 forbidden-language audit |
| `AMB-ISSUE-1307` | Source-repaired candidate / runtime proof pending | AMB-1193 removes source/proof/context/why-this/status rows as primary rendered Goals root UI. | `IMG_8480`, `IMG_8498`, `IMG_8499`; AMB-1193 source/test proof |
| `AMB-ISSUE-1308` | Source-repaired candidate / runtime proof pending | AMB-1193 removes the contradictory `No active thread yet` root diagnostic language from the rendered Goals root. | `IMG_8498`, `IMG_8499`; AMB-1193 forbidden-language audit |
| `AMB-ISSUE-1309` | Source-repaired candidate / runtime proof pending | AMB-1193 replaces duplicated root creation CTAs with a single root plus and contextual empty-region Capture entry. | `IMG_8480`, `IMG_8499`; AMB-1193 source/test proof |

### Time

| ID | Status | Issue | Evidence |
|---|---|---|---|
| `AMB-ISSUE-0009` | Source-repaired candidate / runtime proof pending | AMB-1197 makes Time placement state-backed and local-only; no external calendar sync or cloud scheduling was added. | AMB-1197 source/test proof; device proof pending. |
| `AMB-ISSUE-0501` | Source-repaired candidate / runtime proof pending | AMB-1197 rebuilds root Time toward a native Life Calendar object with Now/current day, fixed/open/protected/pressure/buffer/recovery/goal-load rows and real-step-only placement gating. | `IMG_8481`, `IMG_8482`, `IMG_8490`; AMB-1197 source/test proof. |
| `AMB-ISSUE-0502` | Source-repaired candidate / runtime proof pending | AMB-1197 adds explicit row and accessibility semantics for Now, fixed points, open windows, protected windows, pressure, buffer, recovery, goal load, and list equivalent. | `IMG_8481`, `IMG_8482`, `IMG_8490`; AMB-1197 source/test proof. |
| `AMB-ISSUE-0503` | Source-repaired candidate / runtime proof pending | AMB-1197 keeps Time calendar anchors local and deterministic, with external calendar behavior still optional and non-syncing. | AMB-1197 source/test proof; device proof pending. |
| `AMB-ISSUE-0504` | Source-repaired candidate / runtime proof pending | AMB-1197 stages day/week/month/year/list as explicit calendar rows and keeps list as the accessibility/large-text equivalent instead of a gesture-only horizon. | Current Time screenshots only show limited root state; AMB-1197 source/test proof. |
| `AMB-ISSUE-0505` | Source-repaired candidate / runtime proof pending | AMB-1197 ties fixed points, open windows, protected windows, pressure, buffer, recovery, and goal load to Time projection state instead of unexplained decoration. | `IMG_8481`, `IMG_8482`; AMB-1197 source/test proof. |
| `AMB-ISSUE-0506` | Source-repaired candidate / runtime proof pending | AMB-1197 preserves protected-window representation and keeps protection actions state-backed or unavailable; no fake protection success is claimed. | AMB-1197 source/test proof; device proof pending. |
| `AMB-ISSUE-0507` | Source-repaired candidate / runtime proof pending | AMB-1197 keeps Time placement/protection local and deterministic with before/action/after mutation tests for real Step placement. | AMB-1197 source/test proof; device proof pending. |
| `AMB-ISSUE-1401` | Source-repaired candidate / runtime proof pending | AMB-1197 disables `Place Step` without a real eligible Goal Step or free-floating Capture-derived Step and removes invented Step IDs from the mutation path. AMB-1300 adds typed proof, receipt, motion, undo, fallback, and string-only invalid-state test coverage for touched Time mutation paths. Runtime/device proof remains pending. | Tester notes; `IMG_8481`, `IMG_8482`; AMB-1197 source/test proof; AMB-1300 focused Time mutation source/test proof. |
| `AMB-ISSUE-1402` | Source-repaired candidate / runtime proof pending | AMB-1197 adds compact native labels and VoiceOver values for Open, Protected, Pressure, Buffer, Recovery, and Goal load semantics. | `IMG_8481`, `IMG_8482`, `IMG_8490`; AMB-1197 source/test proof. |
| `AMB-ISSUE-1403` | Source-repaired candidate / runtime proof pending | AMB-1197 removes root user-facing Time object labeling as `TIME · LifeShape Field` and relabels the primary accessibility object as Life Calendar. | `IMG_8481`, `IMG_8482`, `IMG_8490`; AMB-1197 source/test proof. |
| `AMB-ISSUE-1404` | Source-repaired candidate / runtime proof pending | AMB-1197 replaces the generic three-row fallback with ordered calendar rows driven by Time state and keeps the object primary. | `IMG_8481`, `IMG_8482`, `IMG_8490`; AMB-1197 source/test proof. |
| `AMB-ISSUE-1405` | Source-repaired candidate / runtime proof pending | AMB-1197 routes touched Time layer and action colors through semantic theme state styles instead of hard-coded Time RGB assumptions. | `IMG_8490`; AMB-1197 source/test proof; Light/Dark device proof pending. |

### You

| ID | Status | Issue | Evidence |
|---|---|---|---|
| `AMB-ISSUE-0601` | Source-repaired / candidate resolved / runtime proof pending | AMB-1198 rebuilds You root as compact native settings groups with a small local-status capsule instead of the prior system/profile explanation. Current device proof is still required. | `IMG_8483`, `IMG_8489`, `IMG_8496`; AMB-1198 source/test/build proof; simulator screenshot attempt interrupted before usable extraction |
| `AMB-ISSUE-0602` | Source-repaired / candidate resolved / runtime proof pending | AMB-1198 moves You toward native Settings/Profile quality with grouped rows for Appearance, Capture, Life Areas, Privacy, Local Data, Sources, Receipts, Accessibility, and About. Visual/device acceptance remains pending. | `IMG_8483`–`IMG_8487`, `IMG_8489`; AMB-1198 source/test/build proof; simulator screenshot attempt interrupted before usable extraction |
| `AMB-ISSUE-0603` | Source-repaired / candidate resolved / runtime proof pending | AMB-1198 reduces root row copy to title, compact state, icon, and detail route; paragraph-heavy root rows are de-routed into detail surfaces. Current screenshot review remains pending. | `IMG_8483`–`IMG_8487`; AMB-1198 source/test/build proof; simulator screenshot attempt interrupted before usable extraction |
| `AMB-ISSUE-0604` | Source-repaired / candidate resolved / runtime proof pending | AMB-1198 routes each major You row to real controls or honest unavailable/status detail states for Appearance, Capture, Life Areas, Privacy, Local Data, Sources, Receipts, Accessibility, and About. Runtime tap proof remains pending. | Tester notes; AMB-1198 source/test/build proof; simulator screenshot attempt interrupted before usable extraction |
| `AMB-ISSUE-0606` | Source-repaired / candidate resolved / runtime proof pending | AMB-1198 preserves You detail routing through Stage route depth and adds Life Areas and Accessibility as settings details; broader app drilldown maturity remains outside this row. | `IMG_8488`; notes; AMB-1198 source/test/build proof; simulator screenshot attempt interrupted before usable extraction |
| `AMB-ISSUE-1501` | Source-repaired / candidate resolved / runtime proof pending | AMB-1198 removes the per-row divider overlay from the touched You root row component. Current device screenshot proof is still required. | `IMG_8483`–`IMG_8487`; AMB-1198 source/test/build proof; simulator screenshot attempt interrupted before usable extraction |
| `AMB-ISSUE-1502` | Source-repaired / candidate resolved / runtime proof pending | AMB-1198 removes the You root bottom gradient/glow overlay from `YouSurface`. Current device screenshot proof is still required. | `IMG_8483`–`IMG_8487`; AMB-1198 source/test/build proof; simulator screenshot attempt interrupted before usable extraction |
| `AMB-ISSUE-1503` | Source-repaired / candidate resolved / runtime proof pending | Theme changes continue to apply through the existing app container as the You Appearance editor changes preference or accent; AMB-1198 keeps the live preview hook intact. Current device proof is still required. | Tester notes; AMB-1191 source/test proof; AMB-1198 source/test/build proof; simulator screenshot attempt interrupted before usable extraction |
| `AMB-ISSUE-1504` | Source-repaired / candidate resolved / runtime proof pending | AMB-1198 removes the visible root system-facing header language from You root and detail headers. Current device screenshot proof is still required. | `IMG_8483`, `IMG_8489`, `IMG_8496`; AMB-1198 source/test/build proof; simulator screenshot attempt interrupted before usable extraction |
| `AMB-ISSUE-1505` | Source-repaired / candidate resolved / runtime proof pending | AMB-1198 de-routes the `How Ambitions works for me` explanatory root governance block and replaces it with compact grouped settings. Current device screenshot proof is still required. | `IMG_8483`, `IMG_8489`, `IMG_8496`; AMB-1198 source/test/build proof; simulator screenshot attempt interrupted before usable extraction |

### Search

| ID | Status | Issue | Evidence |
|---|---|---|---|
| `AMB-ISSUE-0701` | Source-repaired / candidate resolved / runtime proof pending | Search rows now expose semantic object family, title, human context, source area, state, primary action, optional inspect affordance, and typed destination proof. Device visual proof remains pending. | AMB-1196 source/tests; prior screenshots `IMG_8496`, `IMG_8497` |
| `AMB-ISSUE-1602` | Source-repaired / candidate resolved / runtime proof pending | Search now renders as a Stage-owned full-screen overlay path instead of the previous shallow sheet path; root dock policy hides dock while Search is active. Device visual proof remains pending. | AMB-1196 source/tests; prior screenshots `IMG_8496`, `IMG_8497` |
| `AMB-ISSUE-1603` | Source-repaired / candidate resolved / runtime proof pending | Search UI rendering and focused audit remove internal labels from user-facing Search result copy; raw local object data is preserved behind typed routes. Device visual proof remains pending. | AMB-1196 source/tests; prior screenshots `IMG_8496`, `IMG_8497` |
| `AMB-ISSUE-1604` | Source-repaired / candidate resolved / runtime proof pending | Search uses one focused native search field with submit behavior and no separate small Search button. Device visual proof remains pending. | AMB-1196 source/tests; prior screenshots `IMG_8496`, `IMG_8497` |
| `AMB-ISSUE-1605` | Source-repaired / candidate resolved / runtime proof pending | Search now has local deterministic indexing, origin-biased ranking, typed routing, valid primary actions, Capture-from-query fallback, and local-only/privacy audit proof. Device route/video proof remains pending. | AMB-1196 focused tests; tester notes; prior screenshots |

### Shell / navigation / full-bleed

| ID | Status | Issue | Evidence |
|---|---|---|---|
| `AMB-ISSUE-1701` | Source-repaired candidate / runtime proof pending | AMB-1194 replaces the bordered dock/container with four separate floating icon buttons coordinated by `shell.stage-os.invisible-rail`. | Prior root screenshots; AMB-1194 source/test proof |
| `AMB-ISSUE-1702` | Source-repaired candidate / runtime proof pending | AMB-1194 removes visible dock words from the normal root rail while preserving VoiceOver labels and selected state. | Prior root screenshots; AMB-1194 source/test proof |
| `AMB-ISSUE-1703` | Source-repaired candidate / runtime proof pending | AMB-1194 removes underline, selected capsule fill, active border, and active weight change; selected state is the accent icon plus accessibility selected trait. | Prior root screenshots; AMB-1194 source/test proof |
| `AMB-ISSUE-1704` | Source-repaired candidate / runtime proof pending | AMB-1194 removes root shell subtitles from Goals, Time, and You so the root crown no longer expands into the prior large internal-name header treatment. | `IMG_8479`, `IMG_8481`, `IMG_8483`; AMB-1194 source/test proof |
| `AMB-ISSUE-1705` | Source-repaired candidate / runtime proof pending | AMB-1194 removes root shell subtitle strings `Constellation Atlas`, `LifeShape Field`, and `Profile and settings` from Goals, Time, and You root hosts. | Goals/Time/You screenshots; AMB-1194 source/test proof |
| `AMB-ISSUE-1706` | Source-repaired candidate / visual proof failed | AMB-1194 removes the allocated bottom shelf/backdrop and reduces root dock clearance while keeping policy-owned content clearance. AMB-1199 still shows dock/content overlap on Goals, Time, and You. | Prior root screenshots; AMB-1194 source/test proof; AMB-1199 `screenshot-index.md` |
| `AMB-ISSUE-1707` | Still open / proof pending | AMB-1194 did not rebuild contextual header action button anatomy beyond removing root internal subtitles; current screenshots must verify whether the remaining controls are acceptable or need a later shell action pass. | Goals/Time/You screenshots |
| `AMB-ISSUE-1708` | Source-repaired candidate / runtime proof pending | AMB-1194 aligns root shell rhythm by using the same compact root crown posture and overlaid icon-only dock across Today, Goals, Time, and You; Today object maturity remains outside this bundle. | `IMG_8475`, `IMG_8476`; AMB-1194 source/test proof |
| `AMB-ISSUE-1709` | Still open / proof gap | AMB-1194 preserves root dock hiding in drilldowns and global overlays, but AMB-1199 did not produce Capture, Search, Area Detail, Time drilldown, You detail, or full back/dismiss screenshot proof because the broad UI bundle hit an AX timeout. | Tester notes; Closure/Capture/Search screenshots; AMB-1199 `route-depth-matrix.md` |

### Light mode / appearance

| ID | Status | Issue | Evidence |
|---|---|---|---|
| `AMB-ISSUE-1903` | Source-repaired candidate / runtime proof pending | Appearance preference now resolves through the design-system theme bridge and live editor propagation; Appearance Studio still needs current Light-mode screenshot proof. | Prior runtime evidence: `IMG_8488`; AMB-1191 source/test proof |
| `AMB-ISSUE-1904` | Source-repaired candidate / runtime proof pending | Touched Stage dock rail no longer uses dark-only Liquid Glass constants and now renders from theme material/divider tokens; current Light-mode dock screenshot proof is still required. | Prior runtime evidence: `IMG_8489`–`IMG_8492`; AMB-1191 source/test proof |
| `AMB-ISSUE-1905` | Still open / AMB-1191 foundation repaired | Semantic theme foundations were added, but Today-specific light-mode visual quality was not redesigned in this bounded train. | `IMG_8492`; AMB-1191 did not produce current Today visual proof |
| `AMB-ISSUE-1906` | Still open / AMB-1191 foundation repaired | Semantic theme foundations were added, but Goals and Time light-mode object redesigns were outside this bounded train. | `IMG_8490`, `IMG_8491`; AMB-1191 did not produce current Goals/Time visual proof |

### Accessibility and QA

| ID | Status | Issue | Evidence |
|---|---|---|---|
| `AMB-ISSUE-0807` | Automated evidence candidate / manual proof pending | AMB-1199 aligned and passed the automated accessibility evidence-contract suite, but no manual VoiceOver walkthrough or physical-device accessibility review was performed. No accessibility readiness claim is allowed. | Tester notes; AMB-1199 `AccessibilityNutritionChecklistTests` run: 21 tests passed; `docs/qa/evidence/2026-06-23-final-proof/accessibility-checklist.md` |
| `AMB-ISSUE-1801` | Automated evidence candidate / manual and device proof pending | Dynamic Type, VoiceOver, Reduce Motion, Reduce Transparency, Increase Contrast, Differentiate Without Color, haptics, keyboard/focus, and non-gesture alternatives now have an explicit AMB-1199 checklist plus automated source-contract coverage where available; manual/device execution remains required. | Tester notes; AMB-1199 accessibility checklist and focused test summary |
| `AMB-ISSUE-1802` | Open / contract evidence aligned | AMB-1199 preserved explicit manual-proof limitations and source-contract coverage; this does not replace runtime/device accessibility review. | Canon risk; AMB-1199 evidence package |

## Screenshot evidence map

| Screenshot | Primary evidence |
|---|---|
| `IMG_8475` | Today root, Start Here toggle, rail copy, CTA stack, dock. |
| `IMG_8476` | Today with Meridian toggle selected; no meaningful difference. |
| `IMG_8477` | Capture bottom sheet, internal header/chips, dead mic area, routing block, input alternatives. |
| `IMG_8478` | Closure top; visually acceptable but launched from no-step Today context. |
| `IMG_8479` | Goals root object and internal Constellation Atlas copy. |
| `IMG_8480` | Goals Thread Focus collapsed, diagnostic rows, CTA duplication. |
| `IMG_8481` | Time root dark mode, Open layer, unclear object semantics. |
| `IMG_8482` | Time root lower view, rows under object. |
| `IMG_8483`–`IMG_8487` | You root and settings rows, dividers, statuses, bottom glow. |
| `IMG_8488` | Appearance Studio light mode failure / dark content after light selection. |
| `IMG_8489` | You light mode, low-contrast dock, hard-coded/dim treatment. |
| `IMG_8490` | Time light mode, low-contrast object/dock. |
| `IMG_8491` | Goals light mode, header/object/card issues. |
| `IMG_8492` | Today light mode dim/washed out. |
| `IMG_8493`–`IMG_8495` | Closure flow; acceptable direction but still needs mutation proof and access gating. |
| `IMG_8496`–`IMG_8497` | Search overlay; abstract results and low maturity. |
| `IMG_8498`–`IMG_8499` | Goals expanded Thread Focus, diagnostic/internal rows, unusable root model. |

## Next implementation order implied by this review

1. **P0 Light mode / theme proof follow-through.** AMB-1191 repaired core theme propagation and semantic token coverage; current Light/System/Dark screenshots still need to prove no hard-coded dark objects remain in the rendered app.
2. **P0 Capture full-screen composer rebuild.** Full-screen, no internal chips/copy, working mic/fallback, stable field dominance.
3. **P0 Goals respec/rebuild and `+` crash fix.** Do not patch the current object; rebuild it.
4. **P0 Shell full-bleed chrome rebuild.** Four floating icon-only dock buttons; no bordered dock; no root internal object names.
5. **P0 Today action cleanup.** Remove no-op toggles, internal rail copy, unwanted CTAs; gate Record Outcome by actual step presence.
6. **P0 Search respec/rebuild.** Do not polish current search sheet.
7. **P1 Time second pass.** Remove fake `Place Step`, clarify dots/Now/bars, make actions require real user state.
8. **P1 You polish.** Remove dividers/glow, make settings actionable, and visually prove live theme update.
9. **P1 Full-screen drilldown architecture.** Replace shallow slide-up cards where a real drilldown is required.
10. **QA proof pass.** Build, device screenshots, UI tests, accessibility proof, and visual regression.
