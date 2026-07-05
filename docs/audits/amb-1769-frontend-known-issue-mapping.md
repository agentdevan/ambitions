# AMB-1769 Frontend Known-Issue Mapping

Status: Implemented Yellow / mapping complete without runtime testing
Date: 2026-07-05
Scope: AMB-1769, active frontend issue to known-issue crosswalk
Baseline SHA: `44f0671407619de4429dc1f163b0a7e9d940709a`
Linear status before closeout: `In Progress`

## Purpose

AMB-1769 maps the active frontend recovery work to retained known-issue rows so
new frontend issues do not duplicate existing defects, repair gates do not drift
away from current QA rows, and no known issue is closed without current proof.

The current user instruction authorizes issue completion without running tests.
This packet therefore completes AMB-1769 as a control-plane mapping. It does not
close any `AMB-ISSUE-*` row and does not claim runtime, screenshot,
accessibility, device, TestFlight, App Store, privacy/legal, or Release Green
proof.

## Authority Inputs

- `docs/qa/KNOWN_ISSUES.md` is the live known-issue register.
- `docs/qa/KNOWN_ISSUES_REMEDIATION_DOSSIERS.md` maps known-issue rows to the
  AMB-1191 through AMB-1200 remediation dossiers.
- `docs/linear/reconciliation/2026-07-01-repo-to-linear-app-aspect-coverage-matrix.json`
  maps app aspects to known-issue row groups.
- `docs/linear/current-state/2026-07-01-linear-coverage-map.md` records that the
  known-issue/risk-register area previously lacked complete app-wide current
  Linear coverage.
- Current AMB-1734 through AMB-1776 closeout packets are evidence inputs only;
  they do not close known-issue rows without the register closure law.

## Mapping Rules

- Use this packet as a crosswalk, not as a second known-issue register.
- Do not create duplicate Linear issues when an active row group already exists.
- Do not mark a known issue `Closed - verified` unless the live register closure
  law is satisfied.
- Source acceptance may support `Source-repaired candidate` or gate closure, but
  rendered/device/accessibility/release rows stay open until current proof
  exists.
- If a later issue affects a row group with `owner review required`, route it to
  owner review before promoting closure.

## Active Frontend Mapping

| Linear issue | Workstream | Known-issue mapping | Closure boundary |
| --- | --- | --- | --- |
| AMB-1735 | Root IA / Stage shell acceptance | `AMB-ISSUE-0006`, `0007`, `0806`, `0901`, `0902`, `1011`, `1701`-`1709` | Source acceptance only; shell visual/device proof remains required. |
| AMB-1736 | Capture global composer acceptance | `AMB-ISSUE-0002`, `0003`, `0008`, `0012`, `0201`-`0205`, `1101`-`1111`, `2002`, `2003` | Source acceptance only; Capture screenshot/device/offline proof remains required. |
| AMB-1737 | Today flagship acceptance | `AMB-ISSUE-0001`, `0004`, `0005`, `0016`, `0101`-`0108`, `1001`-`1011`, `1201` | Source acceptance only; Today runtime/device proof remains required. |
| AMB-1738 | Goals flagship acceptance | `AMB-ISSUE-0401`-`0406`, `1301`-`1309` | Source acceptance only; Goals crash/device/visual proof remains required. |
| AMB-1739 | Time flagship acceptance | `AMB-ISSUE-0009`, `0501`-`0507`, `0913`, `1401`-`1405` | Source acceptance only; Time device and placement proof remains required. |
| AMB-1740 | You / trust / privacy acceptance | `AMB-ISSUE-0601`-`0607`, `1501`-`1505`, `2004`, `2005`, `2007` | Source acceptance only; account/privacy/legal/offline proof remains required. |
| AMB-1741 | Visual system hardening | `AMB-ISSUE-0802`, `1503`, `1901`-`1906`, plus final-proof rows `0013`-`0015`, `0801`-`0807`, `0903`-`0912`, `1801`, `1802` | Visual Green blocked until screenshots, accessibility, owner review, and device proof exist. |
| AMB-1742 | Quarantine / stale route deletion | Applies across shell, surface, copy, and final-proof row groups above | Quarantine ledger only; per-row closure still needs affected-owner proof. |
| AMB-1743 | Frontend accessibility acceptance | `AMB-ISSUE-0013`-`0015`, `0801`-`0807`, `0903`-`0912`, `1801`, `1802` | QA ladder only; manual/runtime accessibility proof remains required. |
| AMB-1744 | Screenshot / device proof matrix | `AMB-ISSUE-0013`-`0015`, `0801`-`0807`, `0903`-`0912`, `1801`, `1802`, `2001`-`2012` | Matrix only; App Store/frontend Green remains blocked. |
| AMB-1764 | Search Find / Act / Inspect acceptance | `AMB-ISSUE-0701`, `1601`-`1605` | Source acceptance only; Search screenshot/route/device proof remains required. |
| AMB-1765 | Frontend screenshot / device proof matrix | `AMB-ISSUE-0013`-`0015`, `0801`-`0807`, `0903`-`0912`, `1801`, `1802`, `2001`-`2012` | Future proof lane; no known issue closes without artifacts. |
| AMB-1766 | Frontend accessibility acceptance | `AMB-ISSUE-0013`-`0015`, `0801`-`0807`, `0903`-`0912`, `1801`, `1802` | Future proof lane; automation alone is not Green. |
| AMB-1767 | Offline / no-account frontend acceptance | `AMB-ISSUE-0014`, `0807`, `2004`, `2005`, `2007` | Future proof lane; source/local-first posture is not offline runtime proof. |
| AMB-1768 | Frontend product-law drift scan | Cross-cutting: stale IA, copy, root-surface, and product-law rows | Drift ledger only; it routes blockers but does not close rows. |
| AMB-1769 | Frontend known-issue mapping | This packet | Control-plane crosswalk only; no row closure. |
| AMB-1770 | Capture full-screen composer proof | `AMB-ISSUE-0002`, `0003`, `0008`, `0012`, `0201`-`0205`, `1101`-`1111` | Future proof lane; Capture rendered proof required. |
| AMB-1771 | Search functionality repair gate | `AMB-ISSUE-0701`, `1601`-`1605` | Repair gate only; rendered Search proof required. |
| AMB-1772 | Goals crash / usability repair gate | `AMB-ISSUE-0401`-`0406`, `1301`-`1309` | Future proof lane; current device no-crash proof required. |
| AMB-1773 | Today Reality Window repair gate | `AMB-ISSUE-0001`, `0004`, `0005`, `0016`, `0101`-`0108`, `1001`-`1011`, `1201` | Future proof lane; rendered Today mutation proof required. |
| AMB-1774 | Time Life Calendar device proof gate | `AMB-ISSUE-0009`, `0501`-`0507`, `0913`, `1401`-`1405` | Future proof lane; Time device proof required. |
| AMB-1775 | Shell chrome screenshot matrix | `AMB-ISSUE-0006`, `0007`, `0806`, `0901`, `0902`, `1011`, `1701`-`1709` | Future proof lane; no-overlap route-depth proof required. |
| AMB-1776 | Copy / state language audit | `AMB-ISSUE-0010`, `0802`, `1503`, `1901`-`1906` | Copy ledger only; rendered screenshot review remains required. |

## Duplicate Prevention

- Search work must map to `AMB-ISSUE-0701` and `AMB-ISSUE-1601`-`1605`, not a
  new Search-known-issue family.
- Capture work must map to existing Capture rows, especially `AMB-ISSUE-0008`,
  `0012`, `0201`-`0205`, and `1101`-`1111`.
- Shell/chrome work must map to `AMB-ISSUE-0806`, `1011`, and `1701`-`1709`
  before new route-depth issues are created.
- Accessibility, screenshot, visual, and release proof work must map to
  `AMB-ISSUE-0013`-`0015`, `0801`-`0807`, `0903`-`0912`, `1801`, `1802`, and
  where relevant `2001`-`2012`.
- Account/offline/no-account work must map to `AMB-ISSUE-2004`, `2005`, and
  `2007` before new privacy/account rows are created.

## Proof Ceiling

Allowed claim:

- Current `main` contains a frontend known-issue crosswalk that maps active
  frontend recovery issues to retained QA row groups and blocks duplicate issue
  creation or unsupported known-issue closure.

Forbidden claims from this packet:

- any `AMB-ISSUE-*` row is closed
- Visual Green
- Accessibility Green
- Runtime Green
- Release Green
- TestFlight readiness
- App Store readiness
- privacy/legal approval
- current device proof
- current screenshot proof
- owner acceptance

## Validation

Commands run from `/Users/devan/Documents/GitHub/ambitions`:

- `git diff --check` - passed.
- `jq . docs/audits/amb-1769-frontend-known-issue-mapping.json` - passed.
- `npx markdownlint-cli2 --no-globs docs/audits/amb-1769-frontend-known-issue-mapping.md`
  - passed, `Summary: 0 error(s)`.
- `python3 scripts/ambitions-unsupported-claim-scan.py docs/audits/amb-1769-frontend-known-issue-mapping.md docs/audits/amb-1769-frontend-known-issue-mapping.json`
  - passed, `GREEN: unsupported completion/readiness claim scan passed`.
- `scripts/release-claim-safety-scan.sh docs/audits/amb-1769-frontend-known-issue-mapping.md docs/audits/amb-1769-frontend-known-issue-mapping.json`
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
- `scripts/no-unsupported-ai-claim-scan.sh docs/audits/amb-1769-frontend-known-issue-mapping.md docs/audits/amb-1769-frontend-known-issue-mapping.json`
  - advisory Yellow; review showed truth-file context and explicit non-claims.
- `scripts/privacy-boundary-scan.sh docs/audits/amb-1769-frontend-known-issue-mapping.md docs/audits/amb-1769-frontend-known-issue-mapping.json`
  - advisory Yellow; review showed broad truth-file privacy/local-first context
  and explicit AMB-1769 non-claims.
- `xcodegen generate --spec project.yml` - passed.
- `scripts/ambitions-xcodegen-needed.sh` - passed, `XCODEGEN_NEEDED=0`.

Commands not run:

- XCTest, UI test, simulator, screenshot, manual accessibility, performance
  walkthrough, physical-device, signed archive, and App Store Connect validation
  lanes - skipped under the current no-testing instruction.

## Closeout Notes

- Private Life Orchestration relationship: preserved. Known issues remain tied
  to proof requirements rather than unsupported readiness language.
- Final Architecture Tree inspected: yes.
- Canonical owners inspected: `docs/qa`, `docs/linear/reconciliation`,
  `docs/linear/current-state`, truth, and frontend audit docs.
- Canonical owners touched: none in production source.
- Files created: `docs/audits/amb-1769-frontend-known-issue-mapping.md` and
  `docs/audits/amb-1769-frontend-known-issue-mapping.json`.
- Files moved: none.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Architecture debt: none created; this is docs/control-plane only.
- Remaining proof debt: known-issue row closure still requires the live register
  closure law, current artifacts, and owner acceptance.
- No equivalent folder/path interpretation was used.
