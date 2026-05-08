# Codex Agent Protocol

Status: Active agent behavior protocol.  
Date: 2026-05-07  
Scope: How repo-enabled Codex sessions should operate in Ambitions.

## Start Sequence

1. Read the current user directive.
2. Read `AGENTS.md`.
3. Read `docs/codex/CODEX_OS_INDEX.md`.
4. Select one route file under `.codex/routes/`.
5. Name allowed files, forbidden files, validation tier, and stop conditions.
6. Execute the smallest safe patch.
7. Close with Green / Yellow / Red and evidence.

## Default Bounded Reads

```bash
python3 scripts/ai/acx.py read AGENTS.md --lines 140
python3 scripts/ai/acx.py read docs/codex/CODEX_OS_INDEX.md --lines 160
python3 scripts/ai/acx.py read .codex/reports/current-batch-train-state.md --lines 180
```

## Editing Rules

- Preserve existing Codex OS history.
- Prefer additive owner files over rewriting old reports.
- Use `.codex/state/` for compact durable snapshots, not historical proof.
- Use `.codex/routes/` to reduce context load.
- Do not modify app source during Codex OS tooling/docs passes.
- Do not add dependencies for tooling unless explicitly approved.
- Keep scripts deterministic and advisory by default.

## Reporting Rules

Every meaningful run ends with:

```text
Result: Green / Yellow / Red
Files changed:
Commands run:
Exit codes:
Evidence:
Known limitations:
Next eligible action:
```

## Fall Back Rules

If ACX is unavailable, use normal file reads and bounded shell output. ACX is an efficiency layer, not a hard dependency.

If route files are stale, use the peak protocol and current batch-train state as the higher-trust source, then update the route file in a Codex OS maintenance pass.

## Stop Rules

Stop on unrecoverable Red, unknown dirty tree, source-truth conflict, destructive overwrite need, privacy/security ambiguity, unsupported release claim, or repeated same-root Red after two repair attempts.

## Continue Rules

Continue through Green and accepted Yellow only when the selected protocol permits it. For global trains, follow `docs/codex/CODEX_BATCH_TRAIN_PROTOCOL.md` and `.codex/reports/current-batch-train-state.md`.
