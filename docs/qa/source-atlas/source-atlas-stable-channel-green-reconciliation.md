# Source Atlas Stable Channel Reconciliation

Status: Green

This reconciliation closes the stable-channel and API governance train without claiming outside legal approval, release readiness, account readiness, App Store readiness, known issue closure, complete app runtime Green, or full Source Atlas Green.

## Results

| Area | Result | Evidence |
|---|---|---|
| Legal readiness packet | Present; owner-completed technical legal-readiness review; outside legal approval not claimed | `docs/qa/source-atlas/source-atlas-legal-review-readiness.md`, `docs/qa/source-atlas/source-atlas-legal-review-readiness.json` |
| Owner/legal acceptance | Owner completed technical legal-readiness review; no external legal approval claim | `outsideLegalApprovalClaimed=false`, `ownerLegalReadinessReviewStatus=completed_owner_acceptance` in legal readiness JSON |
| Illegal findings reconciliation | No illegal findings identified; legal-risk restrictions reconciled by blocking/gating unsafe lanes | `illegalFindingsFound=false`, `illegalFindingsReconciled=true` in legal readiness JSON |
| Stable-channel promotion | Green; owner-approved execute completed | `docs/qa/source-atlas/source-atlas-stable-channel-promotion.md`, `docs/qa/source-atlas/source-atlas-stable-channel-promotion.json`, `docs/qa/source-atlas/source-atlas-stable-channel-promotion-execute.json`, `docs/qa/source-atlas/source-atlas-stable-channel-promotion-dry-run.json` |
| API governance | Green for installed governance check | `docs/qa/source-atlas/source-atlas-api-rate-governance.md`, `docs/qa/source-atlas/source-atlas-api-rate-governance.json` |
| R2 proof output | Stable prefix execute uploaded objects, read back objects, verified SHA-256, uploaded revocation, read LKG, and passed rollback-select semantics | `source-atlas/v1/stable/broad-occupational-foundation` execute evidence |

## Source Lane Decisions

| Source lane | Decision |
|---|---|
| O*NET | Packable only with CC BY attribution, license link, O*NET version, USDOL/ETA credit, and modification notice where applicable. |
| BLS | v1 public/no-key lane remains allowed; v2 key mode is optional and governed by `BLS_API_KEY`, rate, budget, retry, and mode evidence. |
| Wikidata | Structured-data crosswalk only; CC0 posture preserved; cannot become regulated requirement authority. |
| OpenAlex | Public/reference scholarly metadata lane with explicit no-key/free-key budget controls, rate-limit header capture, 429 backoff, and high-volume approval gate. |
| USAJOBS/restricted | Blocked from redistributable and R2-ready pack output unless written OPM USAJOBS approval exists. |

## Validation Commands

- `git diff --check` passed.
- `bash scripts/ci/ambitions-pr-review-local.sh --continue` passed.
- `python3 scripts/ambitions-green-standard-audit.py` passed.
- `python3 scripts/source-atlas-boundary-audit.py` passed.
- `python3 scripts/source-atlas-no-private-graph-egress-audit.py` passed.
- `python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests` passed with 66 tests.
- `python3 tools/source-atlas/coverage-ledger.py` passed and rewrote `docs/qa/source-atlas/SOURCE_ATLAS_COVERAGE_LEDGER.md`.
- `python3 tools/source-atlas/source-atlas-foundry.py terms-registry` passed.
- `python3 tools/source-atlas/source-atlas-foundry.py api-governance-check` passed.
- `python3 tools/source-atlas/source-atlas-foundry.py broad-occupation-pack stable-promote-proof --dry-run --bucket ambitions-source-atlas-prod --source-prefix source-atlas/v1/validation/amb-1430 --stable-prefix source-atlas/v1/stable/broad-occupational-foundation --require-owner-approval --require-terms-green --require-privacy-green --require-checksums --require-revocation --require-lkg --require-rollback --emit-evidence docs/qa/source-atlas/source-atlas-stable-channel-promotion-dry-run.json` passed with Yellow dry-run status.
- `SOURCE_ATLAS_STABLE_PROMOTION_OWNER_APPROVED=approved python3 tools/source-atlas/source-atlas-foundry.py broad-occupation-pack stable-promote-proof --execute --bucket ambitions-source-atlas-prod --source-prefix source-atlas/v1/validation/amb-1430 --stable-prefix source-atlas/v1/stable/broad-occupational-foundation --require-owner-approval --require-terms-green --require-privacy-green --require-checksums --require-revocation --require-lkg --require-rollback --emit-evidence docs/qa/source-atlas/source-atlas-stable-channel-promotion-execute.json --markdown docs/qa/source-atlas/source-atlas-stable-channel-promotion-execute.md` passed with Green execute status.

## Validation Not Run

- Outside legal review was not performed or claimed.

## Non-Claims

- Not outside legal approval.
- Not release readiness.
- Not App Store readiness.
- Not account readiness.
- Not known issue closure.
- Not complete app runtime Green.
- Not full Source Atlas Green.
- Not final user paths, schedules, Step lists, or personalized plans.
- Not unbounded OpenAlex high-volume approval.

## Final Verdict

Green for this train. The train installs legal-readiness documentation, owner-completed technical legal-readiness review, stable-channel execute proof, live gated Wikidata/OpenAlex adapter support, and API key/rate/budget governance. Outside legal approval remains not claimed.

## Rollback Plan

Use the stable promotion proof's last-known-good and rollback-select path. If a future candidate manifest fails privacy, checksum, revocation, or stale-critical checks, select last-known-good and do not overwrite the stable channel. Revert this train's code/docs/config changes if governance or adapter behavior must be removed.
