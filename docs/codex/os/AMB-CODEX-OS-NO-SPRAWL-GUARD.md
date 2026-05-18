# AMB-CODEX-OS-NO-SPRAWL-GUARD

Supporting note: This guard supports current Ambitions Codex work but does not override `docs/truth/`.

## Purpose

Prevent the install from creating a second OS or a second source of truth.

## Guardrails

- Do not create duplicate canon trees.
- Do not create duplicate design-system or backend modules.
- Do not create orphan prompts or unregistered docs.
- Do not create a second top-level operating system root.
- Do not let `.codex/runs/` become product-facing documentation.
- Keep new docs subordinate to `docs/truth/*` and the existing `docs/codex-os/` portal.

## Routes to existing support

- `pack-duplication-reviewer`
- `orphan-doc-resolver`
- `changed-file-boundary-reviewer`
- `source-truth-librarian`

## Non-claims

This guard is about scope control, not implementation proof.
