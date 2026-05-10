# Release Evidence Packet

Status: evidence posture, not release approval.

This packet records what validation evidence the repo can currently claim and what it cannot claim.

Phase 12 firewall note, 2026-05-10: this packet proves only the current raw
evidence it cites. Docs-only plans, batch reports, train completion, tool maps,
and repo inventory do not prove release status, validation on real hardware,
public accessibility conformance, performance, legal/privacy signoff, hosted
CI, TestFlight, App Store submission, backend/provider activation, or
implementation completeness.

## Current validation posture

Ambitions uses local VM/Mac validation as the source of truth.

There is no active hosted CI workflow in this repo.

## Current evidence sources

| Evidence source | Location / command | Current claim |
| --- | --- | --- |
| Project generation | `xcodegen generate` | Local project generation path exists. |
| Local simulator build | `./scripts/build-local.sh` or equivalent `xcodebuild` command | Local unsigned simulator build path exists. |
| Unit tests | `xcodebuild ... -only-testing:AmbitionsTests test` | Unit test target exists; pass/fail must come from current local logs. |
| UI tests | `xcodebuild ... -only-testing:AmbitionsUITests test` | UI test target exists; pass/fail must come from current local logs. |
| Archive sanity | unsigned `xcodebuild archive` from `docs/native-build-and-release.md` | Unsigned archive sanity path exists; pass/fail must come from current local logs. |
| Manual platform validation | local simulator/device notes | Not proven by repo docs alone. |

## Required local proof packet

A serious local validation run should save or summarize:

1. commit SHA and branch
2. macOS version
3. Xcode version
4. XcodeGen version
5. `xcodegen generate` result
6. dependency resolution result
7. simulator build result
8. unit test result
9. UI test result
10. unsigned archive sanity result when relevant
11. explicit non-claim notes for device, signing, TestFlight, App Store, accessibility, privacy/legal, and human approval

## Current non-claims

This repo does not currently prove:

- hosted CI success
- signed archive correctness
- provisioning profile correctness
- export options correctness
- TestFlight upload readiness
- App Store Connect validation
- App Store distribution readiness
- physical-device install behavior
- physical-device runtime behavior
- widget behavior on device
- Live Activity behavior on device
- notification behavior on device
- share extension behavior on device
- App Intent / Shortcut behavior on device
- public accessibility conformance
- legal/privacy compliance signoff
- human release approval

## Hosted CI policy

Hosted CI was intentionally removed from the active repo posture because Ambitions is staying on local VM/Mac validation.

Do not add GitHub Actions, Xcode Cloud, Codemagic, Bitrise, or another hosted validation provider unless a future patch explicitly records:

- provider
- expected cost model
- free quota or billing risk
- triggers
- artifact retention
- owner approval
- release-claim limits

## Release-claim rule

A claim may appear in product, README, App Store, TestFlight, investor, or public copy only when the matching evidence exists in the current proof packet.

Allowed current wording:

- under active native iOS development
- local-first / on-device-first posture
- local VM/Mac validation
- simulator build path exists
- unit/UI test targets exist
- release readiness not yet claimed

Forbidden current wording:

- claims that App Store submission can proceed
- claims that TestFlight distribution can proceed
- claims that production launch can proceed
- device-verified
- fully accessible
- legally/privacy approved
- CI-proven
- claims that signed release distribution can proceed

## Update rule

Update this packet whenever:

- validation posture changes
- hosted CI is added or removed
- signing/release proof is added
- device validation is completed
- public accessibility/legal/privacy evidence changes
- root README release language changes
