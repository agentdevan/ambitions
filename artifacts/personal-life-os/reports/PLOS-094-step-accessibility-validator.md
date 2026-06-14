# AMB-715 / PLOS-094 Step Accessibility Validator Report

PLOS child closeout

Linear issue: AMB-715

Parent issue: AMB-627

PLOS label: PLOS-094

Linear project: Ambitions Personal Life OS Runtime Master Build Program (`3cd7ed7e-96ca-4d18-ba27-60d533b4364c`)

## Scope

AMB-715 defines the downstream Step accessibility and VoiceOver validator for M09. It extends the AMB-711 Step Quality Firewall contract with VoiceOver label, value, hint, non-visual summary, visual-only meaning, generic-label, Dynamic Type, and Reduce Motion blocking codes; accepted/rejected accessibility fixtures; `StepQualityVerdict` linkage; and compiler repair fallback linkage.

This is contract/control-plane scope. It does not implement production Swift runtime wiring, app UI, generated Step behavior, Step Graph Compiler repair implementation, Source Atlas pack publication, R2 writes, release proof, privacy/legal approval, accessibility certification, VoiceOver verification, Dynamic Type verification, Reduce Motion verification, device proof, measured performance proof, M09 parent completion, M10 Golden Slice readiness, or full PLOS completion.

## Files And Artifacts

- `artifacts/personal-life-os/step-quality/STEP_ACCESSIBILITY_VALIDATOR.md`: human-readable accessibility validator contract.
- `artifacts/personal-life-os/step-quality/STEP_ACCESSIBILITY_VALIDATOR.json`: machine-readable accessibility rules.
- `artifacts/personal-life-os/step-quality/STEP_ACCESSIBILITY_VALIDATOR_FIXTURES.json`: accepted and rejected accessibility fixture matrix.
- `artifacts/personal-life-os/step-quality/STEP_QUALITY_FIREWALL_CONTRACT.md`: base contract linkage to AMB-715 accessibility authority.
- `artifacts/personal-life-os/step-quality/STEP_QUALITY_FIREWALL_CONTRACT.json`: base contract linkage and accessibility blocking codes.
- `scripts/codex/step-quality-firewall-validate.py`: existing validator extended to load accessibility rules and fixtures.
- `artifacts/personal-life-os/validation/AMB-715-accessibility-required-search-log.txt`: required accessibility search log.
- `artifacts/personal-life-os/validation/AMB-715-accessibility-source-ownership-search-log.txt`: existing-first source ownership search log.
- `artifacts/personal-life-os/validation/AMB-715-accessibility-search-summary.txt`: bounded search summary.
- `artifacts/plos-runtime/reviewer-output/AMB-715-accessibility-validator-review.md`: read-only reviewer pass.

## Downstream Consumer

The validator explicitly names these consumers:

- AMB-716 / PLOS-095 for elasticity variants that must each pass accessibility rules.
- AMB-717 / PLOS-096 for compiler repair path and safe fallback.
- AMB-617 / PLOS-M10 for minimum runnable accessibility validation before Golden Slice runtime consumption.

## Existing-First Ownership Proof

AMB-715 inspected live source before choosing artifact/script scope:

- `Native/Ambitions/Runtime/StepCandidateFieldGenerator.swift` owns current Step candidate accessibility summary generation.
- `Native/Ambitions/Domain/GoalEngine/StepCandidateFieldModels.swift` owns Step candidate seams consumed by Step Quality fixtures.
- `Native/Ambitions/App/ShellCommandModels.swift`, `Native/Ambitions/App/AppShellView.swift`, and `Native/Ambitions/App/AmbitionsRootView.swift` own current shell accessibility labels, values, hints, identifiers, and Reduce Motion posture.
- `Native/Ambitions/Domain/ScreenContractModels.swift` owns screen-level accessibility requirements for future runtime/UI proof.
- `Native/Ambitions/Features/You/YouRootSurface.swift` and `Native/Ambitions/Features/You/YouScreen.swift` show current grouped VoiceOver and Dynamic Type patterns.

No app Swift files were changed.

## Green / Yellow / Red Status

Green/Yellow/Red status: Green for AMB-715 accessibility validator/control-plane scope.

Green evidence:

- Accessibility rules are machine-readable.
- Accessibility fixture set includes accepted accessibility and rejected missing label/value/hint/summary, visual-only, generic-label, Dynamic Type unsafe, and Reduce Motion unsafe cases.
- The local validator passes and reports `accessibility_validator=runnable`.
- Accessibility failures link to `StepQualityVerdict` blocking codes.
- Accessibility failures require Step Graph Compiler repair and safe fallback linkage.
- PLOS labels were used only as local aliases after live AMB binding; Linear reads/writes used AMB identifiers.

Yellow limits:

- Production Swift/runtime Step Quality Firewall integration remains future-owned.
- UI implementation and actual VoiceOver, Dynamic Type, Reduce Motion, screenshot, device, and accessibility certification proof remain future-owned.
- Elasticity and compiler repair implementation remain owned by AMB-716 through AMB-717.
- M09 parent completion remains future-owned until all active M09 children are Done, duplicate/canceled/non-blocking, or accepted Yellow with no-claim boundaries.
- M10 Golden Slice runtime consumption remains blocked until M09 is closed correctly.

Red blockers: none for AMB-715 scoped accessibility validator/control-plane work.

## Validation

Validation run:

- `git status --short --branch` - pass, `main` tracking `origin/main` before edits.
- `git pull --ff-only` - pass, already up to date.
- Live Linear fetch for `AMB-627` - pass, parent resolved by AMB identifier.
- Live Linear fetch for `AMB-715` - pass, child resolved by AMB identifier.
- Live Linear child list for parent `AMB-627` - pass, AMB-711 through AMB-714 Done, AMB-715 through AMB-717 active, AMB-773 through AMB-779 Duplicate/archived/canceled.
- `scripts/codex/program-preflight.sh plos` - pass, `artifacts/plos-runtime/script-output/program-preflight-20260613T222923.log`.
- `scripts/codex/program-phase-gate.sh plos M09` - pass, `artifacts/plos-runtime/script-output/program-phase-gate-M09-20260613T222923.log`.
- `python3 -m json.tool artifacts/personal-life-os/step-quality/STEP_ACCESSIBILITY_VALIDATOR.json` - pass.
- `python3 -m json.tool artifacts/personal-life-os/step-quality/STEP_ACCESSIBILITY_VALIDATOR_FIXTURES.json` - pass.
- `python3 -m json.tool artifacts/personal-life-os/step-quality/STEP_QUALITY_FIREWALL_CONTRACT.json` - pass.
- `python3 scripts/codex/step-quality-firewall-validate.py` - pass with `accessibility_validator=runnable`.
- `rg -n "VoiceOver|accessibility|accessibilityLabel|accessibilityValue|accessibilityHint|nonVisual|Dynamic Type|Reduce Motion|StepQuality" . --glob '!artifacts/personal-life-os/validation/*.txt' --glob '!artifacts/plos-runtime/script-output/*.log' --glob '!output/**' --glob '!DerivedData/**'` - pass, log at `artifacts/personal-life-os/validation/AMB-715-accessibility-required-search-log.txt`.
- `rg -n "VoiceOver|accessibility|accessibilityLabel|accessibilityValue|accessibilityHint|nonVisual|DynamicType|Dynamic Type|ReduceMotion|Reduce Motion|StepCandidateFieldGenerator|StepCandidateFieldModels" Native/Ambitions/Domain Native/Ambitions/Runtime Native/Ambitions/App Native/Ambitions/Features Native/Ambitions/UI Native/AmbitionsTests --glob '*.swift'` - pass, log at `artifacts/personal-life-os/validation/AMB-715-accessibility-source-ownership-search-log.txt`.

Validation still required before closeout:

- `python3 scripts/codex/plos-readiness-validate.py`
- `python3 scripts/codex/source-atlas-readiness-validate.py --self-test`
- `python3 scripts/codex/source-atlas-readiness-validate.py`
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-094-step-accessibility-validator.md`
- `bash scripts/codex/program-proof-index.sh plos`
- `scripts/codex/program-preflight.sh plos`
- `scripts/codex/program-phase-gate.sh plos M09`
- `bash scripts/release-claim-safety-scan.sh`
- `git diff --check`

Validation not run:

- Xcode build/test lanes were not run because AMB-715 changed no app source, app tests, package manifests, Xcode project, entitlements, privacy manifest, or runtime Swift integration.
- UI, screenshot, VoiceOver, Dynamic Type, Reduce Motion, Increase Contrast, physical-device, performance, TestFlight, App Store, privacy/legal, and App Review validation were not run and are not claimed.

## Closeout Fields

Pushed to main: no, pending AMB-715 commit after local validation

Push hash: not pushed yet

App source changed: no

Runtime features implemented: no

PLOS-M00 executed: yes, prior governance scope complete only

Linear identifiers used: AMB issue identifiers only

Owner approval claimed: no

Release/TestFlight/App Store readiness claimed: no

Next recommended action: After AMB-715 is committed, pushed to `main`, and updated in Linear, re-fetch AMB-627 / PLOS-M09 and current children, then start AMB-716 / PLOS-095 only if no new in-scope M09 child was added ahead of it.

## Rollback

Revert the AMB-715 accessibility validator artifacts, validator changes, validation logs/summaries, report, reviewer output, PLOS control-plane updates, proof ledger, and proof-index updates if the validator creates unsafe false Green or blocks valid accessible Step copy beyond the stated contract.
