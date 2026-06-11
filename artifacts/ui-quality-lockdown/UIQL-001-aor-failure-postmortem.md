# AMB-956 / UIQL-001 AOR Failure Postmortem + Supersession

Status: Green for the AMB-956 report gate.

This is a report-only UIQL closeout. It does not modify app source, tests, Xcode project files, product behavior, screenshots, dependencies, or runtime implementation.

## Issue Identity

Linear issue: AMB-956
Sequence label: UIQL-001
Title: AOR Failure Postmortem + Supersession

`UIQL-001` is a title/sequence label only. It is not a Linear identifier.

## Evidence Inspected

- `artifacts/ambitions-ui-reconstruction/reports/AOR-001-report.md`
- `artifacts/ambitions-ui-reconstruction/final-proof/AMB-603-final-ui-quality-verdict.md`
- `artifacts/ambitions-ui-reconstruction/final-proof/AMB-598-final-screenshot-matrix.md`
- `artifacts/ambitions-ui-reconstruction/final-proof/AMB-600-final-accessibility-behavior-proof.md`
- `artifacts/ambitions-ui-reconstruction/final-proof/AMB-597-final-no-card-scan.md`
- `artifacts/ambitions-ui-reconstruction/primitive-audit/AMB-566-no-card-audit.md`
- `artifacts/ambitions-ui-reconstruction/final-gate/AMB-558-screenshot-board.md`
- Linear AMB-603, AMB-604, AMB-606, and AMB-607 comments or issue data available through the connector.
- Current source routing scan for `AmbitionsApp`, `LaunchGateView`, `AmbitionsRootView`, `AppMeridianShell`, `TabView`, and canonical tab routing.
- Visual sample of final AOR screenshot-board files:
  - `artifacts/ambitions-ui-reconstruction/screenshots/today-default-after-final.png`
  - `artifacts/ambitions-ui-reconstruction/screenshots/goals-default-after-final.png`
  - `artifacts/ambitions-ui-reconstruction/screenshots/time-default-after-final.png`
  - `artifacts/ambitions-ui-reconstruction/screenshots/motion-default-after-final.png`
  - `artifacts/ambitions-ui-reconstruction/screenshots/you-default-after-final.png`
  - `artifacts/ambitions-ui-reconstruction/screenshots/capture-activated-after-final.png`

## AOR Intended Outcome

AOR was intended to prove the active runtime UI reconstruction path and provide a final evidence packet around root shell ownership, canonical IA, screenshots, accessibility behavior, no-card anatomy, and focused validation.

For UIQL purposes, the intended high bar should have been:

- Active runtime root and tab ownership are proven from current source.
- Rendered screenshots show the actual active surfaces, not only launch or loading scaffolds.
- Screenshot proof includes visual evaluation against product anatomy and accessibility requirements.
- Card/list/dashboard anatomy is replaced or explicitly blocked, not merely renamed or deferred.
- Accessibility evidence separates source/test contracts from manual VoiceOver, Dynamic Type, Reduce Motion, Reduce Transparency, Increase Contrast, and tap-target proof.
- Final claims avoid owner approval, release readiness, TestFlight readiness, App Store readiness, formal accessibility conformance, and product completion.

## What AOR Actually Proved

AOR proved useful active-runtime scaffolding facts:

- `@main` `AmbitionsApp` opens `LaunchGateView`.
- `LaunchGateView` opens `AmbitionsRootView`.
- `AmbitionsRootView.shellTabView(theme:)` owns the live root `TabView`.
- Active runtime tabs are `Today / Goals / Time / Motion / You`.
- Capture is a global/supporting route, not a top-level tab.
- `AppShellView` is active support, not the root owner.
- `AppMeridianShell` is preview/support material, not the active root path.
- AOR gathered screenshot files and validation artifacts under the AOR artifact tree.
- Later AOR follow-ups identified card/container debt and accessibility-manual-proof gaps instead of proving them away.

This is valuable runtime scaffold evidence. It is not flagship UI quality proof.

## What AOR Explicitly Did Not Prove

AOR did not prove:

- flagship visual quality
- human visual approval
- owner approval
- final UIQL Green
- formal accessibility conformance
- manual VoiceOver traversal
- full Dynamic Type visual proof
- full Reduce Motion visual proof
- full Reduce Transparency visual proof
- full Increase Contrast visual proof
- physical-device behavior
- performance readiness
- privacy/legal approval
- release readiness
- TestFlight readiness
- App Store readiness
- production readiness
- product completeness

The AOR evidence repeatedly states these non-claims in its final artifacts. UIQL must preserve those boundaries.

## False Green And Accepted Yellow Paths

The dangerous path was treating narrow evidence as broad product proof:

| Evidence path | Honest status | False Green risk |
|---|---|---|
| AOR-001 root report | Green for runtime-path proof, with runner-process Yellow | Treating root routing as visual/product quality proof |
| AMB-558 / AMB-604 screenshot board | Yellow; path inventory and capture execution evidence | Treating present screenshot files as visual approval |
| AMB-598 screenshot matrix | Green for screenshot-matrix inventory only | Treating dimensions/file presence as screenshot quality proof |
| AMB-600 accessibility behavior proof | Green for scoped internal behavior contracts only | Treating source/test contracts as formal accessibility proof |
| AMB-597 no-card scan | Yellow; active Card/Tile/Dashboard hits remained | Treating classified debt as completed no-card proof |
| AMB-603 final UI quality verdict | Yellow accepted | Treating accepted Yellow as flagship UI Green |
| AMB-607 card/container cleanup | Yellow accepted; shared/previews/test-only naming limits remained | Treating naming replacement as full rendered-anatomy replacement |

UIQL must not inherit any AOR accepted Yellow as product Green.

## Screenshot-File Existence Examples

AOR artifacts include concrete examples of screenshot-file existence or metadata being sufficient for that gate:

- `AMB-558-screenshot-board.md` lists eleven screenshot paths as `Present` with size and mtime metadata.
- `AMB-598-final-screenshot-matrix.md` treats screenshot path and dimension coverage as the matrix proof, while explicitly excluding visual approval and accessibility conformance.
- The sampled `*-default-after-final.png` and `capture-activated-after-final.png` images render the Ambitions launch/loading scaffold, not the named active surface first viewport. That means file presence proved capture mechanics, not finished surface quality.

UIQL screenshot proof must require actual visual evaluation of the rendered active surface, including safe areas, dock legibility, clipped text, readable copy, product anatomy, variant modes, and accessibility-relevant states.

## Card To Surface Renaming Without Visual Anatomy Replacement

AOR found and later partially repaired card/container language, but the history shows why rename-only proof is insufficient:

- AMB-566 recorded `980` Card/Tile/Dashboard scan lines and `2032` Panel/Chip/Container/Section/Pill scan lines, with active feature and service/model hits across You, Goals, Time, Insights, Habits, Capture, LaunchGate, and dashboard-named seams.
- AMB-597 still found `968` Card/Tile/Dashboard hits and `625` RoundedRectangle/background/corner/shadow hits, plus a structural anti-card validator Red with `127` red findings.
- AMB-607 closed Yellow after runtime/UI test replacements, but its Linear closeout still called out remaining shared component, preview, test-only, and KPI/naming limitations and did not attach visual/accessibility-device-journey/release proof.

Therefore, a renamed `Card` cannot be accepted as a product-quality `Surface` unless the rendered viewport proves a native Ambitions object composition rather than a generic card/list/dashboard stack.

## Root Shell Reality

Current source evidence still matches the AOR root finding:

- Active root path: `Native/Ambitions/App/AmbitionsApp.swift` -> `Native/Ambitions/UI/LaunchGateView.swift` -> `Native/Ambitions/App/AmbitionsRootView.swift`.
- Active root tab owner: `AmbitionsRootView.shellTabView(theme:)`.
- Active top-level tabs: Today, Goals, Time, Motion, You.
- Capture remains global/supporting, not a top-level tab.
- `AppMeridianShell` and related presentation-mode material are support/preview/history unless current source later routes them into the live root.

UIQL may use AOR for root/source ownership orientation, but must rerun current proof before making any UI quality claim.

## Supersession Policy

AOR quality claims are superseded as follows:

- AOR is active runtime scaffold evidence.
- AOR is route ownership and historical migration evidence.
- AOR is not flagship UI quality proof.
- AOR is not screenshot approval.
- AOR is not accessibility certification.
- AOR is not owner approval.
- AOR is not release, TestFlight, App Store, production, or product-completion proof.
- AOR accepted Yellow cannot close a UIQL product gate.
- AOR artifacts may support UIQL setup only when the current AMB issue rechecks source, screenshots, scripts, and no-claim boundaries.

Formal classification: AOR is active runtime scaffold evidence, not flagship UI quality proof.

## Gates That Must Change In UIQL

UIQL must require:

- Real Linear AMB IDs for all fetch/update/comment/closeout operations.
- Program run-state updates using actual AMB issue state.
- Current source ownership proof before source edits.
- Screenshot proof that includes visual evaluation, not only path existence or dimensions.
- No product Yellow for ugly UI, generic anatomy, clipped text, unsafe geometry, unreadable dock, weak copy, or missing accessibility semantics.
- Separate routing proof from visual/product proof.
- Separate source/test accessibility contracts from manual accessibility proof.
- No-card anatomy checks that inspect both source names and rendered object composition.
- Proof ledger entries that state exact claims and non-claims.
- Linear closeout only after push to `main`, using the actual AMB issue ID.

## Screenshot Defects / Proof Gaps Mapped To Failed AOR Gate Design

| Screenshot / surface | Observed defect or proof gap | Failed AOR gate design | UIQL replacement gate |
|---|---|---|---|
| `today-default-after-final.png` | Shows the Ambitions launch/loading scaffold, not Today / Reality Meridian. | Screenshot path and metadata were enough for the board. | Require visible Today first viewport with Start here / Recommended step anatomy and actual visual evaluation. |
| `goals-default-after-final.png` | Shows the launch/loading scaffold, not Goals / Direction. | Capture execution was treated separately from rendered-surface proof. | Require Goals first viewport with current direction language, no stale atlas/lens drift, and no card/list anatomy. |
| `time-default-after-final.png` | Shows the launch/loading scaffold, not Time / LifeShape Field. | The gate did not require loaded surface state before accepting the screenshot board. | Require Time loaded state, dock-safe copy, and LifeShape Field ownership visible. |
| `motion-default-after-final.png` | Shows the launch/loading scaffold, not Motion Current. | Surface-specific proof was not required by the screenshot inventory gate. | Require Motion Current first viewport, readable Source/Proof/Receipt facts, and no Pulse/dashboard/score/streak/feed framing. |
| `you-default-after-final.png` | Shows the launch/loading scaffold, not You / User System Profile. | File presence did not verify surface content. | Require You loaded state with system-profile anatomy and accessibility-aware grouped navigation. |
| `capture-activated-after-final.png` | Shows the launch/loading scaffold, not activated Capture proof. | Capture path existence did not prove composer state, keyboard safety, or global-action behavior. | Require activated Capture state, keyboard/safe-area proof, redaction/no-chatbot posture, and visual evaluation. |
| AMB-597 / AMB-566 no-card scan evidence | Active card/container naming and geometry debt remained. | AOR accepted owner-filed Yellow as enough for closeout. | UIQL must block product Green until active rendered anatomy is replaced or explicitly reframed without product claims. |
| AMB-606 accessibility follow-up evidence | Manual VoiceOver, Dynamic Type, Reduce Motion, Increase Contrast, Capture variants, tap targets, and Differentiate Without Color notes were listed as missing. | Source/test accessibility contracts were allowed to stand in for manual and variant proof. | UIQL accessibility gate must track each variant explicitly and avoid certification claims without actual proof. |

## Current Pushed Synthetic UIQL Commits

The following commits remain partial repo evidence only. They do not close AMB-956 through AMB-970 unless a later AMB closeout explicitly maps and accepts them:

| Commit | Title | Current classification |
|---|---|---|
| `c2321a555c9a7b033210cc9c064ec0de82345ad7` | UIQL-001 preflight authority refresh | Synthetic-label evidence only |
| `1043c1df11737fb7620c9951e92b3a8e61a9f686` | UIQL-001 repair activation contract canon | Synthetic-label evidence only |
| `2aefb43b96f3e7c1bf6742e823b256f4cc833f1e` | UIQL-002 repair shell geometry safe areas | Synthetic-label evidence only |
| `bd487793aa57e7488fee905f93761133d84d3014` | UIQL-003 close Today Reality Meridian quality gate | Synthetic-label evidence only |
| `d4b273e299ac4a207759d9104685a223dbfb9bbd` | UIQL-004 lock Start Here recommendation object | Synthetic-label evidence only |
| `2d9dd87549ef71887ec10d363f5a1f9381436eec` | UIQL-005 lock Goals direction quality gate | Synthetic-label evidence only |
| `8dbc7065a4652da93bc77d0e3915e450a178d3e1` | UIQL-006 lock Time LifeShape Field quality gate | Synthetic-label evidence only |
| `fba3d1b00a349c58f408012e058aeaecd7a8446e` | UIQL-007 lock Motion Current quality gate | Synthetic-label evidence only |
| `7d681b0fd8e4fe9727630726fcad014a758af59e` | UIQL reconcile Goal Mode issue mapping to Linear | Valid reconciliation/tooling evidence |
| `2fa6bc334705bb8bf1d24f29e2356e17a8c934ca` | UIQL bind Goal Mode adapter to Linear AMB issues | Valid mapping/tooling evidence |

## Linear Closeout Boundary

After this report is pushed, AMB-956 may be closed as the AOR postmortem and supersession gate only.

This closeout does not close AMB-957, AMB-958, AMB-959, AMB-960, AMB-961, AMB-962, AMB-963, AMB-964, AMB-965, AMB-966, AMB-967, AMB-968, AMB-970, or AMB-969.

## Validation

- `git diff --check` - passed.
- `bash scripts/codex/program-preflight.sh uiql` - passed, result `GREEN`, artifact `artifacts/ui-quality-lockdown/script-output/program-preflight-20260611T073755.log`.
- `bash scripts/codex/program-proof-index.sh uiql` - passed, wrote `artifacts/proof-ledger/proof-index.json` with `11` entries, artifact `artifacts/ui-quality-lockdown/script-output/program-proof-index-20260611T073756.log`.

No UI implementation tests are required for AMB-956 because this issue is a report-only supersession gate.

## No-Claim Boundary

This report does not claim app behavior changed, source implementation changed, UI repaired, screenshots approved, accessibility certified, owner approval, release readiness, TestFlight readiness, App Store readiness, production readiness, or product completion.

## Next Required Action

Next executable issue after AMB-956 closeout is AMB-957 / UIQL-002 - Install UI Quality Firewall.
