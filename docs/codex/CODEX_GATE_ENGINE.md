# Codex Gate Engine

Status: Active Codex OS gate engine protocol; advisory-first unless an owner sets strict mode.
Date: 2026-05-07

## Purpose

The gate engine maps Ambitions quality gates to proof requirements, scripts, and stop conditions. It preserves existing CQS scripts and adds route/evidence discipline around them.

## Gate Families

| Gate | Applies to | Green | Accepted Yellow | Red / hard Red | Scripts | Raw proof |
| --- | --- | --- | --- | --- | --- | --- |
| Source Truth Gate | Every task | Owner docs/source read. | Nonblocking source gap owned. | Conflict weakens canon. | ACX gate all. | Read list and findings. |
| Scope Gate | Every task | Allowed/forbidden paths named. | Docs-only boundary gap owned. | Unknown boundary or forbidden edit. | ACX diff names/status. | Diff/status raw logs. |
| Senior Architecture Gate | Code tasks | Dependency direction preserved. | Large-file debt owned. | Broad refactor or inversion. | `scripts/cqs-architecture-boundary-scan.sh`. | Scan/build logs. |
| SwiftUI Composition Gate | UI tasks | Native composition and state boundaries preserved. | Existing large view touched narrowly. | Generic dashboard/card sprawl or business logic in view. | Architecture/preview scans. | Diff plus rendered proof. |
| Visual Quality Gate | UI tasks | Premium Ambitions object identity with fresh render proof. | Operator proof gap owned. | Generic/slop UI or fake polish. | Preview/FVQ docs. | Screenshots/previews. |
| FVQ Rendered Proof Gate | UI-affecting tasks | Fresh screenshot/rendered proof. | Tooling/device gap owned. | Visible change without rendered proof. | FVQ protocols. | Image paths/reports. |
| Canon Drift Gate | Product/copy/UI | IA and product laws preserved. | Compatibility term contained. | New tab, habit tracker, chatbot, calendar clone. | `scripts/cqs-product-drift-scan.sh`. | Raw scan. |
| Accessibility Gate | UI/motion/copy | Labels, Dynamic Type, Reduce Motion considered. | Manual proof deferred. | Color-only/motion-only meaning. | `scripts/cqs-accessibility-motion-scan.sh`. | Raw scan/render proof. |
| Privacy / Legal / App Store Gate | Privacy/platform/release | Claims evidence-bound. | Human review named future. | Unsupported compliance/release claim. | `scripts/cqs-privacy-security-claim-scan.sh`. | Raw scan and claim matrix. |
| Performance / Battery Gate | Runtime/UI/platform | Work bounded and measurable. | Instruments deferred with owner. | Always-on costly behavior. | `scripts/cqs-performance-budget-scan.sh`. | Raw scan/profiling logs. |
| Platform Surface Gate | Widgets/App Intents/notifications | Surface data minimized. | Device proof deferred. | Sensitive data exposure. | Platform-specific tests. | Raw tests and route proof. |
| StoreKit Gate | Monetization | Entitlements/restore/cancel clear. | Monetization deferred. | Dark pattern/App Review risk. | StoreKit scans/tests. | Raw logs/human review. |
| Schema / Sync / Migration Gate | Persistence/sync | Migration/conflict rules tested. | Strategy-only docs. | Data loss/schema corruption. | Persistence tests. | Raw test logs. |
| Anti-Slop Gate | Every task | Specific names and no prompt residue. | Existing smell inventoried. | Prompt-built residue introduced. | `scripts/cqs-prompt-built-smell-scan.sh`. | Raw scan. |
| Validation Gate | Every task | Relevant commands run. | Optional tool unavailable. | Required validation missing/failing. | ACX Local profiles. | Exit codes/raw logs. |
| Report Gate | Every task | Evidence packet/closeout complete. | Small report gap owned. | Hidden failure or missing evidence. | AEP templates. | Final packet. |
| Release Claim Firewall | Release/device/privacy/accessibility claims | Claim backed by matching proof. | Claim explicitly not made. | Unsupported readiness/compliance claim. | Claim scan. | Raw scan and non-claims. |
| Deprecated Language Gate | Docs/copy | Ambitions 3.0 terms used. | Legacy internal compatibility explained. | User-facing old IA/product words. | Product drift scan. | Raw scan/diff. |
| Route Context Gate | Every non-trivial task | Route selected before broad search. | Route stale and owner docs used. | Broad work with no route/source owner. | ARC map. | Selected route in report. |
| Evidence Packet Gate | Every meaningful change | Raw logs, exit codes, non-claims present. | Environmental limitation parked. | Claims without proof. | AEP templates. | Packet and raw logs. |

Hard Red always stops continuation.
