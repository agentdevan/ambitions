# AFEP-021 Accessibility Proof Claim Boundary

## Boundary

This batch establishes a deterministic accessibility certification scaffold only.

It does not prove rendered screenshots, manual VoiceOver traversal, Dynamic Type screenshots, Reduce Motion walkthroughs, Increase Contrast measurement, motor/tap-target review, physical-device behavior, release readiness, or public accessibility conformance.

## Allowed Claims

- The five canonical Ambitions surfaces are represented in source.
- The accessibility gate matrix is deterministic.
- The evidence packets are local, path-safe, and include follow-up proof requirements.
- SourceRecord, Receipt, ReplayTrace, and You inspection provenance fields are present.
- The AFRI-034 accessibility proof matrix remains the rollback baseline.
- The AFRI-005 shell screenshot proof path remains the rollback path for rendered proof work.

## Forbidden Claims

- release readiness
- production readiness
- CI proven
- device validation
- TestFlight readiness
- App Store readiness
- fully accessible
- VoiceOver verified
- Dynamic Type verified
- Reduce Motion verified
- Increase Contrast verified
- tap-target verified
- public accessibility certification
- screenshots were rendered
- accessibility certification is public

## Public Claim Lock

The scaffold keeps every public accessibility claim blocked:

- source-backed support is allowed
- automated-test support is allowed
- rendered proof is blocked
- manual proof is blocked
- device proof is blocked
- public certification approval is blocked

## Notes

The scaffold is intended for deterministic preview and proof orchestration only. It does not alter production UI behavior.
