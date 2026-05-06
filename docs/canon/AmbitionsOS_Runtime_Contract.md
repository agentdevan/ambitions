# AmbitionsOS Runtime Contract

Status: AOS01 runtime contract source truth; docs/protocol only; not current app implementation truth
Date: 2026-05-06
Owner: Governance Kernel / Runtime Contract

## AOS01 Activation Boundary

AOS01 activates the AmbitionsOS runtime contract for later AOS batches. It does
not implement AmbitionsOS runtime behavior, model behavior, event logging,
graph persistence, source-pack runtime, UI, platform integration, sync, account,
backend, hosted AI, or external-surface behavior.

The current app remains governed by Ambitions 3.0 source truth. Future AOS
batches may implement only the named kernel slice after this contract, HPS
inheritance, Source Atlas inheritance where relevant, validation, and file
boundaries are satisfied.

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

## HPS Inheritance

Every future AOS output must inherit Human Progress Systems gates before it can
be treated as product behavior:

- Human Progress Graph and one-primary-object surface law
- Verified Proof Ledger and proof portability boundaries
- Source Truth / Requirement Graph claim states
- Commitment Memory and Searchable Life Recall review boundaries
- Recommendation Quality / Start Here Brain regression oracle
- Option Value / Pivot Preservation receipts
- Living Dream Compiler bridge where LDI is relevant
- Privacy / Memory Permission Kernel and deterministic fallback
- AI Governance / Evaluation Assurance Lab
- Singular Experience / Acquisition Readiness Lock no-claim boundary

HPS remains a substrate. AOS must not expose HPS as a separate product layer,
new top-level surface, all-life graph viewer, or broad command surface.

## Source Atlas Inheritance

AOS must use Source Atlas when future behavior touches real-world requirements,
source packs, user-provided sources, source freshness, external claims, school,
career, certification, legal/civic/professional sources, or source-dependent
recommendations.

Required Source Atlas inheritance:

- claim states
- freshness states
- user-provided-is-not-official rule
- source-needed fallback
- stale high-risk block
- claim review before mutation
- local/offline fallback
- private source redaction
- pack validation, revocation, and rollback boundaries

No AOS batch may treat a generated requirement, path claim, source claim, or
recommendation as official/current without source proof.

## Runtime Contract Locks

Future AOS batches must preserve:

- typed contracts before behavior
- deterministic fallback before model assistance
- event/proposal before mutation
- source proof before source-sensitive claims
- user review before consequential changes
- privacy projection before external surfaces
- performance budget before runtime-heavy work
- compatibility review before seam retirement
- maintainability review before large-file work
- release-claim review before public/platform wording

## Future Test Contract

Every future implementation must provide typed fixtures, contract tests, rollback proof, privacy projection proof, source-truth proof where relevant, and release-claim boundary review.
