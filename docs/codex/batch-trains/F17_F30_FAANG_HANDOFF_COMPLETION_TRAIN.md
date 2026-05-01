# F17-F30 FAANG Handoff Completion Train

Path: `docs/codex/batch-trains/F17_F30_FAANG_HANDOFF_COMPLETION_TRAIN.md`
Status: Active release / architecture / product quality train manifest
Created: 2026-05-01

## Purpose

Complete the Ambitions 3.0 FAANG handoff path from F17 Shell/Meridian planning through final handoff packaging and Beyond 3.0 continuation planning without weakening evidence gates or overclaiming release readiness.

This train is not permission to blindly implement. It is a gated train. Codex may continue automatically only on Green.

## Current Entry Point

F17 Shell / Meridian Planning & Readiness Audit.

F18 implementation is blocked unless F17 produces a Green architecture and ownership plan.

FAANG handoff remains PARTIAL until F27 explicitly reruns the FAANG handoff gate and passes.

## Train Type

Release / Architecture / Product Quality Train.

Risk class: Critical.

## Batch Order

| Batch | Name | Run rule |
|---|---|---|
| F17 | Shell / Meridian Planning & Readiness Audit | First; planning-only by default. |
| F18 | Feature-Flagged Meridian Shell Implementation | Only if F17 Green. |
| F18.5 | Shell Architecture Hardening | Conditional after F18 trigger. |
| F19 | Shell Route Parity / Fallback Safety | After F18 or F18.5 Green. |
| F20 | External Surfaces Privacy-Safe Projection | After F19 Green. |
| F21 | Full UI Smoke Stabilization | May run with known prior UI smoke failures. |
| F21.5 | UI Flake / Reliability Hardening | Conditional after F21 trigger. |
| F22 | Product Language + Doc QA Final Migration | May run with known doc QA backlog. |
| F22.5 | Doc QA Backlog Closure | Conditional after F22 trigger. |
| F23 | Accessibility / ADHD / Dynamic Type / VoiceOver QA | After F22 or F22.5 Green. |
| F24 | Privacy / Trust / Local Data / Redaction QA | After F23 Green. |
| F24.5 | Privacy Threat Model Closure | Conditional after F24 trigger. |
| F25 | Device / Performance / State Restoration / Edge Case QA | After F24 or F24.5 Green. |
| F26 | App Store / Marketing / Demo Truth | After F25 Green. |
| F27 | Final FAANG Handoff Gate Rerun | Required before any handoff-ready claim. |
| F28 | FAANG Handoff Repair Train | Conditional only if F27 PARTIAL/FAIL. |
| F29 | Final Handoff Package + Engineer Onboarding | Only after F27 PASS. |
| F30 | Beyond 3.0 Continuation Plan | Only after F29. |

## Accepted Background Yellow Conditions

These are recorded but do not stop the train by themselves unless worsened by the current batch:

- doc QA advisory backlog unchanged
- known full UI smoke failures before F21
- pre-existing architecture extraction warnings unchanged
- documented compatibility seams unchanged
- legacy historical docs explicitly marked non-active

## New Yellow Stops

Stop and write a repair or decision prompt if a current batch introduces:

- new doc QA violations in touched files
- new UI smoke failure in touched scope
- new architecture warning caused by touched files
- product/canon ambiguity
- copy/privacy/accessibility uncertainty
- shell routing ambiguity
- App Store claim ambiguity
- missing evidence for a readiness claim
- device proof unavailable when a device-specific claim is attempted

## Red Stops

Stop immediately if:

- build fails
- focused tests fail
- `.github/workflows/` is touched
- runtime dependency is added
- privacy-sensitive data leaks
- hidden memory or personalization behavior is added
- shell breaks destination access
- fallback navigation is removed
- UI tests are weakened to pass
- a release claim is made without evidence
- commit or push fails
- validation cannot be trusted

## Allowed Files

- `docs/codex/**`
- `docs/canon/**` only for active tracking, release gates, handoff gates, and documented status truth
- `docs/audits/**`
- `docs/marketing/**` for F26 only
- `docs/handoff/**` for F29 only
- `.codex/reports/**`
- `Native/Ambitions/**`, `AppUI/**`, `Sources/**`, `Native/AmbitionsTests/**`, `Native/AmbitionsUITests/**`, and extension/widget paths only when a specific implementation or QA batch allows them
- `project.yml` only if an approved code batch requires XcodeGen target wiring

## Forbidden Files

- `.github/workflows/**`
- runtime dependency manifests unless explicitly approved
- generated output under `tmp/`, `output/`, DerivedData, or `.xcresult`
- unrelated historical docs
- any file used to remove native fallback navigation, delete route access, or weaken UI tests without replacement/retirement evidence

## Gate Requirements

### F17 Green

- shell ownership map
- route parity map
- fallback navigation plan
- feature flag plan
- rollback plan
- accessibility fallback plan
- deep link/App Intent/widget implication map
- tests required for F18/F19
- no unresolved shell ambiguity

### F18 Green

- feature-flagged shell implementation
- native fallback preserved
- top-level destinations reachable
- build passes
- focused shell tests pass
- no F17 route contract broken

### F19 Green

- route parity tests
- fallback safety tests
- state restoration tests where applicable
- one-tap destination access proof
- shell rollback proof

### F20 Green

- App Intents, Shortcuts, widget, and external projection audit and safe implementation where scoped
- privacy-safe projection tests
- no sensitive lock-screen or external leakage
- route handoff tests

### F21 Green

- full UI smoke suite passing, or every remaining failure retired, replaced, or classified with accepted evidence
- no product promise weakened
- UI Test Contract report updated

### F22 Green

- active user-facing legacy language removed
- copy guard passes for active app/docs paths
- doc QA improved materially
- markdown/link/deprecated-language backlog closed or explicitly scoped to F22.5

### F23 Green

- Dynamic Type proof
- VoiceOver label review
- Reduce Motion consideration
- touch target review
- no color-only meaning
- ADHD/cognitive-load review evidence
- focused accessibility checks updated

### F24 Green

- redaction/privacy tests
- What Ambitions Knows evidence
- memory consent proof
- receipt/proof visibility proof
- external-surface privacy proof
- no hidden personalization claims

### F25 Green

- device or device-substitute evidence clearly labeled
- performance, cold launch, large state, state restoration, and edge cases reviewed
- no false physical-device claim if no physical-device proof exists

### F26 Green

- screenshots/demo claims match implemented behavior
- App Store copy truthful
- privacy, ADHD, and subscription claims reviewed
- no marketing overclaim
- investor/demo script truthful

### F27 Green

- FAANG handoff readiness gate rerun
- build/test evidence
- file inventory
- legacy language scan
- internal identifier scan
- traceability
- orphan docs check
- release claim truth
- PASS only if all required gates pass

### F28/F29/F30 Gates

- F28 runs only if F27 is PARTIAL/FAIL and repairs only F27 blockers.
- F29 runs only after F27 PASS.
- F30 runs only after F29.

## Validation Commands

Use the narrowest relevant set for each batch:

```bash
git status --short
scripts/validate-dev-tools.sh || true
scripts/batch-train-preflight.sh || true
scripts/batch-train-gate-check.sh || true
scripts/build-local.sh
scripts/test-local.sh || true
scripts/run-doc-qa.sh || true
scripts/swiftui-architecture-scan.sh || true
git diff --check
```

## Commit Strategy

Use one path-limited commit per Green batch. Push each Green batch before continuing. Stop if commit or push fails.

## Final Report Paths

- Setup: `docs/audits/ambitions-3-0-f17-f30-faang-handoff-completion-train-setup-report.md`
- F17: `docs/audits/ambitions-3-0-f17-shell-meridian-readiness-report.md`
- Final gate: `docs/audits/ambitions-3-0-final-faang-handoff-readiness-report.md`
- Final closeout: `docs/audits/ambitions-3-0-final-train-closeout-report.md`
