# Validation Policy

## Expected Validation By Task Type

- `small-edit`: file inspection and narrow validation when toolchain is unavailable
- `feature-build`: relevant build or tests when available, plus manual notes for routing or OS surfaces
- `domain-sensitive-change`: targeted tests are expected where possible
- `extension-config-work`: config inspection plus generation/build/manual notes depending on environment
- `docs-truth-cleanup`: source-backed claim checks; build/test only if active validation docs changed
- `release-hardening`: strongest available validation plus explicit gaps

## Reporting Rules

- always separate verified, not verified, could not verify here, likely risks, and manual follow-up required
- never claim runtime behavior unless it was exercised or tightly proven by code inspection
- state environment limits clearly
