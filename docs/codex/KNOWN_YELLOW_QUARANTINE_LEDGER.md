# Known-Yellow Quarantine Ledger

Known caveats are recorded here to prevent re-discovery and false "fixed" claims.

## PK15 External Surface Stale Projection Mismatch

ID: KY-2026-05-10-PK15-EXT-01  
Source: PK15 Receipt Backend closeout evidence and queue-state reconciliation  
Observed in: `ExternalSurfaceVerificationChecklistTests.testM04ExistingProjectionsCarryStalePrivateAndFallbackBehavior`  
Status: Accepted Yellow (historically known and pending external-surface follow-up)  
Owner: QA / External Surface proof lane  
Why it is quarantined: The failure is reproducible in full-surface proof context and unrelated to PK16-closeout follow-through; it remains tracked for External Surface follow-up after local trust/backend proof lanes close.

When it blocks:
- Claiming full external-surface validation green.
- Claiming global batch completion based on the affected external-surface expectation.
- Re-running a similarly scoped full-surface gate without explicit external-surface follow-up.

When it does not block:
- Focused trust-history and local persistence work that does not touch the affected external surface projection path.
- Local PK17-PK21 service extraction work when it does not alter the tested external projection path.

Recheck command:
- `bash scripts/global-train-red-repair-hint.sh ExternalSurfaceVerificationChecklistTests.testM04ExistingProjectionsCarryStalePrivateAndFallbackBehavior`

No-claim boundary:
- Do not claim full external-surface verification green until this caveat is resolved by the owning follow-up lane.

