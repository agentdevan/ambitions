# Recent Validation

Status: Compact mirror only. Raw logs and terminal outputs win.
Date: 2026-05-07

This file is updated by intentional Codex OS closeout only. ACX Local raw logs live under `.codex/logs/` and are gitignored.

Current pass planned validation:

- `python3 scripts/ai/acx.py --help`
- `python3 scripts/ai/acx.py read AGENTS.md --lines 40`
- `python3 scripts/ai/acx_local.py list`
- `python3 scripts/ai/acx_local.py run status`
- `python3 scripts/ai/acx_local.py run changed-files`
- `python3 scripts/ai/acx_local.py run diff-stat`
- `python3 scripts/ai/acx_local.py run acx-help`
- `python3 scripts/ai/acx_local.py run acx-gate-all`
- `scripts/ai/acx-local run status`
- `python3 scripts/ai/acx_local.py run "__invalid_profile__"`

Current pass observed results:

| Command | Exit | Raw log |
| --- | --- | --- |
| `python3 scripts/ai/acx.py --help` | 0 | terminal output only |
| `python3 scripts/ai/acx.py read AGENTS.md --lines 40` | 0 | terminal output only |
| `python3 scripts/ai/acx_local.py list` | 0 | terminal output only |
| `python3 scripts/ai/acx_local.py run status` | 0 | `.codex/logs/2026-05-07T23-07-28/status.raw.log` |
| `python3 scripts/ai/acx_local.py run changed-files` | 0 | `.codex/logs/2026-05-07T23-07-53/changed-files.raw.log` |
| `python3 scripts/ai/acx_local.py run diff-stat` | 0 | `.codex/logs/2026-05-07T23-07-28/diff-stat.raw.log` |
| `python3 scripts/ai/acx_local.py run acx-help` | 0 | `.codex/logs/2026-05-07T23-07-28/acx-help.raw.log` |
| `python3 scripts/ai/acx_local.py run acx-gate-all` | 0 | `.codex/logs/2026-05-07T23-07-53/acx-gate-all.raw.log` |
| `scripts/ai/acx-local run status` | 0 | `.codex/logs/2026-05-07T23-07-53/status.raw.log` |
| `python3 scripts/ai/acx_local.py run "__invalid_profile__"` | 2 | `.codex/logs/2026-05-07T23-08-20/invalid-profile.raw.log` |
| `python3 scripts/ai/acx_local.py run cqs-product-drift` | 0 | `.codex/logs/2026-05-07T23-08-21/cqs-product-drift.raw.log` |
| `python3 scripts/ai/acx_local.py run cqs-release-claims` | 0 | `.codex/logs/2026-05-07T23-08-21/cqs-release-claims.raw.log` |
| `python3 scripts/ai/acx_local.py run cqs-accessibility-motion` | 0 | `.codex/logs/2026-05-07T23-08-21/cqs-accessibility-motion.raw.log` |
| `python3 scripts/ai/acx_local.py run cqs-performance` | 0 | `.codex/logs/2026-05-07T23-08-33/cqs-performance.raw.log` |
| `python3 scripts/ai/acx_local.py run xcodegen-generate` | 0 | `.codex/logs/2026-05-07T23-08-45/xcodegen-generate.raw.log` |
| `python3 -m py_compile scripts/ai/acx.py scripts/ai/acx_local.py` | 0 | terminal output only |
| `git diff --check` | 0 | terminal output only |

Notes:

- ACX gate all and broad CQS profiles produced advisory hits from existing repo text/source. They are not app behavior changes and are treated as Yellow advisory scan evidence for this Codex OS pass.
- Invalid profile returned nonzero by design and executed no command.
