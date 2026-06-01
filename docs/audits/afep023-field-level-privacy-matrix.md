# AFEP-023 Field-Level Privacy Matrix

Issue: AMB-417 / AFEP-023
Date: 2026-06-01

## Purpose

This matrix documents the field-category privacy scaffold added for AFEP-023 without changing production storage behavior.

## Covered Field Categories

- Today
- Goals
- Capture
- Time
- You
- continuity snapshots
- schedule blocks
- runtime snapshots
- action history
- evidence records
- corrections
- user system profile

## Policy Summary

- Sensitive/private categories default to local-only or redacted export behavior.
- Raw external projection is disallowed in the packet.
- Continuity, action-history, and user-inspection anchors are represented as policy text only.
- The packet stays simulator-safe and does not require device-only storage access.
