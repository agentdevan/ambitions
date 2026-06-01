<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AFEP-017 — Continuity Surfaces Pack

Linear issue: AMB-411

## Purpose

Make widgets, Live Activities, Handoff, and related continuity surfaces speak the same canonical object grammar.

## Source Truth And Canon Constraints

- Read and obey `docs/truth/*`, `AGENTS.md`, `README.md`, `docs/README.md`, `project.yml`, and `Package.swift` before patching.
- Preserve top-level IA exactly as `Today / Goals / Capture / Time / You`.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Preserve local-first, deterministic, privacy-first behavior.
- Do not add cloud AI, analytics, hosted backend, hosted CI, signing/upload automation, external SDKs, or paid services.
- Do not create parallel product grammar. Extend existing external surface, reopening, widget, handoff, Live Activity, app routing, SourceRecord, ReplayTrace, Receipt, What Ambitions knows, and reset/delete owners where applicable.
- Do not claim device, Spotlight, Siri, Shortcuts, widget, Live Activity, accessibility, privacy/legal, release, TestFlight, App Store, CI, or full-suite readiness without current evidence.

## Scope

Implement the smallest source-changing slice that satisfies AFEP-017:

- Map widget, Live Activity, Handoff, and related continuity models to canonical object grammar.
- Add safe metadata boundaries for lock screen, widget, and handoff contexts.
- Add exact reopen routing where current app routes prove support, otherwise graceful fallback to canonical roots.
- Add state restoration/continuation tests at the existing app/service boundary.
- Preserve rollback to AFRI continuity routes if evidence does not pass.

Prefer existing owners and files. Likely owners include:

- `Native/Ambitions/ExternalSnapshots/ExternalSurfaceActionPayloads.swift`
- `Native/Ambitions/App/AppExternalRouting.swift`
- existing external/widget/handoff/Live Activity projection or contract files under `Native/Ambitions`
- existing focused tests under `Native/AmbitionsTests/App/` or the relevant owner test directory

Do not touch persistence/schema, entitlements, privacy manifest, package dependencies, project dependencies, production signing, widget/share extension runtime files, or generated project files unless a compile blocker forces a narrowly documented compatibility fix.

## Required Proof Artifacts

Create or update these batch proof artifacts:

- `build/reports/afep/AFEP-017/continuity-surface-packet.md`
- `build/reports/afep/AFEP-017/continuity-screenshot-packet.md`
- `build/reports/afep/AFEP-017/privacy-metadata-reopen-routing-report.md`

The screenshot packet may be a contract/no-screenshot packet if no UI/device screenshot is run. It must say exactly what was and was not proven.

## Acceptance Gates

Green requires:

- Continuity surfaces do not create parallel product grammar.
- Metadata is safe for lock screen, widget, and handoff contexts.
- Reopen routes are exact where proven or graceful to canonical roots where not.
- Tests demonstrate safe metadata and routing behavior.
- Proof artifacts separate verified, not passed, not verified, blocked, and human/device follow-up.

Yellow is acceptable only if selected continuity surfaces remain gated while app routes remain canonical and the owner, safety reason, no-claim boundary, and follow-up gate are explicit.

Red stop conditions:

- Parallel grammar.
- Private lock-screen/widget/handoff metadata leakage.
- Broken reopen path without a graceful fallback.
- Required external platform/device claims without proof.

## Validation

Run the strongest relevant validation available through repo wrappers:

- `python3 scripts/ambitions-champion-coverage-check.py --batch AFEP-017`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AFEP-017 --prompt prompts/batches/AFEP-017.md --batch-type source-changing`
- `xcodegen generate`
- `make xcode-build-for-testing BATCH=AFEP-017`
- focused `make xcode-focused-test` lanes with fully qualified XCTest identifiers for every changed owner test class
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AFEP-017 --prompt prompts/batches/AFEP-017.md --changed-from <BASE_SHA> --batch-type source-changing`
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
