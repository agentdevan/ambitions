# UIQL-013.5 / AMB-970 Red-Team Visual Audit

Status: Initial Red; repaired locally after follow-up AMB-970 patch
Linear issue: AMB-970
Program: UIQL
Branch: `main`
Audit mode: initial read-only audit; follow-up repair proof appended after owner-directed continuation
Push status: not pushed by Codex; owner will push local commits manually after GitHub is fixed.

## Verdict

Overall recommendation: Initial audit blocked UIQL-014. Follow-up local repair proof removes the AMB-970 product Red blockers at the local worktree and allows AMB-969 to start locally after commit, but pushed-main and Linear Done status remain pending until the owner manually pushes and verifies main.

The original AMB-970 audit could not recommend the final owner approval package while the then-current screenshot board still had product Red accessibility-variant findings. The strongest blockers were dock legibility failures at large Dynamic Type, incomplete root-level accessibility proof for You, and Create Goal remaining visually close to a modal form flow.

## Repair Addendum - 2026-06-12

Owner feedback after the initial audit identified that the shell safe-area/header reserve was too large and screens were not using the full display. The follow-up repair stayed inside AMB-970/UIQL scope and changed shell proof behavior only where needed:

- Removed the accessibility-size horizontal dock scroll and compacted the Meridian dock so Today / Goals / Time / Motion / You remain visible at rest.
- Reduced root shell dock clearance and the root header top reserve so surfaces use more vertical space.
- Added an opaque root header backing so scrolled content does not bleed through or collide with shell chrome.
- Reduced Time and Motion bottom spacers that were creating excess unused space.
- Corrected Motion dock-clearance proof targeting so the screenshot frames the actual continuity controls above the dock.
- Re-captured You large Dynamic Type as the You root surface.
- Reframed Create Goal around first-path object preview and removed the large Dynamic Type top striping.

Current repaired proof inspected:

- `artifacts/ui-quality-lockdown/script-output/AMB-970-time-header-tight-rerun5.log` - passed 2 UI tests, 0 failures.
- `artifacts/ui-quality-lockdown/screenshots/amb-970/time-header-rerun5/CB59AED4-22DB-4E93-B887-3F223EA88152.png` - Time default proof visually inspected.
- `artifacts/ui-quality-lockdown/screenshots/amb-970/time-header-rerun5/A442D8F2-DE41-448F-B0A7-CFFC534899CE.png` - Time large Dynamic Type proof visually inspected.
- `artifacts/ui-quality-lockdown/script-output/AMB-970-shell-tight-broader-rerun6.log` - passed 3 UI tests, 0 failures.
- `artifacts/ui-quality-lockdown/screenshots/amb-970/shell-tight-rerun6/E0045DD3-85C4-447C-A28A-E88DF369015D.png` - Motion large Dynamic Type proof visually inspected.
- `artifacts/ui-quality-lockdown/screenshots/amb-970/shell-tight-rerun6/3986520D-2B61-4771-9109-998BC177E712.png` - You root large Dynamic Type proof visually inspected.
- `artifacts/ui-quality-lockdown/screenshots/amb-970/shell-tight-rerun6/2F2E829E-AB0E-4408-BFB8-D8E0709DA6C7.png` - Create Goal large Dynamic Type proof visually inspected.
- `artifacts/ui-quality-lockdown/script-output/AMB-970-motion-dock-target-rerun7.log` - passed 1 UI test, 0 failures.
- `artifacts/ui-quality-lockdown/screenshots/amb-970/motion-dock-target-rerun7/262C57E9-4947-4E93-A2C6-8C943A4DC8BD.png` - Motion continuity controls above dock visually inspected.

Repair verdict: AMB-970 product Red blockers are locally repaired for the scoped UIQL evidence board. AMB-969 may proceed locally after this repair is committed. Do not mark AMB-970 Linear Done or claim pushed-main evidence until the owner manually pushes and verifies main.

This audit does not claim owner approval, release readiness, TestFlight readiness, App Store readiness, public accessibility certification, physical-device proof, or production readiness.

## Authority Inspected

- Linear AMB-970 issue: `UIQL-013.5 - Independent Red-Team Visual Audit`
- Linear document: `UIQL Visual North Star Contract`
- Linear document: `UIQL Screenshot Scorecard`
- Linear document: `UIQL Primitive Freeze Policy`
- Linear document: `UIQL Delete-Over-Wrapper Policy`
- Linear document: `UIQL Final Red-Team Protocol`
- Linear document: `UIQL Global Run Contract`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `artifacts/ui-quality-lockdown/UIQL-013-accessibility-variant-proof.md`
- AMB-959 through AMB-968 closeout artifacts in `artifacts/ui-quality-lockdown/`
- Current screenshots under `artifacts/ui-quality-lockdown/screenshots/`

## Red-Team Closeout Block

```text
Red-Team Audit

- Overall recommendation: Block UIQL-014
- Today: Red
- Goals: Yellow
- Time: Red
- Motion: Red
- You: Red
- Capture: Candidate Green
- Create Goal: Red
- Shell/dock: Red
- Copy/canon: Green
- Accessibility variants: Red
- Remaining Red blockers:
  - Large Dynamic Type dock does not show all five tabs at rest in Today, Time, and Motion proof.
  - Large Dynamic Type Time and Motion primary/secondary actions fall into the bottom fade/dock area.
  - You large Dynamic Type proof is a Personal Runtime detail sheet, not the You root surface.
  - Create Goal still reads too close to a generic modal form flow and has suspicious top background striping in large Dynamic Type.
- Owner approval claimed: no
```

## Per-Surface Scorecard

| Surface / Flow | Score | Verdict | Screenshot paths inspected | Red blockers | Yellow limitations |
| --- | ---: | --- | --- | --- | --- |
| Today | 84 | Red | `artifacts/ui-quality-lockdown/screenshots/amb-968/today-rerun2/833E2EEB-6810-4D0A-AF26-3710AB9CD83F.png`; `artifacts/ui-quality-lockdown/screenshots/amb-968/today-rerun2/3B3E33A1-8AE6-4243-B823-640AFECAD502.png`; `artifacts/ui-quality-lockdown/screenshots/amb-968/today-rerun2/F621E1A8-8719-452C-8BED-5CBFC23F6F28.png` | Large Dynamic Type dock shows only Today / Goals / Time, so all five tabs are not identifiable at rest. Secondary `Why this?` / `Move this` controls are visually submerged in the bottom fade. | Default Today is substantially improved and object-owned, but Candidate Green is blocked by the variant dock Red. |
| Goals | 88 | Yellow | `artifacts/ui-quality-lockdown/screenshots/amb-963/rerun11/amb-963-goals-default.png`; `artifacts/ui-quality-lockdown/screenshots/amb-963/rerun11/amb-963-goals-selected-life-area.png`; `artifacts/ui-quality-lockdown/screenshots/amb-963/rerun11/amb-963-goals-proof-source-visible.png`; `artifacts/ui-quality-lockdown/screenshots/amb-963/rerun11/amb-963-goals-large-dynamic-type.png` | none fatal after inspection | Life-area boxes still risk category-card read, and the proof/source object is pushed low/dim in the default screenshot. Score is under the 90 Candidate Green threshold. |
| Time | 80 | Red | `artifacts/ui-quality-lockdown/screenshots/amb-968/time-rerun2/C816021A-9066-48C4-BF8F-9B55086ED0AF.png`; `artifacts/ui-quality-lockdown/screenshots/amb-968/time-rerun2/6BFE25E4-34D2-4A62-92C2-50A8B3D6C1D6.png`; `artifacts/ui-quality-lockdown/screenshots/amb-968/time-rerun2/97B557FC-7415-4D47-BCA0-925416E7C870.png` | Large Dynamic Type dock shows only Today / Goals / Time; Motion / You are not identifiable at rest. Large Dynamic Type action rows are faded under the dock area. | Default Time object is clearer than prior versions, but accessibility-size first viewport cannot pass the dock/action legibility gate. |
| Motion | 82 | Red | `artifacts/ui-quality-lockdown/screenshots/amb-965/rerun5/3175465E-AA84-4498-9F9B-58B3A804E28F.png`; `artifacts/ui-quality-lockdown/screenshots/amb-965/rerun5/9C90891D-10E0-4F38-A68B-6D70D907D5F8.png`; `artifacts/ui-quality-lockdown/screenshots/amb-965/rerun5/F22BFC38-FFAE-4C1A-AC08-F39CC850F5BF.png` | Large Dynamic Type dock shows only Today / Goals / Time; selected Motion is not visible at rest. `Re-enter thread` and lower source/proof content fade into the bottom area. | Default Motion is product-specific and avoids dashboard/score/streak language, but the large-text variant is a dock Red. |
| You | 84 | Red | `artifacts/ui-quality-lockdown/screenshots/amb-966/rerun12/F13E5529-DCE6-4EE3-9A64-3EBB36407610.png`; `artifacts/ui-quality-lockdown/screenshots/amb-966/rerun12/102FE7B1-3A72-4CBC-BB72-7023C4185204.png`; `artifacts/ui-quality-lockdown/screenshots/amb-966/rerun12/815ABB73-018A-42D1-AC84-3CAA98F8AE4A.png` | Required root-level large Dynamic Type proof is not present in the inspected board; the large Dynamic Type image is a Personal Runtime detail sheet. | Default root reads as User System Profile rather than generic settings, but Candidate Green needs root-level variant proof. |
| Capture | 91 | Candidate Green | `artifacts/ui-quality-lockdown/screenshots/amb-967/rerun9/53B1D787-D4EA-4F34-BDE9-0269437749D3.png`; `artifacts/ui-quality-lockdown/screenshots/amb-967/rerun9/E339CA2B-CAB7-4FBE-9D27-DC350DC4D996.png`; `artifacts/ui-quality-lockdown/screenshots/amb-967/rerun9/81ECB722-297A-4872-A57D-2F68D9FBEC7A.png` | none observed | Still needs manual VoiceOver traversal and device proof before any public accessibility claim. |
| Create Goal | 78 | Red | `artifacts/ui-quality-lockdown/screenshots/amb-967/rerun9/C9DF3963-F0E3-4052-B76E-9F155FDBC1C5.png`; `artifacts/ui-quality-lockdown/screenshots/amb-967/rerun9/968D64E9-24BF-4CA1-84C2-8FEAAB2DF3E9.png`; `artifacts/ui-quality-lockdown/screenshots/amb-967/rerun9/2D390290-E516-4049-B80F-722D0CE5487B.png` | The default still reads close to a generic modal form flow: title, descriptive text, input, route selector, submit button. Large Dynamic Type has suspicious horizontal striping behind the top area and does not show the primary create action in the first viewport. | Copy is improved and no AI/spec terms were observed in inspected screenshots. |
| Shell / dock | 75 | Red | AMB-959 final labels set plus root screenshots listed above | Dock is legible in default-size screenshots but fails the all-five-tabs-at-rest requirement in several large Dynamic Type variants. | Shell safe area is mostly improved at default size; no current physical device proof. |

## Top Remaining Visual Defects

1. Large Dynamic Type dock truncates to three tabs on Today, Time, and Motion evidence.
2. Large Dynamic Type Time action rows are visibly submerged under the bottom fade/dock area.
3. Large Dynamic Type Motion hides the selected Motion tab at rest and fades lower action/source content.
4. Today large Dynamic Type keeps `Start now` readable, but secondary trust/reflow controls are effectively hidden in the fade.
5. You root lacks a root-level large Dynamic Type proof screenshot; the inspected large-text proof is a detail sheet.
6. Create Goal still reads too close to a form modal and remains below the object-creation visual standard.
7. Create Goal large Dynamic Type screenshot shows suspicious top background striping.
8. Goals still carries some category-card risk in the life-area row and scores below 90.
9. Default Goals proof/source object is pushed low and dim enough that the first viewport does not fully sell the proof path.
10. Several accessibility variants rely on source/static fallback descriptions rather than direct screenshots for each surface.

## Top Copy Defects

No user-visible banned copy was found in the inspected screenshots. The AMB-970 supporting scan logs report no changed-source blockers for banned UIQL copy. Repo-wide historical/test references remain classification-only and are not active UI proof.

Potential copy-quality risks:

1. Create Goal phrase `Let Ambitions shape it` is understandable but still close to generic product-assist language.
2. Goals phrase `Life areas, proof, source, and Today connection stay in one direction object` is precise but somewhat internal.
3. Time large Dynamic Type `Source proof.` is compact and no longer clipped, but it is a compromise phrase rather than a strong user-facing explanation.

## Top Accessibility / Variant Defects

1. Today large Dynamic Type dock does not show all five tabs.
2. Time large Dynamic Type dock does not show all five tabs.
3. Motion large Dynamic Type dock does not show all five tabs and omits the selected tab.
4. Time large Dynamic Type action rows are below the usable first viewport.
5. Motion large Dynamic Type lower proof/source affordances are below the usable first viewport.
6. You root large Dynamic Type proof is absent.
7. Live VoiceOver traversal was not executed.
8. Physical-device proof was not executed.
9. Manual all-surface Reduce Transparency walkthrough was not executed.
10. Public accessibility certification is not claimed.

## Primitive / Slop Regression Verdict

Primitive policy: Green for AMB-970 because no new source changes or primitives were introduced in this read-only audit.

Delete-over-wrapper verdict: Red remains for Create Goal visual read because the current flow still leans on modal form anatomy. It is not a rename-only card stack anymore, but it has not reached the object-creation standard.

## UIQL-014 Proceed / Block Decision

UIQL-014 must not proceed yet.

Required blockers before UIQL-014:

1. Repair dock legibility at large Dynamic Type so all five tabs remain identifiable at rest or provide an explicitly approved accessible alternative that satisfies the shell contract.
2. Keep primary and secondary surface actions out of the bottom fade/dock area at large Dynamic Type.
3. Produce root-level You large Dynamic Type proof.
4. Rework or re-prove Create Goal so the first viewport reads as object creation with first-path preview, not a generic form modal.
5. Re-run the relevant screenshot matrices and visually score the repaired evidence.

## Validation

- `git branch --show-current` - `main`.
- `git status --short --branch` - clean except generated UIQL scan logs after AMB-970 read-only scans.
- `git pull --ff-only` - already up to date.
- `bash scripts/codex/program-preflight.sh uiql` - Green at local head `61b036a87`.
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-scan-banned-copy.sh` - exit 0; changed-scope scan generated `artifacts/ui-quality-lockdown/script-output/uiql-banned-copy.log`.
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-scan-card-anatomy.sh` - exit 0; changed-scope scan generated `artifacts/ui-quality-lockdown/script-output/uiql-card-anatomy.log`.
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-scan-shell.sh` - exit 0; changed-scope scan generated `artifacts/ui-quality-lockdown/script-output/uiql-shell.log`.

## No-Claim Boundary

This audit does not claim:

- owner approval
- release readiness
- TestFlight readiness
- App Store readiness
- production readiness
- public accessibility certification
- live VoiceOver traversal proof
- physical-device proof
- performance proof
- legal/privacy approval
- CI proof
- AMB-969 completion

## Follow-Up Shell Safe-Area Repair Addendum

Status: local AMB-970 repair follow-up after owner feedback

Owner feedback: the shell header safe-area band still made the active surfaces feel too low and underused the screen.

Repair:

- `Native/Ambitions/App/AppShellView.swift` compacts root-only shell header top and bottom padding.
- Pushed-screen back-button header clearance remains unchanged.
- Meridian dock visual labels and minimum tap targets remain unchanged.
- No product runtime, dependency, project, or release behavior is claimed beyond the shell-header geometry repair.

Validation:

- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -resultBundlePath artifacts/ui-quality-lockdown/script-output/AMB-970-shell-header-compact-rerun8.xcresult -only-testing:AmbitionsUITests/AmbitionsUITests/testUIQL002ShellGeometryKeepsChromeInsideSafeAreasAndDockHittable -only-testing:AmbitionsUITests/AmbitionsUITests/testAMB964TimeReconstructionScreenshotMatrix`
- Result: passed, 2 tests, 0 failures.
- Log: `artifacts/ui-quality-lockdown/script-output/AMB-970-shell-header-compact-rerun8.log`
- Exported screenshots: `artifacts/ui-quality-lockdown/screenshots/amb-970/shell-header-compact-rerun8/`

Visual inspection:

- Default Time now begins materially higher under a compact root rail.
- The dock remains readable with all five tabs visible at rest.
- Large Dynamic Type Time keeps dock labels visible; the captured large screenshot is intentionally scrolled to the capacity proof by the test.

Remaining boundaries:

- No live VoiceOver traversal proof.
- No physical-device proof.
- No public accessibility certification.
- No owner approval.
- No release, TestFlight, or App Store readiness.
- No AMB-969 completion.
