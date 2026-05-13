# Autonomous Train Conductor Skill

Status: Active speed skill  
Purpose: Drive the existing Install / Review / Advance Train / Push repeat loop without re-planning from scratch.

## Use when

Use this skill when the user says:

```text
run autonomous train
run global train
continue autonomous train
```

## Procedure

1. Read `prompts/batches/GLOBAL-TRAIN-AUTOPILOT-FROM-PK18-TO-COMPLETE-01.md`.
2. Read `docs/codex/AUTONOMOUS_TRAIN_FASTPATH.md`.
3. Run or inspect:

```bash
python3 scripts/ambitions-autonomous-train-fastpath.py --status
python3 scripts/ambitions-autonomous-train-fastpath.py --next
```

4. Execute through the runner path only:

```bash
make autonomous-train
```

5. If limiting to one batch:

```bash
python3 scripts/ambitions-autonomous-train-fastpath.py --once
```

## Rules

- Do not bypass the Ambitions runner.
- Do not add tests or test frameworks.
- Do not rewrite canonical queue order.
- Do not skip HBI or MRI applicability checks.
- Do not stage unrelated files.
- Do not make readiness claims without proof.

## Stop conditions

Stop on dirty unknown user work, queue corruption, HBI guard failure, MRI routing conflict, forbidden file mutation, or unproven release/device/App Store/TestFlight/accessibility/privacy/legal claims.
