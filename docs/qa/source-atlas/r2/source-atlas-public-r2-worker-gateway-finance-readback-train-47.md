# Source Atlas Public R2 Worker Gateway Finance Readback Train 47

Status: Green
Worker version: 2a81f5ae-b862-4299-a2f0-e65172814d4f
Domain: finance_public_reference
Pack: source-atlas/v1/domain/finance_public_reference/20260628T000000Z
Pack SHA-256: ca23807f8cae55bf052600a90ca205ff3436f987e5d97f8518e96cd300bd0c19

Allowed finance responses:
- GET source-atlas/v1/production/stable/finance_public_reference/current.json: status=200 hashMatchesExpected=True
- GET source-atlas/v1/production/stable/finance_public_reference/lkg.json: status=200 hashMatchesExpected=True
- GET source-atlas/v1/production/stable/finance_public_reference/revocations.json: status=200 hashMatchesExpected=True
- GET source-atlas/v1/production/stable/finance_public_reference/20260628T000000Z/manifest.json: status=200 hashMatchesExpected=True
- GET source-atlas/v1/production/stable/finance_public_reference/20260628T000000Z/pack.json: status=200 hashMatchesExpected=True

Active current HEAD responses:
- source-atlas/v1/production/stable/occupation_foundation/current.json: status=200 publicHeader=true
- source-atlas/v1/production/stable/public_civic_requirements/current.json: status=200 publicHeader=true
- source-atlas/v1/production/stable/education_credentialing/current.json: status=200 publicHeader=true
- source-atlas/v1/production/stable/business_entrepreneurship/current.json: status=200 publicHeader=true
- source-atlas/v1/production/stable/hobbies_recreation/current.json: status=200 publicHeader=true
- source-atlas/v1/production/stable/health_wellness_reference/current.json: status=200 publicHeader=true
- source-atlas/v1/production/stable/travel_relocation/current.json: status=200 publicHeader=true
- source-atlas/v1/production/stable/finance_public_reference/current.json: status=200 publicHeader=true

Blocked route responses:
- query_private_marker_blocked: status=404 blocked=True
- non_allowlisted_slice_blocked: status=404 blocked=True
- private_marker_path_blocked: status=404 blocked=True
- post_method_blocked: status=405 blocked=True

R2 request privacy proof: fixed public object-key GET/HEAD requests through exact allowlist; private query marker rejected; non-allowlisted slices rejected; POST rejected.
No private graph egress proof: requests contain only public Source Atlas object keys; no goal, capture, schedule, proof, account, device, private graph, personalization, behavior, or user identifiers are sent.
License/terms proof: docs/qa/source-atlas/legal/source-atlas-finance-legal-review-train-47.json; internal terms review only, no outside legal approval claimed.

Production non-claims:
- not outside legal approval
- not release readiness
- not App Store readiness
- not full Source Atlas Green
- not universal goal coverage
- not investment, tax, legal, or debt advice
- not benefit eligibility or approval
- not personalized financial planning
- not final user plans, schedules, Steps, or personalized paths from Source Atlas/R2
