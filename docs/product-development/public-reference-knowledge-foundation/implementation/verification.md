# Verification

## Exact automated and build checks

```bash
python3 scripts/ambitions-canon.py check
python3 scripts/source-atlas-boundary-audit.py
python3 scripts/source-atlas-no-private-graph-egress-audit.py
python3 scripts/ambitions-local-first-boundary-scan.py
scripts/ambitions-xcode-test-focused.sh --batch PDL-PUBLIC-REFERENCE --test AmbitionsTests/PublicReferenceKnowledgeModelsTests --test AmbitionsTests/PublicReferenceAuthorityPolicyTests --test AmbitionsTests/PublicReferenceRepositoryTests --test AmbitionsTests/PublicReferenceInspectionProjectionTests --test AmbitionsTests/PublicReferenceConsumerContractTests --test AmbitionsTests/SourceAtlasNoPrivateGraphEgressAuditTests
xcodegen generate
git diff --exit-code -- Ambitions.xcodeproj
make xcode-build-for-testing BATCH=PDL-PUBLIC-REFERENCE
git diff --check
```

## Required evidence

- Automated: authority/freshness/rights/conflict matrices, deterministic query,
  offline/last-known-good, cancellation, concurrent refresh, corrupt pack,
  schema compatibility, and private-egress attacks cover REQ-001 through REQ-011.
- Build: generated project and build-for-testing pass.
- Runtime: synthetic pack install, offline inspection, stale/conflict recovery,
  refresh, and last-known-good behavior are exercised without a private graph.
- Accessibility: direct inspection flow verification for VoiceOver, assistive
  controls, Dynamic Type, non-color states, reduced motion, and focus recovery.
- Privacy: assert byte-level absence of private IDs, Goal text, Capability data,
  location, schedule, rationale, and derived private keys from requests, caches,
  logs, telemetry, diagnostics, R2, and support payloads.
- Migration: cache-schema upgrade, crash/rerun, incompatible pack quarantine,
  rollback to last-known-good, and deterministic reconstruction.
- Performance: benchmark pack verification, indexed query, refresh swap, and
  inspection projection at representative pack sizes; establish merge budgets
  with device/OS/build metadata.
- Device: required for rendered inspection and assistive-technology proof;
  external-source correctness still requires fixture/source review, not device.
