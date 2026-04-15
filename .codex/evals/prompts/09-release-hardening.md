# Eval Prompt 09: release-hardening

## Prompt

Do a final preflight on this branch and tell me whether anything in docs, plist/privacy, extension notes, or validation still blocks merge, assuming the current environment may not be able to run native Apple toolchain checks.

## Expected Likely Skill(s)

- `release-hardening`
- `repo-truth-enforcer`
- `ios-qa-regression-checker`

## Success Looks Like

- Audits the branch for release-sensitive files.
- Reports exactly what validation ran.
- Checks docs truth and manual notes, especially for extension or OS-surface work.

## Common Failure Patterns

- Declares the branch ready without evidence.
- Ignores plist, entitlement, or privacy changes.
- Skips docs/manual-note drift.

## Files That Should Probably Be Read Or Mentioned

- `project.yml`
- plist / entitlement / privacy manifest files
- `docs/native-build-and-release.md`
- `docs/widget-live-activity-manual-testing.md`
- changed docs

## Files That Should Not Be Touched By Default

- unrelated feature implementation files unless they contain stale release-facing copy
