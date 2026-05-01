# Batch Train Red Stop

Path: .codex/playbooks/batch-train-red-stop.md
Status: Active Ambitions playbook


## Symptoms
List the observed validation, scope, architecture, or canon symptoms.

## Likely Causes
Stale canon, task-width drift, brittle tests, giant feature file, privacy ambiguity, unclear ownership, or missing prerequisite batch.

## Commands To Inspect
```bash
git status --short
git diff --stat
scripts/batch-train-gate-check.sh || true
scripts/swiftui-architecture-scan.sh || true
git diff --check
```

## Safe Response
Stop if Yellow/Red, preserve evidence, write repair prompt, and avoid expanding scope.

## Unsafe Response
Do not skip batches, weaken tests, edit workflows, add dependencies, hide failures, or claim FAANG/release readiness.

## Repair Prompt Output
Include stop class, evidence, allowed files, forbidden files, validation commands, and resume condition.
