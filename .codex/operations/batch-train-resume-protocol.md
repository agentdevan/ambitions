# Batch Train Resume Protocol

Path: .codex/operations/batch-train-resume-protocol.md
Status: Active operation protocol

## When To Use
Use after compaction, failed validation, or user-approved resume.

## Required Inputs
Train manifest, active source docs, current run state, current batch train state, git status, allowed files, forbidden files, validation pack, and latest batch evidence.

## Exact Steps
1. Confirm branch `main`, clean or explainable git state, HEAD, and last commit.
2. Read the manifest and selected batch prompt.
3. Confirm task width, allowed files, forbidden files, and stop conditions.
4. Execute only the current batch or protocol action.
5. Run required validation and classify Green, Yellow, or Red.
6. Write required report and update run-state artifacts.
7. Commit only on Green when this protocol permits continuation.

## Useful Commands
```bash
git status --short
git branch --show-current
git rev-parse HEAD
git log -1 --oneline
scripts/batch-train-gate-check.sh || true
scripts/swiftui-architecture-scan.sh || true
git diff --check
```

## Output Artifacts
Updated run state, batch train state, audit/stop report, repair/resume prompt when stopped, and commit evidence when Green.

## Stop Conditions
Any Yellow/Red gate, unclear dirty state, forbidden file touched, failed build/focused test, privacy/copy leak, unapproved dependency/workflow change, or unapproved task-width escalation.

## Evidence Required
Command outputs, touched-file list, validation status, gate classification, remaining risks, next action.

## Next Action
Green: commit and continue to next manifest batch. Yellow/Red: stop and produce repair/resume prompt.
