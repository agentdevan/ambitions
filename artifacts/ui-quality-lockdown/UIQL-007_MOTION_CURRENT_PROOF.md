# UIQL-007 Motion Current Proof

Status: Scoped Green for UIQL-007
Program: UIQL - Flagship UI Quality Lockdown
Issue: UIQL-007 - Motion / Motion Current quality gate
Branch: `main`
Base commit: `8dbc7065a4652da93bc77d0e3915e450a178d3e1`
Closeout commit: pending at proof creation

## Claim

Motion now presents `Motion Current` as the first-viewport proof/progress/inspection surface without dock-covered text, Pulse language, dashboard anatomy, scoring, streaks, analytics/feed framing, or generic card/list/task framing in the scoped proof path.

The current first viewport visibly includes:

- `Motion Current`
- a structured current-thread summary
- user-control copy before continuity changes
- Source, Proof, and Receipt facts
- re-entry/proof/recovery rhythm context below the object

## What Changed

- Removed the opaque bottom mask from `MotionCurrentScreen` and replaced it with clear safe-area clearance so the native dock no longer hides Motion copy.
- Added clear section clearance after `MotionCurrentField` so the next Motion lane section does not peek under the dock.
- Moved user-control copy into the readable Motion Current field before source/proof/receipt facts.
- Added compact Source / Proof / Receipt fact columns for non-accessibility Dynamic Type, while preserving vertical `ProofRelationshipTracePrimitiveLine` rendering for accessibility Dynamic Type sizes.
- Shortened the empty Motion state copy so the first viewport remains readable and does not depend on internal source-model language.
- Extended Motion unit tests to reject the removed dock mask colors and accept source-bound proof copy without requiring internal `SourceRecord` wording.
- Folded Motion Source/Proof/Receipt UI assertions into the already discoverable canonical five-tab shell UI test.

## Visual Evaluation

Screenshot reviewed:

- Before: `artifacts/ui-quality-lockdown/screenshots/UIQL-007-motion-current-before.png`
- Final: `artifacts/ui-quality-lockdown/screenshots/UIQL-007-motion-current-final.png`

Visual result:

- Green: `Motion Current` is visible as the primary object.
- Green: Source, Proof, and Receipt facts are visible and readable in the first viewport.
- Green: the native dock covers blank clearance, not Motion Current text.
- Green: no visible `Pulse` tab/name in the scoped screenshot.
- Green: no dashboard, score, streak, analytics/feed, or task-list anatomy is visible in the scoped Motion first viewport.
- Yellow/non-claim: screenshot review is current visual proof for this viewport only; it is not full accessibility certification, device proof, or release proof.

## Validation

| Command | Exit | Evidence |
| --- | ---: | --- |
| `git diff --check` | 0 | shell output |
| `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-scan-banned-copy.sh` | 0 | `artifacts/ui-quality-lockdown/script-output/uiql-banned-copy.log` |
| `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-scan-card-anatomy.sh` | 0 | `artifacts/ui-quality-lockdown/script-output/uiql-card-anatomy.log` |
| `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-mini-regression.sh` | 0 | `artifacts/ui-quality-lockdown/script-output/uiql-shell.log` |
| `scripts/ambitions-xcode-build-for-testing.sh --batch UIQL-007` | 0 | `artifacts/ui-quality-lockdown/script-output/UIQL-007-build-for-testing-after-ui-selector-fold-20260611T110340Z.log` |
| `scripts/ambitions-xcode-test-focused.sh --batch UIQL-007 --only-testing AmbitionsTests/MotionCurrentScreenTests/testAMB574MotionObjectStagePrimitiveContractReplacesLanePanels` | 0 | `artifacts/ui-quality-lockdown/script-output/UIQL-007-motion-object-stage-primitive-focused-test-final-20260611T105802Z.log` |
| `scripts/ambitions-xcode-test-focused.sh --batch UIQL-007 --only-testing AmbitionsTests/MotionCurrentScreenTests/testEachMotionCurrentStateTracesSourceProofAndReceipt` | 0 | `artifacts/ui-quality-lockdown/script-output/UIQL-007-motion-source-proof-receipt-focused-test-final-20260611T105916Z.log` |
| `scripts/ambitions-xcode-test-focused.sh --batch UIQL-007 --only-testing AmbitionsTests/MotionCurrentScreenTests/testMotionCurrentCopyAvoidsForbiddenSurfaceFraming` | 0 | `artifacts/ui-quality-lockdown/script-output/UIQL-007-motion-copy-forbidden-focused-test-final-20260611T110733Z.log` |
| `scripts/ambitions-xcode-test-focused.sh --batch UIQL-007 --only-testing AmbitionsUITests/AmbitionsUITests/testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces` | 0 | `artifacts/ui-quality-lockdown/script-output/UIQL-007-motion-current-ui-test-folded-final-20260611T110509Z.log` |

Final focused tests executed 1 test each with 0 failures. The folded UI selector executed 1 UI test and verified `motion.current.field`, `motion.current.fact.source`, `motion.current.fact.proof`, and `motion.current.fact.receipt`.

## Yellow Tooling Limits

- The Xcode wrapper still reports missing `.xcresult` bundles after successful build/test footers. This is retained as a tooling Yellow, not product Yellow.
- Earlier concurrent Motion unit selector attempts returned zero executed tests and are repair evidence only.
- The first standalone UIQL-007 UI selector returned zero executed tests; final proof uses the folded canonical shell selector that executed 1 test.
- Linear issue `UIQL-007` was not found by the available connector fetch path. Manual closeout text is below.

## Non-Claims

This proof does not claim:

- full accessibility certification
- VoiceOver order certification
- Dynamic Type matrix completion beyond the preserved accessibility-size rendering path and current tests
- Reduce Motion, Reduce Transparency, or Increase Contrast certification
- physical-device proof
- performance proof
- privacy/legal approval
- owner approval
- TestFlight, App Store, or release readiness
- PLOS runtime completeness
- UIQL-008 or later completion

## Manual Linear Closeout

Use this if the Linear issue remains unavailable:

```text
UIQL-007 Motion / Motion Current quality gate closed as scoped Green.

- Pushed to main: yes, after commit is pushed
- App source changed: yes, scoped to Motion first-viewport UI
- Motion first viewport now shows Motion Current with readable Source / Proof / Receipt facts.
- Native dock no longer covers Motion Current text; it covers blank clearance only.
- Pulse/dashboard/score/streak/feed/task-list anatomy not visible in scoped proof path.
- Validation:
  - git diff --check: passed
  - uiql-scan-banned-copy.sh: passed
  - uiql-scan-card-anatomy.sh: passed
  - uiql-mini-regression.sh: passed
  - build-for-testing UIQL-007: passed
  - Motion object-stage primitive focused test: passed, 1 executed
  - Motion source/proof/receipt focused test: passed, 1 executed
  - Motion forbidden-copy focused test: passed, 1 executed
  - canonical shell UI test with Motion fact assertions: passed, 1 executed
- Screenshot proof:
  - artifacts/ui-quality-lockdown/screenshots/UIQL-007-motion-current-before.png
  - artifacts/ui-quality-lockdown/screenshots/UIQL-007-motion-current-final.png
- Yellow tooling limits:
  - wrapper .xcresult bundle warnings remain tooling-only
  - earlier zero-test selector attempts retained as repair evidence only
  - Linear issue lookup unavailable through current connector
- Owner approval claimed: no
- Release/TestFlight/App Store readiness claimed: no
```
