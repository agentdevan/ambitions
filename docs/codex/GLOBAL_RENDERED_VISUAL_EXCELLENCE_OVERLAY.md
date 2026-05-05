# Global Rendered Visual Excellence Overlay
<!-- markdownlint-disable MD013 -->

Status: Active global-order overlay for visual execution quality.
Date: 2026-05-05

## Purpose

This overlay exists because the global train can move quickly and the main global order file may be changing while Codex is running. This file gives Codex a stable instruction: visual excellence gates must run before broad continuation, even if the primary order has advanced.

## Live-State Rule

When Codex pulls this file:

1. Finish any active in-progress batch safely.
2. Do not discard uncommitted work.
3. Pull latest remote.
4. Read `GLOBAL_FULL_STACK_COMPLETION_ORDER.md`.
5. If FVQ01 has not run, run FVQ01 at the earliest safe point.
6. Then run FVQ02.
7. Then install FVQ04 recurring UI-batch proof into the operating protocol.
8. Run FVQ03/MEG01 as applicable.
9. Resume the global order only after no Hard Visual Red remains.

## Required FVQ Sequence

- FVQ01 Today rendered visual freshness and flagship proof.
- FVQ02 five top-level surface visual sweep.
- FVQ03 drill-down/external surface sweep where implemented.
- FVQ04 recurring UI-batch rendered proof protocol.
- MEG01 advanced rendering eligibility gate.
- FVQ05 final visual proof packet hook.

## Blocking Rule

No broad continuation into PFC external surfaces, AOS, LDI, or late handoff may proceed with known unresolved Hard Visual Red on a top-level surface.

## Repair Rule

If FVQ finds a failing surface, Codex must create and run a narrow repair batch before broad continuation:

- `FVQ-TODAY-REPAIR`
- `FVQ-GOALS-REPAIR`
- `FVQ-CAPTURE-REPAIR`
- `FVQ-PLAN-REPAIR`
- `FVQ-YOU-REPAIR`
- `FVQ-SHELL-REPAIR`

## No-Claim Boundary

This overlay does not claim visual issues are fixed. It requires them to be proven, repaired, or honestly classified before continuation.
