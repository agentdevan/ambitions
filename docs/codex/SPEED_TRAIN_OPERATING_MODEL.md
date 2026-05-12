# Ambitions Speed Train Operating Model

Status: active speed overlay  
Date: 2026-05-12  
Authority: subordinate to `docs/truth/*`, `AGENTS.md`, and explicit user direction

## Purpose

Speed Train Mode exists to finish remaining Ambitions batches as fast as possible without returning to uncontrolled direct-paste Codex execution.

The goal is not ceremony. The goal is high-throughput batch closure with proof honesty.

## Speed Priority

Optimize for:

1. completed batches per hour,
2. no stale state reruns,
3. no broad dirty worktree growth,
4. no false Green / release / accessibility / device / privacy claims,
5. automatic state advancement,
6. final heavy validation after throughput runs instead of heavy validation after every batch.

## Default Speed Posture

Speed Train runs the canonical runner with faster defaults:

```bash
AUTO_BRANCH=0
ALLOW_MAIN_COMMIT=1
AUTO_COMMIT=1
AUTO_PUSH=1
KEEP_GOING_ON_YELLOW=1
ALLOW_YELLOW_COMMIT=1
MAX_REPAIR_PASSES=1
ACCESS_MODE=full
```

These defaults are aggressive. They are acceptable only because every child batch still runs through the Ambitions runner and must still obey hard-Red stop conditions.

## What Speed Train Must Not Do

- It must not bypass source truth.
- It must not run completed batches.
- It must not collapse PK23, PK24, or PK25 into PK22.
- It must not claim release, device, accessibility, performance, privacy/legal, or global completion without terminal proof.
- It must not run broad repo hygiene early unless hygiene blocks execution.
- It must not treat visual canon docs/control-plane installation as runtime UI completion.

## Light Gates Per Batch

Before each child batch:

- check stale state mirrors,
- check prompt exists,
- check unsupported completion/readiness claims in active docs/prompts,
- check git status is not blocked by unrelated dirty work unless the operator explicitly allows it.

After each child batch:

- check stale state mirrors again,
- scan unsupported claims again,
- continue if Green or accepted Yellow,
- stop on Red, unknown, missing next batch, or repeated same-batch loop.

## Heavy Validation Timing

Heavy validation belongs at the end of a speed run or at explicit terminal gates:

- broad xcodebuild suites,
- visual QA screenshot passes,
- device proof,
- release evidence,
- public accessibility proof,
- performance Instruments proof.

Normal implementation batches should run focused proof only.

## Usage

```bash
make speed-train
```

One batch only:

```bash
make speed-once
```

Status only:

```bash
make speed-status
```

Final heavy gate after a speed run:

```bash
make speed-final-gate
```

## Current Recommended Start

Current next implementation batch after PK21 is:

```text
PK22 SideEffectLedger Foundation
```

Speed Train should proceed PK22 -> PK23 -> PK24 -> PK25 first, unless live queue truth changes.
