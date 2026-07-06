# AMB-1820 Suffix Split First Semantic Rename Group

Status: Implemented Yellow / one suffix group renamed with tests not run
Date: 2026-07-06
Scope: AMB-1820, first semantic suffix-split rename group
Baseline SHA: `7ac3b6fe8a07101663a875b8ecaf9c720f9cd3a8`
Linear status before closeout: `In Progress`

## Purpose

AMB-1820 is a bounded child of AMB-1699. Its job is not repo-wide suffix
elimination. Its job is to choose one `+02` / `+03` / `+04` split group,
rename that group to semantic responsibility names, and update active
references without adding any new suffix files.

The current user instruction authorizes issue completion without running tests.
This packet therefore completes AMB-1820 as Implemented Yellow: the selected
source group is renamed and active test path references are updated, but
focused tests, build tests, simulator tests, and release proof were not run.

## Authority Inputs

- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_ACTION_MAP.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/qa/p1-foundation-reality-inventory.md`
- `.agents/skills/README.md`
- `.agents/skills/ambitions-source-truth-authority/SKILL.md`
- `.agents/skills/ambitions-architecture-tree-enforcement/SKILL.md`
- `.agents/skills/ambitions-ios-quality-gate/SKILL.md`
- `.agents/skills/ambitions-release-proof-honesty/SKILL.md`
- Current issue state for AMB-1820 and AMB-1699
- Live source under `Native/Ambitions/DesignSystem/ProductObjects`
- Live tests under `Native/AmbitionsTests/Today`

## Selected Group

Selected group:

```text
Native/Ambitions/DesignSystem/ProductObjects/TodayDayRailPanels
```

Reason:

- It is under the canonical `DesignSystem/ProductObjects` owner.
- It is a compact five-file suffix group.
- The change is filename responsibility cleanup only.
- Active hardcoded references are confined to a focused Today test file.
- It does not add, remove, or move runtime, persistence, command, projection,
  receipt, replay, side-effect, privacy, sync, migration, repair, diagnostics,
  Source Atlas, or product-surface authority.

## Rename Map

| Old file | New semantic file |
| --- | --- |
| `TodayDayRailPanels+02-AmbitionsDayRailView.swift` | `TodayDayRailView.swift` |
| `TodayDayRailPanels+02-AmbitionsDayRailView+02-state.swift` | `TodayDayRailViewStateRendering.swift` |
| `TodayDayRailPanels+02-AmbitionsDayRailView+03-mappedRowNode.swift` | `TodayDayRailViewCurrentMoment.swift` |
| `TodayDayRailPanels+02-AmbitionsDayRailView+04-upNextRow.swift` | `TodayDayRailViewUpNextRows.swift` |
| `TodayDayRailPanels+03-DayRailRowSlot.swift` | `TodayDayRailRowSlotLabels.swift` |

Reference updated:

- `Native/AmbitionsTests/Today/TodayRealityWindowActionGatingTests.swift`

## Scope Boundary

In scope:

- Rename one selected mechanical suffix group.
- Preserve the canonical owner path.
- Update active test path literals.
- Prove active source/test/project references no longer point at the renamed
  `TodayDayRailPanels+02/+03` files.
- Regenerate Xcode project metadata because Swift source paths changed.

Out of scope:

- Repo-wide suffix elimination.
- Renaming unrelated suffix groups.
- Moving files between architecture owners.
- Product UI behavior changes.
- Runtime authority changes.
- New test plans or screenshot/device proof.

## Proof Ceiling

Allowed claim:

- Current `main` contains an AMB-1820 source rename that removes the selected
  `TodayDayRailPanels` `+02/+03/+04` mechanical file names and updates active
  Today test path references.

Forbidden claims from this packet:

- repo-wide suffix elimination is complete
- AMB-1699 is Green
- no suffix split files remain
- focused Today tests passed
- build validation passed
- simulator validation passed
- device proof exists
- release proof exists
- TestFlight readiness
- App Store readiness
- Release Green

## Validation

Commands run from `/Users/devan/Documents/GitHub/ambitions`:

- `git diff --check` - passed.
- `jq -e . docs/audits/amb-1820-suffix-split-first-semantic-rename-group.json
  >/dev/null` - passed.
- `npx markdownlint-cli2 --no-globs
  docs/audits/amb-1820-suffix-split-first-semantic-rename-group.md` - passed
  with 0 errors.
- `npx markdownlint-cli2 --no-globs
  docs/audits/amb-1820-suffix-split-first-semantic-rename-group.md
  docs/truth/PRODUCT_EXPERIENCE_ACTION_MAP.md
  docs/qa/p1-foundation-reality-inventory.md` - passed with 0 errors.
- `python3 scripts/ambitions-unsupported-claim-scan.py
  docs/audits/amb-1820-suffix-split-first-semantic-rename-group.md
  docs/audits/amb-1820-suffix-split-first-semantic-rename-group.json` -
  passed.
- `python3 scripts/ambitions-unsupported-claim-scan.py
  docs/audits/amb-1820-suffix-split-first-semantic-rename-group.md
  docs/audits/amb-1820-suffix-split-first-semantic-rename-group.json
  docs/truth/PRODUCT_EXPERIENCE_ACTION_MAP.md
  docs/qa/p1-foundation-reality-inventory.md` - passed.
- `scripts/release-claim-safety-scan.sh
  docs/audits/amb-1820-suffix-split-first-semantic-rename-group.md
  docs/audits/amb-1820-suffix-split-first-semantic-rename-group.json` -
  passed.
- `scripts/release-claim-safety-scan.sh
  docs/audits/amb-1820-suffix-split-first-semantic-rename-group.md
  docs/audits/amb-1820-suffix-split-first-semantic-rename-group.json
  docs/truth/PRODUCT_EXPERIENCE_ACTION_MAP.md
  docs/qa/p1-foundation-reality-inventory.md` - passed.
- `rg -n "TodayDayRailPanels\\+02|TodayDayRailPanels\\+03"
  Native/Ambitions Native/AmbitionsTests Sources project.yml -S` - returned no
  active source/test/project hits.
- `rg -n "TodayDayRailPanels\\+02|TodayDayRailPanels\\+03" docs/truth
  docs/qa Native/Ambitions Native/AmbitionsTests Sources project.yml -S` -
  returned no active truth/QA/source/test/project hits after reference repair.
- `xcodegen generate --spec project.yml` - passed and wrote the generated
  project.
- `python3 scripts/ambitions-remediation-governance-check.py` - passed; suffix
  counts reduced to `suffixSplitFiles=224` and `blockedSuffixSplitFiles=182`.
- `python3 scripts/ambitions-architecture-inventory.py` - passed with
  final-tree parity.
- `python3 scripts/ambitions-vocabulary-drift-scan.py` - passed.
- `python3 scripts/ambitions-truth-path-vocabulary-audit.py` - passed after the
  stale truth path was updated to `TodayDayRailViewUpNextRows.swift`.
- `python3 scripts/ambitions-green-standard-audit.py` - passed as a static
  source scan.
- `python3 scripts/ambitions-local-first-boundary-scan.py` - passed.
- `python3 scripts/ambitions-accepted-yellow-misuse-audit.py` - passed.
- `python3 scripts/ambitions-screenshot-artifact-audit.py` - passed as a static
  guard; no screenshot artifact was produced.
- `python3 scripts/ambitions-device-proof-required.py` - passed as a static
  guard; no device proof was produced.
- `scripts/no-unsupported-ai-claim-scan.sh
  docs/audits/amb-1820-suffix-split-first-semantic-rename-group.md
  docs/audits/amb-1820-suffix-split-first-semantic-rename-group.json
  docs/truth/PRODUCT_EXPERIENCE_ACTION_MAP.md
  docs/qa/p1-foundation-reality-inventory.md` - completed with advisory hits
  reviewed as context and non-claims.
- `scripts/privacy-boundary-scan.sh
  docs/audits/amb-1820-suffix-split-first-semantic-rename-group.md
  docs/audits/amb-1820-suffix-split-first-semantic-rename-group.json
  docs/truth/PRODUCT_EXPERIENCE_ACTION_MAP.md
  docs/qa/p1-foundation-reality-inventory.md` - completed with advisory hits in
  existing truth/QA context reviewed as non-claims.
- `scripts/ambitions-xcodegen-needed.sh` - pre-commit output was
  `XCODEGEN_NEEDED=1` because tracked Swift source paths were still dirty;
  `Ambitions.xcodeproj` had no diff after regeneration. The post-commit rerun
  returned `XCODEGEN_NEEDED=0` with reason `project build inputs unchanged`.

Commands not run:

- Focused Today XCTest, full XCTest, build, simulator, screenshot, device,
  performance, signed archive, and App Store Connect validation lanes - skipped
  under the current no-testing instruction.

## Closeout Notes

- Private Life Orchestration relationship: no product behavior changed. This
  preserves repo health for the Today object implementation that supports the
  `Intent -> Context -> Path -> Time Fit -> Reflow -> Action -> Proof ->
  Learning` loop.
- Final Architecture Tree inspected: yes.
- Canonical owners touched: `DesignSystem/ProductObjects` and Today tests.
- Non-canonical owners touched: none.
- Files created: `docs/audits/amb-1820-suffix-split-first-semantic-rename-group.md`
  and `docs/audits/amb-1820-suffix-split-first-semantic-rename-group.json`.
- Current truth/QA references updated:
  `docs/truth/PRODUCT_EXPERIENCE_ACTION_MAP.md` and
  `docs/qa/p1-foundation-reality-inventory.md`.
- Files moved: five `TodayDayRailPanels` suffix files were renamed in place to
  semantic responsibility names.
- Old/non-canonical paths removed: the five selected `TodayDayRailPanels+02/+03`
  filenames were removed from active source.
- Compatibility shims left behind: none.
- Yellow debt: remaining repo suffix groups, parent AMB-1699 proof, focused
  test execution, build validation, simulator proof, and release proof remain
  absent.
- Next repair train: continue AMB-1699 with another bounded suffix group.
- No equivalent folder/path interpretation was used.
