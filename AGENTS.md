# Ambitions contributor guide

Ambitions is a solo-maintainer, local-first iPhone app. Make ordinary tracked
changes directly: no task authorization, attestation, intake pack, owner
self-approval, or finalization receipt is required.

## Product documentation

Start with `docs/canon/generated/CODEX_START_HERE.md`, then follow the owning
product requirement or specification it routes. `docs/canon/README.md` provides
the full reading order for the constitution, specifications, UX blueprint,
visual system, design provenance, and engineering standards. Read relevant
canon together with live source and tests. Canon describes what Ambitions is;
it does not authorize edits or merges.

## Required engineering practice

- Work from the current branch and inspect the current diff before editing.
- Preserve local-first behavior, private-data boundaries, persistence and replay
  invariants, migrations, and concurrency safety.
- Edit `project.yml` and regenerate with XcodeGen; do not hand-edit generated
  Xcode project state.
- Run the changed-scope checks in the Code Quality workflow locally where
  practical. Add focused tests for changed behavior; run UI, accessibility,
  migration, privacy, security, or performance lanes only when their scope is
  affected.
- Keep `git diff --check`, SwiftLint, static analysis, secrets scanning, and
  the relevant build/test lane green. Do not weaken tests to make a check pass.
- Run `python3 scripts/ambitions-canon.py check` when product or design canon
  changes. Use `python3 scripts/ambitions-canon.py query TERM` to locate the
  owning specification or requirement.

There are no process-only repository gates. GitHub branch protection should
require only the `Code Quality` workflow; see `CONTRIBUTING.md`.
