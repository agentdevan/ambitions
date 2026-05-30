<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# IOS26-HARNESS-T02-B01 — Artifact Proof Wrapper Static Gates

## Objective
Complete Harness Slice 1 by installing artifact helper, proof wrapper, static gates, scorecard, and first proof-wrapper follow-up prompt.

## Active source truth
Read docs/truth/*, AGENTS.md, docs/codex/HARNESS_README.md, docs/codex/HARNESS_PLAN.md, docs/codex/HARNESS_ARTIFACT_SCHEMA.md, docs/codex/HARNESS_LINEAR.md, docs/codex/HARNESS_RUNS.md.

## Allowed scope
docs/codex/HARNESS_*.md
scripts/harness/**
scripts/ambitions-slice1-*.py
scripts/ambitions-harness-*.py
prompts/batches/HARNESS*.md
prompts/batches/IOS26-HARNESS*.md
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

## Hard Red
- Any app source, project config, package config, truth-file, signing, secret, entitlement, privacy manifest, app resource, or generated Xcode project change.
- Any app build, app test, simulator, accessibility, performance, device, TestFlight, App Store, or release-readiness claim.
- Any use of harness artifacts as release proof.

## Deliverables
Create or repair:
1. scripts/harness/ambitions-artifact-helper.py
2. scripts/harness/ambitions-proof-wrapper.sh
3. scripts/harness/ambitions-static-gates.py
4. docs/codex/HARNESS_SCORECARD.md
5. prompts/batches/IOS26-HARNESS-T02-B02-first-proof-wrapper-run.md
6. Update docs/codex/HARNESS_README.md and docs/codex/HARNESS_RUNS.md.

Artifact helper must create artifact-manifest.json with batch id, timestamp, branch, SHA, dirty status, environment, commands, artifacts, risks, and claims not made.

Proof wrapper must support --inventory-only and default to no build.

Static gates must check Harness docs/scripts/prompts, runner headers, forbidden path drift, and emit JSON/Markdown under build/reports/harness.

Do not claim app build, tests, UI, accessibility, performance, device, TestFlight, App Store, or release readiness.

## Runner preflight
- Confirm the three-line Ambitions runner header remains intact at the top of the prompt.
- Confirm the batch stays support-only and does not widen into app source, project config, or release scope.
- Confirm the validation list remains aligned with the artifact-helper, proof-wrapper, and static-gate slice.

## Rollback strategy
- Revert only this prompt file if the support scaffold needs to be removed or rewritten.
- Do not touch app source, `docs/truth/*`, project config, or generated Xcode files when rolling back this prompt.

## Validation
Run:
python3 -m py_compile scripts/harness/ambitions-artifact-helper.py scripts/harness/ambitions-static-gates.py
bash -n scripts/harness/ambitions-proof-wrapper.sh
python3 scripts/harness/ambitions-static-gates.py
bash scripts/harness/ambitions-proof-wrapper.sh --inventory-only --batch IOS26-HARNESS-T02-B01-artifact-proof-wrapper-static-gates
git status --short

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
