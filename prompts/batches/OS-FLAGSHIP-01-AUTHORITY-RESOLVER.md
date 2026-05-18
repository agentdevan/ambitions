<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# OS-FLAGSHIP-01-AUTHORITY-RESOLVER

## Purpose

Install and validate the Ambitions Codex OS authority resolver as a subordinate control-plane layer. Do not create a new authority root.

## Required Reads

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/codex/os/AMB-CODEX-OS-AUTHORITY-RESOLVER.md`
- `.codex/skills/ambitions/authority-resolver.md`

## Scope

- Authority classification only.
- No app source, product IA, dependency, signing, hosted CI, or release-claim changes.

## Done

- Active, supporting, historical, obsolete, archive-candidate, delete-candidate, and unknown classifications are documented for touched files.
- Duplicate authority is refused or routed to the existing authority path.
- Validation and rollback notes are recorded.
