# AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01

Status: supporting install report

Supporting note: This report supports current Ambitions Codex work but does not override `docs/truth/`.

## Summary

Installed a thin, subordinate flagship Codex OS layer under `docs/codex/os/`, added routing skill wrappers under `.codex/skills/ambitions/`, and tightened the local Codex OS validator so `--help` can report usage without running validation.

## Installed artifacts

- `docs/codex/os/README.md`
- `docs/codex/os/AMB-CODEX-OS-FLAGSHIP-UPGRADE-MANIFEST.md`
- `docs/codex/os/AMB-CODEX-OS-AUTHORITY-RESOLVER.md`
- `docs/codex/os/AMB-CODEX-OS-GREEN-YELLOW-RED-STANDARD.md`
- `docs/codex/os/AMB-CODEX-OS-NO-SPRAWL-GUARD.md`
- `docs/codex/os/AMB-CODEX-OS-PROOF-LEDGER.md`
- `docs/codex/os/AMB-CODEX-OS-VISUAL-QA-GATE.md`
- `docs/codex/os/AMB-CODEX-OS-PRIVACY-CLAIM-GATE.md`
- `docs/codex/os/AMB-CODEX-OS-APPLE-CONTINUITY-GATE.md`
- `docs/codex/os/AMB-CODEX-OS-LAUNCH-BELIEVABILITY-GATE.md`
- `prompts/batches/OS-FLAGSHIP-01-AUTHORITY-RESOLVER.md`
- `prompts/batches/OS-FLAGSHIP-02-NO-SPRAWL-GUARD.md`
- `prompts/batches/OS-FLAGSHIP-03-PROOF-LEDGER.md`
- `prompts/batches/OS-FLAGSHIP-04-VISUAL-QA-GATE.md`
- `prompts/batches/OS-FLAGSHIP-05-PRIVACY-APPLE-CONTINUITY-GATES.md`
- `prompts/batches/OS-FLAGSHIP-06-LAUNCH-BELIEVABILITY-REVIEW.md`
- `prompts/batches/OS-FLAGSHIP-07-SKILL-REGISTRY-AND-RUNNER-INTEGRATION.md`

## Phase 04 repair notes

- Added the seven required generated batch prompt artifacts with runner headers.
- Repaired the SwiftUI wrapper route from missing `native-ios-believability-reviewer` to existing `ios-native-believability-reviewer`.
- Tightened `scripts/ambitions-codex-os-validate.py` so generated prompt artifacts are required and runner-header checked.
- Restored generated `build/codex-os/*` churn before final validation.

## Validation status

Validation was rerun after the Phase 04 repair and is recorded in the batch closeout narrative for this turn.

## Non-claims

This report does not claim implementation, release readiness, or new product behavior.
