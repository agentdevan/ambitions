# AFEP-023 Export, Reset, Delete, and Redaction Rules

Issue: AMB-417 / AFEP-023
Date: 2026-06-01

## Rules

- Export remains redacted or review-only for sensitive/private fields.
- Reset returns the packet to conservative local-only defaults.
- Delete is explicit and user-directed; no silent hosted deletion path exists.
- Redaction remains local-first and inspectable.
- Raw sensitive fields are not externally projectable.

## Notes

- This document does not change the production export pipeline.
- This document does not authorize cloud sync, analytics, or hosted storage.
