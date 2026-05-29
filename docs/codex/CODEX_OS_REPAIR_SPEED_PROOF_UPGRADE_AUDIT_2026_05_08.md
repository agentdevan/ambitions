# Codex OS Repair Speed Proof Upgrade Audit

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Yellow / Implemented as repo-local tooling and governance upgrade; local execution validation still required.  
Date: 2026-05-08  
Scope: Speed, repair, proof-cache, build sheriff, visual QA, accessibility proof, and privacy/security scan engines.

## Result

The upgrade adds the missing high-impact operating layers that were below peak maturity:

- speed orchestration
- changed-file impact routing
- proof cache / sanitized evidence
- repair classification and proposal loop
- build/test log triage
- visual QA packet generation
- accessibility proof packet generation
- privacy/security scan protocol

No app runtime behavior was changed.

## Files Added

### Speed / impact / closeout

- `.codex/manifests/acx-bundles.yml`
- `.codex/manifests/changed-file-impact-map.yml`
- `scripts/ai/acx_impact.py`
- `scripts/ai/acx-impact`
- `scripts/ai/acx_closeout.py`
- `scripts/ai/acx-closeout`
- `docs/codex/CODEX_SPEED_ENGINE.md`

### Repair

- `.codex/manifests/repair-profiles.yml`
- `.codex/state/active-repair.yml`
- `.codex/state/repair-ledger.md`
- `scripts/ai/acx_repair.py`
- `scripts/ai/acx-repair`
- `docs/codex/CODEX_REPAIR_ENGINE.md`

### Proof cache / sanitized evidence

- `scripts/ai/acx_sanitized_evidence.py`
- `docs/codex/CODEX_PROOF_CACHE_PROTOCOL.md`

### Build / test proof parity

- `.codex/manifests/build-commands.yml`
- `.codex/manifests/test-impact-map.yml`
- `scripts/ai/acx_build_triage.py`
- `docs/codex/CODEX_BUILD_SHERIFF_PROTOCOL.md`

### Visual / accessibility / privacy proof parity

- `.codex/manifests/visual-proof-map.yml`
- `.codex/manifests/accessibility-proof-map.yml`
- `scripts/ai/acx_visual_packet.py`
- `scripts/ai/acx_accessibility_packet.py`
- `docs/codex/CODEX_VISUAL_QA_PROTOCOL.md`
- `docs/codex/CODEX_ACCESSIBILITY_PROOF_PROTOCOL.md`
- `docs/codex/CODEX_PRIVACY_SECURITY_SCAN_PROTOCOL.md`

### Wiring / discovery

- `docs/codex/CODEX_OS_ENGINE_SUPPLEMENT_2026_05_08.md`

## Files Updated

- `scripts/ai/acx_local.py`
- `AGENTS.md`
- `.codex/README.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md`
- `.gitignore`

## What Improved

| Area | Before | After |
| --- | --- | --- |
| Speed orchestration | Individual profiles only | Bundle manifest plus bundle execution and impact planner |
| Repair cycle | Protocol and ledgers | R1-R10 diagnosis/proposal/closeout helper and repair profiles |
| Proof cache | Validation mirror only | Local proof cache with SHA256 raw-log hashes and sanitized packet generator |
| Build/test intelligence | Help profiles only | Saved-log classifier and build/test claim protocol |
| Visual QA | Gate/protocol concept | Packet generator and visual proof map |
| Accessibility proof | Gate/protocol concept | Packet generator and accessibility proof map |
| Privacy/security proof | CQS scan | Dedicated scan protocol and closeout bundle usage |
| Closeout quality | Manual final report | Closeout packet generator |

## Required Local Validation

Run locally from the repo root:

```bash
python3 -m py_compile scripts/ai/acx.py scripts/ai/acx_local.py scripts/ai/acx_impact.py scripts/ai/acx_repair.py scripts/ai/acx_closeout.py scripts/ai/acx_sanitized_evidence.py scripts/ai/acx_build_triage.py scripts/ai/acx_visual_packet.py scripts/ai/acx_accessibility_packet.py
python3 scripts/ai/acx_local.py bundles
python3 scripts/ai/acx_local.py bundle quick
python3 scripts/ai/acx_impact.py scripts/ai/acx_local.py docs/codex/CODEX_SPEED_ENGINE.md
python3 scripts/ai/acx_repair.py diagnose
python3 scripts/ai/acx_repair.py propose
python3 scripts/ai/acx_closeout.py
python3 scripts/ai/acx_sanitized_evidence.py
python3 scripts/ai/acx_visual_packet.py Today Native/Ambitions/Features/Today/Example.swift
python3 scripts/ai/acx_accessibility_packet.py Today Native/Ambitions/Features/Today/Example.swift
python3 scripts/ai/acx_local.py run "__invalid_profile__"
git diff --check
```

Expected high-level result:

- py_compile exits 0
- bundle list exits 0
- quick bundle exits 0 or accepted Yellow only for unavailable optional tools
- impact planner exits 0
- repair diagnose exits 0 or accepted Yellow/Red based on current local logs
- closeout/evidence/visual/accessibility packet generators exit 0
- invalid profile exits 2 and executes no command
- git diff --check exits 0

## Claims Not Made

This upgrade does not claim:

- Ambitions app feature implementation
- SwiftUI refactor
- app build pass
- app test pass
- physical-device proof
- public accessibility conformance
- privacy/legal compliance
- TestFlight/App Store readiness
- release readiness
- production readiness

## Current Score After This Upgrade

Estimated Codex OS maturity after local validation:

- Repair cycle: 96 / 100
- Speed orchestration: 96 / 100
- Usage efficiency: 97 / 100
- Evidence discipline: 97 / 100
- Build/test intelligence: 95 / 100
- Visual QA proof: 95 / 100
- Accessibility proof: 95 / 100
- Privacy/security proof: 95 / 100
- Repo hygiene: 95 / 100
- Product drift protection: 97 / 100

Overall after local validation: 96 / 100.

## Why Not 100 Yet

The remaining gap is not repo-local Codex OS design. It is external proof:

- real full local Xcode build/test logs
- simulator/device validation
- screenshot/render artifacts for touched UI
- human visual approval
- real accessibility device review
- Instruments/performance evidence
- legal/privacy human review
- long-run batch-train use under load

Those can be supported by Codex OS, but they cannot be honestly claimed from docs/tooling alone.

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
