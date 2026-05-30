<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# IOS26-HARNESS-T02-B02 — First Proof Wrapper Run

## Objective
Run the installed harness proof wrapper in inventory-only mode and record the first artifact packet for the support slice.

## Active source truth
Read docs/truth/*, AGENTS.md, docs/codex/HARNESS_README.md, docs/codex/HARNESS_ARTIFACT_SCHEMA.md, docs/codex/HARNESS_RUNS.md, and docs/codex/HARNESS_SCORECARD.md before touching any files.

## Allowed scope
scripts/harness/ambitions-artifact-helper.py
scripts/harness/ambitions-proof-wrapper.sh
scripts/harness/ambitions-static-gates.py
build/reports/harness/**
build/reports/parallel-implementation-guard/IOS26-HARNESS*.md
build/reports/parallel-implementation-guard/IOS26-HARNESS*.json

## Forbidden scope
Native/**
Sources/**
AppUI/**
docs/truth/**
project.yml
Package.swift
Package.resolved
Ambitions.xcodeproj/**
.codex/runs/**
signing, secrets, entitlements, privacy manifest, app resources, generated Xcode project files

## Runner preflight
- Confirm the runner header is present.
- Confirm the wrapper stays inventory-only and does not build.
- Confirm the batch stays inside harness support tooling and proof artifact output.

## Required commands
Run:
bash scripts/harness/ambitions-proof-wrapper.sh --inventory-only --batch IOS26-HARNESS-T02-B01-artifact-proof-wrapper-static-gates
python3 scripts/harness/ambitions-static-gates.py
git status --short

## Hard Red
- Any app build, test, simulator, accessibility, performance, device, TestFlight, App Store, or release claim.
- Any touch to app source, truth files, project config, package config, or generated Xcode files.
- Any use of proof artifacts as release proof.

## Rollback strategy
- Revert only the batch prompt or the harness support files in the allowed scope if the wrapper packet needs to be reset.
- Leave repo truth and app source untouched.

## Final report
Status: Green / Yellow / Red
Batch ID:
Scope:
Files changed:
Commands run:
Artifacts:
Validation:
Risks:
Claims not made:
Next recommended step:
