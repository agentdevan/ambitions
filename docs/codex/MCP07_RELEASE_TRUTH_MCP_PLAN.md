# MCP07 Release Truth MCP Plan

Status: Scaffold only.
Scope: evidence-bound release claim checks.

Planned tools:

- `check_public_claims_against_evidence`
- `check_app_store_packet_shape`
- `check_privacy_support_url_readiness`
- `check_device_evidence_presence`
- `generate_release_truth_packet_stub`

Hard boundaries:

- do not claim release readiness
- do not upload to App Store
- do not create signing automation
- do not create hosted CI
- do not claim physical-device proof, public accessibility proof, legal/privacy approval, TestFlight readiness, or App Store readiness without matching evidence
