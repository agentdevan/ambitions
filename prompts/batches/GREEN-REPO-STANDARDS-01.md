<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

`GREEN-REPO-STANDARDS-01`

# Runner Command

```bash
make batch BATCH=GREEN-REPO-STANDARDS-01 PROMPT=prompts/batches/GREEN-REPO-STANDARDS-01.md
````

# Objective

Bring the Ambitions repo posture to **Ambitions Green** across the areas identified in the latest repo standards review:

1. Truth hierarchy
2. Native iPhone architecture
3. Product IA
4. Object-first product model
5. Local-first / privacy posture
6. Release honesty
7. Release-readiness claim discipline
8. Codex autonomy
9. Repo hygiene
10. Accessibility source/proof posture
11. Visual flagship proof posture

This batch must not fake Green. In Ambitions, Green means evidence supports the claim. Where full Green requires physical-device, signed archive, legal/privacy, human approval, App Store, TestFlight, public accessibility, or performance proof unavailable in the current environment, the correct outcome is:

```text
Green claim discipline + explicit non-claim + current proof path or accepted Yellow blocker.
```

Do not convert missing release/device/legal/accessibility/performance proof into a claim. Make the repo Green by removing source/test/docs drift, adding current evidence, tightening proof packets, and forcing remaining non-claims to be explicit.

# Ambitions Standard

Operate as a world-class native iPhone product, design, iOS engineering, QA, accessibility, privacy, release, repo-hygiene, and Codex autonomy department.

Optimize for:

* native iPhone-first SwiftUI quality
* local-first / on-device-first source posture
* strict source-truth hierarchy
* no obsolete authority paths
* no Plan/Profile/Captures as active user-facing root IA
* no generic productivity-app/dashboard/chatbot framing
* no false build/test/release/accessibility/performance/privacy claims
* current proof over optimism
* scoped reversible patches
* bounded repair loops
* exact validation evidence
* clean rollback

# Active Source Truth To Inspect

Read first, in this order:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/IMPLEMENTATION_TRUTH.md`
4. `docs/truth/RELEASE_TRUTH.md`
5. `docs/truth/CODEX_PROCESS_TRUTH.md`
6. `docs/truth/HISTORICAL_POLICY.md`
7. `AGENTS.md`
8. `README.md`
9. `docs/README.md`
10. `.codex/REPO_INVENTORY.md`
11. `docs/status/current-implementation-map.md`
12. `docs/status/repo-cleanup-index.md`
13. `docs/status/release-evidence-packet.md`
14. `docs/native-build-and-release.md`
15. `project.yml`
16. `Package.swift`
17. `Makefile`
18. `scripts/ambitions-codex-train.sh`
19. `scripts/ambitions-process-preflight.sh`
20. `scripts/ambitions-prompt-audit.sh`
21. `scripts/build-local.sh`

Then inspect relevant source and tests:

```text
Native/Ambitions/App/
Native/Ambitions/Features/Today/
Native/Ambitions/Features/Goals/
Native/Ambitions/Features/Captures/
Native/Ambitions/Features/Plan/
Native/Ambitions/Features/Profile/
Native/Ambitions/Persistence/
Native/Ambitions/Resources/PrivacyInfo.xcprivacy
Native/Ambitions/Support/Ambitions.entitlements
Native/AmbitionsTests/
Native/AmbitionsUITests/
Sources/
AppUI/Sources/
```

# Required Scorecard Target

Produce and close against this scorecard:

| Area                        | Required Target                                                                                                                |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| Truth hierarchy             | Green: no supporting doc routes active authority ahead of `docs/truth/*`.                                                      |
| Native iPhone architecture  | Green-source and current local build proof if environment supports it. If not, accepted Yellow with exact environment blocker. |
| Product IA                  | Green: active user-facing IA is `Today / Goals / Capture / Time / You`; tests and docs agree.                                  |
| Object-first model          | Green-source for touched areas; no generic dashboard/card-stack fallback introduced.                                           |
| Local-first/privacy posture | Green-source; privacy/legal remains non-claim unless proof exists.                                                             |
| Release honesty             | Green: no forbidden release claims.                                                                                            |
| Release readiness           | Green claim discipline only: not release-ready unless full proof packet exists.                                                |
| Codex autonomy              | Green: runner prompts, repair paths, and docs align with runner protocol.                                                      |
| Repo hygiene                | Green: stale active routing corrected; historical material remains classified.                                                 |
| Accessibility               | Green-source for touched UI; public conformance remains non-claim unless current manual proof exists.                          |
| Visual flagship proof       | Green-source plus visual proof packet if screenshots can be produced; otherwise accepted Yellow with exact proof gap.          |

# Phase 0 — Preflight, Branch, Dirty Tree, and Process Safety

Run:

```bash
scripts/ambitions-process-preflight.sh --assert-clear
git status --short --branch
git rev-parse --abbrev-ref HEAD
git rev-parse HEAD
git diff --name-only
```

Rules:

* Work on `main` only unless the current repo protocol says otherwise.
* Do not create a branch unless required by repo policy.
* If dirty files exist, classify them before editing:

  * active source
  * tests
  * docs/truth
  * docs/status
  * prompts/batches
  * Codex state
  * generated logs/artifacts
  * unexpected
* Do not overwrite unknown user work.
* If dirty source/test files are unrelated to this batch and cannot be classified safely, stop Red.
* If dirty files are expected current batch files, continue with path-limited scope.

Artifact:

```text
docs/audits/green-repo-standards-01-report.md
```

Start the report in Phase 0 and update it through every phase.

# Phase 1 — Truth Hierarchy and Supporting-Doc Authority Repair

Goal: make authority routing Green.

Inspect and repair stale authority language in:

```text
README.md
docs/README.md
docs/status/current-implementation-map.md
docs/status/repo-cleanup-index.md
.codex/REPO_INVENTORY.md
AGENTS.md
```

Required repairs:

1. Active product/design authority must start at:

```text
docs/truth/PRODUCT_DESIGN_TRUTH.md
```

2. AmbitionsCanon must be described only as supporting canon where compatible with `docs/truth/*`.

3. Current implementation authority must be:

```text
live source/project/test/script evidence
read through docs/truth/IMPLEMENTATION_TRUTH.md
```

4. Release/proof authority must be:

```text
current raw proof/logs
read through docs/truth/RELEASE_TRUTH.md
```

5. No supporting doc may say or imply `docs/AmbitionsCanon/README.md` is active product/design source truth ahead of `docs/truth/*`.

6. Do not rewrite large historical docs in this phase.

Validation for Phase 1:

```bash
grep -RIn "AmbitionsCanon/README.md.*source truth\|source truth.*AmbitionsCanon/README.md\|active product/design source truth" README.md docs .codex AGENTS.md || true
git diff --check
```

Expected result:

* Any remaining matches must be clearly supporting-only or historical.
* Record remaining matches in the audit report with classification.

# Phase 2 — Product IA Drift Repair: Time / Plan, You / Profile, Capture / Captures

Goal: make active IA Green without unsafe broad renames.

Canonical active top-level IA:

```text
Today / Goals / Capture / Time / You
```

Allowed internal compatibility seams:

```text
.plan
PlanScreen
planNavigation()
Native/Ambitions/Features/Plan/
.profile
ProfileScreen
Native/Ambitions/Features/Profile/
.captures
Native/Ambitions/Features/Captures/
```

Required inspection:

```bash
rg -n '"Plan"|Plan tab|tab/plan|app\.tabBars\.buttons\["Plan"\]|selectedTab\("Plan"|Profile tab|Captures tab|DayTimelineRail|Hero Step Panel|Mission Control|Dashboard|Assistant|AI recommends|best next move|overdue|failed|streak|score' Native README.md docs .codex AGENTS.md || true
```

Required repairs:

1. UI tests must expect `"Time"` for the active top-level tab label, not `"Plan"`.

2. Deep links may remain `ambitions://tab/plan` only as backward-compatible route values, but test names and assertions must say they land on canonical Time.

3. Shell command copy must say `"Time"` / `"Shape Time"` where user-facing; internal `quickPlanPatch` identifiers may remain only if not surfaced as active top-level product language.

4. Any user-facing “Plan” root tab copy must become “Time.”

5. “Profile” may remain internal only; user-facing copy must be “You.”

6. “Captures” may remain internal only; user-facing copy must be “Capture.”

7. Do not blind rename source symbols.

8. Do not change top-level IA.

9. Do not add a sixth tab.

Likely files to inspect and potentially patch:

```text
Native/Ambitions/App/AppTab.swift
Native/Ambitions/App/AmbitionsRootView.swift
Native/Ambitions/App/ShellCommandModels.swift
Native/Ambitions/App/AppNavigationModel.swift
Native/Ambitions/App/DefaultAppExternalRouter.swift
Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift
Native/AmbitionsUITests/AmbitionsUITests.swift
docs/status/current-implementation-map.md
docs/status/repo-cleanup-index.md
```

Phase 2 validation:

```bash
rg -n 'app\.tabBars\.buttons\["Plan"\]|waitForSelectedTab\("Plan"|openCanonicalDestination\("Plan"|Missing top-level tab \\(tab\\).*Plan|for tab in \["Today", "Goals", "Capture", "Plan", "You"\]' Native/AmbitionsUITests || true
rg -n '"Plan"|Plan tab|Profile tab|Captures tab' Native/Ambitions/App Native/AmbitionsUITests docs/status README.md AGENTS.md || true
git diff --check
```

Expected result:

* No UI test asserts `Plan` as active tab label.
* Any remaining `Plan` in app source is internal compatibility or deep-link compatibility and documented as such.
* Audit report records compatibility seams.

# Phase 3 — Active UI Language Audit and Scoped Cleanup

Goal: remove active user-facing obsolete/banned language where safely patchable.

Banned or high-risk user-facing language includes:

```text
Plan as active root tab
Profile as active root tab
Captures as active root tab
Dashboard
Assistant
AI recommends
best next move
overdue
failed
streak
score
generic productivity dashboard framing
Mission Control as active product language unless explicitly internal/detail-only and compatible
DayTimelineRail as active product language
Hero Step Panel as active product language
```

Required scan:

```bash
rg -n -i 'dashboard|assistant|AI recommends|best next move|overdue|failed|streak|score|Mission Control|DayTimelineRail|Hero Step Panel|Plan tab|Profile tab|Captures tab' Native Sources AppUI README.md docs .codex AGENTS.md || true
```

Classify each active-source hit:

```text
active user-facing defect
internal compatibility seam
test identifier only
historical/supporting doc
false positive
acceptable domain term
```

Patch only active user-facing defects in this batch.

Do not:

* rename files/folders broadly
* rewrite historical docs
* alter domain concepts without product-truth support
* remove accessibility identifiers unless tests are updated
* weaken tests

Update the audit report with a table:

```text
term / path / classification / action / remaining risk
```

Phase 3 validation:

```bash
git diff --check
scripts/codex-forbidden-claim-scan.sh README.md docs/status docs/truth Native Sources AppUI 2>/dev/null || true
```

If the forbidden claim scanner is advisory or exits non-zero on historical files, classify output rather than suppressing it.

# Phase 4 — Object-First Source Compliance Pass

Goal: make touched primary surfaces source-Green against Product Design Truth.

Inspect:

```text
Native/Ambitions/Features/Today/
Native/Ambitions/Features/Goals/
Native/Ambitions/Features/Captures/
Native/Ambitions/Features/Plan/
Native/Ambitions/Features/Profile/
```

For each top-level surface, verify and record:

```text
Today -> Start Here / Reality Meridian posture
Goals -> long-term direction, not KPI dashboard
Capture -> composer-first intake, not inbox/feed-first product
Time -> LifeShape / shape time posture, not calendar clone
You -> preferences/trust/privacy/control, not social profile
```

Patch only small, high-confidence source/copy defects discovered during inspection.

Do not attempt a broad visual redesign in this batch unless the defect is narrow and directly blocks standards compliance.

Required report section:

```markdown
## Surface Compliance
| Surface | Source paths inspected | Primary object | Defects found | Patches made | Remaining proof gap |
```

Phase 4 validation:

```bash
git diff --check
```

# Phase 5 — Accessibility Source Gate

Goal: make touched UI source-Green for accessibility and make proof gaps explicit.

For any touched UI path, verify:

```text
[ ] VoiceOver label/value/hint where primary object/action is touched.
[ ] Logical grouping.
[ ] Primary action discoverable.
[ ] Dynamic Type does not destroy primary object/action at source level.
[ ] Reduce Motion fallback preserved where motion/state transitions are touched.
[ ] Color is not sole state cue.
[ ] 44pt minimum touch target preserved.
[ ] Error/recovery state semantics not weakened.
```

Required scan:

```bash
rg -n 'accessibilityLabel|accessibilityValue|accessibilityHint|accessibilityIdentifier|dynamicTypeSize|accessibilityReduceMotion|accessibilityContrast' Native/Ambitions/Features Native/Ambitions/App Sources AppUI/Sources || true
```

Patch narrow omissions only in files touched by this batch or directly impacted by Phase 2/3.

Do not claim:

```text
fully accessible
VoiceOver verified
Dynamic Type verified
Reduce Motion verified
accessibility compliant
```

unless current manual proof exists.

Phase 5 output:

```text
docs/audits/green-repo-standards-01-accessibility-source-check.md
```

This may be a section inside the main audit report if shorter.

# Phase 6 — Visual Proof Packet Attempt

Goal: produce visual proof if the local environment supports it; otherwise make the proof gap explicit and non-claim safe.

First inspect whether the repo has screenshot/preview tooling:

```bash
find scripts tools docs Native -iname '*screenshot*' -o -iname '*preview*' -o -iname '*visual*' | sort
rg -n 'screenshot|preview|visual QA|Dynamic Type|Reduce Motion|XCUIApplication|XCUIScreenshot' scripts tools docs Native || true
```

If safe screenshot tooling exists, run the narrowest non-release visual proof flow for:

```text
Today
Goals
Capture
Time
You
```

Required visual proof metadata:

```text
commit SHA
branch
date/time
machine/environment
Xcode version
simulator/device
surface
state
light/dark mode if captured
Dynamic Type state if captured
Reduce Motion state if captured
known defects
non-claims
```

If no screenshot tooling exists or the environment cannot run it, create a proof-gap entry:

```text
Visual proof not produced because: <exact reason>
Required next local command/procedure: <exact command/procedure>
Claims not made: visual QA passed / flagship visual quality / screenshot approval
```

Do not fabricate screenshots.

Do not claim visual QA passed from preview source alone.

Artifact:

```text
docs/status/visual-proof-gap-green-repo-standards-01.md
```

or, if screenshots are produced:

```text
output/visual-proof/green-repo-standards-01/
docs/status/visual-proof-green-repo-standards-01.md
```

# Phase 7 — Current Build/Test Proof Packet

Goal: move native architecture and validation posture as far Green as current environment permits.

Run in this order, stopping on unknown root cause after bounded repair:

```bash
scripts/ambitions-process-preflight.sh --assert-clear
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" build CODE_SIGNING_ALLOWED=NO
```

Then run focused tests for this batch:

```bash
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsUITests test
```

If full UI tests are too broad or unavailable, run the narrowest UI test class/methods affected by Time/Plan label drift.

Also run relevant unit tests if source files beyond docs/tests were touched:

```bash
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests test
```

If `iPhone 17` is unavailable, select the first available iPhone simulator and record it.

If Xcode/XcodeGen/simulator are unavailable, do not fake proof. Record exact blocker and use accepted Yellow for build/test proof.

Save or summarize logs under:

```text
output/logs/green-repo-standards-01/
```

or another existing repo-approved proof path.

Required proof packet:

```text
docs/status/green-repo-standards-01-proof-packet.md
```

It must include:

```text
branch
commit before patch
commit after patch if committed
date/time
machine/environment if available
macOS version if available
Xcode version if available
XcodeGen version if available
simulator/device name and OS if available
commands run
exit codes
log paths
pass/fail result
known skipped checks
non-claims
```

Bounded repair:

* If validation fails because UI tests still expect stale `Plan`, patch the test/source mismatch once and rerun the targeted test.
* If validation fails because of unrelated pre-existing failures, classify them and do not hide them.
* Maximum two focused repair attempts for same root cause.
* Do not delete or weaken tests to pass.

# Phase 8 — Release Truth, Privacy, and Non-Claim Firewall

Goal: make release honesty Green and prevent false claims.

Run:

```bash
scripts/codex-forbidden-claim-scan.sh README.md docs Native Sources AppUI .codex prompts 2>/dev/null || true
rg -n -i 'production-ready|release-ready|App Store-ready|TestFlight-ready|device-verified|physical-device validated|CI-proven|fully tested|fully accessible|VoiceOver verified|Dynamic Type verified|Reduce Motion verified|performance validated|privacy approved|legally approved|App Review ready|signed release-ready|crash-free' README.md docs Native Sources AppUI .codex prompts || true
```

Patch active overclaims only.

Do not rewrite historical files broadly. For historical hits, classify as historical/supporting or leave for a dedicated cleanup pass if not actively misleading.

Update:

```text
docs/status/release-evidence-packet.md
```

only if the current proof posture changed because this batch produced current build/test/visual/accessibility proof.

Do not update `docs/truth/RELEASE_TRUTH.md` unless this batch produces durable proof that changes release truth. If updating `docs/truth/*` would be required, stop and report that explicit approval is needed.

Privacy/local-first check:

```bash
rg -n -i 'supabase|firebase|postgres|backend|server|OpenAI|LLM|analytics|telemetry|tracking|CloudKit|iCloud|R2|Cloudflare|network|URLSession' Native Sources AppUI Package.swift project.yml README.md docs .codex AGENTS.md || true
```

Classify hits:

```text
active app dependency
future allowed exception
historical/supporting
forbidden drift
false positive
```

Hard Red if this batch discovers active unapproved hosted backend, external/cloud LLM core, telemetry, tracking, or user-private data network dependency.

# Phase 9 — Codex Runner Autonomy and Prompt Hygiene Gate

Goal: make Codex autonomy Green for this repo state.

Run:

```bash
scripts/ambitions-codex-train.sh --self-check
scripts/ambitions-prompt-audit.sh
make -n batch BATCH=GREEN-REPO-STANDARDS-01 PROMPT=prompts/batches/GREEN-REPO-STANDARDS-01.md
make -n repair-status
make -n repair-next
make -n autonomous-train-status
make -n autonomous-train-next
git diff --check
```

If prompt audit returns accepted Yellow for support/eval/template classifications, record it.

Do not run global train.

Do not run autonomous train.

Do not spawn child batches unless this batch hits a bounded repair condition that cannot be safely handled inline. If a child repair prompt is needed, generate exactly one repair prompt and stop Yellow.

# Phase 10 — Final Scorecard, Commit, and Closeout

Before staging:

```bash
git status --short --branch
git diff --name-only
git diff --check
```

Stage only files changed for this batch.

Do not use:

```bash
git add -A
git add .
git commit -a
```

Allowed changed paths for this batch:

```text
README.md
AGENTS.md
docs/README.md
docs/status/current-implementation-map.md
docs/status/repo-cleanup-index.md
docs/status/release-evidence-packet.md
docs/status/green-repo-standards-01-proof-packet.md
docs/status/visual-proof-gap-green-repo-standards-01.md
docs/status/visual-proof-green-repo-standards-01.md
docs/audits/green-repo-standards-01-report.md
docs/audits/green-repo-standards-01-accessibility-source-check.md
Native/Ambitions/App/
Native/Ambitions/Features/
Native/AmbitionsUITests/
Native/AmbitionsTests/
scripts/ only if validation/proof helper defects directly block this batch
```

Forbidden changed paths unless explicitly justified in the audit report:

```text
docs/truth/
.github/
Package.swift
project.yml
Native/Ambitions/Resources/PrivacyInfo.xcprivacy
Native/Ambitions/Support/*.entitlements
Native/AmbitionsWidgetExtension/
Native/AmbitionsShareExtension/
Sources/
AppUI/
tools/mcp/
.codex/runs/
```

If source or tests changed, commit message:

```text
GREEN-REPO-STANDARDS-01: align repo standards and proof posture
```

Commit body must include:

```text
- fixed Time/Plan active IA drift
- corrected stale supporting-doc authority routing
- classified remaining compatibility seams
- added current proof packet or exact proof blockers
- preserved release non-claims
- validation commands and outcomes
- claims not made
```

Push only if current repo/runner policy allows push and branch is `main`.

# Hard Red Stop Conditions

Stop immediately with `STATUS: RED` if:

1. Truth hierarchy conflict cannot be resolved.
2. Product/design patch would violate `PRODUCT_DESIGN_TRUTH.md`.
3. A change would revive `Plan`, `Profile`, or `Captures` as active user-facing root IA.
4. A change would add a sixth top-level tab.
5. A change would introduce generic dashboard/task-app/calendar-clone/chatbot/SaaS/admin framing.
6. A change would add external/cloud LLM core behavior.
7. A change would add custom hosted backend/account/user-data server behavior.
8. A change would add telemetry/analytics/tracking of sensitive life behavior.
9. A change would upload personal user data to R2 or any external service.
10. A change would add hosted CI or cost-bearing services without explicit approval.
11. Validation failure root cause is unknown after two focused repair attempts.
12. Same-root validation failure repeats after bounded repair.
13. Dirty tree contains unknown user changes that cannot be safely classified.
14. Required source cannot be inspected.
15. Staging would include unrelated files.
16. `docs/truth/*` must be changed but explicit approval is absent.
17. Release/TestFlight/App Store/device/accessibility/performance/privacy/legal readiness would need to be claimed without proof.
18. Signing, provisioning, App Store, TestFlight, secrets, or credentials are required.

# Rollback Expectations

Before any patch, record touched files in the audit report.

If validation breaks and repair fails:

1. Revert only this batch’s changes.
2. Preserve user changes and pre-existing dirty work.
3. Preserve logs/proof artifacts if they explain the failure.
4. Report files reverted and files left untouched.
5. Report safest next action.

Never use broad destructive reset commands on an unknown dirty tree.

# Required Final Report

End with:

```markdown
## Status

STATUS: GREEN | STATUS: ACCEPTED YELLOW | STATUS: RED

## Scope

What was requested and what was actually completed.

## Scorecard

| Area | Final status | Evidence | Remaining gap |
|---|---|---|---|
| Truth hierarchy |  |  |  |
| Native iPhone architecture |  |  |  |
| Product IA |  |  |  |
| Object-first model |  |  |  |
| Local-first/privacy posture |  |  |  |
| Release honesty |  |  |  |
| Release-readiness claim discipline |  |  |  |
| Codex autonomy |  |  |  |
| Repo hygiene |  |  |  |
| Accessibility |  |  |  |
| Visual proof posture |  |  |  |

## Files Changed

- path — reason

## Evidence

- truth files inspected
- source paths inspected
- proof packets/logs
- screenshots/visual artifacts if produced
- scanner outputs

## Validation

Commands run:
- command — exit code — result

Commands not run:
- command — reason

Artifacts:
- path

## Compatibility Seams Preserved

- internal `.plan` / `PlanScreen` / `Native/Ambitions/Features/Plan/`
- internal `.profile` / `ProfileScreen` / `Native/Ambitions/Features/Profile/`
- internal `.captures` / `Native/Ambitions/Features/Captures/`
- any remaining identifiers classified as internal/test/historical

## Risks / Remaining Gaps

- gap
- impact
- next proof needed

## Claims Not Made

- release readiness
- TestFlight readiness
- App Store readiness
- signed archive readiness
- physical-device validation
- public accessibility conformance
- VoiceOver verification
- Dynamic Type verification
- Reduce Motion verification
- performance validation
- privacy/legal approval
- hosted CI proof
- crash-free / production readiness

## Commit

- committed:
- commit SHA:
- pushed:
- staged files:

## Next Recommended Step

One bounded next step only.
```

# Completion Standard

This batch is Green only if:

* active authority routing is corrected
* Time/Plan active IA drift is fixed in source/tests/docs within scope
* remaining obsolete names are classified as compatibility or historical
* no forbidden release/product/privacy claims remain in active paths
* local build/test proof was produced, or environment blocker is exact and accepted Yellow
* visual/accessibility proof posture is honest
* release readiness remains unclaimed unless full proof exists
* final report includes claims not made
* staged files are path-limited
* no unrelated cleanup or broad rewrites were mixed in

Final rule: Make the repo Green by evidence, not by language.
