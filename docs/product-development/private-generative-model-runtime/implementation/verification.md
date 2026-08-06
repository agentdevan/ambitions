# Verification

## Exact commands

```bash
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py check docs/product-development/private-generative-model-runtime --json
python3 scripts/ambitions-canon.py check
python3 -m unittest discover -s tools/tests -p 'test_ambitions_canon_compiler.py'
python3 -m pytest tools/generative-runtime/tests
python3 tools/generative-runtime/cli.py validate-fixtures
python3 tools/generative-runtime/cli.py build --config tools/generative-runtime/config/task-registry-v1.json --output /tmp/ambitions-generation-registry
python3 tools/generative-runtime/cli.py verify --artifact /tmp/ambitions-generation-registry/generation-task-registry-v1.json
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/source-atlas-no-private-graph-egress-audit.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
bash scripts/ci/ambitions-gitleaks-scan.sh --range-only
scripts/ambitions-xcode-test-focused.sh --batch PDL-PRIVATE-GENERATION --test AmbitionsTests/GenerationTaskRegistryTests --test AmbitionsTests/GenerationModePolicyTests --test AmbitionsTests/GenerationContextMinimizationTests --test AmbitionsTests/GenerationTransferConsentTests --test AmbitionsTests/GenerationReadToolGatewayTests --test AmbitionsTests/GenerationValidationPipelineTests --test AmbitionsTests/GenerationRepairSessionTests --test AmbitionsTests/GenerationAdapterTests --test AmbitionsTests/GenerationPrivacyBoundaryTests --test AmbitionsTests/GenerationChangePurgeTests --test AmbitionsTests/GenerationAccessibilityTests
make test-local BATCH=PDL-PRIVATE-GENERATION-FULL LANE=test-plan
swift test --package-path Packages/AmbitionsExternalContracts
xcodegen generate
git diff --check -- Ambitions.xcodeproj project.yml
make xcode-build-for-testing BATCH=PDL-PRIVATE-GENERATION
git diff --check
```

Record command/status/count/hash/device/OS/model availability and exact task/
model/runtime/prompt/schema/policy tuple. Repeat registry build network-denied
and require identical bytes. Run platform inference only on supported physical
devices and distinguish fake-adapter, simulator, on-device and PCC evidence.

## Required evidence

- Registry rejects unknown/changed/unsigned task bundles and embedded prompts.
- Routing matrices prove deterministic on-device preference, manual fallback,
  no content-dependent provider choice and no silent cloud escalation.
- Context minimization fixtures show only registered fields and exact inclusion
  reasons; hosted captures have ephemeral IDs and no private/stable canaries.
- Consent version/revoke/interruption tests block unauthorized transfer.
- Tool injection/write/arbitrary URL/recursive graph/resource attacks fail.
- Validator fuzz/property tests reject malformed/deep/large/Unicode/injected,
  unsupported citation, invented ID, cycle and prohibited-claim outputs.
- Bounded repair, timeout, refusal, resource pressure, context overflow,
  cancellation and dependency-change tests yield honest terminal states.
- No runtime path reaches commands; feature owner revalidates candidate.
- Receipts/logs/metrics contain no payload; fault-injected purge is complete,
  resumable and deletion terminal.
- Migration evidence proves no legacy or existing content is reclassified as
  model output and unsupported registry/schema versions fail closed.
- Security evidence covers prompt/tool injection, schema/resource attacks,
  artifact tampering, provider misrouting and command-boundary reachability.
- OS/model change invalidates only exact drafts; accepted canonical bytes remain.
- Accessibility and direct-user evidence cover AI/mode/data disclosure, progress,
  sources, limits, edit/retry/alternative/cancel/clear.
- Physical-device latency, time-to-first-useful-result, memory, storage, thermal,
  energy and background/cancellation performance meet thresholds established
  before implementation acceptance.
- Task/mode/version quality hard gates cover validity, grounding/citation,
  privacy, bias/dignity, refusal, correction and usefulness.

## Final claim ceiling

Passing proves the registered runtime and exact evaluated on-device tasks on
tested devices/OS/model tuples. It does not prove PCC entitlement, any hosted
provider, all device/locale coverage, destination/path usefulness, autonomous
actions, deployment or release.
