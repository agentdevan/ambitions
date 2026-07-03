# AMB-1754 Launch-Floor Retention Pass

Status: retention pass complete; validation recorded below
Issue: AMB-1754
Parent: AMB-1680 Source Atlas Scope Freeze
Baseline: `main` at `fc1f3d0b479958af9278405b5e6998617ffac114`
Date: 2026-07-03

## Scope

This pass uses the AMB-1729 stale-file deletion inventory and the AMB-1753 QA
packet consolidation ledger to choose the current launch-floor ledger/corpus
set, then delete superseded tracked LFF train outputs and launch-floor QA
artifacts.

This pass is a retention/deletion cleanup. It does not regenerate launch-floor
proof and does not upgrade Source Atlas, R2, release, privacy, device, or App
Store readiness.

## Authority Boundary

Source Atlas remains public/reference/freshness infrastructure only. R2 is not a
user-data backend and must not receive goals, captures, calendar data, schedule
assumptions, proof, receipts, closure history, personalization, behavior
patterns, inferred priorities, private user context, or the private life graph.

Release truth still blocks Source Atlas production readiness, R2 production
readiness, privacy/legal approval, device proof, accessibility proof, TestFlight
readiness, App Store readiness, and Release Green unless separate current
evidence proves those claims.

## Current Retained Launch-Floor Set

| Class | Retained path(s) | Reason |
|---|---|---|
| Current launch-floor ledger | `docs/qa/source-atlas/source-atlas-launch-floor-ledger-current.json`, `docs/qa/source-atlas/source-atlas-launch-floor-ledger-current.md`, `tools/source-atlas/generated/source-atlas-launch-floor-ledger/lff-m04-l04-current/**` | Current ledger version is `source-atlas-launch-floor-ledger-lff-m04-l04`. |
| Current shard corpus compiler evidence | `docs/qa/source-atlas/source-atlas-launch-floor-shard-corpus-compiler-lff-m02.*`, `tools/source-atlas/generated/source-atlas-launch-floor-shard-corpus-compiler/lff-m02-l02-current/**` | Current ledger input for bounded public/reference shard-corpus manifest. |
| Current R2 layout proof input | `docs/qa/source-atlas/source-atlas-launch-floor-r2-layout-proof-lff-m02.*`, `tools/source-atlas/generated/source-atlas-launch-floor-r2-layout-proof/lff-m02-l03-current/**` | Current ledger input; this remains public/reference proof and not production R2 readiness. |
| Current golden-intent corpus | `docs/qa/source-atlas/source-atlas-launch-floor-golden-intent-corpus-lff-m03.*`, `tools/source-atlas/generated/source-atlas-launch-floor-golden-intent-corpus/lff-m03-l02-current/**` | Current 50,000+ golden-intent corpus evidence. |
| Current fallback and missing-shard pipeline evidence | `docs/qa/source-atlas/source-atlas-source-needed-fallback-metric-lff-m03.*`, `docs/qa/source-atlas/source-atlas-missing-shard-events-lff-m03.json`, `docs/qa/source-atlas/source-atlas-missing-shard-*-lff-m04.*`, `tools/source-atlas/generated/source-atlas-source-needed-fallback-metric/lff-m03-l03-current/**`, `tools/source-atlas/generated/source-atlas-missing-shard-*/lff-m04-*-current/**` | Current LFF-M03/LFF-M04 ledger inputs for fail-closed missing-shard expansion. |
| Current launch-floor support proofs | `docs/qa/source-atlas/source-atlas-goal-domain-router-lff-m01.*`, `docs/qa/source-atlas/source-atlas-launch-floor-domain-taxonomy-lff-m01.*`, `docs/qa/source-atlas/source-atlas-launch-floor-native-shard-index-proof-lff-m02.*`, `docs/qa/source-atlas/source-atlas-launch-floor-governance-renewal-lff-m06.*`, matching generated current support roots | Current support artifacts remain referenced by retained tooling, QA, or test proof. |
| Current completion audit | `docs/qa/source-atlas/source-atlas-completion-audit-lff-m02.*`, `tools/source-atlas/generated/source-atlas-completion-audit/lff-m02-l03-current/**` | Current completion-audit proof remains blocked by the active launch-floor ledger ceiling. |

The current ledger records:

- `status`: `Source Green for launch-floor ledger tooling / Launch-floor targets not met`
- `versionID`: `source-atlas-launch-floor-ledger-lff-m04-l04`
- `launchFloorMet`: `false`
- `launchFloorClaimAllowed`: `false`
- `sourceAtlasStatusCeiling`: `Yellow overall Source Atlas; launch-floor targets are measured or fail-closed but not met`
- `public_reference_shards_1m`: `71 / 1,000,000`, status `not_met`

## Deleted Batch

The active-reference check used tracked repo files only. Candidate files were
removed only when no non-candidate tracked file referenced the exact path or
candidate directory, except historical `docs/audits/**` ledgers that document
prior retention/deletion context.

Deleted 57 tracked files:

| Class | Count | Deleted scope |
|---|---:|---|
| Superseded generated launch-floor ledgers | 36 | All `tools/source-atlas/generated/source-atlas-launch-floor-ledger/**` roots except `lff-m04-l04-current`. |
| Superseded generated golden-intent corpus | 5 | `tools/source-atlas/generated/source-atlas-launch-floor-golden-intent-corpus/lff-m03-l01-current/**`. |
| Superseded generated completion audits | 10 | `tools/source-atlas/generated/source-atlas-completion-audit/lff-m00-current/**` and `lff-m01-current/**`. |
| Superseded launch-floor QA packets | 6 | `source-atlas-completion-audit-lff-m00.*`, `source-atlas-completion-audit-lff-m01.*`, and `source-atlas-near-universal-launch-floor-file-audit.*`. |

The reference scan ignored one historical audit reference in
`docs/audits/amb-1752-generated-output-pruning.md`; that file records previous
retention context and is not active launch-floor evidence.

## Proof Ceiling

This pass supports AMB-1754 as a launch-floor retention/deletion cleanup only.
It does not close AMB-1680 by itself. The remaining Source Atlas Scope Freeze
leaf is AMB-1755 for R2 proof retention, followed by AMB-1680 parent closeout.

Unsupported claims:

- No launch-floor complete claim.
- No Source Atlas readiness claim.
- No production R2 behavior or R2 readiness claim.
- No privacy/legal approval claim.
- No device, accessibility, TestFlight, App Store, or Release Green claim.
- No historical generated proof promoted to current proof.

## Validation

Validation was run after the retention/delete pass and this ledger were present:

```bash
git status --short --branch
python3 /tmp/amb1754-active-reference-check.py
python3 /tmp/amb1754-json-parse-check.py
git diff --check
git diff --cached --check
python3 scripts/ambitions-remediation-governance-check.py --json
python3 scripts/ambitions-accepted-yellow-misuse-audit.py --json
python3 scripts/ambitions-unsupported-claim-scan.py docs/audits/amb-1754-launch-floor-retention-pass.md
bash scripts/release-claim-safety-scan.sh
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/source-atlas-boundary-audit.py --json
python3 scripts/source-atlas-no-private-graph-egress-audit.py --json
python3 -m pytest -q tools/source-atlas/foundry/tests/test_launch_floor_domain_taxonomy_lff_m01.py tools/source-atlas/foundry/tests/test_launch_floor_golden_intent_corpus_lff_m03.py tools/source-atlas/foundry/tests/test_launch_floor_governance_renewal_lff_m06.py tools/source-atlas/foundry/tests/test_launch_floor_native_shard_index_proof_lff_m02.py tools/source-atlas/foundry/tests/test_launch_floor_r2_layout_proof_lff_m02.py tools/source-atlas/foundry/tests/test_launch_floor_shard_corpus_compiler_lff_m02.py tools/source-atlas/foundry/tests/test_launch_floor_shard_corpus_lff_m02.py tools/source-atlas/foundry/tests/test_missing_shard_activation_executor_lff_m04.py tools/source-atlas/foundry/tests/test_missing_shard_event_queue_lff_m04.py tools/source-atlas/foundry/tests/test_missing_shard_expansion_supervisor_lff_m04.py tools/source-atlas/foundry/tests/test_missing_shard_review_gate_lff_m04.py tools/source-atlas/foundry/tests/test_source_atlas_launch_floor_ledger.py tools/source-atlas/foundry/tests/test_source_needed_fallback_metric_lff_m03.py
```

Validation result: passed. The reference check ignored only the historical
`docs/audits/amb-1752-generated-output-pruning.md` reference, the retained JSON
parse check covered 62 files, boundary audits passed with zero issues, and the
focused launch-floor pytest lane passed `63` tests in `217.97s`.
