<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AFEP-018 — Lifecycle Reconciler

Linear issue: AMB-412

## Purpose

Reconcile app, extension, widget, Live Activity, background, and relaunch lifecycle events through canonical objects and deterministic state.

## Source Truth And Canon Constraints

- Read and obey `docs/truth/*`, `AGENTS.md`, `README.md`, `docs/README.md`, `project.yml`, and `Package.swift` before patching.
- Preserve top-level IA exactly as `Today / Goals / Capture / Time / You`.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Preserve local-first, deterministic, privacy-first behavior.
- Do not add cloud AI, analytics, hosted backend, hosted CI, signing/upload automation, external SDKs, or paid services.
- Do not create parallel product grammar. Extend existing lifecycle, external surface, app routing, SourceRecord, ReplayTrace, Receipt, What Ambitions knows, reset/delete, and recovery owners where applicable.
- Do not claim background execution, device relaunch, widget, Live Activity, Handoff, accessibility, privacy/legal, release, TestFlight, App Store, CI, or full-suite readiness without current evidence.

## Scope

Implement the smallest source-changing slice that satisfies AFEP-018:

- Define lifecycle reconciliation states for app, extension, widget, Live Activity, background, and relaunch contexts.
- Add deterministic stale/fresh source behavior that is inspectable by canonical object state.
- Add background maintenance boundaries that do not silently mutate user data.
- Add state restoration and relaunch/replay tests at existing app/service boundaries.
- Preserve rollback to AFRI lifecycle routes if state continuity is unstable.

Prefer existing owners and files. Likely owners include:

- `Native/Ambitions/App/AppExternalRouting.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalSurfaceActionPayloads.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalSurfaceContractModels.swift`
- existing lifecycle, external surface, SourceRecord, ReplayTrace, Receipt, app routing, and state restoration owners under `Native/Ambitions`
- existing focused tests under `Native/AmbitionsTests/App/` or the relevant owner test directory

Do not touch persistence/schema, entitlements, privacy manifest, package dependencies, project dependencies, production signing, widget/share extension runtime files, or generated project files unless a compile blocker forces a narrowly documented compatibility fix.

## Required Proof Artifacts

Create or update these batch proof artifacts:

- `build/reports/afep/AFEP-018/lifecycle-reconciliation-matrix.md`
- `build/reports/afep/AFEP-018/relaunch-replay-packet.md`
- `build/reports/afep/AFEP-018/background-maintenance-boundary-report.md`

Each packet must separate verified, not passed, not verified, blocked, and human/device follow-up.

## Acceptance Gates

Green requires:

- Relaunch and continuation preserve proof and canonical object state.
- Background maintenance does not silently mutate user data.
- Stale/fresh source state is inspectable.
- Tests demonstrate deterministic lifecycle reconciliation and replay behavior.
- Proof artifacts avoid unverified background, device, accessibility, release, or privacy/legal claims.

Yellow is acceptable only for partial lifecycle coverage with explicit fallback, owner, safety reason, no-claim boundary, and follow-up gate.

Red stop conditions:

- Silent mutation of user data.
- Lost proof or replay continuity.
- Unverified background behavior claim.
- Parallel lifecycle grammar outside canonical objects.

## Validation

Run the strongest relevant validation available through repo wrappers:

- `python3 scripts/ambitions-champion-coverage-check.py --batch AFEP-018`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AFEP-018 --prompt prompts/batches/AFEP-018.md --batch-type source-changing`
- `xcodegen generate`
- `make xcode-build-for-testing BATCH=AFEP-018`
- focused `make xcode-focused-test` lanes with fully qualified XCTest identifiers for every changed owner test class
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AFEP-018 --prompt prompts/batches/AFEP-018.md --changed-from <BASE_SHA> --batch-type source-changing`
- `git diff --check`
- `git diff --cached --check` before commit

If a wrapper reports a pass without executing tests, do not count it as proof. Rerun with fully qualified XCTest identifiers and record the boundary.

## Closeout

Include:

- Files changed and why.
- Active truth files inspected.
- Validation run with raw command names and current evidence.
- Validation not run with reason.
- Proof/claim boundaries.
- Risks or Yellow items.
- Rollback notes.
- Next eligible AFEP issue/gate.
