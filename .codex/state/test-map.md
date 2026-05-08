# Test Map

Status: Compact mirror only. `rg --files '*Tests*'`, Xcode schemes, and owner docs win.
Date: 2026-05-07

- Unit/focused tests: `Native/AmbitionsTests/`
- UI tests: `Native/AmbitionsUITests/` where present.
- Validation packs: `.codex/validation/`
- CQS advisory scripts: `scripts/cqs-*.sh`
- ACX Local validation logs: `.codex/logs/` local-only.

Do not infer full test pass from helper output, docs, generated project success, or partial focused tests.
