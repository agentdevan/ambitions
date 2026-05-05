# AQOS Tools And Skills Insertion Report
<!-- markdownlint-disable MD013 -->

Result: PASS WITH ACCEPTED YELLOW
Date: 2026-05-05
Scope: AQOS tool specifications, dependencies, report template, prompts, and reviewer skills

## Task

Add scripts, tools, dependencies, skills, and supporting prompts to simulate human FAANG-level review as much as practical inside Codex OS.

The user asked for quality to be primary and taste review to happen later, after the global train completes.

## Live State Awareness

Before changes, live run-state was fetched from `main`; the connector returned current-run-state metadata SHA `9c9c26ef201b6527bd8ee9986050d10577cb6aad`. The active global run is still moving, so this update avoided direct run-state mutation and production edits.

## Files Created

- `docs/codex/quality/AQOS_SCRIPT_AND_TOOL_MAP.md`
- `docs/codex/quality/AQOS_REPORT_TEMPLATE.md`
- `docs/codex/quality/AQOS_TOOL_DEPENDENCIES.md`
- `.codex/skills/evidence-gated-quality-reviewer.md`
- `.codex/skills/accessibility-privacy-performance-quality-reviewer.md`
- `.codex/skills/founder-vision-and-handoff-reviewer.md`
- `docs/codex/batches/AQOS_TOOLS_SKILLS_AND_SCRIPTS_PROMPT.md`
- `docs/audits/aqos-tools-and-skills-insertion-report.md`

## Executable Script Note

An attempt to create executable shell scripts directly under `scripts/` through the remote connector was blocked by the connector safety layer. To avoid fighting the connector and risking partial files, this update installs exact script specifications and a Codex-local materialization prompt.

The AQOS adoption batch must create these scripts locally:

- `scripts/aqos-impact-classifier.sh`
- `scripts/aqos-required-evidence-check.sh`
- `scripts/aqos-claim-truth-scan.sh`
- `scripts/aqos-copy-internal-term-scan.sh`
- `scripts/aqos-visual-card-stack-scan.sh`
- `scripts/aqos-architecture-fitness-scan.sh`
- `scripts/aqos-privacy-exposure-scan.sh`
- `scripts/aqos-screenshot-freshness-check.sh`
- `scripts/aqos-evidence-folder-check.sh`
- `scripts/aqos-state-coverage-check.sh`
- `scripts/aqos-evidence-maturity-ledger-check.sh`
- `scripts/aqos-run-all-advisory.sh`

## Tooling Policy Added

AQOS uses minimal dependencies:

- Bash
- Git
- grep / sed / awk / find / wc
- Python 3 standard library
- Xcode command-line tools
- xcodebuild
- xcrun simctl
- xcodegen where already used

No new third-party dependency is approved by this insertion.

## Reviewer Skills Added

- Evidence-Gated Quality Reviewer
- Accessibility / Privacy / Performance Quality Reviewer
- Founder Vision And Handoff Reviewer

Existing related skills remain:

- Autonomous Quality Operating System Reviewer
- FAANG Rendered Visual Reviewer

## What This Fixes

This gives Codex local tooling instructions for:

- impact classification
- required evidence checking
- claim-truth scanning
- internal-term copy scanning
- visual card-stack heuristic scanning
- architecture fitness scanning
- privacy exposure scanning
- screenshot freshness validation
- evidence folder checking
- state coverage checking
- evidence maturity ledger checking
- all-in advisory gate execution

## No-Claim Boundary

This insertion does not claim the scripts have been materialized or run yet. It does not claim the app is visually fixed, accessible, private, secure, release-ready, legally reviewed, or FAANG-handoff-ready.

It installs the tool specifications and prompts needed for the AQOS adoption batch to create executable tooling locally.

## Validation

This update was performed through the GitHub connector. Local shell validation was not available in this session. The following were not run here:

- `git status --short`
- `git diff --check`
- `scripts/run-doc-qa.sh`
- `scripts/batch-train-gate-check.sh`
- AQOS scripts

The update stayed docs/skills/prompts-only and did not edit production Swift, route/raw values, persistence/schema, workflows, signing, entitlements, CI, release, sync/cloud, monetization, AI runtime, or LDI runtime files.

## Accepted Yellow

- Executable scripts are specified but not materialized through this connector session.
- AQOS local materialization prompt must be run by Codex in the repo environment.
- Active global train may not read these until next pull/batch boundary.

## Next Expected Action

Codex should run:

`docs/codex/batches/AQOS_TOOLS_SKILLS_AND_SCRIPTS_PROMPT.md`

at the next safe AQOS adoption point, create the scripts locally, run them advisory-first, and integrate them into the global orchestrator/report template.
