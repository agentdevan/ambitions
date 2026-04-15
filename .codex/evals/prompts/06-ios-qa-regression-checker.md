# Eval Prompt 06: ios-qa-regression-checker

## Prompt

Validate the recent capture and routing changes and tell me exactly what was verified versus what still needs simulator checks.

## Success Looks Like

- Uses the real repo validation commands and docs.
- Separates executed checks from unexecuted manual follow-up.
- Mentions routing/container consistency in addition to raw build status.

## Common Failure Patterns

- Claims builds or tests passed without running them.
- Gives a generic QA list instead of repo commands.
- Ignores manual checks for routing or OS surfaces.

## Files That Should Probably Be Read Or Mentioned

- `docs/native-build-and-release.md`
- `.github/workflows/ios-validate.yml`
- changed app/capture/routing files

## Should Not Touch By Default

- unrelated design files
