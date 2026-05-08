# Codex OS Engine Supplement

Status: Active supplement to `docs/codex/CODEX_OS_INDEX.md`.  
Date: 2026-05-08  
Scope: Adds repair, speed, proof-cache, build, visual, accessibility, and privacy/security parity engines.

## Why This Exists

The existing Codex OS index already maps ACX, routes, gates, evidence, batch state, and skills. This supplement adds the higher-order operating engines that push repair, speed, validation routing, and proof discipline toward FAANG-grade maturity.

## New Engines

| Engine | Purpose | Owners |
| --- | --- | --- |
| Speed Engine | Bundles, impact routing, proof cache, and closeout acceleration. | `docs/codex/CODEX_SPEED_ENGINE.md`, `.codex/manifests/acx-bundles.yml`, `.codex/manifests/changed-file-impact-map.yml`, `scripts/ai/acx_impact.py`, `scripts/ai/acx_closeout.py` |
| Repair Engine | Failure classification, safe repair boundary, active repair state, repair ledger, and hard-stop behavior. | `docs/codex/CODEX_REPAIR_ENGINE.md`, `.codex/manifests/repair-profiles.yml`, `scripts/ai/acx_repair.py` |
| Proof Cache | Local-only proof reuse with raw-log hashes and sanitized packets. | `docs/codex/CODEX_PROOF_CACHE_PROTOCOL.md`, `scripts/ai/acx_sanitized_evidence.py`, `.codex/state/proof-cache.json` local-only |
| Build Sheriff | Build/test saved-log classification and build/test claim boundaries. | `docs/codex/CODEX_BUILD_SHERIFF_PROTOCOL.md`, `.codex/manifests/build-commands.yml`, `.codex/manifests/test-impact-map.yml`, `scripts/ai/acx_build_triage.py` |
| Visual QA | UI visual proof packet generation and FVQ field discipline. | `docs/codex/CODEX_VISUAL_QA_PROTOCOL.md`, `.codex/manifests/visual-proof-map.yml`, `scripts/ai/acx_visual_packet.py` |
| Accessibility Proof | Accessibility proof packet generation and claim boundaries. | `docs/codex/CODEX_ACCESSIBILITY_PROOF_PROTOCOL.md`, `.codex/manifests/accessibility-proof-map.yml`, `scripts/ai/acx_accessibility_packet.py` |
| Privacy/Security Scan | Secrets, privacy, sensitive logs, and unsupported compliance claim scanning. | `docs/codex/CODEX_PRIVACY_SECURITY_SCAN_PROTOCOL.md`, CQS privacy/security scan, ACX Local bundles |

## Default Modern Flow

```bash
python3 scripts/ai/acx_local.py bundle quick
python3 scripts/ai/acx_impact.py <changed files>
python3 scripts/ai/acx_local.py bundle <suggested-bundle>
python3 scripts/ai/acx_repair.py diagnose
python3 scripts/ai/acx_closeout.py
```

Use `acx_repair.py diagnose` only when there is a failed profile, repeated Yellow, Red, hard Red, or repair-oriented closeout.

## Claim Boundary

These engines improve routing, speed, repair intelligence, and proof packaging. They do not independently prove app build/test/device/accessibility/release/legal/privacy readiness. Those claims still require matching raw evidence and owner proof.
