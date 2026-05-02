# AmbitionsOS Runtime Contract

Status: Future runtime contract; not current app implementation truth

## Allowed Outputs

- GraphDelta
- Projection
- Recommendation
- Question
- Receipt
- ReviewRequest
- SourceRequest
- ClosurePrompt
- PathComparison
- ImpactReport
- PrivacyProjection
- LoadingState
- FailureState
- CapabilityFallback
- PerformanceBudgetReport
- TrustState
- CompatibilityImpactReport
- MaintainabilityImpactReport
- MigrationPlan
- RollbackPlan
- TestPlan

## Forbidden Outputs And Behaviors

- vague prose as truth
- model output directly mutating Life Graph
- unsourced regulated facts as verified
- unbounded background computation
- unreviewed privacy-sensitive external projection
- silent consequential changes
- source-sensitive recommendations without source state
- app launch dependency on model inference
- navigation dependency on internet
- release claims without evidence
- adding behavior to large files without extraction review
- retiring compatibility seams without migration/test/rollback proof
- changing user-visible terminology without copy guard

## Gate Order

Runtime output must pass trust, performance-energy, privacy, compatibility, maintainability, and user-approval gates before consequential event logging.

## Future Test Contract

Every future implementation must provide typed fixtures, contract tests, rollback proof, privacy projection proof, source-truth proof where relevant, and release-claim boundary review.
