# Ambitions Known Issues — Live Register

**Status:** Runtime device review reconciled. Current app status is **Red**.

**Last source reconciliation:** 2026-06-23
**Last device/runtime review:** 2026-06-22  
**Runtime evidence set:** `More issues.zip`, screenshots `IMG_8475.PNG` through `IMG_8499.PNG`, plus tester notes from the same review.  
**Baseline source context:** `ce75bb77122350fcab9500806e5ff26f8ee02e58` (`AMB-1180 rebuild LifeShape field object`) plus current `main` docs commits.

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
| AMB-1192 | `AMB-1192-capture-route-graph-composer.md` | Capture |
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
6. **Time improved but still does not communicate a usable LifeShape Field. It can place a step when no real user-created step or goal exists.**
7. **Shell chrome has AMB-1194 source repairs for icon-only floating root buttons, root header subtitle cleanup, invisible rail coordination, and reduced root dock clearance, but current screenshot/device proof is still missing.**
8. **The app is still shallow: most drilldowns are slide-up cards rather than mature full-screen surfaces.**

## Verified improvements from this device review

| Issue | Runtime status | Evidence |
|---|---|---|
| Old hardcoded Today time | **Improved / device observed** | Today now showed real current time in screenshots and tester notes. Keep a regression test requirement. |
| Motion as root surface | **Resolved in source and not observed as root** | Dock shows Today / Goals / Time / You only. |
| Capture as root tab | **Resolved in source and not observed as root** | Capture appears through shell/action overlay, but current overlay behavior is still poor. |
| Duplicate native/custom bottom shelf | **Source-repaired candidate / runtime proof pending** | AMB-1194 removes the allocated bottom shelf/backdrop and renders the root dock as an overlayed invisible rail with separate icon buttons; current screenshot proof still required. |
| Root dock in drilldowns | **Improved / device observed** | Tester notes: root dock hides on drilldowns. |
| Old Time vertical-letter wrapping | **Improved / not observed in current Time screenshots** | Current Time no longer shows the severe source/receipt vertical wrap. |
| Closure visual quality | **Acceptable for v1 / still needs state gating** | Tester notes: Closure looks good enough for v1; however Record Outcome appears when no step exists. |

## Active P0 issues

| ID | Surface | Status | Issue | Evidence | Required closure proof |
|---|---|---|---|---|---|
| `AMB-ISSUE-0003` | Capture | **Source-repaired candidate / runtime proof pending** | AMB-1192 removes the dead mic affordance from the primary Capture composer and keeps dictation honest through the native iOS keyboard input path. | `IMG_8477`; tester notes; AMB-1192 source/test proof. | Device proof that no dead mic appears and keyboard dictation fallback remains understandable. |
| `AMB-ISSUE-0004` | Today / Closure | **Still open — runtime proof incomplete** | Closure can launch, but Today mutation after saving is not yet proven. | Closure screenshots `IMG_8478`, `IMG_8493`–`IMG_8495`; no before/after mutation proof. | Before/action/after screenshots and proof/undo artifact. |
| `AMB-ISSUE-0005` | Today / Navigation | **Still present — runtime verified** | Today CTAs route incorrectly or too shallowly. | `IMG_8475`, `IMG_8476`; tester notes. | Contextual route map and screenshots for each action. |
| `AMB-ISSUE-0008` | Capture / Keyboard | **Source-repaired candidate / runtime proof pending** | AMB-1192 routes activated Capture through a full-screen Stage seam, hides root dock chrome, and removes primary route taxonomy while composing; current device keyboard screenshots are still required. | `IMG_8477`; tester notes; AMB-1192 source/test proof. | Full-screen composer screenshots across blank/focused/proposal/receipt states. |
| `AMB-ISSUE-0010` | Language | **Still present — runtime verified** | Primary UI exposes internal/architecture/trust language. | `IMG_8475`–`IMG_8499`. | ForbiddenLanguageAudit + screenshot review. |
| `AMB-ISSUE-0012` | Capture | **Source-repaired candidate / runtime proof pending** | AMB-1192 makes activated Capture a global full-screen Stage composer path instead of a root tab or half-sheet; device proof remains pending. | `IMG_8477`; AMB-1192 source/test proof. | Full-screen composer device proof. |
| `AMB-ISSUE-0014` | Quality | **Still open** | Proof artifacts remain insufficient for release-quality closure. | Device review did not include tests/audits. | ShellChrome, SafeArea, ForbiddenLanguage, DynamicType, MotionReduction, VisualRegression, RealDevice outputs. |
| `AMB-ISSUE-0016` | Whole app | **Still present — runtime verified** | Frontend remains too shallow and confusing for reliable runtime validation. | Tester notes across Today, Goals, Time, You, Search. | Current scenario matrix plus before/after mutation proof. |
| `AMB-ISSUE-0806` | Shell | **Source-repaired candidate / runtime proof pending** | AMB-1194 removes the visible dock container/backdrop, overlays the root rail on the full-bleed Stage, reserves content clearance through `StageSafeAreaPolicy`, and removes root shell subtitles exposing internal object names. | Prior runtime evidence: `IMG_8475`–`IMG_8499`; AMB-1194 source/test proof. | Full-bleed shell screenshot matrix. |
| `AMB-ISSUE-0913` | Time / Trust | **Still present — runtime verified** | Time mutation feedback may expose proof/receipt/haptic-style metadata or imply fake mutation success. | `IMG_8481`, `IMG_8482`, `IMG_8490`; tester clicked Place Step and got step placed without a real step. | Mutation source trace + UI copy audit + no-fake-step proof. |
| `AMB-ISSUE-1001` | Today | **New — runtime verified** | `Start Here` / `Meridian` segmented toggles appear at top of Today and make no visible difference. They do not belong on Today. | `IMG_8475`, `IMG_8476`, `IMG_8492`. | Remove or replace with meaningful shell/state control; before/after screenshots. |
| `AMB-ISSUE-1002` | Today | **New — runtime verified** | Rail/status copy `No source change yet` and `All from work context` is confusing and should not appear in the Today primary object. | `IMG_8475`, `IMG_8476`, `IMG_8492`. | Root Today screenshot with no internal rail copy. |
| `AMB-ISSUE-1003` | Today / Capture | **New — runtime verified** | `Capture what changed` is inside the Today object, but Capture should remain global shell behavior; copy also sounds like closure. | `IMG_8475`, `IMG_8476`. | Today root without embedded Capture CTA. |
| `AMB-ISSUE-1004` | Today / Time | **New — runtime verified** | `Shape Time` routes to top-level Time; expected behavior is step recommendation drilldown/context, not root tab jump. | Tester notes. | Route proof from Today action to correct recommendation/detail. |
| `AMB-ISSUE-1005` | Today | **New — runtime verified** | `Review context` is a dead/unwanted button. | `IMG_8475`, `IMG_8476`; tester notes. | Button removed or converted into requested inspection-only path. |
| `AMB-ISSUE-1006` | Today / Closure | **New — runtime verified** | `Record outcome` appears when there is no step to close. | `IMG_8475`, `IMG_8476`; tester notes. | No-step Today screenshot without outcome action. |
| `AMB-ISSUE-1007` | Today / Time / Capture | **New — runtime verified** | `Protect this window` routes to top-level Time; expected behavior is a focused protection flow asking how much time to protect. | Tester notes. | Protection flow screenshot from Today context. |
| `AMB-ISSUE-1101` | Capture | **Source-repaired candidate / runtime proof pending** | AMB-1192 moves activated Capture out of the sheet path into a full-screen Stage seam. | `IMG_8477`; AMB-1192 source/test proof. | Full-screen Capture screenshots. |
| `AMB-ISSUE-1102` | Capture | **Source-repaired candidate / runtime proof pending** | AMB-1192 removes visible input-alternative explainer UI from the primary composer while retaining accessibility/dictation state through non-primary labels. | `IMG_8477`; AMB-1192 source/test proof. | Composer screenshot without visible input-alternative explainer block. |
| `AMB-ISSUE-1103` | Capture | **Source-repaired candidate / runtime proof pending** | AMB-1192 removes the `Open Field` / `Today - review before save` header from activated Capture. | `IMG_8477`; AMB-1192 source/test proof. | Header removal screenshot proof. |
| `AMB-ISSUE-1104` | Capture | **Source-repaired candidate / runtime proof pending** | AMB-1192 removes `Activated`, `Keyboard`, and `Local read` chips from the primary Capture composer. | `IMG_8477`; AMB-1192 source/test proof. | Primary composer screenshot with no internal state chips. |
| `AMB-ISSUE-1105` | Capture | **Source-repaired candidate / runtime proof pending** | AMB-1192 replaces visible self-descriptive composer copy with a field-first input, spatial teaching, and proposal/receipt flow. | `IMG_8477`; AMB-1192 source/test proof. | Composer screenshot showing direct input affordance. |
| `AMB-ISSUE-1106` | Capture | **Source-repaired candidate / runtime proof pending** | AMB-1192 removes root composer placeholder text entirely; spatial cursor/iconography/first-run teaching replaces placeholder copy. | `IMG_8477`; tester notes; AMB-1192 source/test proof. | Blank composer screenshot proving no placeholder text. |
| `AMB-ISSUE-1107` | Capture | **Source-repaired candidate / runtime proof pending** | AMB-1192 keeps route proposals out of the primary composing state and opens route choices only in the proposal step. | Tester notes; visible routing block in `IMG_8477`; AMB-1192 source/test proof. | Composer and proposal screenshots proving input stays dominant. |
| `AMB-ISSUE-1108` | Capture / Language | **Source-repaired candidate / runtime proof pending** | AMB-1192 changes touched Capture route/object labels from Task to Step in primary Capture, proposal, attachment, and route-preview surfaces. | Tester notes; AMB-1192 source/test proof. | String audit and screenshots. |
| `AMB-ISSUE-1109` | Capture / Language | **Source-repaired candidate / runtime proof pending** | AMB-1192 removes `Route needs your choice` and `Inspectable route` from the touched Capture route/proposal path. | Tester notes; AMB-1192 source/test proof. | Capture routing screenshot plus forbidden-language scan. |
| `AMB-ISSUE-1301` | Goals | **New P0 — runtime verified** | Goals `+` button crashes. | Tester notes. | Crash log + no-crash device proof. |
| `AMB-ISSUE-1302` | Goals | **New P0 — runtime verified** | Goals is currently unusable and needs full re-spec/rebuild. | `IMG_8479`, `IMG_8480`, `IMG_8491`, `IMG_8498`, `IMG_8499`; tester notes. | New Goals spec, target, implementation, screenshot proof. |
| `AMB-ISSUE-1601` | Search | **New P0 — runtime verified** | Search exists visually but is nowhere near functional; needs re-spec and rebuild. | `IMG_8496`, `IMG_8497`; tester notes. | Search spec + actionable result flow proof. |
| `AMB-ISSUE-1901` | Light mode | **Source-repaired candidate / runtime proof pending** | AMB-1191 centralizes System/Light/Dark theme preference resolution and adds semantic foundation token coverage, but current Light/System/Dark screenshot proof is still required. | Prior runtime evidence: `IMG_8488`–`IMG_8492`; AMB-1191 source/test proof. | Light-mode screenshot matrix. |
| `AMB-ISSUE-1902` | Theme / Design system | **Source-repaired candidate / runtime proof pending** | AMB-1191 adds semantic color/material/typography/spacing/motion/haptics/glyph audit coverage and routes the touched dock material through `AmbitionTheme`; full visual hard-coded-dark purge remains proof-gated. | Prior runtime evidence: `IMG_8488`–`IMG_8492`; tester notes; AMB-1191 token/source tests. | Token audit + light-mode screenshot proof. |

## Active P1/P2 issues by surface

### Today

| ID | Status | Issue | Evidence |
|---|---|---|---|
| `AMB-ISSUE-0101` | Still present | Today does not yet prove a mature Reality Meridian; it is still a rail with buttons, icons, and status text. | `IMG_8475`, `IMG_8476`, `IMG_8492` |
| `AMB-ISSUE-0102` | Still present | Start Here/no-step state is confused by extra toggles and actions. | `IMG_8475`, `IMG_8476` |
| `AMB-ISSUE-0103` | Still present | CTA stack dominates Today and makes it feel like a menu, not a life-operating surface. | `IMG_8475`, `IMG_8476` |
| `AMB-ISSUE-0106` | Still present | Random icons remain on the timeline without clear semantic attachment. | `IMG_8475`, `IMG_8476`, `IMG_8492` |
| `AMB-ISSUE-1008` | New | Active dot next to the step is slightly misaligned with the timeline rail. | `IMG_8475`, `IMG_8476` |
| `AMB-ISSUE-1009` | New | `Live now` copy under the current time is redundant and should be removed. | `IMG_8475`, `IMG_8476`, `IMG_8492` |
| `AMB-ISSUE-1010` | New | Timeline icons appear decorative/random rather than tied to visible steps, fixed points, or proof. | `IMG_8475`, `IMG_8476`, `IMG_8492` |
| `AMB-ISSUE-1011` | Source-repaired candidate / runtime proof pending | AMB-1194 moves the dock out of a bottom shelf, keeps the Stage background full-bleed, and preserves content clearance through the shell policy; Today-specific object/crown maturity still needs screenshot review. | `IMG_8475`, `IMG_8476`; AMB-1194 source/test proof |

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
| `AMB-ISSUE-1201` | New | Closure can be opened from Today when no step exists; access condition belongs on Today action gating. | `IMG_8475`, `IMG_8478`; notes |

### Goals

| ID | Status | Issue | Evidence |
|---|---|---|---|
| `AMB-ISSUE-0401` | Still present / Red | Goals does not prove Constellation Atlas as a useful relational goal object. | `IMG_8479`, `IMG_8480`, `IMG_8491`, `IMG_8498`, `IMG_8499` |
| `AMB-ISSUE-0402` | Still present | Life areas are static tiles with repeated Today statuses. | `IMG_8479`, `IMG_8491` |
| `AMB-ISSUE-0403` | Still present | Goal threads, step chains, substeps, attachments, dates, reminders, and real goal operations are not proven. | Goals screenshots |
| `AMB-ISSUE-0404` | Still present | Recommended Step relationship to Today is not visually or functionally proven. | `IMG_8498`, `IMG_8499` |
| `AMB-ISSUE-0405` | Still present | Opening goals and goal actions remain unclear. | Goals screenshots |
| `AMB-ISSUE-1303` | New | Goals object talks at the user with explanatory/system copy instead of becoming an obvious object. | `IMG_8479`, `IMG_8480`, `IMG_8498` |
| `AMB-ISSUE-1304` | New | Goals has the same report/card failure pattern Time had before its object rebuild. | All Goals screenshots |
| `AMB-ISSUE-1305` | New | User-facing header exposes `GOALS · Constellation Atlas`. | `IMG_8479`, `IMG_8480`, `IMG_8491`, `IMG_8498` |
| `AMB-ISSUE-1306` | New | Thread Focus is a diagnostic console, not a user-facing goal operation. | `IMG_8480`, `IMG_8498`, `IMG_8499` |
| `AMB-ISSUE-1307` | New | Source/proof/context/why-this/status language dominates root Goals. | `IMG_8480`, `IMG_8498`, `IMG_8499` |
| `AMB-ISSUE-1308` | New | `No active thread yet` coexists with many thread/proof rows, creating contradiction. | `IMG_8498`, `IMG_8499` |
| `AMB-ISSUE-1309` | New | Bottom `Create your first goal` CTA is duplicated by floating `+` and appears inside a broken root model. | `IMG_8480`, `IMG_8499` |

### Time

| ID | Status | Issue | Evidence |
|---|---|---|---|
| `AMB-ISSUE-0501` | Improved but still present | Time is much better than the prior build but remains alpha/prototype and not usable. | `IMG_8481`, `IMG_8482`, `IMG_8490`; notes |
| `AMB-ISSUE-0502` | Still present | Time object does not explain what dots, bars, or the central Now line mean. | `IMG_8481`, `IMG_8482`, `IMG_8490` |
| `AMB-ISSUE-0504` | Still present | Day/week/month/year/list orientation is not proven. | Current Time screenshots only show limited root state. |
| `AMB-ISSUE-0505` | Still present | Fixed points/open capacity/protected windows remain abstract and not tied to obvious real constraints. | `IMG_8481`, `IMG_8482` |
| `AMB-ISSUE-1401` | New | `Place Step` appears and succeeds without a real user-created step or goal. This is fake-action behavior. | Tester notes; `IMG_8481`, `IMG_8482` |
| `AMB-ISSUE-1402` | New | `Open / Protected / Pressure / Buffer` segmented layers are not self-explanatory. | `IMG_8481`, `IMG_8482`, `IMG_8490` |
| `AMB-ISSUE-1403` | New | User-facing header exposes `TIME · LifeShape Field`. | `IMG_8481`, `IMG_8482`, `IMG_8490` |
| `AMB-ISSUE-1404` | New | Time rows below the object (`Today`, `This week`, `Rest of month`) still read like generic cards beneath an object. | `IMG_8481`, `IMG_8482`, `IMG_8490` |
| `AMB-ISSUE-1405` | New | Light-mode Time is low-contrast and visually broken. | `IMG_8490` |

### You

| ID | Status | Issue | Evidence |
|---|---|---|---|
| `AMB-ISSUE-0601` | Improved but open | You looks better, but still starts as a system/profile explanation rather than a polished native profile. | `IMG_8483`, `IMG_8489`, `IMG_8496` |
| `AMB-ISSUE-0602` | Still present | You still does not fully match premium native settings/profile quality. | `IMG_8483`–`IMG_8487`, `IMG_8489` |
| `AMB-ISSUE-0603` | Still present | Rows remain copy-heavy and status-heavy. | `IMG_8483`–`IMG_8487` |
| `AMB-ISSUE-0604` | Still present | Most settings/details do not expose real options. | Tester notes |
| `AMB-ISSUE-0606` | Improved but open | You has full-screen details, but many app drilldowns elsewhere are still slide-up cards. | `IMG_8488`; notes |
| `AMB-ISSUE-1501` | New | Divider lines between every row should be removed. | `IMG_8483`–`IMG_8487` |
| `AMB-ISSUE-1502` | New | Weird shadow/glow appears at the bottom of You border/container. | `IMG_8483`–`IMG_8487` |
| `AMB-ISSUE-1503` | Source-repaired candidate / runtime proof pending | Theme changes now apply through the app container as the You Appearance editor changes preference or accent; current device proof is still required. | Tester notes; AMB-1191 source/test proof |
| `AMB-ISSUE-1504` | New | Header exposes `YOU · Profile and settings` and `Your System` system language. | `IMG_8483`, `IMG_8489`, `IMG_8496` |
| `AMB-ISSUE-1505` | New | `How Ambitions works for me` is still explanatory trust copy on root You. | `IMG_8483`, `IMG_8489`, `IMG_8496` |

### Search

| ID | Status | Issue | Evidence |
|---|---|---|---|
| `AMB-ISSUE-0701` | Still present / Red | Search result rows are abstract and not useful. | `IMG_8496`, `IMG_8497` |
| `AMB-ISSUE-1602` | New | Search is a shallow sheet/card instead of a mature shell overlay. | `IMG_8496`, `IMG_8497` |
| `AMB-ISSUE-1603` | New | Results expose internal labels like `Handoff`, `Global Capture`, `Week`, and `owning surfaces`. | `IMG_8496`, `IMG_8497` |
| `AMB-ISSUE-1604` | New | Search field plus separate small Search button is low-quality and not native-feeling. | `IMG_8496`, `IMG_8497` |
| `AMB-ISSUE-1605` | New | Search does not prove real indexing, routing, result actionability, or scoped/global behavior. | Tester notes; screenshots |

### Shell / navigation / full-bleed

| ID | Status | Issue | Evidence |
|---|---|---|---|
| `AMB-ISSUE-1701` | Source-repaired candidate / runtime proof pending | AMB-1194 replaces the bordered dock/container with four separate floating icon buttons coordinated by `shell.stage-os.invisible-rail`. | Prior root screenshots; AMB-1194 source/test proof |
| `AMB-ISSUE-1702` | Source-repaired candidate / runtime proof pending | AMB-1194 removes visible dock words from the normal root rail while preserving VoiceOver labels and selected state. | Prior root screenshots; AMB-1194 source/test proof |
| `AMB-ISSUE-1703` | Source-repaired candidate / runtime proof pending | AMB-1194 removes underline, selected capsule fill, active border, and active weight change; selected state is the accent icon plus accessibility selected trait. | Prior root screenshots; AMB-1194 source/test proof |
| `AMB-ISSUE-1704` | Source-repaired candidate / runtime proof pending | AMB-1194 removes root shell subtitles from Goals, Time, and You so the root crown no longer expands into the prior large internal-name header treatment. | `IMG_8479`, `IMG_8481`, `IMG_8483`; AMB-1194 source/test proof |
| `AMB-ISSUE-1705` | Source-repaired candidate / runtime proof pending | AMB-1194 removes root shell subtitle strings `Constellation Atlas`, `LifeShape Field`, and `Profile and settings` from Goals, Time, and You root hosts. | Goals/Time/You screenshots; AMB-1194 source/test proof |
| `AMB-ISSUE-1706` | Source-repaired candidate / runtime proof pending | AMB-1194 removes the allocated bottom shelf/backdrop and reduces root dock clearance while keeping policy-owned content clearance. | Prior root screenshots; AMB-1194 source/test proof |
| `AMB-ISSUE-1707` | Still open / proof pending | AMB-1194 did not rebuild contextual header action button anatomy beyond removing root internal subtitles; current screenshots must verify whether the remaining controls are acceptable or need a later shell action pass. | Goals/Time/You screenshots |
| `AMB-ISSUE-1708` | Source-repaired candidate / runtime proof pending | AMB-1194 aligns root shell rhythm by using the same compact root crown posture and overlaid icon-only dock across Today, Goals, Time, and You; Today object maturity remains outside this bundle. | `IMG_8475`, `IMG_8476`; AMB-1194 source/test proof |
| `AMB-ISSUE-1709` | Still open / outside AMB-1194 source repair | AMB-1194 preserves root dock hiding in drilldowns and global overlays, but full-screen drilldown maturity for Capture, Search, Closure, Goals detail, Area detail, and Time Fit belongs to later dossiers. | Tester notes; Closure/Capture/Search screenshots |

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
| `AMB-ISSUE-0807` | Still open | Accessibility was not tested; no accessibility readiness claim is allowed. | Tester notes |
| `AMB-ISSUE-1801` | New | Dynamic Type, VoiceOver, Reduce Motion, Reduce Transparency, High Contrast, Differentiate Without Color, and haptics remain unverified. | Tester notes |
| `AMB-ISSUE-1802` | New | Retrofitting accessibility after normal-use perfection is a release risk; any rebuild must preserve semantic mirrors and accessible actions from implementation start. | Canon risk |

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
