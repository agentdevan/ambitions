# UI Test Contract Pack

## Purpose

Validate UI test changes against Ambitions 3.0 user promises instead of brittle
layout assumptions.

## Commands

```bash
scripts/build-local.sh
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsUITests/AmbitionsUITests/<testName> test CODE_SIGNING_ALLOWED=NO
```

## Expected Evidence

- Test class and owner.
- Failure classification.
- Focused rerun result.
- Whether full UI suite is required.

## Failure Interpretation

Classify as outdated expectation, implementation bug, fixture drift,
identifier drift, navigation drift, copy migration, canon conflict, simulator
issue, or flake.

## Escalation Rules

Escalate when the fix would delete coverage, change navigation architecture,
or alter product behavior.

## Focused Vs Full Validation

Focused reruns are required first. Full UI suite is required after shared shell,
routing, fixture, or accessibility identifier changes.
