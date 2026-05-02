# REC05 Human Review Packet Prompt
<!-- markdownlint-disable MD013 -->

Status: Queued Ambitions 4.0 evidence batch; not started; blocked pending `Continue Release Evidence Closure` or current global 4.0 preauthorization and REC04 Green.

## Batch Identity

- Batch ID: `REC05`
- Name: Human Review Packet
- Train: Release Evidence Closure
- Mode: evidence/docs-only
- Owner: operator release review handoff
- Required approval phrase: `Continue Release Evidence Closure` or current
  global Ambitions 4.0 preauthorization

## Purpose

Create the human/operator release review packet that a product owner can use to
decide what to verify next. This packet must be explicit about evidence,
non-claims, human-only proof, and stop conditions.

## Source Truth Files To Read First

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Release_Readiness_And_Evidence_Gates.md`
- `docs/canon/Ambitions_3_0_FAANG_Handoff_Readiness_Gate.md`
- `docs/codex/batch-trains/REC01_REC06_RELEASE_EVIDENCE_CLOSURE_TRAIN.md`
- REC01-REC04 reports
- Human operator proof plan from REC02
- Validation ledger from REC03
- Claim scan report from REC04
- `docs/codex/GLOBAL_BATCH_CONTINUATION_PROTOCOL.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`

## Required Preflight Checks

- `git status --short`
- `git branch --show-current`
- `git rev-parse HEAD`
- `git log -1 --oneline`
- Confirm REC04 is Green or accepted Yellow.
- Confirm no human proof is being marked passed by Codex.

Stop if REC01-REC04 evidence is incomplete or contradictory.

## Allowed Files

- `docs/**`
- `.codex/**`

## Forbidden Files

- `Native/**`, `AppUI/**`, `Sources/**`
- `.github/workflows/**`
- Dependency manifests, lockfiles, signing/project config, generated output,
  persistence/schema, route/App Intent/widget implementation files

## Required Work

- Create a human review packet with:
  - current evidence summary
  - release-claim boundary
  - validation ledger links
  - human proof checklist
  - screenshots/manual review checklist if needed
  - operator stop conditions
  - exact launch/build/review references when already documented
  - decision options and consequences
- Separate "verified by repo evidence" from "requires human/operator proof".
- Preserve REC and Ambitions 3.0 historical truth.
- Do not claim the human review happened.

## Required Non-Goals

No app implementation, no archive/signing/App Store Connect action, no TestFlight
upload, no device proof, no release decision, no workflow/dependency/signing
change, no product strategy rewrite.

## Required Validation Commands

- `git status --short`
- `git diff --check`
- Release-claim scan over `README.md docs .codex`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`
- Changed-file boundary check limited to `docs/**` and `.codex/**`

## Required Evidence Outputs

- REC05 report under `docs/audits/`
- Human review packet under `docs/**`
- Updated registry/context/run-state only after evidence
- Remaining human-proof checklist
- Exact next safe prompt

## Green / Yellow / Red Criteria

Green: packet is operator-ready, evidence and non-claims are separated, human
proof is not faked, no forbidden files changed, and validation is clean or
advisory-only.

Yellow: human proof remains pending and is clearly assigned to the operator.

Red: packet claims approval/readiness, Codex marks human proof as passed, app
files change, release/platform claim is introduced, or validation failure is
unclassified.

## Stop Conditions

Stop on Red, missing REC04 evidence, human-proof ambiguity, release-claim
ambiguity, or pressure to make a release decision.

## What This Batch May Claim

It may claim a human review packet exists after commit.

## What This Batch Must Not Claim

No human approval, release readiness, App Store readiness, TestFlight readiness,
physical-device proof, public accessibility conformance, signed archive
validation, App Store Connect validation, or external-platform proof.

## Commit Message Recommendation

`Run REC05 human review packet`

## Next Safe Prompt / Path

`REC06 Release Evidence Closure Handoff` only after REC05 is Green or accepted
Yellow, committed, pushed, and train continuation is explicitly allowed.
