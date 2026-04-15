# Release Hardening Checklist

- Verify `project.yml` is the source of truth for target changes.
- Verify plist, entitlements, and privacy manifest changes match current code behavior.
- Verify bundle IDs, app groups, and extension wiring are internally consistent.
- Verify docs and README reflect the branch’s actual shipped state.
- Verify build/test/archive commands were run where possible.
- Verify manual-test notes exist for extension or OS-surface work.
- List remaining blockers honestly.
