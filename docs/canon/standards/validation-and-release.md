# Validation and release

Validate the changed behavior, not paperwork. Every change must pass
`git diff --check`; Swift, package, and project changes also require XcodeGen
drift verification plus the relevant no-sign build and focused tests.

Run unit and integration tests for changed logic. Add UI and accessibility
tests for affected interactions; run migration, persistence/replay,
concurrency, privacy/security, or performance lanes when the changed scope
touches those concerns. Keep SwiftLint, meaningful static analysis, and
secrets scanning enabled.

Release distribution still requires a successful unsigned build and the
platform-specific checks appropriate to the release, but there are no
authorization receipts, claim-ceiling labels, owner self-approvals, or
documentation-linkage gates.
