# AMB-1761 Validation Command Inheritance - Architecture

Status: Implemented Yellow / Ready For Review for this control-plane leaf
Date: 2026-07-05T14:41:08Z
Baseline main SHA: `525e686beb2ca317a5b3d789496f885f1165f171`
Project: Architecture Simplification + Flagship Readiness Remediation (`59c3917f-f662-4ca3-b412-b532613f3a7a`)
Issue: `AMB-1761` Validation Command Inheritance - Architecture

## Scope

This packet attaches the exact validation-command expectations required by
`AMB-1761` to the active architecture child leaves created by the architecture
active parent decomposition gate.

The work is Linear/control-plane and docs evidence only. It does not change
Swift source, XcodeGen project source, Package.swift, runtime behavior, rendered
UI, privacy behavior, or release behavior.

## Live Inputs Inspected

- `AGENTS.md`
- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `.agents/skills/README.md`
- `.agents/skills/ambitions-source-truth-authority/SKILL.md`
- `.agents/skills/ambitions-architecture-tree-enforcement/SKILL.md`
- `.agents/skills/ambitions-ios-quality-gate/SKILL.md`
- `.agents/skills/ambitions-release-proof-honesty/SKILL.md`
- `docs/linear/reconciliation/2026-07-05-architecture-active-parent-decomposition-gate.md`
- Live Linear state for `AMB-1761` and project architecture leaves.

## Inherited Command Expectations

Every target architecture leaf now carries the following Linear comment:

```text
## AMB-1761 inherited architecture validation commands

This architecture leaf inherits the project validation-command expectations
below. Closeout for this leaf must record each command as run with result, or
explicitly record it as not run with the current reason and proof ceiling. This
attachment is not evidence that the commands passed.
```

The exact inherited command set is:

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -resolvePackageDependencies
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "<simulator>" build CODE_SIGNING_ALLOWED=NO
./scripts/build-local.sh
./scripts/ambitions-xcode-build-for-testing.sh --batch <BATCH>
./scripts/ambitions-xcode-test-focused.sh --batch <BATCH> --test <TEST_ID>
./scripts/ambitions-xcode-validate.sh --batch <BATCH> --lane build-for-testing
python3 scripts/ambitions-architecture-inventory.py
python3 scripts/ambitions-green-standard-audit.py
python3 scripts/ambitions-vocabulary-drift-scan.py
python3 scripts/ambitions-local-first-boundary-scan.py
```

These commands are expectations for architecture leaf closeouts. A future leaf
may record an explicit not-run reason and proof ceiling when a command is not
applicable or when the current owner/user instruction forbids that command.

## Linear Attachments

Attachment target set is the architecture child leaf set recorded in
`AMB-1757`.

| Leaf | Comment ID |
| --- | --- |
| `AMB-1798` | `87938531-fa91-4f96-ab52-356aa201da44` |
| `AMB-1799` | `c533026b-9ade-4828-abc3-1223ef58bbe4` |
| `AMB-1800` | `7cb488b5-62dc-49a8-89aa-a5bbeca67fa1` |
| `AMB-1801` | `8a087c1e-1cb9-4f4c-8837-d8f27cbad978` |
| `AMB-1802` | `ab20b5f0-eba0-4057-b874-a12a88831bf1` |
| `AMB-1803` | `f709b92f-4527-4708-bec2-c5fba5e7a4eb` |
| `AMB-1804` | `dafb8b85-79fd-47bb-9cf7-46b0ba974838` |
| `AMB-1805` | `2954dc21-1e1b-447e-9b68-42c47db4b192` |
| `AMB-1806` | `b7254438-e756-48e9-b76b-aa2e66facbc3` |
| `AMB-1807` | `9cb2ef78-6eb6-430c-a9a7-2578090bcc31` |
| `AMB-1808` | `cd5dfd0f-1f57-438a-b72f-ac3db737a070` |
| `AMB-1809` | `894c1711-5d19-4974-9cfe-6d84358dca8c` |
| `AMB-1810` | `e6b28920-9a5a-41f7-af12-5b0f1c21bf53` |
| `AMB-1811` | `5f59050f-e843-4e1c-bf03-93714b27c905` |
| `AMB-1812` | `beb54eda-22fa-40d6-831c-3f37731c40a2` |
| `AMB-1813` | `489d44c3-4967-42a7-9200-96c37c38d983` |
| `AMB-1814` | `bd6982c4-a42f-41bd-b15d-32e4a3b01b01` |
| `AMB-1815` | `3b04ec38-f3f1-423e-aa44-c7ba44844b8a` |
| `AMB-1816` | `142c2c12-d3c9-4f82-b1ed-b7f46ca60d56` |
| `AMB-1817` | `ca636975-d0ce-4ef3-ad49-e419aa99e800` |
| `AMB-1818` | `a7484a97-7194-4cdb-87f0-029109982bac` |
| `AMB-1819` | `37221a24-c85b-4ff2-b706-d632f5c525ce` |
| `AMB-1820` | `ff7e9ced-f460-4657-8dc5-1bbdf28f9cc5` |
| `AMB-1821` | `c8ce1aff-fc18-4106-a959-d4e2dfa66923` |
| `AMB-1822` | `b5834760-e43e-49be-943a-5d5d197e0e9f` |
| `AMB-1823` | `a03d9f83-796c-406f-ae00-b4cd32201ca0` |
| `AMB-1824` | `f0a447df-41ef-4c21-a19f-c6875b71d1be` |
| `AMB-1825` | `5e04c239-d48a-4ab7-a4be-af6a81be558f` |
| `AMB-1826` | `d744b541-5412-4a51-b783-5a6ddab3f3cb` |

Machine-readable ledger:
`docs/linear/reconciliation/2026-07-05-amb-1761-validation-command-inheritance.json`.

## Non-Claims

- The inherited comments do not prove the commands pass.
- No XCTest, xcodebuild build, build-for-testing, focused test, or simulator test
  success is claimed for this AMB-1761 control-plane packet.
- No Swift source behavior, runtime behavior, privacy behavior, rendered UI,
  accessibility conformance, device proof, Visual Green, Release Green,
  TestFlight readiness, App Store readiness, or final architecture Green is
  claimed.
- `AMB-1705` final architecture closeout remains blocked until its separate
  evidence and blocker gates close.

## Validation

Completed for this docs/control-plane packet:

- `git diff --check`
- `python3 -m json.tool docs/linear/reconciliation/2026-07-05-amb-1761-validation-command-inheritance.json`
- `python3 scripts/ambitions-remediation-governance-check.py`
- `python3 scripts/ambitions-quality-gate.py`
- `python3 scripts/ambitions-accepted-yellow-misuse-audit.py`
- `python3 scripts/ambitions-unsupported-claim-scan.py docs/linear/reconciliation/2026-07-05-amb-1761-validation-command-inheritance.md docs/linear/reconciliation/2026-07-05-amb-1761-validation-command-inheritance.json`

Validation not run:

- XCTest, xcodebuild build, build-for-testing, focused test, and simulator test
  commands were not run under the user's standing instruction authorizing issue
  completion without testing until advised otherwise.
- The inherited command set itself was attached as an expectation, not executed
  as proof for this docs/control-plane issue.

## Private Life Orchestration Relationship

Private Life Orchestration preserved: this control-plane leaf protects the Proof
and Learning side of Ambitions' Intent -> Context -> Path -> Time Fit -> Reflow
-> Action -> Proof -> Learning loop by requiring architecture leaves to carry
explicit validation commands and not-run proof ceilings. It does not alter user
data, the private life graph, runtime mutation behavior, or product surfaces.

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched: none in source; docs evidence only under
  `docs/linear/reconciliation/`.
- Non-canonical owners touched: none.
- Files moved or created: two reconciliation artifacts.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Architecture debt: `AMB-1705` remains blocked by separate proof/review gates.
- Next repair train if debt remains: continue M14 with `AMB-1759`, `AMB-1760`,
  `AMB-1762`, and the still-open parent/leaf blockers recorded by `AMB-1826`.
- No equivalent folder/path interpretation was used.

## Rollback

If this inheritance attachment must be reversed, delete or supersede the Linear
comments listed above, reopen or move `AMB-1761` back to `Needs Repair`, and
revert this evidence packet commit.
