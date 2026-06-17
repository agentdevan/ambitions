Status: ACTIVE
Owner: Governance OS
Authority Tier: active
Supersedes: none
Superseded By: none
Proof Expectation: docs-only
Cleanup Destination: none
Expected Lifetime: permanent

# Ambitions Operating Context

Ambitions is a premium native iPhone-first, local-first Personal Life OS. The active repo authority lives in `docs/truth/README.md` and the truth files it indexes.

Current operating constraints:

- Work on `main` unless explicitly told otherwise.
- Read `docs/truth/PRODUCT_DESIGN_TRUTH.md` before product, design, frontend, architecture, QA, release, privacy, account, R2, Source Atlas, or Codex implementation work.
- Preserve the active top-level surfaces: `Today / Goals / Time / You`.
- Treat `Capture` as the global composer/action layer, not a persistent surface, tab, inbox, notes feed, category grid, chatbot, or persistent floating button.
- Treat `Motion` as `Stage/Motion` cross-surface behavior that expresses change, proof, recovery, re-entry, time shifts, protected boundaries, and undo. Motion is not a destination or root surface.
- Treat `Proof / Source / Privacy / History / Receipts` as inspectable trust details, not primary root UI.
- Treat Ambitions Accounts as optional launch identity/entitlement infrastructure using Sign in with Apple and Google Sign-In.
- Preserve complete offline core behavior with no Ambitions Account, no network dependency, and no R2 dependency.
- Treat R2 as first-class Source Atlas/reference-freshness infrastructure only. R2 is not a user-data backend and must never receive private life graph data.
- Treat hosted AI services, external/cloud LLMs, cloud model APIs, server-side profiling, and hosted personal-data intelligence as excluded from core architecture.
- Treat Apple/iCloud-style sync and future user-owned sync as unapproved implementation unless active truth and source/proof explicitly establish it.
- Treat Plan/Profile/Captures/Pulse/Motion-tab/Capture-tab language as historical or compatibility context only unless active truth explicitly scopes a migration.
- Do not claim implementation, release, device, accessibility, privacy, production, TestFlight, App Store, account auth, R2 freshness, sync, or readiness status without proof.
- Codex may self-heal Yellow-safe repo-OS/process/metadata blockers only inside the bounded authority in `docs/truth/CODEX_PROCESS_TRUTH.md`; Red-class blockers still stop fail-closed.

Codex OS reads this file as operational context only. It does not override truth files, source files, or current proof artifacts.
