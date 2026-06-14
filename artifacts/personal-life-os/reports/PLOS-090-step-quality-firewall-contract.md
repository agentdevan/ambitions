# AMB-711 / PLOS-090 Step Quality Firewall Contract Report

PLOS child closeout

Linear issue: AMB-711

Parent issue: AMB-627

PLOS label: PLOS-090

Linear project: Ambitions Personal Life OS Runtime Master Build Program (`3cd7ed7e-96ca-4d18-ba27-60d533b4364c`)

## Scope

AMB-711 installs the downstream Step Quality Firewall contract for M09 and the minimum M10 dependency surface. It creates contract-level, machine-readable, and runnable validation artifacts for `StepQualityInput`, `StepQualityVerdict`, accepted/rejected fixtures, generic-step rejection, capability-fit rejection, source/proof rejection, accessibility rejection, elasticity rejection, and repair-path linkage.

This is contract/control-plane scope. It does not implement production Swift runtime wiring, app UI, generated Step behavior, Step Graph Compiler repair implementation, Source Atlas pack publication, R2 writes, release proof, privacy/legal approval, accessibility certification, device proof, measured performance proof, M09 parent completion, M10 Golden Slice readiness, or full PLOS completion.

## Files And Artifacts

- `artifacts/personal-life-os/step-quality/STEP_QUALITY_FIREWALL_CONTRACT.md`: human-readable Step Quality Firewall contract and downstream consumer map.
- `artifacts/personal-life-os/step-quality/STEP_QUALITY_FIREWALL_CONTRACT.json`: machine-readable `StepQualityInput` and `StepQualityVerdict` contract.
- `artifacts/personal-life-os/step-quality/STEP_QUALITY_FIREWALL_FIXTURES.json`: accepted and rejected fixture matrix.
- `scripts/codex/step-quality-firewall-validate.py`: local runnable validator and draft test harness for the M10 dependency.
- `artifacts/personal-life-os/validation/AMB-711-required-step-quality-contract-search-log.txt`: required contract discoverability search log.
- `artifacts/personal-life-os/validation/AMB-711-step-quality-source-ownership-search-log.txt`: existing-first source ownership search log.
- `artifacts/personal-life-os/validation/AMB-711-step-quality-search-summary.txt`: bounded search summary.
- `artifacts/plos-runtime/reviewer-output/AMB-711-step-quality-contract-review.md`: read-only reviewer pass.

## Downstream Consumer

The contract explicitly names these consumers:

- AMB-712 / PLOS-091 for generic blocked-list scanner expansion.
- AMB-713 / PLOS-092 for context-fit validation.
- AMB-714 / PLOS-093 for source/proof validation.
- AMB-715 / PLOS-094 for accessibility and VoiceOver validation.
- AMB-716 / PLOS-095 for elasticity coverage validation.
- AMB-717 / PLOS-096 for compiler repair path and safe fallback.
- AMB-617 / PLOS-M10 for the minimum runnable validator dependency before Golden Slice runtime consumption.

## Existing-First Ownership Proof

AMB-711 inspected live source before choosing artifact/script scope:

- `Native/Ambitions/Runtime/StepCandidateFieldGenerator.swift` owns Step candidate generation, ranking, rejection, traces, and accessibility summaries.
- `Native/Ambitions/Runtime/SourceAtlasStepCandidateFieldBridge.swift` owns Source Atlas Step candidate expansion and source trace preservation.
- `Native/Ambitions/Domain/GoalEngine/StepCandidateFieldModels.swift` owns Step candidate model seams, validity, rejection records, risk, proof, source, and elastic variants.
- `Native/Ambitions/Domain/GoalEngine/GoalEngineStepRewriter.swift` owns existing vague Step copy rewriting seams.
- `Native/Ambitions/Domain/ProjectStepOperationModels.swift` and `Native/Ambitions/Runtime/StepReallocationRuntimeBridge.swift` own reallocation and mutation-impact seams.

No app Swift files were changed.

## Green / Yellow / Red Status

Green/Yellow/Red status: Green for AMB-711 contract/control-plane scope.

Green evidence:

- `StepQualityInput` and `StepQualityVerdict` are explicit in the machine-readable contract.
- Accepted and rejected fixture sets exist.
- The local validator passes and reports `m10_dependency=runnable`.
- Fixture coverage rejects generic Steps, beginner/expert mismatches, expert-after-proof starter mismatch, stale source, revoked source, missing proof expectation, missing accessibility semantics, and missing elasticity coverage.
- PLOS labels were used only as local aliases after live AMB binding; Linear reads/writes used AMB identifiers.

Yellow limits:

- Production Swift/runtime Step Quality Firewall integration remains future-owned.
- Full generic phrase scanner, context-fit validator, source/proof validator, accessibility validator, elasticity validator, and compiler repair implementation remain owned by AMB-712 through AMB-717.
- M09 parent completion remains future-owned until all active M09 children are Done, duplicate/canceled/non-blocking, or accepted Yellow with no-claim boundaries.
- M10 Golden Slice runtime consumption remains blocked until M09 is closed correctly.

Red blockers: none for AMB-711 scoped contract/control-plane work.

## Validation

Validation run:

- `git status --short --branch` - pass, `main` tracking `origin/main` before edits.
- `git pull --ff-only` - pass, already up to date.
- Live Linear fetch for `AMB-627` - pass, parent resolved by AMB identifier.
- Live Linear fetch for `AMB-711` - pass, child resolved by AMB identifier.
- Live Linear child list for parent `AMB-627` - pass, canonical active children AMB-711 through AMB-717; AMB-773 through AMB-779 Duplicate/archived/canceled.
- `scripts/codex/program-preflight.sh plos` - pass, `artifacts/plos-runtime/script-output/program-preflight-20260613T214205.log`.
- `scripts/codex/program-phase-gate.sh plos M09` - pass, `artifacts/plos-runtime/script-output/program-phase-gate-M09-20260613T214205.log`.
- `scripts/codex/program-preflight.sh plos` - pass after AMB-711 control-plane updates, `artifacts/plos-runtime/script-output/program-preflight-20260613T215038.log`.
- `scripts/codex/program-phase-gate.sh plos M09` - pass after AMB-711 control-plane updates, `artifacts/plos-runtime/script-output/program-phase-gate-M09-20260613T215038.log`.
- `python3 scripts/codex/plos-readiness-validate.py` - pass.
- `python3 scripts/codex/source-atlas-readiness-validate.py --self-test` - pass.
- `python3 scripts/codex/source-atlas-readiness-validate.py` - pass.
- `python3 -m json.tool artifacts/personal-life-os/step-quality/STEP_QUALITY_FIREWALL_CONTRACT.json` - pass.
- `python3 -m json.tool artifacts/personal-life-os/step-quality/STEP_QUALITY_FIREWALL_FIXTURES.json` - pass.
- `python3 scripts/codex/step-quality-firewall-validate.py` - pass.
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-090-step-quality-firewall-contract.md` - pass.
- `git diff --check` - pass.
- `bash scripts/codex/program-proof-index.sh plos` - pass, wrote 114 entries, `artifacts/plos-runtime/script-output/program-proof-index-20260613T215045.log`.
- `rg -n "Step Quality Firewall|StepQualityInput|StepQualityVerdict" . --glob '!artifacts/personal-life-os/validation/*.txt' --glob '!artifacts/plos-runtime/script-output/*.log' --glob '!output/**' --glob '!DerivedData/**'` - pass, log at `artifacts/personal-life-os/validation/AMB-711-required-step-quality-contract-search-log.txt`.
- `rg -n "StepCandidateFieldGenerator|SourceAtlasStepCandidateFieldBridge|StepCandidateField|GoalEngineStepRewriter|StepReallocationRuntimeBridge|CandidateValidity|StepCandidateRejectionRecord|accessibilitySummary" Native/Ambitions/Domain Native/Ambitions/Runtime Native/AmbitionsTests --glob '*.swift'` - pass, log at `artifacts/personal-life-os/validation/AMB-711-step-quality-source-ownership-search-log.txt`.

Validation not run:

- Xcode build/test lanes were not run because AMB-711 changed no app source, app tests, package manifests, Xcode project, entitlements, privacy manifest, or runtime Swift integration.
- UI, screenshot, VoiceOver, Dynamic Type, Reduce Motion, Increase Contrast, physical-device, performance, TestFlight, App Store, privacy/legal, and App Review validation were not run and are not claimed.

## Closeout Fields

Pushed to main: no, pending AMB-711 commit after local validation

Push hash: not pushed yet

App source changed: no

Runtime features implemented: no

PLOS-M00 executed: yes, prior governance scope complete only

Linear identifiers used: AMB issue identifiers only

Owner approval claimed: no

Release/TestFlight/App Store readiness claimed: no

Next recommended action: After AMB-711 is committed, pushed to `main`, and updated in Linear, re-fetch AMB-627 / PLOS-M09 and current children, then start AMB-712 / PLOS-091 only if no new in-scope M09 child was added ahead of it.

## Rollback

Revert the AMB-711 contract artifacts, validator, validation logs/summaries, report, reviewer output, PLOS control-plane updates, proof ledger, and proof-index updates if the contract creates unsafe downstream ambiguity or validator false Green.
