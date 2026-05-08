# Codex OS Index

Status: Active repo-local Codex OS index for Ambitions engineering sessions; not product implementation evidence.
Date: 2026-05-07

## Purpose

This file is the top-level map for the Ambitions Codex OS. It exists to make future Codex sessions faster, less noisy, safer, and more evidence-bound while preserving Ambitions 3.0 source truth.

It does not override `AGENTS.md`, Ambitions 3.0 canon, owner docs, source code, validation logs, or `docs/codex/BATCH_REGISTRY.md`.

## Six Subsystems

| Subsystem | Name | Purpose | Primary owners |
| --- | --- | --- | --- |
| ACX | Ambitions Command eXtractor | Bounded reads, saved-log summaries, changed-file grouping, advisory scans, and allowlisted local execution through a separate companion. | `scripts/ai/acx.py`, `scripts/ai/acx_local.py`, `docs/codex/CODEX_ACX_LOCAL_EXECUTOR.md` |
| ARC | Ambitions Route Context | Pick a route before broad search so sessions load targeted docs, paths, tests, gates, and forbidden edits. | `.codex/routes/README.md`, `docs/codex/CODEX_ROUTE_CONTEXT_PROTOCOL.md` |
| AGE | Ambitions Gate Engine | Advisory/strict gate families for source truth, scope, architecture, design, claims, privacy, accessibility, validation, and reports. | `docs/codex/CODEX_GATE_ENGINE.md`, `.codex/manifests/gate-engine-map.yml` |
| AEP | Ambitions Evidence Packets | Raw-log, exit-code, validation-tier, claim-boundary, screenshot/device/human-proof, and closeout standards. | `docs/codex/CODEX_EVIDENCE_STANDARD.md`, `.codex/templates/evidence-packet.md` |
| ABS | Ambitions Batch State | Compact mirrors for current facts, active batch, Yellow/Hard Red ledgers, recent validation, and restart prompts. | `.codex/state/*`, `docs/codex/CODEX_BATCH_TRAIN_PROTOCOL.md` |
| ASK | Ambitions Skills Kit | Routes work to existing `.codex/skills/` agents and review boards without duplicating skills. | `docs/codex/CODEX_SKILLS_KIT.md`, `.codex/manifests/skills-routing-map.yml` |

## Read Order For Codex OS Passes

1. `AGENTS.md`
2. `docs/codex/CODEX_OS_INDEX.md`
3. `docs/codex/CODEX_OS_PEAK_OPERATING_PROTOCOL.md`
4. `docs/codex/CONTEXT_INDEX.md`
5. `docs/codex/CODEX_ROUTE_CONTEXT_PROTOCOL.md`
6. `.codex/routes/README.md`
7. The selected route owner docs and source paths.
8. `docs/codex/CODEX_GATE_ENGINE.md`
9. `docs/codex/CODEX_EVIDENCE_STANDARD.md`
10. `docs/codex/CODEX_BATCH_TRAIN_PROTOCOL.md` when a train is involved.

## Operating Rules

- Pick one route before broad search. Add a second route only for real cross-boundary work.
- Use `scripts/ai/acx.py` for non-executing extraction. It must not execute commands.
- Use `scripts/ai/acx_local.py` only for allowlisted local profiles. It must not accept arbitrary shell strings or use `shell=True`.
- Preserve raw logs under `.codex/logs/`; the directory is local-only and gitignored.
- Treat `.codex/state/*` as compact mirrors only. Owner docs and raw evidence win.
- Continue batch trains through Green and accepted Yellow only when owner, safety reason, and no-claim boundary are recorded.
- Stop on hard Red, unknown dirty tree, destructive conflict, privacy/security/legal ambiguity, unsupported release/device/accessibility/legal/privacy claims, or repeated same-root Red.
- Never claim planned, canonized, scaffolded, implemented, built, tested, device-verified, accessible, privacy/legal reviewed, or release-ready as the same proof state.

## Subsystem Artifacts

- Efficiency map: `.codex/manifests/codex-os-efficiency-map.yml`
- Command profiles: `.codex/manifests/acx-command-profiles.yml`
- Gate map: `.codex/manifests/gate-engine-map.yml`
- Skills routing: `.codex/manifests/skills-routing-map.yml`
- File ownership: `.codex/manifests/file-ownership.yml`
- Source truth: `.codex/manifests/source-truth-map.yml`
- No double work: `.codex/manifests/no-double-work-map.yml`

## Claim Firewall

Forbidden shortcuts remain forbidden unless matching raw evidence exists: production-ready, release-ready, fully tested, fully accessible, App Store ready, TestFlight ready, device verified, privacy compliant, legally approved, and performance safe.
