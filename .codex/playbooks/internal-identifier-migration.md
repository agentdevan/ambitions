# Internal Identifier Migration

## Trigger

Use this playbook when internal identifier migration appears during Ambitions 3.0 work.

## Triage

1. Preserve local state: `git status --short`, `git diff`, and current HEAD.
2. Classify the failure as repo, environment, simulator, dependency, flaky, stale test, or unclear.
3. Inspect the smallest owning file set.
4. Retry only with a narrower informed command.
5. Stop before destructive changes or release/device claims.

## Recovery Commands

```bash
git status --short
xcodegen generate
xcrun simctl list devices available | grep -E 'iPhone' | head -20
```

## Evidence To Capture

- Exact command.
- Error summary.
- Owner path.
- Next fix.
- Whether the result blocks commit/push.
