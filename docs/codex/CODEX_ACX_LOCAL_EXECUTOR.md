# ACX Local Executor

Status: Active local-only executor protocol for Ambitions Codex OS; not build, test, release, or app behavior proof.
Date: 2026-05-07

## Separation Of Duties

- `scripts/ai/acx.py` is non-executing. It reads bounded files, summarizes saved logs, groups saved status text, runs advisory scans, and prints gate reports.
- `scripts/ai/acx_local.py` is the only ACX command runner. It runs named allowlisted profiles only.
- `scripts/ai/acx` and `scripts/ai/acx-local` are thin wrappers.

## Safety Rules

- No arbitrary shell strings.
- No `shell=True`.
- Commands are argv arrays.
- Unknown profiles fail with exit code `2` and execute nothing.
- Destructive command terms fail before execution with exit code `2`.
- ACX Local never stages, commits, pushes, resets, cleans, deletes, switches branches, runs `sudo`, or runs `bash -c` / `sh -c`.
- Optional unavailable tools produce Yellow summaries, not hard Red.

## Raw Logs

Each run writes:

- full raw output to `.codex/logs/YYYY-MM-DDTHH-MM-SS/<profile>.raw.log`
- compact summary to `.codex/logs/YYYY-MM-DDTHH-MM-SS/<profile>.summary.md`

The terminal summary must always print the raw log path. `.codex/logs/` is local-only and gitignored.

## Profiles

The active profile map lives in `.codex/manifests/acx-command-profiles.yml`.

Required examples:

```bash
python3 scripts/ai/acx.py --help
python3 scripts/ai/acx_local.py list
python3 scripts/ai/acx_local.py run status
python3 scripts/ai/acx_local.py run changed-files
python3 scripts/ai/acx_local.py run diff-compact
python3 scripts/ai/acx_local.py run acx-gate-all
python3 scripts/ai/acx_local.py run xcodegen-generate
scripts/ai/acx-local run status
```

## Local Overrides

Optional local overrides may live at `.codex/local/acx-local-overrides.yml`. They must stay gitignored, must use argv arrays, and still pass destructive-term checks. They are for local operator convenience only and are not source truth.
