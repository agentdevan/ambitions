# Verification

## Exact commands

```bash
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py check docs/product-development/personal-context-and-constraint-controls --json
python3 scripts/ambitions-canon.py check
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
bash scripts/ci/ambitions-gitleaks-scan.sh --range-only
scripts/ambitions-xcode-test-focused.sh --batch PDL-PERSONAL-CONTEXT --test AmbitionsTests/ContextFactModelsTests --test AmbitionsTests/ContextPurposeGrantTests --test AmbitionsTests/PersonalContextRepositoryTests --test AmbitionsTests/PersonalContextResolverTests --test AmbitionsTests/ContextPrecedenceConflictTests --test AmbitionsTests/ContextUnitTimezoneTests --test AmbitionsTests/PersonalContextReadBoundaryTests --test AmbitionsTests/TaskLocalContextOverrideTests --test AmbitionsTests/ContextInfluenceImpactTests --test AmbitionsTests/PersonalContextMigrationPurgeTests --test AmbitionsTests/PersonalContextPrivacyTests --test AmbitionsTests/PersonalContextAccessibilityTests
make test-local BATCH=PDL-PERSONAL-CONTEXT-FULL LANE=test-plan
swift test --package-path Packages/AmbitionsExternalContracts
xcodegen generate
git diff --check -- Ambitions.xcodeproj project.yml
make xcode-build-for-testing BATCH=PDL-PERSONAL-CONTEXT
git diff --check
```

## Required evidence

- Typed round-trip for every fact/status/grant/unit/time/recurrence/sensitivity.
- Unknown/declined/not-included/conflict never becomes zero/unmet/negative fit.
- Purpose expiry/revoke and sensitive/generic fallback matrices pass.
- Consumers cannot enumerate/write/persist/egress joined context; private
  values/notes/locations/times never appear in diagnostics/metrics.
- Security evidence covers protected storage, no-enumeration capability checks,
  stale/replayed grants, injected values and prohibited remote/command paths.
- Precedence/must-respect/conflict/what-if fixtures are deterministic and
  registry bytes remain unchanged for local overrides.
- DST/timezone/calendar/locale/currency changes re-resolve and notify exact
  dependents without canonical mutation.
- Fault-injected save/edit/disable/archive/migrate/delete/purge is atomic,
  resumable and deletion terminal.
- Suggestion client remains unavailable without a promoted evidence-bound policy.
- Accessibility/localization/physical-device proof covers all categories/states,
  impact and delete flows; performance/resource thresholds are established.
- Direct-user evidence assesses capture burden, language, influence/conflict
  comprehension and dignity before enabling defaults.

## Final claim ceiling

Passing proves manual/purpose-controlled context on tested devices and consumers.
It does not prove import integrations, inferred suggestions, improved planning/
scheduling outcomes, hosted privacy, deployment or release.
