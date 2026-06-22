# Ambitions Known Issues — Live Register

**Status:** Runtime device review reconciled. Current app status is **Red**.

**Last source reconciliation:** 2026-06-22  
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

## Current release verdict

The current build is materially improved in source architecture, Time foundation, and some shell behavior, but the runtime device review still shows a shallow, prototype-feeling app. The app is not ready for TestFlight-quality dogfooding. The most severe remaining blockers are:

1. **Goals is Red / unusable and has a crash on the `+` button.**
2. **Capture is not a full-screen global composer; it opens as a half-screen bottom sheet and has a dead microphone button.**
3. **Light mode is effectively unusable because many objects remain hard-coded dark or low-contrast.**
4. **Search exists visually but is not functionally useful and needs a complete rebuild.**
5. **Today still contains confusing toggles, status phrases, and context actions that do not belong in the primary Today object.**
6. **Time improved but still does not communicate a usable LifeShape Field. It can place a step when no real user-created step or goal exists.**
7. **Shell chrome still feels prototype: bordered dock, words under icons, over-indicated active state, large root headers, internal object names, and excessive safe-area padding.**
8. **The app is still shallow: most drilldowns are slide-up cards rather than mature full-screen surfaces.**

## Verified improvements from this device review

| Issue | Runtime status | Evidence |
|---|---|---|
| Old hardcoded Today time | **Improved / device observed** | Today now showed real current time in screenshots and tester notes. Keep a regression test requirement. |
| Motion as root surface | **Resolved in source and not observed as root** | Dock shows Today / Goals / Time / You only. |
| Capture as root tab | **Resolved in source and not observed as root** | Capture appears through shell/action overlay, but current overlay behavior is still poor. |
| Duplicate native/custom bottom shelf | **Improved / not observed in same old form** | The old second tab shelf is not the dominant failure now; dock styling/safe area remain open. |
| Root dock in drilldowns | **Improved / device observed** | Tester notes: root dock hides on drilldowns. |
| Old Time vertical-letter wrapping | **Improved / not observed in current Time screenshots** | Current Time no longer shows the severe source/receipt vertical wrap. |
| Closure visual quality | **Acceptable for v1 / still needs state gating** | Tester notes: Closure looks good enough for v1; however Record Outcome appears when no step exists. |

## Active P0 issues

| ID | Surface | Status | Issue | Evidence | Required closure proof |
|---|---|---|---|---|---|
| `AMB-ISSUE-0003` | Capture | **Still present — runtime verified** | Mic button appears in text field but is dead. | `IMG_8477`; tester notes. | Mic permission states, working voice path or disabled/fallback state, device proof. |
| `AMB-ISSUE-0004` | Today / Closure | **Still open — runtime proof incomplete** | Closure can launch, but Today mutation after saving is not yet proven. | Closure screenshots `IMG_8478`, `IMG_8493`–`IMG_8495`; no before/after mutation proof. | Before/action/after screenshots and proof/undo artifact. |
| `AMB-ISSUE-0005` | Today / Navigation | **Still present — runtime verified** | Today CTAs route incorrectly or too shallowly. | `IMG_8475`, `IMG_8476`; tester notes. | Contextual route map and screenshots for each action. |
| `AMB-ISSUE-0008` | Capture / Keyboard | **Still present — runtime verified** | Capture is a half-screen bottom sheet and layout collapses when routing/category UI appears. | `IMG_8477`; tester notes. | Full-screen composer screenshots across collapsed/focused/expanded states. |
| `AMB-ISSUE-0010` | Language | **Still present — runtime verified** | Primary UI exposes internal/architecture/trust language. | `IMG_8475`–`IMG_8499`. | ForbiddenLanguageAudit + screenshot review. |
| `AMB-ISSUE-0012` | Capture | **Still present — runtime verified** | Capture is not yet a global full-screen Atmosphere Composer. | `IMG_8477`. | Full-screen composer device proof. |
| `AMB-ISSUE-0014` | Quality | **Still open** | Proof artifacts remain insufficient for release-quality closure. | Device review did not include tests/audits. | ShellChrome, SafeArea, ForbiddenLanguage, DynamicType, MotionReduction, VisualRegression, RealDevice outputs. |
| `AMB-ISSUE-0016` | Whole app | **Still present — runtime verified** | Frontend remains too shallow and confusing for reliable runtime validation. | Tester notes across Today, Goals, Time, You, Search. | Current scenario matrix plus before/after mutation proof. |
| `AMB-ISSUE-0806` | Shell | **Still present — runtime verified** | Header/dock/safe-area composition remains prototype and not full-bleed. | `IMG_8475`–`IMG_8499`; shell notes. | Full-bleed shell screenshot matrix. |
| `AMB-ISSUE-0913` | Time / Trust | **Still present — runtime verified** | Time mutation feedback may expose proof/receipt/haptic-style metadata or imply fake mutation success. | `IMG_8481`, `IMG_8482`, `IMG_8490`; tester clicked Place Step and got step placed without a real step. | Mutation source trace + UI copy audit + no-fake-step proof. |
| `AMB-ISSUE-1001` | Today | **New — runtime verified** | `Start Here` / `Meridian` segmented toggles appear at top of Today and make no visible difference. They do not belong on Today. | `IMG_8475`, `IMG_8476`, `IMG_8492`. | Remove or replace with meaningful shell/state control; before/after screenshots. |
| `AMB-ISSUE-1002` | Today | **New — runtime verified** | Rail/status copy `No source change yet` and `All from work context` is confusing and should not appear in the Today primary object. | `IMG_8475`, `IMG_8476`, `IMG_8492`. | Root Today screenshot with no internal rail copy. |
| `AMB-ISSUE-1003` | Today / Capture | **New — runtime verified** | `Capture what changed` is inside the Today object, but Capture should remain global shell behavior; copy also sounds like closure. | `IMG_8475`, `IMG_8476`. | Today root without embedded Capture CTA. |
| `AMB-ISSUE-1004` | Today / Time | **New — runtime verified** | `Shape Time` routes to top-level Time; expected behavior is step recommendation drilldown/context, not root tab jump. | Tester notes. | Route proof from Today action to correct recommendation/detail. |
| `AMB-ISSUE-1005` | Today | **New — runtime verified** | `Review context` is a dead/unwanted button. | `IMG_8475`, `IMG_8476`; tester notes. | Button removed or converted into requested inspection-only path. |
| `AMB-ISSUE-1006` | Today / Closure | **New — runtime verified** | `Record outcome` appears when there is no step to close. | `IMG_8475`, `IMG_8476`; tester notes. | No-step Today screenshot without outcome action. |
| `AMB-ISSUE-1007` | Today / Time / Capture | **New — runtime verified** | `Protect this window` routes to top-level Time; expected behavior is a focused protection flow asking how much time to protect. | Tester notes. | Protection flow screenshot from Today context. |
| `AMB-ISSUE-1101` | Capture | **New — runtime verified** | Capture opens as a half-screen bottom sheet; this looks immature and contradicts full-screen composer direction. | `IMG_8477`. | Full-screen Capture screenshots. |
| `AMB-ISSUE-1102` | Capture | **New — runtime verified** | Capture lists input alternatives inside the composer. This is explanatory UI, not a premium input object. | `IMG_8477`. | Composer without visible input-alternative explainer block. |
| `AMB-ISSUE-1103` | Capture | **New — runtime verified** | Capture header exposes `Open Field` and `Today - review before save`. | `IMG_8477`. | Header removed/simplified; screenshot proof. |
| `AMB-ISSUE-1104` | Capture | **New — runtime verified** | Capture chips `Activated`, `Keyboard`, and `Local read` expose internal state. | `IMG_8477`. | Chips removed from primary composer. |
| `AMB-ISSUE-1105` | Capture | **New — runtime verified** | Rounded wording block includes `Capture composer`; the app is talking about itself instead of letting the object work. | `IMG_8477`. | Remove block or replace with direct user input affordance. |
| `AMB-ISSUE-1106` | Capture | **New — runtime verified** | Text field placeholder `Where can this go?` is wrong; current requested temporary placeholder is `Shoot For the Stars`. | `IMG_8477`; tester notes. | Placeholder screenshot. |
| `AMB-ISSUE-1107` | Capture | **New — runtime verified** | Routing classification (`Task`, `Goal`, `Needs a Place`) overtakes the text field and pushes it out of focus. | Tester notes; visible routing block in `IMG_8477`. | Composer state where user input remains dominant after typing. |
| `AMB-ISSUE-1108` | Capture / Language | **New — runtime verified** | Ambitions must not use `Task`; user model is Step / one-step goal. | Tester notes. | String audit and screenshots. |
| `AMB-ISSUE-1109` | Capture / Language | **New — runtime verified** | `Route needs your choice` and `Inspectable route` must be removed from user-facing capture flow. | Tester notes. | Capture routing screenshot + forbidden language scan. |
| `AMB-ISSUE-1301` | Goals | **New P0 — runtime verified** | Goals `+` button crashes. | Tester notes. | Crash log + no-crash device proof. |
| `AMB-ISSUE-1302` | Goals | **New P0 — runtime verified** | Goals is currently unusable and needs full re-spec/rebuild. | `IMG_8479`, `IMG_8480`, `IMG_8491`, `IMG_8498`, `IMG_8499`; tester notes. | New Goals spec, target, implementation, screenshot proof. |
| `AMB-ISSUE-1601` | Search | **New P0 — runtime verified** | Search exists visually but is nowhere near functional; needs re-spec and rebuild. | `IMG_8496`, `IMG_8497`; tester notes. | Search spec + actionable result flow proof. |
| `AMB-ISSUE-1901` | Light mode | **New P0 — runtime verified** | Light mode is fully failed/unusable. | `IMG_8488`–`IMG_8492`. | Light-mode screenshot matrix. |
| `AMB-ISSUE-1902` | Theme / Design system | **New P0 — runtime verified** | App contains hard-coded dark colors; objects remain dark or low-contrast in light mode. | `IMG_8488`–`IMG_8492`; tester notes. | Token audit + light-mode screenshot proof. |

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
| `AMB-ISSUE-1011` | New | Today still lacks a mature full-bleed shell/crown relationship. | `IMG_8475`, `IMG_8476` |

### Capture

| ID | Status | Issue | Evidence |
|---|---|---|---|
| `AMB-ISSUE-0201` | Still present | Capture visual quality is below flagship composer standard. | `IMG_8477` |
| `AMB-ISSUE-0202` | Still present | Capture uses generic/internal routing copy. | `IMG_8477`; notes |
| `AMB-ISSUE-0205` | Still present | Collapsed/focused/expanded/full-screen composer state machine is not proven; current implementation is a cramped bottom sheet. | `IMG_8477` |
| `AMB-ISSUE-1110` | New | The plus/accessory control is visually unclear and competes with mic and routing UI. | `IMG_8477` |
| `AMB-ISSUE-1111` | New | Capture claims keyboard/local state through chips while actual focus/keyboarding remains unclear. | `IMG_8477` |

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
| `AMB-ISSUE-1503` | New | Theme changes do not apply live until app close/reopen. | Tester notes |
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
| `AMB-ISSUE-1701` | New | Dock still has a border/container; target is four floating buttons, no bordered dock. | All root screenshots |
| `AMB-ISSUE-1702` | New | Dock still shows words under icons. Target is icon-only. | All root screenshots |
| `AMB-ISSUE-1703` | New | Active tab is over-indicated with bordered circle, color change, and underline. Target is accent-highlighted icon only. | All root screenshots |
| `AMB-ISSUE-1704` | New | Large root headers remain on Goals, Time, and You. | `IMG_8479`, `IMG_8481`, `IMG_8483` |
| `AMB-ISSUE-1705` | New | User should not see internal object names in headers (`Constellation Atlas`, `LifeShape Field`, `Profile and settings`). | Goals/Time/You screenshots |
| `AMB-ISSUE-1706` | New | Dock and header do not obey full-screen bleed; safe areas feel massive. | All screenshots |
| `AMB-ISSUE-1707` | New | Header buttons remain large ambiguous circular controls. | Goals/Time/You screenshots |
| `AMB-ISSUE-1708` | New | Today has no mature shell/header/crown treatment while other roots have large headers; shell rhythm is inconsistent. | `IMG_8475`, `IMG_8476` |
| `AMB-ISSUE-1709` | New | The app lacks mature full-screen drilldowns; most non-root flows are slide-up cards. | Tester notes; Closure/Capture/Search screenshots |

### Light mode / appearance

| ID | Status | Issue | Evidence |
|---|---|---|---|
| `AMB-ISSUE-1903` | New | Appearance Studio remains dark/illegible even after selecting Light. | `IMG_8488` |
| `AMB-ISSUE-1904` | New | Light-mode dock is a low-contrast grey pill and does not preserve flagship polish. | `IMG_8489`–`IMG_8492` |
| `AMB-ISSUE-1905` | New | Light-mode Today appears dimmed/washed out and unusable. | `IMG_8492` |
| `AMB-ISSUE-1906` | New | Light-mode Goals and Time retain dark-object assumptions and low-contrast treatment. | `IMG_8490`, `IMG_8491` |

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

1. **P0 Light mode / theme token purge.** No hard-coded dark objects; live theme propagation.
2. **P0 Capture full-screen composer rebuild.** Full-screen, no internal chips/copy, working mic/fallback, stable field dominance.
3. **P0 Goals respec/rebuild and `+` crash fix.** Do not patch the current object; rebuild it.
4. **P0 Shell full-bleed chrome rebuild.** Four floating icon-only dock buttons; no bordered dock; no root internal object names.
5. **P0 Today action cleanup.** Remove no-op toggles, internal rail copy, unwanted CTAs; gate Record Outcome by actual step presence.
6. **P0 Search respec/rebuild.** Do not polish current search sheet.
7. **P1 Time second pass.** Remove fake `Place Step`, clarify dots/Now/bars, make actions require real user state.
8. **P1 You polish.** Remove dividers/glow, make settings actionable, fix live theme update.
9. **P1 Full-screen drilldown architecture.** Replace shallow slide-up cards where a real drilldown is required.
10. **QA proof pass.** Build, device screenshots, UI tests, accessibility proof, and visual regression.
