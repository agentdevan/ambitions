# Toolchain Readiness Pack

## Purpose

Check whether the local Mac can support Ambitions 3.0 Codex work.

## Commands

```bash
brew bundle check || true
scripts/validate-dev-tools.sh || true
xcrun simctl list devices available | grep -E 'iPhone' | head -20
```

## Expected Evidence

- Required tools present or blocker named.
- Adopted tools present or setup gap named.
- Simulator destination available.

## Failure Interpretation

Required missing tools block native validation. Adopted tool gaps block only
the relevant enhanced evidence path.

## Escalation Rules

Ask for human action only when Xcode, simulator runtimes, credentials, or
installation permissions are missing.
