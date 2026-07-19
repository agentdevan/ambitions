# AMB-1771 Search Functionality Repair Gate

Status: Implemented Yellow / gate closed under no-testing authorization
Date: 2026-07-05
Scope: AMB-1771, Search local-only functionality repair gate
Baseline SHA: `6ef06166f72be79e38eb387dce0292ea400b80bb`
Linear status before closeout: `In Progress`

## Purpose

AMB-1771 is the repair gate that prevents Search from being accepted as a
chatbot, cloud search surface, unbounded route shortcut, or proof-free feature.
It is closed only by tying the Search path to current source evidence, explicit
non-claims, and rollback policy.

The current user instruction authorizes issue completion without running tests.
This packet therefore closes the repair gate as Implemented Yellow. It does not
claim screenshot proof, manual accessibility proof, simulator/device behavior,
offline/no-account runtime behavior, or rendered Search mutation proof.

## Gate Inputs

| Input | Role |
| --- | --- |
| `docs/audits/amb-1764-search-find-act-inspect-acceptance.md` | Primary source-acceptance packet for local Find / Act / Inspect. |
| `docs/audits/amb-1764-search-find-act-inspect-acceptance.json` | Machine-readable acceptance evidence and proof ceiling. |
| `docs/audits/frontend-product-law-drift-scan.md` | Product-law scan clearing Search routing while preserving proof blockers. |
| `docs/truth/2026-06-22-runtime-remediation-decision-register.md` | Defines Search as unified Find / Act / Inspect, not chatbot or generic text search. |
| `Native/Ambitions/Core/LocalRuntimeOS/Search/` | Current canonical Search runtime owner. |
| `Native/Ambitions/Stage/Overlays/QuietCommandMemoryLensOverlay.swift` | Current Search overlay, empty fallback, Capture fallback, accessibility source contract. |
| `Native/Ambitions/App/ShellCommandRouter.swift` | Trusted Search route handling and visible continuity receipt source path. |
| `Native/Ambitions/App/ShellCommandDestination.swift` | Canonical handoff owner mapping and stale IA blockers. |
| `Native/Ambitions/Surfaces/You/Projection/SearchLens.swift` | Local, inspectable, source-tied Search trust boundary. |

## Gate Decision

| Gate question | Decision |
| --- | --- |
| Does Search remain local-only Find / Act / Inspect? | Yes as source contract, through AMB-1764 evidence. |
| Is Search framed as chatbot or cloud search? | No active Search owner uses chatbot/cloud-search framing; source copy states local results and no external service. |
| Are actions constrained before routing? | Yes in source, through `SearchActionValidator`, trusted handoffs, and stale destination blockers. |
| Is safe fallback present? | Yes in source: no-match Capture fallback, missing-goal Memory Lens fallback, and held stale destinations. |
| Is visible mutation present when action is supported? | Source-supported through route history and `Search opened` continuity receipt; not runtime-rendered in this packet. |
| Can this issue claim Green? | No. Runtime, screenshot, accessibility, offline/no-account, and device proof are absent. |

## Repair Policy

- Block any Search route that targets stale IA, non-canonical roots, or untrusted
  destination owners.
- Deny actions that fail privacy, family, local-only, command-validation, or
  target checks.
- Keep Search copy local, inspectable, and source-tied; do not introduce chatbot
  or cloud-search framing.
- Use Capture fallback for a query that has no local match; do not silently
  create or mutate private runtime state from Search.
- Keep AMB-1479 and later proof trains as the place for Visual Green and
  rendered-device claims.

## Proof Ceiling

Allowed claim:

- The Search functionality repair gate has a current source-acceptance packet,
  canonical owner map, product-law non-claims, validation record, and rollback
  policy that keep Search local-only, source-tied, and action-bounded.

Forbidden claims from this packet:

- current screenshot proof
- rendered Search behavior
- manual accessibility conformance
- simulator or device behavior
- offline/no-account runtime behavior
- runtime UI mutation proof
- final visual approval
- TestFlight readiness
- App Store readiness
- frontend Visual Green
- Release Green

## Validation

Commands run from `/Users/devan/Documents/GitHub/ambitions`:

- `git diff --check` - passed.
- `jq . docs/audits/amb-1771-search-functionality-repair-gate.json` - passed.
- `npx markdownlint-cli2 --no-globs docs/audits/amb-1771-search-functionality-repair-gate.md`
  - passed, `Summary: 0 error(s)`.
- `python3 scripts/ambitions-unsupported-claim-scan.py docs/audits/amb-1771-search-functionality-repair-gate.md docs/audits/amb-1771-search-functionality-repair-gate.json`
  - passed, `GREEN: unsupported completion/readiness claim scan passed`.
- `scripts/release-claim-safety-scan.sh docs/audits/amb-1771-search-functionality-repair-gate.md docs/audits/amb-1771-search-functionality-repair-gate.json`
  - passed, `GREEN proof-sensitive release terms are framed as non-claims,
  boundaries, or future proof`.
- `python3 scripts/ambitions-remediation-governance-check.py` - passed,
  `GREEN remediation governance guard passed`.
- `python3 scripts/ambitions-architecture-inventory.py` - passed,
  `GREEN final-tree parity achieved`.
- `python3 scripts/ambitions-vocabulary-drift-scan.py` - passed,
  `GREEN: canonical and active vocabulary terms are present and explicit ban
  terms are absent`.
- `python3 scripts/ambitions-truth-path-vocabulary-audit.py` - passed,
  `GREEN: truth paths resolve or are explicitly planned/internal, and active
  stale terms are quarantined`.
- `python3 scripts/ambitions-green-standard-audit.py` - passed,
  `GREEN: no disallowed architecture-as-UI strings found in active primary UI
  source`.
- `python3 scripts/ambitions-local-first-boundary-scan.py` - passed,
  `GREEN: local-first/account/R2/hosted-AI boundary checks passed in active
  authority files`.
- `python3 scripts/ambitions-accepted-yellow-misuse-audit.py` - passed,
  `valid=true`, `invalidAcceptedYellowIssues=0`.
- `scripts/no-unsupported-ai-claim-scan.sh docs/audits/amb-1771-search-functionality-repair-gate.md docs/audits/amb-1771-search-functionality-repair-gate.json`
  - advisory Yellow; review showed truth-file context and explicit non-claims.
- `scripts/privacy-boundary-scan.sh docs/audits/amb-1771-search-functionality-repair-gate.md docs/audits/amb-1771-search-functionality-repair-gate.json`
  - advisory Yellow; review showed broad truth-file privacy/local-first context
  and explicit AMB-1771 non-claims.
- `xcodegen generate --spec project.yml` - passed.
- `scripts/ambitions-xcodegen-needed.sh` - passed, `XCODEGEN_NEEDED=0`.

Commands not run:

- XCTest, UI test, simulator, screenshot, manual accessibility, performance
  walkthrough, physical-device, signed archive, and App Store Connect validation
  lanes - skipped under the current no-testing instruction.

## Closeout Notes

- Private Life Orchestration relationship: preserved. Search stays local,
  inspectable, source-tied, and action-bounded.
- Final Architecture Tree inspected: yes.
- Canonical owners inspected: `Core/LocalRuntimeOS/Search`, `Stage/Overlays`,
  `App`, `Surfaces/You/Projection`, truth, retained tests, and audit docs.
- Canonical owners touched: none in production source.
- Files created: `docs/audits/amb-1771-search-functionality-repair-gate.md`
  and `docs/audits/amb-1771-search-functionality-repair-gate.json`.
- Files moved: none.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Architecture debt: no production path change was made. Screenshot,
  accessibility, simulator/device, offline/no-account runtime, rendered receipt,
  and performance proof remain absent.
- Next proof train: AMB-1765, AMB-1766, AMB-1767, AMB-1770, AMB-1774, and
  AMB-1775 when testing/device proof is re-enabled.
- No equivalent folder/path interpretation was used.
