# F17 Shell / Meridian Planning And Readiness Audit Prompt

Status: Active next batch prompt
Train: F17-F30 FAANG Handoff Completion Train

Run F17 as planning/readiness only. Do not implement Shell/Meridian UI.

Inspect:

- `AppUI/`
- `Native/Ambitions/App`
- `Native/Ambitions/Features/Today`
- `Native/Ambitions/Features/Captures`
- `Native/Ambitions/Features/Plan`
- `Native/Ambitions/Features/Goals`
- `Native/Ambitions/Features/Profile`
- `Native/AmbitionsTests`
- `Native/AmbitionsUITests`
- widget and App Intent files if present

Create `docs/audits/ambitions-3-0-f17-shell-meridian-readiness-report.md` with:

- current shell/navigation architecture
- current top-level destination access
- route ownership map
- deep link map
- App Intent handoff map
- widget/external surface implications
- fallback navigation plan
- feature flag plan
- rollback plan
- one-tap destination access plan
- accessibility fallback plan
- UI tests needed
- files F18 may touch
- files F18 may not touch
- F18 implementation plan
- F17 gate: Green / Yellow / Red

F17 Green requires:

- F18 can be feature-flagged
- fallback navigation remains available
- top-level destinations remain reachable
- route parity can be tested
- accessibility fallback is clear
- rollback is clear
- no shell ownership ambiguity remains
- no dependency/workflow changes are needed

Validate:

```bash
git status --short
scripts/build-local.sh
scripts/batch-train-gate-check.sh || true
scripts/swiftui-architecture-scan.sh || true
git diff --check
```

If Green, commit and push F17, then continue to F18. If Yellow/Red, stop and write a repair/decision prompt.
