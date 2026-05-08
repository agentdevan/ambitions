# Codex Build Sheriff Protocol

Status: Active build/test triage protocol.  
Date: 2026-05-08  
Scope: Build/test command discovery, saved-log triage, and proof boundaries.

## Components

- `.codex/manifests/build-commands.yml`
- `.codex/manifests/test-impact-map.yml`
- `scripts/ai/acx_build_triage.py`
- ACX Local profiles: `build-help`, `test-help`, `xcodegen-generate`

## Rules

- `build-help` and `test-help` discover docs only. They do not prove success.
- Build pass requires raw build log, exit code, commit, and command.
- Test pass requires raw test log, exit code, commit, and command.
- Build/test failures should be classified before repair.
- Do not add dependencies or change project config without explicit scope.

## Triage Command

```bash
python3 scripts/ai/acx_build_triage.py <saved-log>
```

## Failure Classes

- Swift compile error
- Swift warning
- build failed
- test failed
- XcodeGen/project drift
- simulator destination issue
- dependency resolution issue

## Claims Not Made

Saved-log triage does not prove build pass, test pass, device proof, release readiness, or performance safety.
