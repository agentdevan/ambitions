# Codex Visual QA Protocol

Status: Active visual proof protocol.  
Date: 2026-05-08  
Scope: UI-affecting Ambitions changes and FVQ evidence.

## Components

- `.codex/manifests/visual-proof-map.yml`
- `scripts/ai/acx_visual_packet.py`
- CQS Visual Quality Gate
- FVQ Rendered Proof Gate

## Packet Command

```bash
python3 scripts/ai/acx_visual_packet.py Today Native/Ambitions/Features/Today/SomeFile.swift
```

## Required Fields

- surface
- changed files
- expected primary object
- screenshot/render path
- proof freshness date
- visual score
- drift result
- primary object visibility
- anti-card-stack / anti-dashboard note
- accessibility/readability note
- Reduce Motion note
- privacy/redaction rendering note
- claims not made

## Claim Boundary

A visual packet proves that a review structure exists. It does not prove human visual approval, public accessibility conformance, or release readiness unless matching evidence is supplied.
