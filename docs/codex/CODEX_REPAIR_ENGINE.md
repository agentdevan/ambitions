# Codex Repair Engine

Status: Active repair intelligence protocol.  
Date: 2026-05-08  
Scope: Failure diagnosis, repair classification, proposal, closeout, and hard-stop behavior.

## Purpose

The repair engine turns Green/Yellow/Red from a final label into a controlled loop:

```text
detect -> classify -> propose -> validate -> ledger -> continue or stop
```

## Components

- `.codex/manifests/repair-profiles.yml`
- `scripts/ai/acx_repair.py`
- `scripts/ai/acx-repair`
- `.codex/state/active-repair.yml`
- `.codex/state/repair-ledger.md`

## Repair Classes

| Class | Meaning | Auto-safe |
| --- | --- | --- |
| R1 | formatting / whitespace | yes |
| R2 | docs drift | yes |
| R3 | deprecated language | yes |
| R4 | unsupported release claim | yes |
| R5 | CQS advisory | no |
| R6 | XcodeGen/project drift | no |
| R7 | build failure | no |
| R8 | test failure | no |
| R9 | source-truth conflict | hard stop |
| R10 | hard Red stop | hard stop |

## Commands

```bash
python3 scripts/ai/acx_repair.py diagnose
python3 scripts/ai/acx_repair.py diagnose --log .codex/logs/<timestamp>/<profile>.raw.log
python3 scripts/ai/acx_repair.py propose
python3 scripts/ai/acx_repair.py closeout
```

## Auto-Repair Boundary

Only narrow docs/tooling/copy repairs are auto-safe. Swift source, persistence/schema, privacy/security behavior, destructive git actions, build/test failures without raw logs, and source-truth conflicts are not auto-safe.

## Stop Rules

Stop on:

- source-truth conflict
- hard Red
- unknown dirty tree
- privacy/security/legal ambiguity
- unsupported release/device/accessibility claim
- repeated same-root Red after two repair attempts

## Closeout

Every repair closeout must name:

- repair class
- source log
- files touched
- validation bundle
- exit codes
- raw logs
- ledger update
- claims not made
