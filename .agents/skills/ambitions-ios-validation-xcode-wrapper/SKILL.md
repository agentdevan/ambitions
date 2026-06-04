---
name: ambitions-ios-validation-xcode-wrapper
description: Use for Ambitions iOS/Xcode validation planning, focused test selection, wrapper-first build/test commands, and avoiding raw xcodebuild front doors.
---

# Ambitions iOS Validation Xcode Wrapper

## Authority Boundary
Start from `docs/truth/*` before using this skill. Skills are operating support only: they are not product truth, implementation proof, validation proof, release proof, privacy approval, accessibility proof, App Store proof, or permission to change app behavior outside the current task scope.

Active top-level IA is `Today / Goals / Time / Motion / You`. Global action: `Capture` (not a tab). `Motion` replaces `Pulse` (historical context only). `Plan` may appear only as an internal compatibility seam unless an active truth-file-scoped migration changes it.

Hard stops: required cloud AI/LLM core behavior, hosted personal-data backend, analytics/tracking SDKs without approval, privacy manifest dishonesty, release/App Store/TestFlight/device/accessibility/performance claims without evidence, `Plan` as top-level IA, broad staging, destructive cleanup without indexed approval, or converting Ambitions into a dashboard/chatbot/calendar clone/task manager/habit tracker.
## Wrapper-First Rule
Use repo wrappers before raw Xcode commands:
```bash
scripts/ambitions-xcode-validate.sh --batch <BATCH_ID> --lane build
scripts/ambitions-xcode-validate.sh --batch <BATCH_ID> --lane focused-test --test <TEST_ID>
scripts/ambitions-xcode-validate.sh --batch <BATCH_ID> --lane test-plan --test-plan <PLAN_NAME>
scripts/ambitions-xcode-benchmark.sh --status
make xcode-validate BATCH=<BATCH_ID> LANE=<lane>
make xcode-benchmark BATCH=<BATCH_ID> LANE=<lane> CMD='scripts/ambitions-xcode-validate.sh --batch <BATCH_ID> --lane <lane>'
make xcode-focused-test BATCH=<BATCH_ID> TEST=<TEST_ID>
make xcode-test-plan BATCH=<BATCH_ID> TEST_PLAN=<PLAN_NAME>
```

Raw `xcodebuild` belongs inside wrapper internals or an explicitly approved focused helper, not as the default front door.

## Workflow
1. Choose the smallest lane that proves the changed scope.
2. Prefer focused tests for bounded source changes, build lane for compile safety, and test-plan only when broader coverage is needed.
3. Use `.codex/xcode-benchmarks` timing evidence to diagnose slow validation before repo-local DerivedData cleanup or broader-suite escalation.
4. Record command, exit code, log path, benchmark path, environment, skipped checks, and proof boundaries.
5. If validation is blocked or timed out, close Yellow, not Green.
