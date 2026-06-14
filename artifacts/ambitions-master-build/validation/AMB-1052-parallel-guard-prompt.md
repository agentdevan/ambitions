# AMB-1052 Parallel Implementation Guard Prompt

Issue: `AMB-1052` / `M01.T04`

Scope: Build local diagnostics, privacy-redacted support bundle export, deterministic export formats, redaction rules, and testable support flows without third-party analytics by default.

Expected source owners:
- `Native/Ambitions/Persistence/SupportDiagnosticsBundle.swift`
- `Native/AmbitionsTests/Persistence/SupportDiagnosticsBundleTests.swift`
- `docs/codex/existing-code-champion-coverage.yml`

Do not create a duplicate diagnostics/export architecture. Compose existing persistence-accessible diagnostic, portable export, and storage privacy boundary models without modifying locked owner paths.

Required invariants:
- Local-first only.
- No third-party analytics or telemetry SDK by default.
- Private diagnostic entries are redacted in support exports.
- Support exports require user review and a Green storage privacy boundary.
- Export formats are deterministic and testable.
- No user-facing UI, release, privacy/legal, external security audit, device, accessibility certification, or App Store readiness claim.
