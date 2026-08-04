# Verification

## Exact commands

```bash
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py check docs/product-development/grounded-generative-destination-proposals --json
python3 scripts/ambitions-canon.py check
python3 -m pytest tools/generative-runtime/tests/test_destination_proposal_task.py
python3 tools/generative-runtime/cli.py validate-task destination-proposals-v1
python3 scripts/source-atlas-boundary-audit.py
python3 scripts/source-atlas-no-private-graph-egress-audit.py
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
bash scripts/ci/ambitions-gitleaks-scan.sh --range-only
scripts/ambitions-xcode-test-focused.sh --batch PDL-DESTINATION-PROPOSALS --test AmbitionsTests/AmbitionInterpretationTests --test AmbitionsTests/DestinationCandidateBundleTests --test AmbitionsTests/DestinationProposalValidationTests --test AmbitionsTests/DestinationProposalCoordinatorTests --test AmbitionsTests/DestinationProposalRepositoryTests --test AmbitionsTests/DestinationProposalAdoptionBoundaryTests --test AmbitionsTests/DestinationProposalPrivacyTests --test AmbitionsTests/DestinationProposalAccessibilityTests
make test-local BATCH=PDL-DESTINATION-PROPOSALS-FULL LANE=test-plan
swift test --package-path Packages/AmbitionsExternalContracts
xcodegen generate
git diff --check -- Ambitions.xcodeproj project.yml
make xcode-build-for-testing BATCH=PDL-DESTINATION-PROPOSALS
git diff --check
```

## Required evidence

- Golden/adversarial interpretations preserve exact input and expose ambiguity.
- Unknown/minted/stale candidate aliases, false equivalence/qualification,
  unsupported source/current/capability claims and prose facts fail validation.
- Domain/route sets produce meaningfully different supported options or fewer
  results; source sparsity never becomes negative fit or no-opportunity claim.
- Private canaries never enter public/provider/log/receipt paths; no model or
  coordinator reaches commands.
- Context/source/model revision races, cancel/retry/save/delete/migrate and
  adoption revalidation preserve atomicity and deletion terminality.
- Migration evidence preserves legacy deterministic recommendation provenance
  and never recasts it as generated or source-grounded output.
- Security evidence covers prompt/alias injection, malformed/deep output,
  prohibited command reachability and public/private boundary canaries.
- Accessibility/device proof covers interpretation, source/unknown inspection,
  comparison, correction, fallback and handoff.
- Claim-bound evaluation covers fidelity, grounding/citation, diversity,
  transfer, privacy/sensitive inference, bias/dignity, correction and usefulness.
- Physical-device retrieval/generation/validation latency, memory, energy and
  cancellation performance meet thresholds established before implementation
  acceptance.

## Final claim ceiling

Passing proves grounded proposal behavior for exact admitted corpus/task/model/
device versions. It does not prove universal destination coverage, path quality,
Goal adoption, hosted privacy, external action, deployment or release.
