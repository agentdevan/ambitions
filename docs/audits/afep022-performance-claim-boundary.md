# AFEP-022 Performance Claim Boundary

Issue: AMB-416 / AFEP-022
Date: 2026-06-01

## Rule

Public or release performance claims stay locked unless current measured validation exists.

## Packet Fields

- Command
- Artifact path
- SourceRecord reference
- Receipt reference
- ReplayTrace reference
- Passed/blocked/skipped state
- Known limitation
- Owner

## Boundary

The batch only establishes a claim boundary. It does not unlock public performance claims.
