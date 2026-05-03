# Global Patch Train Interrupted Run Recovery Protocol

Status: Active Codex operating protocol
Date: 2026-05-03

## Purpose

This protocol explains how to resume Ambitions batch trains after usage-limit
stops, compacted sessions, interrupted Xcode builds, dirty working trees, and
half-written audit reports.

The rule is simple: resume from repo truth. Do not restart completed batches,
discard uncommitted work, or invent proof.

## First Commands

```bash
git status --short
git branch --show-current
git log --oneline -8
cat .codex/reports/current-run-state.md || true
cat .codex/reports/current-batch-train-state.md || true
scripts/global-train-next-batch.sh || true
scripts/global-train-status-summary.sh || true
scripts/batch-train-gate-check.sh || true
```

## Dirty Tree Checklist

1. Classify every changed file as intended batch work, generated output, local
   tool cache, accidental duplicate, or unknown.
2. Read the changed audit report before editing it.
3. Check whether run state, batch train state, registry, and global order agree.
4. Keep intended batch work unless repo evidence proves it is trash.
5. Remove generated output only when it is ignored/cache-like and not intended
   evidence.
6. Stop on unknown dirty files that cannot be safely classified.

## Interrupted Build Checklist

1. Check whether a build process is still running.
2. If no process remains, read the newest log under `output/logs/`.
3. Rerun the narrowest equivalent command only once before broadening.
4. Record the exact command result and whether the previous interruption was
   inconclusive, failed, or repaired.

## Half-Written Audit Report Checklist

1. Leave source truth and files-changed sections intact if they match git.
2. Replace `pending` only after validation has actually run.
3. Separate passed, failed, accepted Yellow, and not-run checks.
4. Never claim screenshot, physical-device, VoiceOver, Instruments, battery, or
   human review proof unless that evidence exists in the current run.

## Stop Conditions

- Unknown dirty tree.
- Same Red root cause repeats more than twice.
- Route/raw value, persistence/schema, dependency, workflow, signing, or
  top-level-tab change appears without an owning batch.
- A report or state file would require falsifying validation.

## Non-Negotiables

- Never restart completed batches.
- Never discard uncommitted work without inspection.
- Never fake proof.
- Never turn accepted Yellow into vague debt; record an owner and required
  proof.
