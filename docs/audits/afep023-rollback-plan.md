# AFEP-023 Rollback Plan

Issue: AMB-417 / AFEP-023
Date: 2026-06-01

## Primary Rollback

Remove the AFEP-023 support/report scaffold and audit docs, then re-run the focused validation to confirm the repo remains on the conservative local-only privacy baseline.

## Exact Revert Targets

- `Native/Ambitions/Support/ReleasePrivacyProtectedStorageReport.swift`
- `Native/AmbitionsTests/App/ReleasePrivacyProtectedStorageReportTests.swift`
- `docs/audits/afep023-field-level-privacy-matrix.md`
- `docs/audits/afep023-protected-storage-architecture-packet.md`
- `docs/audits/afep023-export-reset-delete-redaction-rules.md`
- `docs/audits/afep023-privacy-manifest-alignment-report.md`
- `docs/audits/afep023-rollback-plan.md`

## Rollback Steps

1. Remove the AFEP-023 source scaffold and tests.
2. Remove the AFEP-023 audit docs.
3. Keep `Native/Ambitions/Resources/PrivacyInfo.xcprivacy` unchanged.
4. Confirm the repo still declares no tracking, no collected data, and no accessed API reasons.
5. Re-run the focused AFEP-023 validation and claim-scan commands.
