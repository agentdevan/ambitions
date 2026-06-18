---
name: ambitions-ios-quality-gate
description: Use for Ambitions native iPhone source/UI changes that need build, accessibility, visual, safe-area, Dynamic Type, Reduce Motion, and proof discipline.
---

# Ambitions iOS Quality Gate

This skill is operating support only. Product truth lives in `docs/truth/*`.

## Required Posture

- Preserve native SwiftUI architecture and XcodeGen.
- Verify active source ownership before source edits.
- Keep root surfaces to Today / Goals / Time / You.
- Treat Capture as global composer and Motion as behavior.
- Use focused build/test validation first, then broader validation when risk warrants it.
- Do not claim accessibility, visual, device, TestFlight, App Store, or release readiness without current proof.

## Expected Evidence

- source paths touched
- focused build/test commands and exit codes
- screenshot or explicit not-run reason for UI changes
- accessibility/non-claim notes where relevant
- rollback path
