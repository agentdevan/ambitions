# Codex Batch Prompt — T-A: Shell & IA Lock

## Objective

Make the executable app shell canonical, testable, and free of active legacy IA seams.

## Scope

### AMB-FR-001 — Canonical root shell and app chrome integrity

Severity: Critical
Priority: P0
Labels: frontend, swiftui, app-shell, prelaunch
Dependencies: None

Affected files:
- `Native/Ambitions/App`
- `Native/Ambitions/Features`
- `Native/AmbitionsUITests`

Problem: Root shell expectations and rendered shell affordances are not fully aligned.

Implementation: Create one canonical shell path for tab host, contextual header rail, continuity ribbon, global capture entry, overlay host, safe-area behavior, accessibility identifiers, and UI smoke tests.

Acceptance: All five tabs render through one canonical shell path and shell UI tests pass.

Validation: xcodegen generate; xcodebuild test -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 16 Pro'; scripts/validate_flagship_remediation.sh

Rollback: Keep prior TabView shell as a temporary compatibility fallback until tests pass.

### AMB-FR-002 — Slice AppContainer into bounded capabilities

Severity: High
Priority: P0
Labels: architecture, dependency-injection, prelaunch
Dependencies: AMB-FR-001

Affected files:
- `Native/Ambitions/App/AppContainer.swift`
- `Native/Ambitions/App`

Problem: The app container is too dense and risks becoming a service locator.

Implementation: Split capabilities into shell, runtime, persistence, platform, user system, and feature factory slices. Feature screens should receive only the required slice.

Acceptance: Feature construction is inspectable and no screen imports the full global container unnecessarily.

Validation: Build, dependency review artifact, affected feature tests.

Rollback: Keep AppContainer as a facade delegating to sliced capabilities.

### AMB-FR-003 — Retire active legacy IA route seams

Severity: High
Priority: P0
Labels: ia, navigation, canon, prelaunch
Dependencies: AMB-FR-001

Affected files:
- `Native/Ambitions/App/AppNavigation.swift`
- `Native/Ambitions/App/AppTab.swift`
- `Native/Ambitions/AppIntents`

Problem: Legacy route language can leak into active product routes and weaken canonical IA clarity.

Implementation: Move legacy route compatibility into documented boundary adapters only. Active APIs must use Today, Goals, Capture, Time, and You.

Acceptance: No active user-facing route or app intent exposes deprecated top-level object names except hidden compatibility shims.

Validation: Canon grep/lint, navigation tests, App Intent route tests.

Rollback: Preserve hidden deep-link compatibility mappings.

### AMB-FR-004 — Shell visual QA and preview matrix

Severity: High
Priority: P1
Labels: frontend, visual-qa, accessibility
Dependencies: AMB-FR-001, AMB-FR-003

Affected files:
- `Native/Ambitions/UI`
- `Native/Ambitions/Features`
- `Native/AmbitionsUITests`

Problem: Shell polish needs device-visible proof across sizes, Dynamic Type, Reduce Motion, and dark/OLED states.

Implementation: Add preview matrices and screenshot hooks for all top-level tabs and major shell states.

Acceptance: Each tab has preview coverage and screenshot proof path.

Validation: Preview compile, UI screenshot smoke, proof artifact.

Rollback: Keep preview data isolated from production models.

## Batch rules

- Keep the batch scoped to listed issues.
- Do not use generic task-manager terminology.
- Do not use cloud/external LLMs as core runtime architecture.
- Add or update tests before declaring Green.
- Add proof artifacts under `docs/audits/flagship-remediation/`.
- End with summary, files changed, validation, proof artifacts, risks, rollback path, and Green / Yellow / Red status.
