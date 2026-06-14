# Ambitions Master Build Reviewer Prompts

Status: Active read-only reviewer prompt library
Use: Copy the relevant prompt into a read-only reviewer/subagent pass. Reviewers inspect and report; the main implementation agent owns edits.

## Shared Reviewer Input Packet

- Active issue: `<AMB-* issue id and title>`
- Train: `<M##.T##>`
- Scope: `<source/control-plane/ui/runtime/privacy/release/etc.>`
- Changed files: `<git diff --name-only>`
- Truth files inspected: `<list>`
- Validation run so far: `<commands and outcomes>`
- Proof boundary: `<what is not claimed>`

## Linear / Train-Order Reviewer

Review this packet for Linear identifier, train-order, and synthetic issue drift risks. Confirm every train label is bound to an actual `AMB-*` issue, Linear fetch/update/comment/closeout targets use `AMB-*` identifiers, and the train order matches `artifacts/ambitions-master-build/AMB_MASTER_EXECUTION_QUEUE.json`. Treat train labels used as Linear identifiers, missing AMB bindings, or unrecorded dependency bypass as Red. Return findings first with file/line references, then Green/Yellow/Red, then required repair.

## Runtime Architecture Reviewer

Review this packet for Ambitions runtime architecture integrity. Confirm the change extends canonical owners, preserves local-first deterministic Private Life Runtime behavior, avoids duplicate implementations, avoids generic task/calendar/dashboard/chatbot patterns, and does not claim behavior that source/tests do not prove. Treat required cloud runtime, hidden recommendation mutation, missing receipts/replay, source ownership ambiguity, or broad behavior without tests as Red. Return findings first with file/line references, then Green/Yellow/Red, then required repair.

## Privacy / Local-First / Source Boundary Reviewer

Review this packet for privacy, local-first, iCloud/CloudKit, R2, Source Atlas, diagnostics, and sharing boundaries. Confirm private user context stays local/user-iCloud, R2/public Source Atlas remains generic public-reference/source/seed data, diagnostics and exports are user-controlled/redacted, and no required cloud LLM/backend/telemetry path is introduced. Treat private user data in R2, required cloud LLM core behavior, telemetry/tracking drift, or unproven privacy claims as Red. Return findings first with file/line references, then Green/Yellow/Red, then required repair.

## Visual / Accessibility Reviewer

Review this packet for flagship native iPhone quality, accessibility, and product anatomy if user-facing surfaces changed. Confirm safe areas, Dynamic Type, VoiceOver semantics, Reduce Motion, Reduce Transparency, Increase Contrast, tap targets, copy language, and avoidance of dashboard/card/list/chatbot/calendar-clone anatomy. Treat ugly UI, clipped text, unsafe shell geometry, missing accessibility semantics, or screenshot-path-only proof as Yellow or Red depending on severity. Return findings first with file/line references, then Green/Yellow/Red, then required repair.

## Validation / Closeout Reviewer

Review this closeout for proof honesty. Confirm it lists actual `AMB-*` issue IDs, changed files, validation commands, failures, Yellow limits, Red blockers, Linear update target, commit/push state, and next eligible train. Confirm it does not claim owner approval, release readiness, accessibility certification, privacy/legal approval, performance verification, TestFlight/App Store readiness, or full project completion without evidence. Return findings first with file/line references, then Green/Yellow/Red, then required repair.
