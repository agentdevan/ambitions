# AMB-POST23 Repair Routing

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-59518727, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-34058953

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Use this file after the truth audit to decide what must be repaired before UI Suite, Backend Flagship, or Frontend Flagship trains run.

## Mandatory routing rules

| Finding | Route |
| --- | --- |
| Start Here is fake, hardcoded, or not backend-grounded | Core-loop repair before UI polish |
| Reality Meridian is decorative only | Backend projection repair plus UI Suite review |
| Final IA is incomplete | Shell/IA repair before flagship polish |
| Proof/receipts are UI-only | Backend proof/receipt repair |
| Closure is not durable | Backend closure/receipt repair |
| View layer computes planning truth | Backend projection repair and SwiftUI boundary cleanup |
| UI is generic, dashboard-like, or card-stack-heavy | UI Suite review and frontend repair |
| Tests are missing or weak | Proof/validation repair before next flagship train |
| Authority is duplicated | Authority cleanup before more trains |
| Apple continuity assumptions exist but no implementation | Continuity strategy, not implementation claim |
| Old Plan/Habits/Insights/Profile top-level residue remains | IA cleanup/rehome repair |
| Privacy/local-first claims outrun code | Privacy claim repair before App Store/launch work |
| Integrated proof is mock-only | Core-loop proof repair before launch-hardening |

## Repair priority order

1. Final IA correctness.
2. No fake Start Here.
3. No decorative-only Reality Meridian.
4. No view-layer planning truth.
5. Durable closure/receipt/proof where shown.
6. Backend projection contracts exist.
7. Deterministic recommendation proof or honest Yellow.
8. Old top-level IA residue removed or rehome-marked.
9. Duplicate canon/authority eliminated or classified.
10. Validation reports updated honestly.

## Forbidden repair scope

The repair pass must not become a second flagship train. It must not install Apple continuity, full frontend polish, full backend platform work, or broad redesign. It repairs the promised post-23 foundation only.

## Next-train decision rules

- If core loop is not real, repair core loop first.
- If backend truth is weak, run backend repair before UI polish.
- If UI is implemented but generic, run UI Suite next.
- If source truth is duplicated, run authority cleanup before any major train.
- If Apple continuity is only assumed, run Apple continuity strategy after core foundation is real.
- If post-23 foundation is Green enough, proceed to UI Suite, then Backend Flagship, then Frontend Flagship unless evidence suggests a different order.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
