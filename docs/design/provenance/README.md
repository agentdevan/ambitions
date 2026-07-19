# Code-Connect-Free VSP Provenance

Status: Active Git-owned provenance system
Scope: VSP-01 through VSP-10 Figma-to-SwiftUI ownership, proof gaps, annotation copy, and Linear-ready handoff specs
Claim boundary: not Figma Code Connect, not Visual Green, not source implementation, not device proof, not accessibility conformance, not release proof, and not owner approval

## Why This Exists

Figma Code Connect is unavailable in the current workspace because Code Connect requires the required Figma account/seat capability. Ambitions still needs the service Code Connect would have provided: a durable mapping from Figma/VSP frames to SwiftUI source owners, proof gaps, and implementation handoff constraints.

This directory is the manual, repo-owned equivalent.

## What It Replaces

This system replaces guessing. It does not replace Figma, owner review, screenshots, SwiftUI implementation, validation logs, or Linear status.

It provides:

- VSP-to-source ownership mapping;
- component-to-VSP ownership mapping;
- known Figma node and screenshot evidence;
- proof gaps and proof ceilings;
- Figma annotation copy;
- Linear-ready issue specs;
- governance gates that prevent shell and product-law drift.

## Canonical Files

- `vsp-provenance.json` is the canonical VSP registry.
- `component-registry.json` is the curated component/source-owner registry.
- `figma-node-index.json` records known Figma nodes and durable proof paths.
- `proof-registry.json` records present, missing, blocked, and not-applicable proof.
- `linear-map.json` mirrors likely Linear handoff structure without mutating Linear.

Generated inventory and report output lives under `generated/`.

## Why Git Is Canonical

Git is the only place here where Codex can reliably inspect, diff, validate, and preserve the registry without Figma API or Linear access. The Git registry is therefore the source of truth for implementation ownership until a future approved system replaces it.

## Why Linear Is A Mirror

Linear is not updated by this system. `linear-map.json` and `Linear-Issue-Pack.md` are handoff specs only. They can be copied into Linear after explicit owner authorization, but they do not create issues, close issues, or mark VSPs complete.

## Why Figma Annotations Are Generated / Manual

Because Code Connect is unavailable, Figma annotations are generated as copy in `Figma-Annotation-Pack.md`. The copy is not considered present in Figma until someone manually applies it and records evidence. Do not claim Code Connect exists.

## Why Screenshots And Proofs Are Separate

Figma screenshots prove candidate visual evidence only. They do not prove live SwiftUI rendering, device behavior, accessibility conformance, runtime behavior, privacy boundaries, or owner approval. Proof status is tracked separately in `proof-registry.json`.

## Yellow And Green

Yellow means candidate evidence, source-owner mapping, or proof scaffolding exists, but one or more required proof artifacts are missing.

Green requires current proof for the exact scope:

- owner approval tied to frame IDs;
- durable screenshots;
- live SwiftUI render proof where applicable;
- device proof where claimed;
- Dynamic Type, VoiceOver, Reduce Motion, Reduce Transparency, Increase Contrast, and haptic proof where applicable;
- VSP-08 privacy/offline/account/R2 proof where applicable;
- validation command output;
- no shell or product-law violation.

Codex may not self-certify Visual Green.

## How Codex Should Use This

Before implementing any future VSP source leaf:

1. Read `vsp-provenance.json`.
2. Confirm VSP-01 shell authority is preserved.
3. Confirm the target VSP has source owners and allowed implementation areas.
4. Confirm forbidden areas and non-goals.
5. Use `Linear-Issue-Pack.md` only as a spec, not as a Linear mutation.
6. Run the provenance audit.
7. Keep claims capped at Yellow unless current proof exists.

## Future Code Connect Upgrade

If Ambitions later has the required Figma Code Connect capability, this registry can seed real Code Connect work:

- `figma-node-index.json` provides file keys and node IDs.
- `component-registry.json` provides source owners.
- `Figma-Annotation-Pack.md` provides provenance language.
- `proof-registry.json` keeps proof claims separate from mapping claims.

The future upgrade must still preserve VSP-01 shell authority and must not mark Code Connect, Visual Green, or Done unless those facts are actually proven.

## Validation

```bash
python3 scripts/ambitions-component-inventory-generate.py
python3 scripts/ambitions-provenance-report-generate.py
python3 scripts/ambitions-vsp-provenance-audit.py
git diff --check
```
