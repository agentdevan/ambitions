# AFRI-039 Repo Authority Automation Manifest Proof

Issue: AMB-391 / AFRI-039
Date: 2026-05-31
Scope: Collapse AFRI authority routing into truth-first governance, local validation scripts, runner instructions, active batch routing, Green/Yellow/Red proof reporting, and rollback behavior.

## Summary

AFRI-039 adds a machine-readable authority manifest and local validators so future Codex sessions can identify active source truth, sequence inputs, validation commands, proof artifact expectations, and rollback behavior without treating historical canon, stale batch prose, or generated reports as active authority.

The patch repairs an active governance hierarchy drift where `docs/governance/AUTHORITY_HIERARCHY.md` still promoted `docs/canon/` as Tier 1. It now routes Tier 1 to `docs/truth/`, keeps live source/project evidence separate, and classifies governance/execution/proof/history under that truth-first order.

No app source, runtime behavior, Swift package dependency, project dependency, signing setting, hosted service, analytics path, cloud AI path, privacy manifest, or release posture changed.

## Files Changed

| Path | Classification | Purpose |
| --- | --- | --- |
| `docs/codex/AFRI_ACTIVE_AUTHORITY_MANIFEST.json` | active governance manifest | Machine-readable authority order, active batch manifest, runner instructions, validation commands, proof states, rollback behavior, and claim boundaries. |
| `docs/codex/AFRI_ACTIVE_AUTHORITY_MANIFEST.md` | active supporting runbook | Human-readable companion for the manifest and runner/proof reporting rules. |
| `scripts/ambitions-afri-authority-manifest-validate.py` | local validation script | Validates manifest shape, truth-first order, required paths, runner header requirements, proof states, rollback keys, and stale-doc detector outcome. |
| `scripts/ambitions-afri-stale-doc-detector.py` | local validation script | Scans active authority/front-door docs for focused stale-routing patterns. |
| `docs/governance/AUTHORITY_HIERARCHY.md` | active governance doc | Repairs Tier 1 from legacy canon to `docs/truth/` and separates live source, governance, execution, proof, and history. |
| `.codex/os/ACTIVE_AUTHORITY_MAP.md` | active Codex OS map | Adds `PRODUCT_MOAT_TRUTH`, live source/project evidence, and the AFRI manifest route. |
| `Makefile` | local validation entry point | Adds `afri-authority-validate` and `afri-stale-doc-scan` targets. |

## Validation

Verified:

- `python3 scripts/ambitions-afri-authority-manifest-validate.py`
  - Green
- `python3 scripts/ambitions-afri-stale-doc-detector.py`
  - Initial run Red on a false positive for AGENTS.md hard-stop cloud AI prohibition; repaired detector negative-context handling.
  - Re-run Green
- `make afri-authority-validate`
  - Green
- `make afri-stale-doc-scan`
  - Green
- `python3 -m py_compile scripts/ambitions-afri-authority-manifest-validate.py scripts/ambitions-afri-stale-doc-detector.py`
  - Green
- `python3 scripts/ambitions-repo-authority-validate.py`
  - Green
- `bash scripts/validate-repo-authority.sh`
  - Green / Yellow-compatible
- `python3 scripts/ambitions-stale-state-check.py`
  - Green
- AMB-391 post guard
  - Green
  - Report: `build/reports/parallel-implementation-guard/AMB-391-post.md`
- `git diff --check`
  - Green

Targeted claim scans:

- Release/cloud/provider scan on AMB-391 touched files found only negative proof-boundary wording and detector pattern definitions; no active release/cloud/provider claim was introduced.
- Old-term scan on AMB-391 touched files found only detector pattern definitions and pre-existing Makefile target names outside the AMB-391 diff.

## Claim Boundary

This proof demonstrates governance routing and local validation only after validation is filled in. It does not claim implementation completeness, release readiness, device proof, CI proof, public accessibility proof, privacy/legal approval, TestFlight readiness, App Store readiness, or product behavior completion.

## Rollback

Revert the AMB-391 commit to restore the previous authority hierarchy, active authority map, Makefile targets, manifest, validators, and proof packet. Do not delete historical material to repair a validator; update classification or detector rules instead.
