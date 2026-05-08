# Codex Accessibility Proof Protocol

Status: Active accessibility proof protocol.  
Date: 2026-05-08  
Scope: UI-affecting Ambitions changes.

## Components

- `.codex/manifests/accessibility-proof-map.yml`
- `scripts/ai/acx_accessibility_packet.py`
- CQS Accessibility Gate

## Packet Command

```bash
python3 scripts/ai/acx_accessibility_packet.py Today Native/Ambitions/Features/Today/SomeFile.swift
```

## Required Fields

- surface
- touched files
- VoiceOver order
- Dynamic Type behavior
- Reduce Motion equivalent
- tap target risks
- color-only meaning check
- motion-only meaning check
- privacy/redaction readability
- known limitations
- human/device follow-up

## Claim Boundary

Accessibility packets do not prove public accessibility conformance unless backed by human/device proof or dedicated audit evidence.
