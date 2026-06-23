# Known Issues → Codex Remediation Dossier Map

**Status:** Active cross-link for the 2026-06-22 runtime QA remediation.  
**Primary register:** `docs/qa/KNOWN_ISSUES.md`  
**Runtime report:** `docs/qa/device_review_20260622_more_issues.md`  
**Global law:** `docs/qa/remediation/2026-06-22-codex-remediation-law.md`

Use this file to route known issues to the correct Codex execution dossier. Do not mark any known issue `Closed - verified` unless the relevant dossier proof matrix is satisfied and owner acceptance is recorded.

| Linear bundle | Dossier | Known issue coverage |
|---|---|---|
| `AMB-1191` | `docs/qa/remediation/dossiers/AMB-1191-theme-design-system.md` | Light Mode / theme / hard-coded dark color rows: `AMB-ISSUE-1901`–`1906`, `1503`, `0802` |
| `AMB-1194` | `docs/qa/remediation/dossiers/AMB-1194-shell-stage-os.md` | Shell / dock / header / full-bleed rows: `AMB-ISSUE-0006`, `0007`, `0806`, `0901`, `0902`, `1011`, `1701`–`1709` |
| `AMB-1192` | `docs/qa/remediation/dossiers/AMB-1192-capture-route-graph-composer.md` | Capture rows: `AMB-ISSUE-0002`, `0003`, `0008`, `0012`, `0201`–`0205`, `1101`–`1111` |
| `AMB-1193` | `docs/qa/remediation/dossiers/AMB-1193-goals-root-detail.md` | Goals rows: `AMB-ISSUE-0401`–`0406`, `1301`–`1309` |
| `AMB-1195` | `docs/qa/remediation/dossiers/AMB-1195-today-reality-window.md` | Today / Closure-gating rows: `AMB-ISSUE-0001`, `0004`, `0005`, `0016`, `0101`–`0108`, `1001`–`1011`, `1201` |
| `AMB-1196` | `docs/qa/remediation/dossiers/AMB-1196-search-find-act-inspect.md` | Search rows: `AMB-ISSUE-0701`, `1601`–`1605` |
| `AMB-1197` | `docs/qa/remediation/dossiers/AMB-1197-time-native-life-calendar.md` | Time rows: `AMB-ISSUE-0009`, `0501`–`0507`, `0913`, `1401`–`1405` |
| `AMB-1198` | `docs/qa/remediation/dossiers/AMB-1198-you-settings-privacy.md` | You / settings rows: `AMB-ISSUE-0601`–`0607`, `1501`–`1505` |
| `AMB-1199` | `docs/qa/remediation/dossiers/AMB-1199-final-proof-accessibility.md` | Accessibility / final proof / release-gate rows: `AMB-ISSUE-0013`–`0015`, `0801`–`0807`, `0903`–`0912`, `1801`, `1802` |
| `AMB-1200` | `docs/qa/remediation/dossiers/AMB-1200-register-sync-control-closeout.md` | Register sync and project-control rows |

## Closure law

A known issue row may move to `Candidate resolved` only when the corresponding dossier implementation is complete and source/test/audit evidence exists.

A known issue row may move to `Closed - verified` only when:

1. the relevant dossier proof matrix is satisfied,
2. `docs/qa/KNOWN_ISSUES.md` is updated,
3. current screenshots/videos/audits/persistence proof are linked or committed,
4. the owner accepts the result.

Historical screenshots from `More issues.zip` prove the defect, not the fix.
