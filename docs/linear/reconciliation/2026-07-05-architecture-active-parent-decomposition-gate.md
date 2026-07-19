# AMB-1757 Architecture Active Parent Decomposition Gate

Status: Linear control-plane proof packet
Date: 2026-07-05T06:39:56Z
Baseline main SHA: `aa85d75a94c85abae33b40c67507638deea69bd0`
Project: Architecture Simplification + Flagship Readiness Remediation (`59c3917f-f662-4ca3-b412-b532613f3a7a`)
Issue: `AMB-1757` Architecture Active Parent Decomposition Gate

## Scope

This packet records the AMB-1757 decomposition gate for active broad architecture
parents. The work is Linear/control-plane only except for the local XcodeBuildMCP
transport wrapper repair needed to validate the repo's simulator/tooling path.

## Live Inputs Inspected

- `AGENTS.md`
- `docs/truth/README.md`
- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_ORIGIN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `.agents/skills/README.md`
- `.agents/skills/ambitions-source-truth-authority/SKILL.md`
- `.agents/skills/ambitions-architecture-tree-enforcement/SKILL.md`
- `.agents/skills/ambitions-ios-quality-gate/SKILL.md`
- `.agents/skills/ambitions-release-proof-honesty/SKILL.md`
- `.agents/skills/ambitions-runtime-contract-engineering/SKILL.md`
- Live Linear project and issue state for `AMB-1757` and active parent Features.

## Parent Decomposition Inventory

Each listed broad active parent Feature was marked with `parent-not-leaf` and
`needs-leaf-decomposition`, then given at least one bounded child leaf in
`Ready For Codex`.

| Parent | Child leaf | Child title |
| --- | --- | --- |
| `AMB-1676` | `AMB-1798` | Domain Classification Leaf - Split AmbitionsOS model families |
| `AMB-1677` | `AMB-1799` | Domain Loop Leaf - Messy intent to proof scenario gate |
| `AMB-1678` | `AMB-1800` | Design System Leaf - Token and primitive duplicate inventory |
| `AMB-1679` | `AMB-1801` | ExperienceKernel Leaf - Live import and boundary decision |
| `AMB-1681` | `AMB-1802` | Package Boundary Leaf - ADR for active package ownership |
| `AMB-1682` | `AMB-1803` | Source Atlas Receipt Leaf - First influence receipt contract |
| `AMB-1683` | `AMB-1804` | Privacy Manifest Leaf - Data and accessed-API inventory |
| `AMB-1684` | `AMB-1805` | File Protection Leaf - Data-class protection matrix |
| `AMB-1685` | `AMB-1806` | App Group Snapshot Leaf - Writer inventory and redaction check |
| `AMB-1686` | `AMB-1807` | Export Import Reset Leaf - Data-scope and reset semantics audit |
| `AMB-1687` | `AMB-1808` | App Intents Leaf - Mutating intent command-routing inventory |
| `AMB-1688` | `AMB-1809` | Widget Live Activity Leaf - Scope allowlist and snapshot proof |
| `AMB-1689` | `AMB-1810` | Background Task Leaf - Allowed use-case and registration proof |
| `AMB-1690` | `AMB-1811` | EventKit Reminders Leaf - Permission-denied receipt path |
| `AMB-1691` | `AMB-1812` | Xcode Test Plan Leaf - Smoke plan bootstrap |
| `AMB-1692` | `AMB-1813` | UI Test Suite Leaf - First monolith split inventory |
| `AMB-1693` | `AMB-1814` | Accessibility Audit Leaf - First automated nutrition gate |
| `AMB-1694` | `AMB-1815` | Screenshot Harness Leaf - First deterministic snapshot lane |
| `AMB-1695` | `AMB-1816` | Performance Gate Leaf - Runtime smoke measurement harness |
| `AMB-1696` | `AMB-1817` | Release Evidence Leaf - Build and test summary generator |
| `AMB-1697` | `AMB-1818` | File Size Leaf - Current top cleanup queue |
| `AMB-1698` | `AMB-1819` | Naming Simplification Leaf - Next concrete owner rename |
| `AMB-1699` | `AMB-1820` | Suffix Split Leaf - First semantic rename group |
| `AMB-1700` | `AMB-1821` | Release Candidate Leaf - RC checklist non-claim packet |
| `AMB-1701` | `AMB-1822` | Device Proof Leaf - Device matrix and simulator ceiling |
| `AMB-1702` | `AMB-1823` | Truth Status Leaf - Normalize one truth-file claim cluster |
| `AMB-1703` | `AMB-1824` | Risk Register Leaf - P0/P1 architecture risk ledger |
| `AMB-1704` | `AMB-1825` | Doctrine Rewrite Leaf - Gap scan against installed simplification law |
| `AMB-1705` | `AMB-1826` | Final Closeout Leaf - Pre-scorecard blocker inventory |

## Acceptance Evidence

- Active broad parent Feature inventory exists in the table above.
- Each listed broad parent has the `parent-not-leaf` and
  `needs-leaf-decomposition` labels in Linear.
- Each listed broad parent has at least one bounded child leaf in `Ready For
  Codex`.
- `AMB-1826` was corrected so the child leaf no longer carries the parent-only
  `parent-not-leaf` or `needs-leaf-decomposition` labels.
- Linear query `project=59c3917f-f662-4ca3-b412-b532613f3a7a`,
  `state=Ready For Codex`, `query=Parent Feature` returned an empty `issues`
  array. The tool also returned `hasNextPage=true` without a cursor, so this
  packet does not treat that pagination flag as broader proof.

## MCP Transport Repair

The current run found stale `xcodebuildmcp@2.6.2 mcp` peer processes that had
been alive for more than four hours. Direct XcodeBuildMCP startup reported
`peer-age-high` and `peer-count-high` before cleanup.

Repair applied:

- `/Users/devan/.codex/config.toml`: `service_tier` changed from `default` to
  `fast`, matching the repo's documented Codex MCP repair path.
- `scripts/ambitions-xcodebuildmcp-stdio.sh`: wrapper now disables Sentry for
  local MCP transport and terminates pre-existing pinned XcodeBuildMCP peer
  processes before launching `npx -y xcodebuildmcp@2.6.2 mcp`.

Transport proof after repair:

- `codex mcp list`: succeeded and listed `xcodebuildmcp` as enabled with
  command `/Users/devan/Documents/GitHub/ambitions/scripts/ambitions-xcodebuildmcp-stdio.sh`.
- SDK-backed stdio call through the wrapper: connected, registered 68 tools,
  found `session_show_defaults`, and returned `didError=false`.
- Returned defaults: profile `ambitions-ios`, project
  `/Users/devan/Documents/GitHub/ambitions/Ambitions.xcodeproj`, scheme
  `Ambitions`, simulator `iPhone 17 Pro Max`,
  `0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E`.
- `scripts/ambitions-xcode-sim-health.sh --json --timeout 30s`: passed with
  selected simulator booted and zero blocking Xcode processes.

Current-host limitation:

- The already-running Codex MCP namespace still returned `Transport closed` for
  `mcp__xcodebuildmcp.session_show_defaults` after the wrapper and config repair.
  That is recorded as a stale current-host transport boundary requiring Codex
  app-server reload, not as evidence that the repo wrapper command is invalid.

## Non-Claims

- No final architecture Green is claimed.
- No source/runtime remediation Green is claimed for any parent Feature.
- No Visual Green, accessibility conformance, device proof, privacy/legal
  approval, TestFlight/App Store readiness, R2 readiness, or release readiness is
  claimed.
- No Swift source behavior was changed by this AMB-1757 control-plane gate.

## Validation

Completed before closeout:

- `bash -n scripts/ambitions-xcodebuildmcp-stdio.sh`
- `codex mcp list`
- SDK-backed stdio MCP call to `session_show_defaults`
- `scripts/ambitions-xcode-sim-health.sh --json --timeout 30s`
- `git diff --check`
- `python3 scripts/ambitions-accepted-yellow-misuse-audit.py`: valid, zero
  invalid Accepted Yellow issues.
- `python3 scripts/ambitions-remediation-governance-check.py`: Green
  remediation governance guard passed.
- `python3 scripts/ambitions-quality-gate.py`: Green all strict quality gates
  passed.

Xcode build/test was not run for this packet because the Linear decomposition
gate did not change Swift source, app runtime behavior, XcodeGen project source,
or test targets.

## Rollback

If this decomposition gate must be reversed, reopen `AMB-1757`, remove the
parent-only labels from the broad parent set, cancel or relabel the created child
leaves, and revert this proof packet plus the wrapper cleanup commit.
