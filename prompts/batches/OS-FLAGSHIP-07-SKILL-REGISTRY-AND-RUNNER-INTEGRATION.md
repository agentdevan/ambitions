<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# OS-FLAGSHIP-07-SKILL-REGISTRY-AND-RUNNER-INTEGRATION

## Purpose

Validate that the flagship Codex OS skills and generated prompt artifacts are discoverable from the existing Ambitions runner/control-plane.

## Required Reads

- `docs/truth/README.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/codex/CODEX_OS_INDEX.md`
- `docs/codex/os/AMB-CODEX-OS-FLAGSHIP-UPGRADE-MANIFEST.md`
- `.codex/skills/ambitions/README.md`
- `scripts/ambitions-codex-os-validate.py`
- `scripts/ambitions-codex-os-doctor.py`

## Scope

- Skill registry, prompt registry, validation, and doctor discoverability only.
- No branch creation, app-source implementation, product IA change, dependency change, hosted CI, signing, or release automation.

## Done

- Generated prompt files have runner headers.
- Skill wrappers route to existing skills or clearly documented local wrappers.
- Validator and doctor report the installed layer without creating a second OS.
- Validation and rollback notes are recorded.
