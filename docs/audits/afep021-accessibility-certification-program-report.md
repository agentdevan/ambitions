# AFEP-021 Accessibility Certification Program Report

## Result

Source-backed scaffold only. Public accessibility certification remains blocked until manual/device proof exists.

## Batch

AFEP-021 - Accessibility Certification Program.

## Scope

This batch adds a reusable accessibility certification scaffold for the five canonical Ambitions surfaces:

- Today
- Goals
- Capture
- Time
- You

The scaffold keeps source hooks, labels, fixture metadata, evidence-packet metadata, proof-kind boundaries, and rollback paths local to the repo. It does not certify accessibility, render screenshots, or claim public conformance.

## Files

- `Native/Ambitions/PreviewSupport/ShellPreviewMatrix.swift`
- `Native/AmbitionsTests/App/ShellPreviewMatrixTests.swift`
- `docs/audits/afep021-accessibility-certification-program-report.md`
- `docs/audits/afep021-accessibility-gate-matrix.md`
- `docs/audits/afep021-accessibility-proof-claim-boundary.md`
- `docs/audits/afep021-accessibility-rollback-plan.md`

## Source Model

- `AFEP021AccessibilityCertificationProgram` captures surface fixtures, gate matrix entries, evidence packets, proof-boundary metadata, provenance references, and local-only claim flags.
- The five canonical surfaces keep their active primary objects:
  - Today -> Reality Meridian
  - Goals -> Constellation Atlas
  - Capture -> Atmosphere Composer
  - Time -> LifeShape Field
  - You -> User System Profile
- Required gates are represented for VoiceOver, Dynamic Type, Reduce Motion, Increase Contrast, tap targets, semantic grouping, non-color meaning, motion-independent meaning, privacy/redaction readability, and cognitive load.
- The evidence packets record command, artifact path, surface, fixture state, pass/skipped state, known limitation, owner, proof kind, and follow-up proof requirement.
- Local-only provenance labels use:
  - `SourceRecord.afep021.accessibility-certification-program`
  - `Receipt.afep021.accessibility-certification-program`
  - `ReplayTrace.afep021.accessibility-certification-program`
  - `You / What Ambitions knows`

## Claim Boundary

- No public accessibility certification claim.
- No VoiceOver verification claim.
- No Dynamic Type verification claim.
- No Reduce Motion verification claim.
- No Increase Contrast verification claim.
- No tap-target or motor verification claim.
- No physical-device validation claim.
- No rendered screenshot proof claim.
- No release, TestFlight, App Store, or production claim.

## Rollback

Revert the AFEP-021 source and test scaffold to restore the AFRI-034 accessibility proof baseline and the AFRI-005 shell screenshot rollback path.
