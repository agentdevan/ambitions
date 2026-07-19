# AMB-1755 R2 Proof Retention Pass

Status: retention pass complete; validation recorded below
Issue: AMB-1755
Parent: AMB-1680 Source Atlas Scope Freeze
Baseline: `main` at `2bcd1ba3063650ce7c0762f104ea6de7d43f2fc2`
Date: 2026-07-03

## Scope

This pass uses the AMB-1729 stale-file deletion inventory plus the AMB-1752,
AMB-1753, and AMB-1754 retention ledgers to preserve current public/reference
R2 proof artifacts, then delete stale R2, production, and readiness packets that
are not current evidence.

This pass is a retention/deletion cleanup. It does not regenerate R2 proof and
does not upgrade Source Atlas, R2, release, privacy, device, accessibility,
TestFlight, App Store, or Release Green status.

## Authority Boundary

Source Atlas remains public/reference/freshness infrastructure only. R2 is not a
user-data backend and must not receive goals, captures, calendar data, schedule
assumptions, proof, receipts, closure history, personalization, behavior
patterns, inferred priorities, private user context, or the private life graph.

Release truth still blocks Source Atlas production readiness, R2 production
readiness, privacy/legal approval, device proof, accessibility proof,
TestFlight readiness, App Store readiness, and Release Green unless separate
current evidence proves those claims.

## Classification Method

The retention pass used tracked repo evidence and exact active references:

```bash
git diff --cached --name-only --diff-filter=D > /tmp/amb1755-delete-files.txt
rg --no-filename -o -F -f /tmp/amb1755-delete-files.txt -g '!docs/audits/**' . | sort -u
rg -l -F -f /tmp/amb1755-delete-files.txt -g '!docs/audits/**' .
```

Any exact path referenced by a retained non-`docs/audits/**` file was restored
from the deletion batch. Historical audit ledgers under `docs/audits/**` may
continue to name deleted files as prior context; those references are not active
current proof.

## Retained Current Proof Set

The following classes are retained by this pass:

| Class | Retained path(s) | Reason |
|---|---|---|
| Current AMB-1754 launch-floor R2 layout proof | `docs/qa/source-atlas/source-atlas-launch-floor-r2-layout-proof-lff-m02.*`, `tools/source-atlas/generated/source-atlas-launch-floor-r2-layout-proof/lff-m02-l03-current/**` | Current launch-floor ledger input. It remains public/reference proof only and not production R2 readiness. |
| Current Train 133 proof-refresh QA packets | `docs/qa/source-atlas/source-atlas-production-*-train-133-proof-refresh.*`, `docs/qa/source-atlas/source-atlas-production-target-ledger-current-train-133-proof-refresh.*` | Current proof-refresh summaries are retained as the latest production-risk summaries, without promoting them to release proof. |
| Current Train 133 autonomous production supervisor proof refresh | `tools/source-atlas/generated/autonomous-production-supervisor/train-133-current-proof-refresh/**` | Retained where current proof-refresh QA packets and retained generated reports depend on it. |
| Current Train 131 production target ledger and gateway evidence | `tools/source-atlas/generated/production-target-ledger/train-131-tetradeca-current/**`, `tools/source-atlas/generated/r2-public-gateway/train-131-tetradeca-deploy-live-verify/**`, and exact referenced Train 131 generated dependencies | Retained because non-audit current proof packets name these exact artifacts. |
| Current Train 132 release proof packet | `tools/source-atlas/generated/release-proof-packet/train-132-current/**` | Retained as current release-proof packet source material. It does not by itself prove release readiness. |
| Current Train 137 R2 live inventory | `tools/source-atlas/generated/r2-live-inventory/train-137-post-hygiene-resolution-inventory/**` | Retained as the current post-hygiene R2 inventory artifact. It does not prove R2 production readiness. |
| Exact non-audit references | Any staged deletion path named by retained non-`docs/audits/**` files | Restored before the final deletion set so active retained files do not point at missing artifacts. |

## Deleted Batch

The final staged deletion set contains 658 tracked files and 154,703 deleted
lines. These files are stale R2, production, generated publisher, and readiness
artifacts that are not exact active dependencies after the reference-restoration
pass.

| Class | Count |
|---|---:|
| `tools/source-atlas/generated/r2-publisher/**` | 174 |
| `tools/source-atlas/generated/pack-production/**` | 126 |
| `docs/qa/source-atlas/r2/**` | 90 |
| `tools/source-atlas/generated/r2-hygiene-cleanup/**` | 69 |
| `docs/qa/source-atlas/` root production/R2/readiness packets | 52 |
| `tools/source-atlas/generated/r2-publisher-readback/**` | 42 |
| `tools/source-atlas/generated/r2-publisher-local-store/**` | 28 |
| `tools/source-atlas/generated/public-reference-delivery-chain/**` | 26 |
| `tools/source-atlas/generated/r2-public-gateway/**` stale variants | 26 |
| `tools/source-atlas/generated/autonomous-registry-activation-chain/**` | 10 |
| `tools/source-atlas/generated/r2-live-inventory/**` stale variants | 6 |
| `tools/source-atlas/generated/governed-harvest/**` | 4 |
| `tools/source-atlas/generated/production-sweep/**` | 3 |
| `tools/source-atlas/generated/production-finish-line-gate/**` | 2 |

## Proof Ceiling

This pass supports AMB-1755 as an R2 proof retention/deletion cleanup only. It
does not close AMB-1680 by itself until parent closeout evidence is reviewed.

Unsupported claims:

- No Source Atlas readiness claim.
- No production R2 behavior or R2 readiness claim.
- No R2 entitlement-gating claim.
- No R2 privacy-boundary release claim.
- No privacy/legal approval claim.
- No device, accessibility, TestFlight, App Store, or Release Green claim.
- No historical generated proof promoted to current proof.

## Validation

Validation must be run after the retention/delete pass and this ledger are
present:

```bash
git diff --cached --name-only --diff-filter=D > /tmp/amb1755-delete-files.txt
rg -l -F -f /tmp/amb1755-delete-files.txt -g '!docs/audits/**' .
python3 - <<'PY'
import json
from pathlib import Path
for root in (Path('docs/qa/source-atlas'), Path('tools/source-atlas/generated')):
    for path in root.rglob('*.json'):
        with path.open('r', encoding='utf-8') as handle:
            json.load(handle)
PY
git diff --check
git diff --cached --check
python3 scripts/ambitions-remediation-governance-check.py --json
python3 scripts/ambitions-accepted-yellow-misuse-audit.py --json
python3 scripts/ambitions-unsupported-claim-scan.py docs/audits/amb-1755-r2-proof-retention-pass.md
bash scripts/release-claim-safety-scan.sh
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/source-atlas-boundary-audit.py --json
python3 scripts/source-atlas-no-private-graph-egress-audit.py --json
python3 -m pytest -q tools/source-atlas/foundry/tests/test_r2_pack_publisher_train_10.py tools/source-atlas/foundry/tests/test_r2_public_gateway_allowlist_train_82.py tools/source-atlas/foundry/tests/test_r2_public_gateway_release_train_83.py tools/source-atlas/foundry/tests/test_r2_live_inventory_train_134.py tools/source-atlas/foundry/tests/test_r2_hygiene_cleanup_train_136.py tools/source-atlas/foundry/tests/test_release_proof_packet_train_132.py tools/source-atlas/foundry/tests/test_production_target_ledger_train_84.py tools/source-atlas/foundry/tests/test_production_target_gate_train_85.py tools/source-atlas/foundry/tests/test_production_finish_line_gate_train_114.py tools/source-atlas/foundry/tests/test_production_recertification_gate_train_104.py tools/source-atlas/foundry/tests/test_production_sweep_train_116.py tools/source-atlas/foundry/tests/test_launch_floor_r2_layout_proof_lff_m02.py
```

Validation result: passed.

- Exact active-reference check passed with no non-`docs/audits/**` retained file
  referencing a staged-deleted path.
- Retained JSON parse check passed for 2,037 remaining JSON files under
  `docs/qa/source-atlas/**` and `tools/source-atlas/generated/**`.
- `git diff --check` and `git diff --cached --check` passed.
- Remediation governance check passed with `findingCount=0`.
- Accepted Yellow misuse audit passed with `findingCount=0`.
- Unsupported completion/readiness claim scan passed for this ledger.
- Release claim safety scan passed.
- Local-first boundary scan passed.
- Source Atlas boundary audit and no-private-graph egress audit passed.
- Focused Source Atlas R2/production pytest lane passed 61 tests in 15.26s.
