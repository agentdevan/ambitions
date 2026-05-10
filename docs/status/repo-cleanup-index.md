> T05b classification: Supporting cleanup/status context.
> This file is not product, implementation, release, or Codex process authority.
> Current authority begins in `docs/truth/`; any older routing below is retained as cleanup history unless re-approved by `docs/truth/*`.

# Repo Cleanup Index

Status: cleanup routing and quarantine policy, not product canon.

This document records how Ambitions separates active product/app evidence from historical, future, and AI/Codex operating material.

## Current cleanup decision

Ambitions is staying on local VM/Mac validation. There is no active hosted CI workflow in the repo.

The current cleanup strategy is quarantine-first, delete-later:

1. Make the root README clean and user/developer readable.
2. Route implementation truth through `docs/status/current-implementation-map.md`.
3. Route release proof through `docs/status/release-evidence-packet.md`.
4. Keep historical/Codex/batch material out of the public front door.
5. Do not delete batch-train or Codex operating material until a dedicated archive/removal pass verifies it will not break current workflows.

## Active front-door files

These files are allowed to define the current repo posture:

| File | Purpose |
| --- | --- |
| `README.md` | Public/developer landing page |
| `docs/AmbitionsCanon/README.md` | Active product/design source truth |
| `docs/status/current-implementation-map.md` | Evidence-based implementation status |
| `docs/status/release-evidence-packet.md` | Release and validation evidence posture |
| `docs/native-build-and-release.md` | Local validation procedure |
| `AGENTS.md` | AI/Codex contributor rules |
| `docs/README.md` | Full docs map |

## Quarantined but retained material

These areas may remain in the repo but should not be treated as root README material:

| Area | Status | Rule |
| --- | --- | --- |
| `docs/codex/` | Retained operating material | Link only from AI/Codex docs or full docs map. |
| `.codex/` | Retained automation/context material | Not product source truth. |
| `.agents/` | Retained skill/context material | Not product source truth. |
| `docs/audits/` | Retained evidence/history | Use for traceability, not current product claims by default. |
| `docs/handoff/` | Retained handoff/history | Use for traceability, not current product claims by default. |
| older `docs/canon/Ambitions_3_0*` and `Ambitions_4_0*` files | Retained compatibility/history/source context | Active only when compatible with AmbitionsCanon or stricter evidence gates. |
| PXOS / SI / FCP / PFC / AOS / LDI batch materials | Retained program history | Not root README material. |

## Cost-sensitive automation policy

Hosted CI may not be added unless the patch explicitly states:

- expected runner provider
- billing/cost posture
- trigger policy
- monthly quota impact
- artifact retention behavior
- who approved the cost risk

Until then, validation stays local through Mac/VM commands and checked-in scripts.

## Cleanup backlog

### P0

- Keep README short, product-readable, and developer-readable.
- Keep local validation posture explicit.
- Keep historical/Codex material out of the root README.
- Keep release non-claims visible.

### P1

- Add a dedicated archive/removal review for backend/provider-specific skill material that is not active native-iOS truth.
- Reduce duplicate source-truth language across docs.
- Move batch-train status detail out of general-purpose docs where safe.
- Add a document owner for each major docs area.

### P2

- Consider moving old train records into a clearly named archive folder.
- Consider generating a docs index that tags files as active, supporting, historical, future, or archived.
- Consider pruning obsolete status files only after a traceability pass.

## Hard rules

- Do not delete production Swift, tests, project config, scripts, or extension files as part of docs cleanup unless a dedicated implementation owner approves it.
- Do not delete `.codex`, `.agents`, or batch-train material opportunistically.
- Do not reintroduce hosted CI by accident.
- Do not allow docs-only plans to imply shipped behavior.
- Do not use release-ready, App Store-ready, TestFlight-ready, device-verified, public-accessibility-compliant, or legally approved language without matching evidence.
