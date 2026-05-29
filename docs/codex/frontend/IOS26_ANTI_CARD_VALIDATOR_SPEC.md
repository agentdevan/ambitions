# iOS 26 Anti-Card / Object Purity Validator Spec

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Final working draft  
Target script: `scripts/ios26-anti-card-check.py`  
Report root: `build/reports/frontend-object-purity/`

---

## 1. Purpose

The validator protects Ambitions from regressing into generic card, surface, feed, chat, list, calendar-clone, or equal-panel top-level frontend architecture.

It does not enforce visual taste. It enforces active source evidence that each top-level surface is composed around the named object system:

- Today → Reality Meridian
- Time → LifeShape Field
- Goals → Constellation Atlas
- Capture → Atmosphere Composer
- You → User System Profile
- Proof/receipt → Proof / Receipt / Closure / Recovery runtime

---

## 2. Modes

Required CLI:

```bash
python3 scripts/ios26-anti-card-check.py --surface shell --batch IOS26-T04L-B01
python3 scripts/ios26-anti-card-check.py --surface today --batch IOS26-T05-B01
python3 scripts/ios26-anti-card-check.py --surface time --batch IOS26-T06-B02
python3 scripts/ios26-anti-card-check.py --surface goals --batch IOS26-T07-B01
python3 scripts/ios26-anti-card-check.py --surface capture --batch IOS26-T08-B01
python3 scripts/ios26-anti-card-check.py --surface you --batch IOS26-T09-B02
python3 scripts/ios26-anti-card-check.py --surface proof --batch IOS26-T10-B03
python3 scripts/ios26-anti-card-check.py --surface global --batch IOS26-T10-B04
```

Optional flags:

```bash
--report-dir build/reports/frontend-object-purity
--json
--markdown
--strict
```

---

## 3. Scan scope

Scan active source/test/preview files, not historical docs.

Required roots:

```text
Native/Ambitions/App
Native/Ambitions/Features
Native/AmbitionsTests
Native/AmbitionsUITests
Native/AmbitionsDesignSystem
Sources
Package.swift
project.yml
```

Exclude by default:

```text
docs/archive
docs/historical
docs/audits
build/reports
.codex/runs
DerivedData
```

Codex may tune these roots to match actual repo structure.

---

## 4. Hard-fail patterns

Red if active rendered surface contains:

```text
Card
surface
Feed
Chat
Assistant
Calendar clone root
Agenda root
Kanban / Board root
KPI
Ring
Score
proof thread
Hero as active source/UI concept
.card accessibility identifiers
equal-weight top-level panel stack
```

Examples:

```swift
struct GoalCard: View
struct CaptureDraftRoutePreviewCard: View
.accessibilityIdentifier("today.step.card")
Text("surface")
Text("AI assistant")
```

---

## 5. Surface-specific required object evidence

### Shell
Must find living chrome/command surface evidence and must not find shell-level chat/dashboard/global-card root.

### Today
Must find/infer Reality Meridian object root evidence and collapsed Start here relationship. Must not find task-list/calendar-agenda/card-stack root.

### Time
Must find LifeShape Field root evidence. Must not find calendar-grid clone, agenda root, surface widget root, or equal cards.

### Goals
Must find Constellation Atlas evidence. Must not find goal-card root, board/kanban root, KPI/ring/score root, or generic goal list as root.

### Capture
Must find Atmosphere Composer and Capture Route Lens evidence. Must not find inbox/feed/chat/notes/task-list/card root.

### You
Must find User System Profile / native configuration hub evidence. Native grouped rows are allowed, but profile-card/admin-dashboard/AI-memory-dashboard root is Red.

### Proof
Must find proof/receipt/closure/recovery object evidence. Must not find receipt-card/log-feed/audit-dashboard/KPI root.

---

## 6. Compatibility policy

The user selected no active compatibility allowance for card architecture.

Therefore:

- Active rendered card compatibility wrappers cannot close Green.
- If a compatibility wrapper remains but is not active/rendered, validator may classify it Yellow only with exact path, reason, and follow-up gate.
- Historical docs are ignored by scan scope rather than allow-commented.
- Do not create a broad allow-comment escape hatch.

If implementation absolutely requires a temporary compatibility marker, use only:

```text
AMB_FRONTEND_COMPAT_YELLOW
```

This marker is not Green. It forces Yellow with an owner, reason, no-claim boundary, and follow-up gate.

---

## 7. Output

For every run, write:

```text
build/reports/frontend-object-purity/<batch-id>-anti-card.md
build/reports/frontend-object-purity/<batch-id>-anti-card.json
```

Console summary must include:

```text
Status: Green / Yellow / Red
Surface:
Batch:
Files scanned:
Red findings:
Yellow findings:
Historical ignored:
Object root evidence:
Preview evidence:
Test evidence:
Accessibility evidence:
Next gate:
```

JSON must include equivalent machine-readable fields.

---

## 8. Test fixtures

Add validator self-tests for:

- active Card type detection
- `.card` accessibility ID detection
- historical ignored path
- You native grouped row allowed
- active top-level goal card root Red
- Capture route lens allowed
- receipt card Red
- no active findings Green

---

## 9. Required in batches

Run validator in:

```text
IOS26-T04L-B01
IOS26-T05-B01
IOS26-T06-B02
IOS26-T07-B01
IOS26-T08-B01
IOS26-T09-B01/B02
IOS26-T10-B01/B02/B03
IOS26-T10-B04
```

Final global sweep must run every surface mode plus global mode.

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
