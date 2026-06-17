# Local Data Cloud Boundary Law

Status: Active supporting governance law  
Authority posture: Supporting law subordinate to `docs/truth/*`  
Runtime implementation proof: none  
Account implementation proof: none  
R2 implementation proof: none  
Sync implementation proof: none

This law defines data-boundary rules for future Ambitions execution. It does not implement accounts, Sign in with Apple, Google Sign-In, R2, sync, entitlements, privacy manifest changes, source packs, sharing, or runtime behavior.

---

## 1. Active Product Boundary

Active root IA is:

```text
Today / Goals / Time / You
```

Capture is the global composer. Motion is the cross-surface behavior layer. Proof / Source / Privacy / History / Receipts are an inspectable trust layer.

Private user life data stays on-device first.

The core app must work fully offline with no Ambitions Account, no R2 access, no network dependency, and no hosted personal-data backend.

Ambitions Accounts are allowed at launch only for identity, entitlement, R2 reference/freshness access, account recovery/support, and future paid identity features. Ambitions Accounts must not store the private life graph unless a future canon explicitly approves a user-owned sync architecture.

R2 is not a user-data backend. R2 is public-reference and Source Atlas freshness distribution only. R2 must never store, receive, personalize from, or infer private user life data.

Hosted AI services and cloud LLMs are excluded from core architecture and are not core app runtime dependencies.

No future issue may claim data-boundary Green unless it preserves:

- local-first user data
- offline core value with no account
- optional Ambitions Account identity/entitlement boundary when scoped
- no private life graph in hosted backend
- no private user context in R2 requests
- R2 as public non-personal reference/source infrastructure only
- explicit data classification
- hosted AI/cloud LLM exclusion from core runtime architecture
- honest release/privacy/legal proof boundaries

---

## 2. User Data Rule

User data is on-device first.

User data includes:

- goals
- life areas
- captures
- held items
- schedule assumptions
- calendar-derived personal context
- protected time
- closures
- receipts
- proof
- pivots
- recovery history
- personalization
- planning defaults
- recommendation history
- user-specific learning
- private source imports
- private share artifacts
- private context and life graph state

User data may leave the device only when a narrower active law or future canon explicitly authorizes the exact path and proof requirements.

Allowed future user-owned sync paths require explicit truth/source/proof updates before claims.

Ambitions Account does not, by itself, authorize user-data sync or private life graph backend storage.

---

## 3. Ambitions Account Boundary

Ambitions Accounts are product truth at launch when scoped through `PRODUCT_DESIGN_TRUTH.md`.

Launch authentication providers:

```text
Sign in with Apple
Google Sign-In
```

Ambitions Account may support:

- identity
- entitlements
- R2 freshness/reference-pack access
- account recovery/support
- future paid identity layer
- future approved network features

Ambitions Account must not store:

- goals
- life areas
- captures
- held items
- schedule assumptions
- calendar-derived personal context
- planning defaults
- protected time
- closures
- receipts
- proof
- pivots
- recovery history
- personalization
- behavior patterns
- inferred priorities
- recommendation history
- private user context
- private life graph state

unless a future canon explicitly approves a user-owned sync architecture.

Missing account data classification is Yellow for governance docs and Red for runtime behavior that can move private data.

---

## 4. R2 / Source Atlas Boundary

R2 is not a user-data backend.

Allowed R2 material:

- public source packs
- public seed packs
- public goal and Step pathing metadata
- public manifests
- public freshness data
- source revocation data
- compatibility metadata
- non-user-specific public dates, rules, requirements, templates, and references
- non-personal Source Atlas metadata
- read-only reference packs

R2 must not store, receive, derive, or personalize from:

- user goals
- schedules
- calendar data
- proof
- private receipts
- closure history
- local learning
- private share artifacts
- private imports
- OCR output
- photos
- private files
- personal context
- behavior patterns
- inferred priorities
- private user context
- any user-identifying private life graph state

R2 requests must not include private user context to personalize returned packs. A future R2 implementation must support anonymous/non-personal fetches, entitlement-only fetches with no private life graph context, or block.

---

## 5. Hosted AI / Cloud LLM Boundary

Hosted AI services and cloud LLMs are excluded from core architecture and are not core app runtime dependencies.

Codex, prompts, CI, repository tools, and external coding helpers are development tooling. They are not Ambitions app runtime architecture.

A future issue that attempts to add hosted AI, cloud LLM, cloud model API, hosted personal-data intelligence, server-side profiling, or chatbot-first architecture is Red unless product truth is explicitly updated first and privacy/legal/release proof exists.

---

## 6. Data Classification

Every future data path must classify data before Green:

| Class | Meaning | Allowed destinations |
|---|---|---|
| local-only | Private user life data or private derived state. | Device local storage only unless a narrower law approves user-owned sync. |
| account-identity | Minimal account identity/entitlement data. | Ambitions Account provider/backend when scoped and privacy-reviewed. |
| account-entitlement | R2/reference-pack entitlement state. | Ambitions Account entitlement service; no private life graph context. |
| downloaded source/pathing data | Public Source Atlas/source pack material. | Bundled cache, local cache, R2/public source mirror, last-known-good local fallback. |
| user-owned sync | User-approved sync data. | Not approved by this law unless future canon/source/proof approves. |
| user-initiated export | User chooses to export or share. | Local rendered/exported artifact after preview and redaction. |
| collected by Ambitions | Data collected by Ambitions as a company or service. | Disallowed by default unless separately approved and privacy-reviewed. |
| never transmitted | Sensitive data that cannot leave the device. | Device local storage only; export/share blocked or redacted. |

Missing classification is Yellow for governance docs and Red for runtime behavior that can move data.

---

## 7. User-Facing Wording

Allowed law examples:

- “Ambitions downloads public reference packs.”
- “Your goals, schedule, proof, and life context stay on your device by default.”
- “Sign in unlocks reference updates and account support. It is not required for the offline app.”
- “This source pack is public reference data.”
- “This stays local unless you choose to export it.”

Forbidden wording:

- training data
- cloud learns your life
- uploaded for personalization
- synced to Ambitions servers
- R2-backed personal storage
- anonymous if private identifiers or context are sent
- account required for core use
- privacy approved without proof

These are law examples, not shipped copy.

---

## 8. Green Enforcement

Any future issue that claims local data, account identity, entitlements, R2, Source Atlas packs, pack freshness, data lifecycle, privacy, export, deletion, or sync Green must reference this law before Green.

Green requires:

- live issue identifier when applicable
- existing-first inspection of live source, entitlements, privacy manifest, persistence, Source Atlas, export/share, and release truth as applicable
- explicit data classification
- no private user data in R2 or public Source Atlas objects
- no private life graph in hosted backend
- offline core preserved with no account
- hosted AI/cloud LLM excluded from core runtime architecture
- receipts, rollback, delete, export, and conflict handling when behavior changes data
- privacy/legal/release no-claim boundary unless current proof exists

Yellow is allowed when this law is installed but future account, R2, pack, privacy, sync, export, or runtime proof remains unowned or unproven.

Red is required for private user data in R2, vague user data collection, private life graph backend drift, cloud training claims, hosted AI/cloud LLM core runtime drift, account-required core use, entitlement/privacy manifest mutation outside scope, or phase-order violation.
