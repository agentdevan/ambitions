# Validation Runbook

Use wrapper-first validation for Ambitions iOS work. Raw `xcodebuild` belongs inside approved wrapper internals or explicitly scoped helper scripts, not as the default front door.

1. Run the smallest wrapper lane that proves the changed scope:
   - `scripts/ambitions-xcode-validate.sh --batch <BATCH_ID> --lane build`
   - `scripts/ambitions-xcode-validate.sh --batch <BATCH_ID> --lane focused-test --test <TEST_ID>`
   - `scripts/ambitions-xcode-validate.sh --batch <BATCH_ID> --lane test-plan --test-plan <PLAN_NAME>`
2. Equivalent Make wrappers are preferred when convenient:
   - `make xcode-validate BATCH=<BATCH_ID> LANE=<lane>`
   - `make xcode-focused-test BATCH=<BATCH_ID> TEST=<TEST_ID>`
   - `make xcode-test-plan BATCH=<BATCH_ID> TEST_PLAN=<PLAN_NAME>`
3. Record command, exit code, log path, environment, skipped checks, and proof boundaries.
4. Do not turn wrapper success into release, device, accessibility, performance, TestFlight, or App Store claims.
5. If the wrapper is unavailable, blocked, or timed out, close Yellow and record the blocker.
