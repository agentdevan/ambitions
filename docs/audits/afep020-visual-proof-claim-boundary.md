# AFEP-020 Visual Proof Claim Boundary

## Boundary

This batch establishes a deterministic lab scaffold only.

It does not prove rendered screenshots, accessibility certification, device validation, CI validation, release readiness, or production visual QA.

## Allowed Claims

- The five canonical Ambitions surfaces are represented in source.
- The visual diff lab metadata is deterministic.
- Artifact names and paths are local and path-safe.
- SourceRecord, Receipt, ReplayTrace, and You inspection provenance fields are present.
- The AFRI-005 screenshot proof path remains available as the fallback path for rendered proof work.

## Forbidden Claims

- `release-ready`
- `production-ready`
- `CI-proven`
- `device-verified`
- `TestFlight-ready`
- `App Store-ready`
- `fully accessible`
- `VoiceOver verified`
- `Dynamic Type verified`
- `Reduce Motion verified`
- `Increase Contrast verified`
- `screenshots were rendered`
- `visual diffs are production-ready`

## Rollback / Fallback

If a rendered screenshot baseline is needed, use the existing AFRI-005 shell screenshot proof path:

`docs/proof/afri/afri-005-shell-preview-screenshot-proof.md`

## Notes

The scaffold is intended for deterministic preview and proof orchestration only. It does not alter production UI behavior.
