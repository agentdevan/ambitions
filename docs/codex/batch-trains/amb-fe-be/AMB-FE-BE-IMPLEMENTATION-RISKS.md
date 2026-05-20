# AMB-FE-BE Implementation Risks

Status: Installed docs-only risk note

## Primary risks

- A later batch could drift into app source outside its allowed seam.
- A later batch could revive obsolete IA or compatibility names as active truth.
- A later batch could overclaim implementation, validation, device proof, or release readiness.
- A later batch could treat this contract freeze as proof of implementation or release readiness.
- A later batch could widen scope from the bounded train into repo cleanup or architecture rewrites.
- A later batch could treat the required visual or accessibility handoff references as proof that this docs-only hardening batch produced screenshots, previews, or conformance evidence.

## Mitigations

- Keep each prompt narrow and self-contained.
- Re-read `docs/truth/*` before every bounded patch.
- Keep the active IA and local-only posture explicit.
- Keep contract language and proof artifacts separate.
- Require hard Red stop conditions in every batch prompt.
- Keep rollback guidance per prompt and per train document.
- Label visual and accessibility references as handoff requirements only, not as proof artifacts for this batch.

## Non-claims

This risk note does not authorize implementation. It only records the installer-level concern set.
