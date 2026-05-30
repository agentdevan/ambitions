# Codex Batch Prompt — T-D: Apple Platform Depth

## Objective

Expand safe Apple-native depth through intents, search, Handoff, background maintenance, widgets, and continuity gates.

## Scope

### AMB-FR-015 — Deep App Intents action surface

Severity: High
Priority: P1
Labels: app-intents, shortcuts, platform, ios26
Dependencies: AMB-FR-003, AMB-FR-013

Affected files:
- `Native/Ambitions/AppIntents`
- `Native/Ambitions/App`

Problem: App Intents should do more than open routes.

Implementation: Add parameterized intents for capture, goal draft, open current step, start current step, guarded close step, show receipt, and inspect local knowledge.

Acceptance: Shortcuts can perform meaningful Ambitions-native actions with safety boundaries.

Validation: App Intent tests, phrase review, route execution tests.

Rollback: Disable public shortcut exposure until safety review passes.

### AMB-FR-016 — Spotlight and Handoff object reopening

Severity: High
Priority: P1
Labels: spotlight, handoff, platform, privacy
Dependencies: AMB-FR-007, AMB-FR-010

Affected files:
- `Native/Ambitions/App`
- `Native/Ambitions/Services`
- `Native/Ambitions/Features`

Problem: Search and Handoff strategy should be implemented with privacy boundaries.

Implementation: Index safe summaries for goals, current step, receipts, and captures. Add Handoff reopening for active step and goal detail.

Acceptance: Apple-native reopening works without leaking sensitive private content.

Validation: Indexing tests, redaction tests, Handoff route tests.

Rollback: Gate indexing behind opt-in/internal flag.

### AMB-FR-017 — Optional CloudKit continuity decision gate

Severity: High
Priority: P1
Labels: cloudkit, icloud, privacy, persistence
Dependencies: AMB-FR-008, AMB-FR-022

Affected files:
- `Native/Ambitions/Persistence`
- `Native/Ambitions/Features/You`
- `docs/architecture`

Problem: Continuity matters, but it cannot compromise local-first trust or launch stability.

Implementation: Create a decision gate for optional CloudKit with schema, conflict model, opt-in UX, off switch, privacy copy, and proof tests.

Acceptance: No sync implementation proceeds without signed-off privacy and migration strategy.

Validation: Architecture decision record, sync fixture plan, privacy review packet.

Rollback: Keep launch local-only if proof is not green.

### AMB-FR-018 — Background maintenance and notification reconciliation

Severity: High
Priority: P2
Labels: background, notifications, reliability
Dependencies: AMB-FR-008, AMB-FR-013

Affected files:
- `Native/Ambitions/Services`
- `Native/Ambitions/App`
- `Native/Ambitions/Features/Today`

Problem: The app needs coherent state after relaunch, day rollover, stale notifications, and interrupted sessions.

Implementation: Add background-safe reconciliation for day maintenance, notification schedule refresh, stale-step closure prompts, and receipt freshness.

Acceptance: Relaunch and day transitions preserve coherent Today state.

Validation: Clock travel tests, notification reconciliation tests, lifecycle UI tests.

Rollback: Gate background writes until read-only reconciliation is proven.

### AMB-FR-019 — Widget and Live Activity flagship expansion

Severity: Medium
Priority: P2
Labels: widgetkit, activitykit, platform, frontend
Dependencies: AMB-FR-013, AMB-FR-015

Affected files:
- `Native/AmbitionsWidgetExtension`
- `Native/Ambitions/AppIntents`

Problem: External surfaces should feel like native Ambitions extensions, not demos.

Implementation: Expand widget families for current step, Today pressure, protected time, capture entry, and recovery state. Add Live Activity proof where appropriate.

Acceptance: Widgets and Live Activity states are Ambitions-native and validated.

Validation: Widget snapshots, ActivityKit update tests, lock screen review.

Rollback: Keep existing Next Step widget baseline.

## Batch rules

- Keep the batch scoped to listed issues.
- Do not use generic task-manager terminology.
- Do not use cloud/external LLMs as core runtime architecture.
- Add or update tests before declaring Green.
- Add proof artifacts under `docs/audits/flagship-remediation/`.
- End with summary, files changed, validation, proof artifacts, risks, rollback path, and Green / Yellow / Red status.
