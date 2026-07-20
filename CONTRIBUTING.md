# Contributing

Ambitions is maintained by one developer. Make a focused change, add or update
the behavior tests it needs, and run the applicable checks. There are no task
starts, finalizations, attestations, intake packs, or self-approvals.

## Local validation

Always run `git diff --check`. For Swift, package, project, or test changes,
run `xcodegen generate`, verify that it leaves no project drift, then use the
focused test or `scripts/ambitions-xcode-build-for-testing.sh`. Run privacy,
security, migration, accessibility, UI, concurrency, or performance tests when
the changed scope affects those areas. For product or design canon changes, run
`python3 scripts/ambitions-canon.py build` and
`python3 scripts/ambitions-canon.py check`.

## CI

The `Code Quality` workflow uses changed-file routing. It runs whitespace,
secrets scanning, the fast product-canon integrity check, SwiftLint/static
checks, XcodeGen drift detection, and the relevant focused tests/builds. It adds
Source Atlas, privacy, shell, workflow, or documentation checks only when those
files change.

For GitHub repository settings, require only `Code Quality`; remove environment
approval rules and all retired canon, authorization, proof, and review checks.
