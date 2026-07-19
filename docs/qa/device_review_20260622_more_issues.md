# Runtime Device Review — 2026-06-22 — More Issues

**Review status:** Red  
**Input:** tester notes plus screenshot set `IMG_8475.PNG` through `IMG_8499.PNG` from `More issues.zip`.  
**Scope:** Today, Capture, Closure, Goals, Time, You, Search, Shell, Light Mode, general interaction depth.  
**Validation not run:** build, simulator, UI automation, crash symbolication, VoiceOver, Dynamic Type, Reduce Motion, Reduce Transparency, real-device performance profiling.

## Executive verdict

The current build is not failing because of isolated polish. It is failing because most root surfaces still do not present mature product objects, and several core flows remain shallow, confusing, or broken. Source architecture has improved since the previous report, and Time is clearly moving in the right direction, but the device-visible product still reads like an alpha prototype.

Current severity by area:

| Area | Verdict | Reason |
|---|---|---|
| Today | Red | Wrong controls, confusing rail copy, misleading CTA stack, broken action routing, random timeline icons. |
| Capture | Red | Half-screen sheet, internal chips/copy, dead mic, wrong placeholder, routing UI overtakes field. |
| Closure | Yellow | Looks acceptable for v1, but access is incorrectly offered with no step and mutation proof is missing. |
| Goals | Red | `+` crashes, object is nonsensical, internal copy dominates, unusable. Needs rebuild. |
| Time | Yellow/Red | Much improved, but object still does not explain itself and can fake-place a step. |
| You | Yellow | Visually improved, but dividers/glow/settings gaps/theme propagation remain. |
| Search | Red | Exists visually but is not useful. Needs rebuild. |
| Shell | Red | Dock/header/safe-area/full-bleed behavior still below flagship level. |
| Light mode | Red | Unusable; hard-coded dark colors and low contrast. |
| Accessibility | Unverified / Red for release | Not tested; no readiness claim possible. |

## What improved

- Today appears to show real current time now.
- Motion is no longer visible as a root dock destination.
- Capture is not a root dock destination.
- Root dock hides on drilldowns according to tester notes.
- Closure sheet is directionally acceptable for v1.
- Time is significantly better than the previous card/report implementation.
- You is directionally better than the previous settings wall.

These improvements do not make the build Green. They mostly move some prior Red defects into Candidate Resolved or Yellow while exposing the next-order problems.

---

# Surface findings

## Today

Evidence: `IMG_8475`, `IMG_8476`, `IMG_8492`.

### Findings

1. `Start Here` and `Meridian` are presented as a segmented toggle at the top of Today. The screenshots show no meaningful product difference between the two states. This adds cognitive load and makes Today feel like a mode panel instead of a direct current-life surface.
2. The rail copy `No source change yet` and `All from work context` is not meaningful to an end user. It exposes unexplained system state and should be removed from primary Today.
3. The CTA stack still makes Today feel like a menu. Today should not need five central buttons to be understandable.
4. `Capture what changed` is wrongly embedded inside Today. Capture belongs globally in shell/composer behavior. The copy also sounds like closure rather than capture.
5. `Shape Time` routes to top-level Time. From Today, it should preserve context and route into the relevant step recommendation/detail or a specific shaping flow.
6. `Review context` is a dead/unwanted button.
7. `Record outcome` appears even though there is no current step to close. This is a state-gating failure.
8. `Protect this window` routes to top-level Time instead of a focused protection flow asking how much time to protect.
9. The active dot beside the current/no-step state is slightly misaligned with the timeline rail.
10. Current time is improved, but `Live now` beneath it is redundant and should be removed.
11. Random icons remain on the rail without visible semantic attachment.
12. Today still lacks a mature full-bleed relationship to shell/crown/dock. It is a rail plus menu, not a flagship Reality Meridian.
13. In light mode (`IMG_8492`), Today is washed out/dim and effectively unusable.

### Product consequence

Today still does not prove `Reality Meridian + Start Here`. It shows live time now, but the main object is still contaminated by unexplained controls, internal copy, and menu-style buttons.

---

## Capture

Evidence: `IMG_8477`.

### Findings

1. Capture opens as a half-screen bottom sheet. This is not acceptable for the global composer. It looks cramped and immature.
2. The half-screen layout becomes worse once routing/category UI appears; the text field loses dominance.
3. Header copy `Open Field` and `Today - review before save` should not appear. The composer should be self-evident.
4. Chips `Activated`, `Keyboard`, and `Local read` expose internal/system state.
5. A rounded explanatory block includes `Capture composer`; this is implementation-language presentation, not product behavior.
6. The round wording block itself should be removed. It tells the user what the system is rather than giving them a premium input experience.
7. The mic button in the text field is dead.
8. Placeholder `Where can this go?` is wrong. Temporary requested placeholder is `Shoot For the Stars`.
9. Routing categorization (`Task`, `Goal`, `Needs a Place`) overtakes the text field and jumps the field upward.
10. Ambitions should not use `Task`. The user model is Step / one-step goal.
11. `Route needs your choice` and `Inspectable route` need removal. The app should stop narrating routing internals.
12. The plus/accessory button competes with mic and field affordance.
13. The sheet says keyboard/local state but the screenshot does not prove a coherent keyboard choreography.
14. Capture is not yet a flagship full-screen composer and should be treated as a P0 rebuild, not polish.

### Product consequence

Capture is supposed to be the Open Field / Atmosphere Composer. Current Capture is still a small command sheet with internal diagnostics and a broken mic. It blocks trust in Ambitions’ primary input path.

---

## Closure

Evidence: `IMG_8478`, `IMG_8493`, `IMG_8494`, `IMG_8495`.

### Findings

1. Closure visual direction is good enough for v1.
2. The default choices are clearer than the prior review.
3. The advanced section is acceptable as long as default closure stays fast.
4. However, Today offered `Record outcome` when there was no step. The defect is upstream gating, not the closure surface itself.
5. Closure still needs before/action/after proof that saving visibly mutates Today.
6. Closure still appears as a slide-up card/sheet, which may be acceptable for v1 closure, but it should not become the pattern for all drilldowns.

### Product consequence

Closure can be left as Yellow for now. Do not spend the next train rebuilding it before Goals/Capture/Light Mode/Shell unless mutation proof fails.

---

## Goals

Evidence: `IMG_8479`, `IMG_8480`, `IMG_8491`, `IMG_8498`, `IMG_8499`.

### Findings

1. The `+` button crashes. This is a P0 blocker.
2. The new-message/icon action opens Capture. If this remains, it needs clearer shell-level ownership; it currently contributes to action ambiguity.
3. Goals object makes no sense as a user-facing product object.
4. The object talks at the user with explanatory copy instead of showing an understandable relationship map.
5. It has the same failure pattern Time had before its object recreation: root card/report structure, internal labels, source/proof/context rows, and no clear direct manipulation.
6. Header exposes `GOALS · Constellation Atlas`. The user should not see internal object nomenclature in the root header.
7. Life areas are static tiles with repeated `Today`; no clear meaning or manipulation.
8. The `Your Direction` object is a bordered card/report, not a Constellation Atlas.
9. `Thread Focus` is diagnostic UI. It lists selected area, active thread, recommended step, feeds Today, proof available, context, why-this, quiet. This is not a goal interaction.
10. `No active thread yet` appears while many thread/focus rows are shown. This is contradictory.
11. Source/proof/context/why-this language dominates root Goals.
12. Bottom `Create your first goal` CTA plus floating `+` duplicates creation affordance.
13. Goals is not reviewable as a finished implementation. It needs a respec and rebuild.

### Product consequence

Goals is the reddest area of the app. Do not patch around the current object. It needs a new product-object spec and implementation train.

---

## Time

Evidence: `IMG_8481`, `IMG_8482`, `IMG_8490`.

### Findings

1. Time is much better than before.
2. It is still not usable.
3. The object still does not explain what the dots mean.
4. The central line says `NOW`, but the relationship between now, bars, dots, fixed points, pressure, buffer, recovery, and recommended action remains unclear.
5. `Place Step` appears despite no real user-created step or goal. Clicking it says a step was placed. This is fake-action behavior and must be blocked.
6. `Open / Protected / Pressure / Buffer` segmented controls are not self-explanatory.
7. `NEXT FIXED POINT No fixed blocks yet` does not make the object more useful.
8. Time still exposes internal object name in the header: `TIME · LifeShape Field`.
9. Rows beneath the object (`Today`, `This week`, `Rest of month`) still feel like card/list fallback below the supposed primary object.
10. Light mode Time is low-contrast and visibly unstable.

### Product consequence

Time is on its way but remains alpha. The next pass should not invent more layers; it should make the existing object readable and prevent fake mutations.

---

## You

Evidence: `IMG_8483`, `IMG_8484`, `IMG_8485`, `IMG_8486`, `IMG_8487`, `IMG_8488`, `IMG_8489`, `IMG_8496`.

### Findings

1. You is looking better.
2. Divider lines between every row make the surface feel table-like and less premium.
3. There is a weird shadow/glow at the bottom of the container/border.
4. Many settings do not have options.
5. Changing theme does not update the view until closing and reopening the app.
6. Many surfaces/objects retain hard-coded dark colors in light mode.
7. Root header exposes `YOU · Profile and settings` and `Your System`; this remains system-facing.
8. `How Ambitions works for me` is still explanatory root copy.
9. Rows still rely on status labels such as Guided, Stored on this device, Not requested, Ready, Not currently connected.
10. Appearance Studio is especially broken in light mode: the selected Light state does not produce a light/polished detail surface.

### Product consequence

You is salvageable. It needs a disciplined native-settings polish pass, live theme propagation, token cleanup, row divider removal, and actual option surfaces.

---

## Search

Evidence: `IMG_8496`, `IMG_8497`.

### Findings

1. Search exists in concept only.
2. It is not near functional.
3. It appears as a shallow sheet/card overlay rather than a mature global search experience.
4. Result cards are abstract: `External entries return to owning surfaces`, `Text`, `This week is the shaping surface`.
5. Results expose internal labels like `Handoff`, `Global Capture`, `Week`, `owning surfaces`, `current recall`, and similar system terms.
6. The search field plus small separate Search button is low-quality and non-native feeling.
7. Search does not prove indexing, scope, useful routing, result actionability, or privacy boundaries.
8. Search should be re-spec'd and rebuilt completely.

### Product consequence

Search should not be polished in place. It needs a new shell-scoped interaction spec and rebuilt result model.

---

## Shell

Evidence: all root screenshots.

### Findings

1. Root dock hides on drilldowns. Good.
2. Dock still has a bordered/container shape. Desired direction: four floating buttons, no bordered dock.
3. Dock still includes words. Desired direction: icon-only.
4. Active tab uses too many indicators: bordered circle, color change, and underline. Desired direction: highlighted accent icon only.
5. Today has no mature header/crown treatment, while other top-level surfaces still have large headers.
6. Goals/Time/You top-level headers are too large and expose internal names.
7. User should not see `GOALS` / `Constellation Atlas` in the header.
8. User should not see `TIME` / `LifeShape Field` in the header.
9. User should not see `YOU` / `Profile and settings` in the header.
10. Dock and header do not obey full-screen bleed.
11. Safe areas are massive. The app should only respect true iOS status/gesture areas, not create large artificial padding shelves.
12. Header buttons remain large, ambiguous, circular controls.
13. Drilldowns are largely missing; the app often uses slide-up cards instead of full-screen depth. Only You appears to have real full-screen detail screens in this review.

### Product consequence

The shell still tells the user this is a prototype. Root dock and crown/header must be redesigned as a full-bleed stage system.

---

## Light mode

Evidence: `IMG_8488`, `IMG_8489`, `IMG_8490`, `IMG_8491`, `IMG_8492`.

### Findings

1. Light mode is fully failed and not usable.
2. Appearance Studio remains dark even when Light is selected.
3. Today in light mode is washed out/dimmed and unreadable as a primary surface.
4. Time in light mode is low-contrast and not flagship quality.
5. Goals in light mode preserves the weak object model and exposes dark/card assumptions.
6. Dock in light mode becomes a giant grey low-contrast pill.
7. Hard-coded dark colors are present across objects and surfaces.
8. Theme changes do not live-update correctly.

### Product consequence

Light mode is a P0 design-system/token bug, not a polish issue.

---

## Accessibility

Accessibility was not tested. No accessibility readiness claim is allowed. The current app should not move toward release until normal interaction stabilizes, but implementation work must still preserve semantic mirrors, VoiceOver actions, Dynamic Type behavior, Reduce Motion, Reduce Transparency, and High Contrast support from the beginning of each rebuild.

---

# Screenshot-by-screenshot evidence log

| Screenshot | Findings |
|---|---|
| `IMG_8475` | Today root. No-op Start Here/Meridian control, internal rail copy, CTA stack, random rail icons, bordered dock with labels. |
| `IMG_8476` | Today Meridian state. Toggle changes selection only; product object does not meaningfully change. |
| `IMG_8477` | Capture bottom sheet. Half-screen, internal header/chips, input-alternative explanation, dead mic, routing copy, text field buried. |
| `IMG_8478` | Closure top. Directionally acceptable; issue is that Today can launch it without a step. |
| `IMG_8479` | Goals root. Header exposes Constellation Atlas; object is explanatory and card-like. |
| `IMG_8480` | Goals lower. Thread Focus is diagnostic console; duplicate create affordance; source/proof/context rows. |
| `IMG_8481` | Time root. Better than before but unclear dots/bars/Now line; Place Step appears without real step context. |
| `IMG_8482` | Time lower. Rows under object still feel like list/card fallback. |
| `IMG_8483` | You root. Better, but system-facing header/copy, dividers, status-heavy rows, bottom glow. |
| `IMG_8484` | You rows. Dividers and status labels dominate; many rows appear non-actionable. |
| `IMG_8485` | You rows. Capture/Session/Appearance/Privacy statuses; row density and dividers remain. |
| `IMG_8486` | You rows. Receipts/Sources/Local data/Export rows are mostly status wrappers. |
| `IMG_8487` | You lower. Help/About rows; local/status posture dominates. |
| `IMG_8488` | Appearance detail in Light mode. Detail remains dark and illegible. Theme change not reflected correctly. |
| `IMG_8489` | You light mode. Low contrast, huge grey dock, hard-coded tone problems. |
| `IMG_8490` | Time light mode. Low-contrast object and dock; light mode not mature. |
| `IMG_8491` | Goals light mode. Object model still weak and header still exposes internal name. |
| `IMG_8492` | Today light mode. Washed/dimmed content; unusable. |
| `IMG_8493` | Closure. Default options clearer; still needs mutation proof. |
| `IMG_8494` | Closure advanced. More options acceptable if default remains fast. |
| `IMG_8495` | Closure receipt/review. V1 acceptable; still needs Today mutation proof. |
| `IMG_8496` | Search over You. Search sheet is shallow and results are abstract. |
| `IMG_8497` | Search full view. Result rows expose internal labels and are not useful. |
| `IMG_8498` | Goals expanded Thread Focus. Diagnostic/internal rows dominate; root object is not user-facing. |
| `IMG_8499` | Goals lower. CTA/floating plus duplication; source/proof/why-this/root diagnostic language. |

---

# Required next trains

## P0 — Unblock product usefulness

1. Light mode/token purge.
2. Capture full-screen composer rebuild and mic/permission repair.
3. Goals respec/rebuild and `+` crash fix.
4. Shell full-bleed dock/header rebuild.
5. Today action cleanup and state gating.
6. Search respec/rebuild.
7. Time fake-mutation guard (`Place Step` cannot succeed without a real Step/Goal context).

## P1 — Make improved areas actually mature

1. Time semantic clarity pass: dots, Now line, bars, fixed points, pressure/buffer/recovery.
2. You native settings polish: remove dividers/glow, make rows actionable, live theme update.
3. Drilldown architecture: replace slide-up card depth with mature full-screen detail where appropriate.
4. Copy/language audit across all root surfaces.
5. Visual regression and screenshot matrix.

## P2 — Accessibility proof after interaction stabilization

1. VoiceOver transcripts.
2. Dynamic Type screenshots.
3. Reduce Motion and Reduce Transparency proof.
4. High Contrast / Differentiate Without Color proof.
5. Haptic behavior proof.

---

# Release posture

This build remains **Red**. It is improved enough to identify the next correct rebuild targets, but not improved enough to be considered a coherent dogfoodable product surface.
