# Codex Quality System Skill Map

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, status-expedite
> Dispositions: clarify-status-before-use, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Active CQS skill map
Date: 2026-05-05

| Skill | Path | Primary gate |
| --- | --- | --- |
| Staff iOS Architect | `.codex/skills/staff-ios-architect.md` | Architecture, module boundaries, testability. |
| SwiftUI Composition Reviewer | `.codex/skills/swiftui-composition-reviewer.md` | Native composition, state seams, view size. |
| Apple Design Award Visual Reviewer | `.codex/skills/apple-design-award-visual-reviewer.md` | Premium visual quality and object identity. |
| Anti-Agentic-Slop Reviewer | `.codex/skills/anti-agentic-slop-reviewer.md` | Prompt-built smell and fake intelligence. |
| Product Canon Drift Reviewer | `.codex/skills/product-canon-drift-reviewer.md` | Tabs, IA, anti-generic product laws. |
| Accessibility / Reduced Motion Reviewer | `.codex/skills/accessibility-reduced-motion-reviewer.md` | VoiceOver, Dynamic Type, Reduce Motion. |
| Privacy / Legal / App Store Reviewer | `.codex/skills/privacy-legal-app-store-reviewer.md` | Claim truth, privacy manifests, legal stops. |
| Performance / Battery Reviewer | `.codex/skills/performance-battery-reviewer.md` | Runtime, rendering, animation, background budgets. |
| Platform Surface Reviewer | `.codex/skills/platform-surface-reviewer.md` | Widgets, Live Activities, App Intents, notifications. |
| StoreKit / Monetization Reviewer | `.codex/skills/storekit-monetization-reviewer.md` | Entitlements, restore, cancellation, paywall safety. |
| Schema / Sync / Migration Reviewer | `.codex/skills/schema-sync-migration-reviewer.md` | Schema, migration, conflict, data-loss prevention. |
| FAANG Handoff Reviewer | `.codex/skills/faang-handoff-reviewer.md` | Repo readability and handoff evidence. |

Use the smallest relevant reviewer set for a batch, then record invoked or
mapped reviewers in the batch report.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
