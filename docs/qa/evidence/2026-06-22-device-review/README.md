# 2026-06-22 Device Review Evidence

**Linear control issue:** `AMB-1282` — QA-00B commit 2026-06-22 device review evidence package to repo  
**Linear QA control plane:** `AMB-1181` — Runtime QA control plane and closure gate  
**Runtime review report:** `docs/qa/device_review_20260622_more_issues.md`  
**Known-issues register:** `docs/qa/KNOWN_ISSUES.md`  
**Source reconciliation note:** `docs/qa/source_reconciliation_20260622.md`

## Purpose

This directory is the repo-side evidence index for the 2026-06-22 on-device runtime review that produced the current Ambitions Runtime QA Remediation Linear project.

The review evidence is release-blocking QA evidence, not design inspiration and not historical commentary. It is used to verify runtime defects documented in `docs/qa/KNOWN_ISSUES.md` and the corresponding Linear project issues.

## Primary evidence package

The binary evidence archive is attached directly to Linear issue `AMB-1181` as:

- `More issues.zip`

The archive contains the device screenshot sequence reviewed for the runtime report:

- `IMG_8475.PNG` through `IMG_8499.PNG`

The zip is intentionally referenced from Linear instead of duplicated here until the repo adopts a binary-evidence policy such as Git LFS or an external durable artifact store. This directory commits the durable evidence index, mapping, and closeout rules required for source-controlled traceability.

## Evidence files in this directory

- `README.md` — provenance, operating rules, and evidence policy.
- `screenshot-index.md` — screenshot-by-screenshot evidence map.
- `manifest.json` — machine-readable evidence inventory for future QA tooling.

## Closure rule

Do not close a runtime-visible Linear issue or mark a `docs/qa/KNOWN_ISSUES.md` row `Closed - verified` from this index alone.

Closure still requires current proof appropriate to the defect:

- device screenshot or screen recording evidence,
- crash-free interaction proof where relevant,
- mutation before/action/after proof where relevant,
- audit output where relevant,
- accessibility proof when accessibility is claimed,
- update to `docs/qa/KNOWN_ISSUES.md` with evidence status.

## Status

This repo directory completes the source-controlled evidence index. The binary evidence package remains attached in Linear at `AMB-1181` unless and until a binary artifact policy is adopted.
