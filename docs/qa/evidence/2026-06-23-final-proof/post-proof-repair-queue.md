# Post-Proof Repair Queue

Status: AMB-1200 proposed next repair queue after AMB-1199.  
Source: final-proof packet, `docs/qa/KNOWN_ISSUES.md`, Linear search, and remediation dossiers.  
Rule: do not create duplicate Linear issues where matching parents or `AMB-ISSUE-*` tickets already exist.

The queue below is implementation guidance for later bounded trains. AMB-1200 does not implement any of these app fixes.

## P0 Visual / Shell Proof Repair

Scope: repair and prove shell geometry, route-depth policy, and proof manifests after AMB-1199 showed dock/content overlap and the global shell completion gate remained Red.

Blocked issue IDs: `AMB-ISSUE-0014`, `AMB-ISSUE-0806`, `AMB-ISSUE-1011`, `AMB-ISSUE-1701`-`1709`; Linear parents `AMB-1185`, `AMB-1194`.

Evidence source: `screenshot-index.md`, `route-depth-matrix.md`, `boundary-scan-results.md`, AMB-1199 manifest, current dark root screenshots.

Required proof: Goals/Time/You dock/content non-overlap screenshots, root and drilldown screenshots for Today/Goals/Time/You/Capture/Search, route-depth safe-area audit, back/dismiss proof, updated shell completion manifest, and rerun of `python3 scripts/ambitions-global-shell-completion-gate.py`.

Red if criteria: any root content remains hidden behind dock; any root/drilldown/overlay manifest marker stays `not_started`, `missing_evidence`, or `false`; Capture/Search route-depth proof remains absent.

Suggested Linear issue strategy: use existing `AMB-1185` / `AMB-1194` and issue leaves such as `AMB-ISSUE-0806`, `1706`, `1709`; do not create a duplicate shell parent.

Implementation/review: Codex-implemented for source/script/manifest repair, owner-reviewed for visual acceptance and device proof.

## P0 Goals Visual Repair

Scope: repair Goals root text fit and prove Goals root, Area Detail, Goal Detail, and creation paths.

Blocked issue IDs: `AMB-ISSUE-0401`-`0406`, `AMB-ISSUE-1301`-`1309`; Linear parents `AMB-1184`, `AMB-1193`.

Evidence source: AMB-1199 Goals root screenshot, `screenshot-index.md`, `route-depth-matrix.md`, known-issues Goals rows.

Required proof: clipped/split Quiet text fixed, Goals root visual proof, Area Detail screenshot/video, Goal Detail screenshot/video, device no-crash proof for creation if still missing, route-depth/back proof, Dynamic Type text-fit proof.

Red if criteria: any visible text splits/clips in default content size, dock overlaps Goals content, Goals `+` lacks device no-crash proof, Area/Goal Detail proof remains absent.

Suggested Linear issue strategy: continue under `AMB-1184` / `AMB-1193` and existing `AMB-ISSUE-1301`, `1302`, `0401`, `0405`; no duplicate Goals parent.

Implementation/review: Codex-implemented for source repair, owner-reviewed for visual and device acceptance.

## P0 Capture Proof Repair

Scope: produce deterministic Capture proof and repair any composer defects found during proof.

Blocked issue IDs: `AMB-ISSUE-0003`, `0008`, `0012`, `0201`-`0205`, `1101`-`1111`; Linear parents `AMB-1183`, `AMB-1192`.

Evidence source: AMB-1199 broad UI proof AX timeout, `screenshot-index.md`, known-issues Capture rows.

Required proof: Capture screenshots/video for blank, focused, proposal, receipt, and full-screen composer states; keyboard/accessibility proof; proposal/receipt mutation proof; attachment/context proof if applicable; route-depth proof that root dock hides.

Red if criteria: Capture proof remains missing, composer opens as a sheet, dead mic/accessory appears as primary control, proposal/receipt path is unproven, keyboard blocks primary input, accessibility labels/actions are unverified.

Suggested Linear issue strategy: continue under `AMB-1183` / `AMB-1192` and existing issue leaves; do not create a duplicate Capture proof parent.

Implementation/review: Codex-implemented if source/proof harness repairs are required, owner-reviewed for final composer quality.

## P0 Search Proof Repair

Scope: produce deterministic Search proof and repair any overlay/route defects found during proof.

Blocked issue IDs: `AMB-ISSUE-0701`, `AMB-ISSUE-1601`-`1605`; Linear parents `AMB-1187`, `AMB-1196`.

Evidence source: AMB-1199 broad UI proof AX timeout, `screenshot-index.md`, known-issues Search rows.

Required proof: Search screenshots/video for dense results, no-result state, result tap, inspect/open route, Capture fallback, local-only proof artifacts, route-depth proof that root dock hides.

Red if criteria: Search screenshot proof remains absent, result actions do not route, Capture fallback is missing, local-only scan cannot support non-network claim, overlay behaves like a shallow sheet.

Suggested Linear issue strategy: continue under `AMB-1187` / `AMB-1196` and existing Search issue leaves.

Implementation/review: Codex-implemented for source/proof repair, owner-reviewed for interaction quality.

## P0 Light/System Theme Proof Repair

Scope: prove semantic theme behavior across Light, System, and Dark and repair any mode-specific contrast failures.

Blocked issue IDs: `AMB-ISSUE-1901`-`1906`, `AMB-ISSUE-1503`, `AMB-ISSUE-0802`; Linear parents `AMB-1182`, `AMB-1191`.

Evidence source: AMB-1199 missing Light/System matrix, AMB-1191 source/test proof, known-issues Light mode rows.

Required proof: Light/System screenshot matrix for Today, Goals, Time, You, Capture, Search, and Closure; Appearance live-switch proof; contrast review; dock material proof; Dynamic Type and Increase Contrast spot checks.

Red if criteria: Light/System screenshots remain missing, live-switch proof absent, hard-coded dark treatment appears, contrast is unreadable, dock material becomes low-contrast.

Suggested Linear issue strategy: continue under `AMB-1182` / `AMB-1191` and existing Light mode issue leaves.

Implementation/review: Codex-implemented for theme/source fixes, owner-reviewed for visual acceptance.

## P0 Today Runtime Proof Repair

Scope: prove Today action gating and runtime mutation paths from no-step and valid-step states.

Blocked issue IDs: `AMB-ISSUE-0001`, `0004`, `0005`, `0016`, `0101`-`0108`, `1001`-`1011`, `1201`; Linear parents `AMB-1186`, `AMB-1195`.

Evidence source: AMB-1199 dark Today root screenshot, known-issues Today rows, AMB-1195 source/action-gating proof.

Required proof: no-step state screenshot, valid-step state screenshot, closure before/action/after mutation proof, protection flow proof, proof/undo artifact, accessibility announcement proof.

Red if criteria: Record Outcome is visible without a valid step, closure mutation is not visible, protection flow is fake or unproven, no-step/valid-step matrix missing.

Suggested Linear issue strategy: continue under `AMB-1186` / `AMB-1195`.

Implementation/review: Codex-implemented for state/proof gaps, owner-reviewed for runtime acceptance.

## P0 Time Runtime Proof Repair

Scope: prove Time placement and calendar-grade view states.

Blocked issue IDs: `AMB-ISSUE-0009`, `0501`-`0507`, `0913`, `1401`-`1405`; Linear parents `AMB-1188`, `AMB-1197`.

Evidence source: AMB-1199 Time root screenshot, known-issues Time rows, AMB-1197 source/test proof.

Required proof: no-step/no-placement proof, valid placement proof, day/week/month/year/list proof, protected/open/pressure/buffer proof, before/action/after mutation proof, device proof.

Red if criteria: `Place Step` can imply success without a real Step, placement variants remain unproven, dock overlaps Time content, calendar orientations are missing.

Suggested Linear issue strategy: continue under `AMB-1188` / `AMB-1197`.

Implementation/review: Codex-implemented for runtime/source/proof gaps, owner-reviewed for calendar-grade acceptance.

## P0 You Appearance / Settings Proof Repair

Scope: prove You root, detail settings, and Appearance live-switch behavior.

Blocked issue IDs: `AMB-ISSUE-0601`-`0607`, `AMB-ISSUE-1501`-`1505`; Linear parents `AMB-1189`, `AMB-1198`.

Evidence source: AMB-1199 You root screenshot, known-issues You rows, AMB-1198 source/test/build proof.

Required proof: You root proof, Appearance before/after proof, detail settings proof, accessibility/settings proof, Local Data row non-overlap, device proof.

Red if criteria: dock overlaps You content, Appearance before/after proof absent, settings rows do not route to real detail or honest unavailable state, device proof absent.

Suggested Linear issue strategy: continue under `AMB-1189` / `AMB-1198`.

Implementation/review: Codex-implemented for source/proof gaps, owner-reviewed for settings quality.

## P0 Accessibility / AX Timeout Repair

Scope: fix proof-runner reliability and produce actual accessibility evidence beyond source-contract tests.

Blocked issue IDs: `AMB-ISSUE-0807`, `AMB-ISSUE-1801`, `AMB-ISSUE-1802`; Linear issues `AMB-1266`, `AMB-1252`, `AMB-1253`; parent `AMB-1190`.

Evidence source: AMB-1199 manifest, `accessibility-checklist.md`, broad UI proof failure with `XCTDaemonErrorDomain Code=18 Timed out waiting for AX loaded notification`.

Required proof: AX timeout root cause, deterministic screenshot/proof runner reliability, VoiceOver walkthrough, Dynamic Type matrix, Reduce Motion, Increase Contrast, Reduce Transparency, Differentiate Without Color, keyboard/focus and non-gesture alternatives.

Red if criteria: broad proof bundle still times out, manual/device accessibility remains unrun, source-contract tests are treated as accessibility readiness, screenshots are missing.

Suggested Linear issue strategy: continue under `AMB-1190`, `AMB-1199`, and existing accessibility leaves; no duplicate accessibility parent.

Implementation/review: Codex-implemented for runner reliability and automation, owner-reviewed/manual for accessibility acceptance.

## P0 Device Proof / Owner Review Package

Scope: collect physical-device evidence and owner review without closing unresolved gaps.

Blocked issue IDs: `AMB-ISSUE-0014`, `0015`, `0016`, `0807`, `0909`, `1801`, `1802`; parents `AMB-1181`, `AMB-1190`, `AMB-1200`.

Evidence source: AMB-1199 release ceiling, known-issues closure law, remediation law.

Required proof: physical device build/run path, screen recording checklist, root/drilldown/overlay screenshot matrix, owner review script, issue intake after owner review, explicit non-release-ready verdict if blockers remain.

Red if criteria: physical-device proof absent, owner acceptance absent, unresolved proof gaps marked closed, project status moves on track while P0s remain.

Suggested Linear issue strategy: keep under current QA project/control plane; use `AMB-1181`, `AMB-1190`, `AMB-1200`, and existing leaves. Create new issues only after owner review identifies defects not already covered by known rows.

Implementation/review: both; Codex prepares artifacts and scripts, owner performs acceptance/rejection.

## Linear Creation Decision

AMB-1200 Linear search found matching parents and issue leaves for the repair groups above. New repair issues are not created in this train to avoid duplicates. If Linear issue creation is needed later, create only after confirming no matching parent or `AMB-ISSUE-*` ticket exists.
