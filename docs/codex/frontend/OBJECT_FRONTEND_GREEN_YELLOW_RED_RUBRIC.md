# Object Frontend Green / Yellow / Red Rubric

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-48361765, AMB28-same_source_file_targeted_by_multiple_active_batches-73637881, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Final working draft  
Scope: Object frontend implementation, validator, previews, tests, proof, and no-card architecture

---

## Green

A batch may close Green only when all required items are true:

- Source changed in the intended scope.
- Named or inferred object root installed.
- Active card architecture removed.
- Top-level surface no longer resembles cards/list/dashboard/feed/chat/calendar clone.
- Tests updated.
- Preview matrix updated.
- Accessibility labels/identifiers present.
- Reduce Motion path exists where motion changed.
- `scripts/ios26-anti-card-check.py` passes for the relevant surface.
- Proof artifact written.
- Screenshot/manual proof supplied where required.
- Final report separates source, tests, previews, validators, proof, prompts, and design-system changes.

---

## Yellow

Yellow is allowed only after a repair cycle.

A valid Yellow must include:

- exact reason
- exact files affected
- owner
- no-claim boundary
- follow-up gate
- validation posture
- repair attempts already made
- whether user-visible UI is affected

Allowed Yellow cases:

- screenshot automation unavailable
- legacy compatibility remains outside active UI
- design-system cleanup intentionally deferred
- external tool/simulator unavailable
- manual screenshot checklist required

Yellow may not claim object-purity completion.

---

## Red

Red if any of these remain:

- active top-level card stack
- active dashboard/feed/chat/list/calendar-clone root
- object root absent
- design system overwritten without scoped need
- accessibility path broken
- gesture without tap fallback
- motion-only meaning
- haptic-only confirmation
- silent material mutation
- unreceipted material change
- active card compatibility wrapper in rendered UI
- forbidden Assistant/chat/dashboard/productivity/task framing

---

## Rollback

Rollback must:

- revert only files touched by the batch
- preserve unrelated dirty work
- remove malformed generated artifacts
- keep generated reports if needed for failure diagnosis
- never broad reset the repo

---

## Final Implementation Thesis

```text
Install an object-first SwiftUI frontend that inherits AmbitionsDesignSystem and removes generic card architecture from active top-level surfaces.

Convert Ambitions from screen/card UI into named native life instruments with proof, motion, accessibility, and validation.

Make Ambitions’ frontend implementation match its product objects: Meridian, Field, Atlas, Composer, Profile, and Proof.
```

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
