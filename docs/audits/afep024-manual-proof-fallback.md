# AFEP-024 Manual Proof Fallback

Issue: `AMB-418`
Batch: `AFEP-024`
Date: 2026-06-01

## Fallback Goal

Keep a manual AFRI-style proof packet path available when automation is unavailable, unstable, or too limited for the current evidence set.

## Manual Workflow

1. Collect the current repo-local validation commands.
2. Record the current commit, branch, and generated timestamp.
3. List artifact paths only when they are local and inspectable.
   - Use repo-relative artifact paths only; do not reference absolute paths or paths outside the repo.
4. Mark missing optional proof as `notVerified` or `blocked`.
5. Keep release, accessibility, privacy/legal, performance, device, TestFlight, App Store, CI, and production claims as `notClaimed`.
6. Preserve `SourceRecord`, `Receipt`, `ReplayTrace`, and `You / What Ambitions knows` as provenance strings only.

## Disable Automation

- Remove `scripts/afep024_evidence_packet.py`
- Remove `fixtures/afep024/`
- Keep the AFEP-024 audit reports only if they continue to reflect current repo truth

## Safety Boundary

This fallback is a local documentation path. It does not create release proof and does not change runtime behavior.
