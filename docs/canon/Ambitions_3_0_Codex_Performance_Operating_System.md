# Ambitions 3.0 — Codex Performance Operating System

Status: Historical supporting canon; subordinate to `docs/truth/*`
Last updated: 2026-04-30

## Purpose

This document defines how Codex should work on Ambitions 3.0 so future runs are faster, safer, more truthful, and more valuable.

It is broader than skills. It governs source truth, context loading, task routing, dependency discipline, validation, recovery, stale-doc protection, and release-claim discipline.

## Operating Philosophy

Codex should behave like a principal engineer and product-system owner:

- Ground in current repo truth before edits.
- Prefer Ambitions 3.0 canon over older docs.
- Build through primitives and state machines, not raw idea banks.
- Keep changes scoped, reversible, and evidence-backed.
- Improve the system while protecting product identity.
- Report PARTIAL or FAIL honestly when evidence is incomplete.

## Ambitions 3.0 Source Hierarchy

1. `README.md`
2. `docs/README.md`
3. `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
4. `docs/canon/Ambitions_3_0_Front_End_Redesign_Index.md`
5. `docs/canon/Ambitions_3_0_Rebuild_Operating_Model.md`
6. `docs/canon/Ambitions_3_0_Documentation_System_Index.md`
7. `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
8. `docs/canon/Ambitions_3_0_Product_Language_System.md`
9. The target Ambitions 3.0 primitive, surface, state-machine, privacy, accessibility, QA, release, or dependency doc.
10. `docs/codex/BATCH_REGISTRY.md` for implementation status truth only.

Older docs are supporting context only where Ambitions 3.0 explicitly keeps them binding.

## Codex Modes

| Mode | Use when | Primary output |
|---|---|---|
| Recon Mode | Repo truth, status, source-order, or stale-local risk is unclear. | Current truth summary and risk list. |
| Audit Mode | Asked to inspect, compare, inventory, or find gaps. | Audit file with evidence and next fixes. |
| Planning Mode | Multi-file or risky work needs a safe path. | Touch budget, file list, validation plan. |
| Feature Build Mode | Implementing product behavior. | Code, tests, docs/status update. |
| UI Build Mode | Building SwiftUI surfaces or components. | UI code, previews/fixtures, UI-specific validation. |
| Refactor Mode | Reshaping code without changing behavior. | Compatibility-preserving diff and regression proof. |
| Test Mode | Adding or fixing tests. | Focused test coverage and command evidence. |
| Copy/Language Mode | Visible text, App Intent copy, docs language, or copy guards. | Copy diff plus scan evidence. |
| Privacy/Trust Mode | Memory, receipts, proof, personalization, export/import, external surfaces. | Privacy posture and consent evidence. |
| Accessibility Mode | Labels, Dynamic Type, Reduce Motion, motor, contrast, VoiceOver. | Accessibility notes and test/manual proof requirements. |
| Dependency Mode | Tooling, packages, CI, scripts, or local setup changes. | Dependency decision record and rollback plan. |
| Release Gate Mode | Readiness, TestFlight, App Store, device, archive, claims. | Gate report with blocked/unblocked claims. |
| Cleanup Mode | Generated artifacts, stale docs, indexes, repo hygiene. | Cleanup diff and inventory proof. |
| Recovery Mode | Build/test/git/tooling failure or bad Codex run. | Root cause, bounded fix, and retry/stop decision. |
| Closeout Mode | Work is ready to stage/commit/push/report. | Final evidence, risks, next prompt. |

## Task Routing

1. Identify whether the task is docs, code, UI, test, dependency, release, cleanup, or recovery.
2. Classify XS/S/M/L/XL/XXL width with `Ambitions_3_0_Task_Width_And_Batch_Combining_Gate.md`.
3. Split XXL or disallowed multi-primitive work before edits.
4. Choose the smallest `.codex/context-packs/*.md` file that covers the work.
5. Choose the relevant `.codex/skills/*.md` file; combine skills only when ownership is clear.
6. Choose the operation protocol under `.codex/operations/`.
7. Choose a focused validation pack under `.codex/validation/`.
8. Escalate to broader validation only when touched paths or risk demand it.

## FAANG-Team Role Review

Use `Ambitions_3_0_FAANG_Team_Operating_Model.md` to pick role passes by task size. XS/S work stays light. M/L work adds relevant product, design, content, accessibility, privacy, QA, or engineering review. XL work requires explicit checkpoints, TPM/release ownership, and no single-commit mega-change.

## Ready / Done Gates

Use `Ambitions_3_0_Definition_Of_Ready_And_Done.md` before and after non-trivial implementation. Ready means the primitive, surface, acceptance criteria, allowed files, forbidden files, validation pack, copy/accessibility/privacy/test/release impact, and task width are known. Done means implementation, evidence, docs/status truth, closeout, and next prompt are all present or explicitly blocked.

## Skill Selection

Skills are execution checklists, not permission to widen scope. Prefer one primary skill and one supporting skill. When skills disagree, Ambitions 3.0 source truth and current repo code win.

## Context Loading

Load context in layers:

1. Required read order.
2. One context pack.
3. Target docs named by that context pack.
4. Target source/test files discovered with `rg` or `git ls-files`.
5. Previous reports only when they directly affect the task.

Avoid reading huge historical docs unless a current 3.0 doc points to them.

## Touch Budgets

Before edits, name primary files, secondary files, and validation files. Do not modify unrelated app features during docs/tooling passes. Do not change product behavior while building Codex infrastructure unless a narrow test expectation must be aligned to current repo truth.

## Prompt Compression

Future prompts should include: goal, mode, active docs, allowed files, forbidden scope, validation pack, closeout format. Use `.codex/templates/` rather than long bespoke prompts.

## Dependency Gatekeeping

Default to no new runtime dependencies. Xcode, XcodeGen, Swift Package Manager, Ruby from macOS/Xcode, shell tools, and local Markdown/scripts are enough for most work. Any new dependency needs purpose, install command, risk, removal path, and validation command.

## Local Mac Validation

Use local commands first:

```bash
git status --short
xcodegen generate
xcrun simctl list devices available | grep -E 'iPhone' | head -20
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' build CODE_SIGNING_ALLOWED=NO
```

Use `iPhone 17` when `iPhone 16` is unavailable and record the destination.

## Build/Test Strategy

- Build after meaningful code/project changes.
- Run focused tests for touched code.
- Run copy/privacy/accessibility scans for affected surfaces.
- Run full UI suite only when the validation pack requires it or focused UI proof suggests broader risk.
- Current full UI suite has known failures from the FAANG handoff audit; do not hide that failure.

## Failure Recovery

Classify failures as repo, environment/tooling, simulator, dependency, flaky, or unclear. Retry only when the next attempt is narrower and informed by the failure. Stop when the next action would be destructive, speculative, or require unavailable human/device proof.

## Evidence Reporting

Every closeout must list files changed, commands run, PASS/PARTIAL/FAIL results, what was not verified, remaining risks, and the next exact prompt.

## Release Claim Discipline

Do not claim release readiness, App Store readiness, TestFlight readiness, public accessibility verification, device verification, or FAANG handoff readiness unless every relevant gate has current evidence.

## Stale-Doc Prevention

- Active docs must point to Ambitions 3.0 first.
- Historical docs may mention older canon only as history.
- New status docs must distinguish canonized, implemented, tested, device-verified, and release-ready.
- Run the stale active-guidance scan before closeout on governance/docs changes.

## Handoff-Readiness Preservation

The FAANG handoff audit remains the baseline until replaced by a later report. New Codex work must improve or preserve file inventory, traceability, generated-artifact hygiene, active-doc clarity, migration debt documentation, and validation evidence.

## Quality Gates

A pass is complete only when:

- source truth is current,
- every created skill/pack/template is indexed,
- validation ran or was blocked with reason,
- no generated junk is staged,
- release claims are conservative,
- next work is explicit.

## What Codex Must Never Do

- Start from stale 2.0/v2 docs as active direction.
- Create new top-level destinations.
- Add app runtime dependencies casually.
- Replace XcodeGen.
- Hide failing tests.
- Claim implementation from canon docs alone.
- Delete useful history to make the repo look clean.
- Silently mutate calendar/sync/account/release claims.

## Adopted Developer Tooling Layer

Codex should use the local developer tooling layer when it materially improves speed or evidence quality:

- Run `scripts/validate-dev-tools.sh` before major local work or when a run depends on optional developer tools.
- Run `scripts/run-doc-qa.sh` for docs-heavy changes. Use `DOC_QA_STRICT=1 scripts/run-doc-qa.sh` only for deliberate blocking docs gates.
- Run `scripts/build-local.sh` for app build validation; it regenerates the Xcode project, selects an available iPhone simulator, preserves `xcodebuild` status, and uses `xcbeautify` when installed.
- Run `scripts/test-local.sh` for full local test validation, while recording known UI smoke failures honestly.
- Use `Brewfile` for adopted developer tools and `Brewfile.optional-later` only when policy promotes staged tools.
- Use `.codex/validation/dependency-drift-pack.md` when Brewfile, scripts, tooling docs, or dependency policy changes.
- Use `.codex/validation/local-ci-parity-pack.md` before claiming local/CI parity.

## Batch Train Orchestrator

When a prompt spans multiple Ambitions 3.0 batches, load `docs/codex/AMBITIONS_3_0_BATCH_TRAIN_ORCHESTRATOR.md`, select exactly one manifest under `docs/codex/batch-trains/`, initialize `.codex/reports/current-batch-train-state.md`, and continue only on Green. Yellow/Red stops with repair/resume material. FAANG handoff remains PARTIAL unless its gate is re-run and passes.
