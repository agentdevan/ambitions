# Build Failure Triage Protocol

Use when `xcodegen`, `scripts/build-local.sh`, direct `xcodebuild`, or CI build proof fails.

## Steps

1. Run `scripts/validate-dev-tools.sh || true`.
2. Identify whether failure is wrapper, generation, package, compile, simulator, signing, or cache related.
3. If wrapper-specific, run direct command and fix wrapper only.
4. If repo compile failure, inspect the first compiler error before later noise.
5. If environment failure, document missing tool/runtime and next human action.
6. Re-run the narrow proof after a repo fix.

## Commands

```zsh
scripts/validate-dev-tools.sh || true
xcodegen generate
scripts/build-local.sh
```

## Stop Conditions

Do not edit product behavior for a tooling or simulator failure.
