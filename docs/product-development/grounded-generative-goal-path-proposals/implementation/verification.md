# Verification

## Exact commands

```bash
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py check docs/product-development/grounded-generative-goal-path-proposals --json
python3 scripts/ambitions-canon.py check
python3 -m pytest tools/generative-runtime/tests/test_goal_path_proposal_task.py
python3 tools/generative-runtime/cli.py validate-task goal-path-proposals-v1
python3 scripts/source-atlas-boundary-audit.py
python3 scripts/source-atlas-no-private-graph-egress-audit.py
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
bash scripts/ci/ambitions-gitleaks-scan.sh --range-only
scripts/ambitions-xcode-test-focused.sh --batch PDL-GENERATIVE-GOAL-PATH --test AmbitionsTests/RouteEvidenceGraphTests --test AmbitionsTests/GenerativeRouteComposerTests --test AmbitionsTests/RouteProposalValidationTests --test AmbitionsTests/GroundedGoalPathProposalRepositoryTests --test AmbitionsTests/RouteProposalDeltaTests --test AmbitionsTests/GoalPathProposalComparisonBoundaryTests --test AmbitionsTests/GoalPathProposalActivationBoundaryTests --test AmbitionsTests/GoalPathProposalPrivacyTests --test AmbitionsTests/GoalPathProposalAccessibilityTests
make test-local BATCH=PDL-GENERATIVE-GOAL-PATH-FULL LANE=test-plan
swift test --package-path Packages/AmbitionsExternalContracts
xcodegen generate
git diff --check -- Ambitions.xcodeproj project.yml
make xcode-build-for-testing BATCH=PDL-GENERATIVE-GOAL-PATH
git diff --check
```

## Required evidence

- Golden route graphs for NASA alternatives/selection/training, regulated,
  education, hobby, sparse and closed-current cases.
- Invented alias/source/gate/equivalence/current fact, false satisfaction,
  authority-as-user-work, cycles/graph bombs/injection and prediction fail.
- Every source-owned element is inspectable; generic edits lose attribution.
- Model unavailable/sparse/stale/canceled/invalid paths retain v1/manual value.
- No private canary enters public/provider/log/receipt and no composition path
  reaches Goal/Path/Step/Proof/Time commands.
- Revision races and fault-injected save/migrate/delta/compare/activate/delete/
  purge preserve immutable snapshots and deletion terminality.
- Migration evidence is lossless-or-inspection-only and never reclassifies
  unsupported legacy path semantics as grounded generated output.
- Security evidence covers graph/alias injection, cycle/resource bombs,
  prohibited commands and public/private boundary canaries.
- Delta fixtures preserve accepted completion/history and explain every change.
- Accessibility/device proof covers list-equivalent graph and delta at scale.
- Physical-device performance evidence measures graph assembly, generation,
  validation, projection, delta, cancellation, memory, storage and energy.
- Task/model/source-bound evaluation covers graph/source/semantic correctness,
  granularity, alternatives, continuity, privacy/bias/dignity and usefulness.

## Final claim ceiling

Passing proves proposal composition for exact admitted route evidence and tested
task/model/device versions. It does not prove universal route knowledge,
personal eligibility/success, canonical activation, scheduling, external action,
deployment or release.
