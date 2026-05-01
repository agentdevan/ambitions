# Ambitions 3.0 F26 App Store / Marketing / Demo Truth Report

Date: 2026-05-01

Status: Green

## Scope

F26 reviewed App Store copy, screenshot truth, preview video concept truth, privacy claims, ADHD/accessibility positioning, subscription/trial claims, investor/demo script, and launch narrative consistency against current Ambitions 3.0 repo evidence.

## Artifacts Created

- `docs/marketing/Ambitions_3_0_App_Store_Truth_Packet.md`
- `docs/marketing/Ambitions_3_0_Demo_Script.md`

## Source Evidence

- `docs/canon/Ambitions_3_0_Launch_Narrative_And_Demo_Script.md`
- `docs/canon/Ambitions_3_0_Release_Readiness_And_Evidence_Gates.md`
- `docs/canon/Ambitions_3_0_Release_Claim_Truth_Protocol.md`
- `docs/canon/Ambitions_App_Store_Release_Compliance.md`
- `Native/Ambitions/Support/ReleaseExternalTruthReadinessPacket.swift`
- `Native/AmbitionsTests/App/ReleaseExternalTruthReadinessPacketTests.swift`
- `docs/audits/ambitions-3-0-f23-accessibility-adhd-qa-report.md`
- `docs/audits/ambitions-3-0-f24-privacy-trust-qa-report.md`
- `docs/audits/ambitions-3-0-f25-device-performance-edge-case-qa-report.md`

## Claim Mapping

| Public / demo claim | Allowed wording | Evidence | Limit |
| --- | --- | --- | --- |
| Core value | Ambitions makes life feel organized by turning intent into place, plan, step, recovery, and proof. | Golden Launch Loop canon; F22-F25 reports; release truth packet. | No release or public approval claim. |
| App Store subtitle | Organize life into clear next steps. | Product language and current IA. | Human review still required before App Store Connect entry. |
| Screenshots | Tell the Start here, Capture, Plan, Still Counts, Proof saved, You are in control story. | Launch Narrative and Screenshot Readiness canon. | Final screenshots must come from signed build and privacy-safe demo data. |
| Preview video | Demo `Release 3 songs by August 1` through the Golden Launch Loop. | Launch Narrative and Demo Script canon. | Do not show future behavior as shipped. |
| Privacy | Local-first trust, no Ambitions account required, privacy-scoped external projections. | Privacy manifest, F24 report, release truth packet. | App Store privacy labels require final binary and human review. |
| ADHD/cognitive load | Designed to reduce cognitive load with one clear step, recovery language, and visible controls. | F23 report and accessibility canon. | No medical, treatment, or public accessibility conformance claim. |
| Subscription/trial | No subscription, trial, paid unlock, or IAP claim approved for current copy. | Release compliance doc and Launch Operator Runbook. | Monetization review required if this enters scope. |
| Investor/demo | Prepared with limitations using privacy-safe fixture data. | Release truth packet and demo canon. | Not physical-device, TestFlight, App Store, or final release proof. |

## Scan Result

The F26 claim scan found expected guard/history/test hits for terms such as subscription, productivity score, accessibility claims, App Store submission posture, and TestFlight limitations. No new active public claim was introduced by F26.

## Validation

Required F26 validation:

- Marketing claim map: Pass.
- Demo script truth: Pass.
- Privacy claim truth: Pass.
- ADHD/accessibility claim limits: Pass.
- Subscription/trial claim review: Pass.
- App Store and TestFlight overclaim prevention: Pass.
- Focused release-truth tests: Pass. `ReleaseExternalTruthReadinessPacketTests` and `ReleaseCandidateLockDecisionReportTests` passed 9 selected tests with 0 failures. Log: `output/logs/f26-release-truth-tests-20260501-154409.log`. Result bundle: `Test-Ambitions-2026.05.01_15-44-19--0400.xcresult`.
- Diff whitespace check: Pass.

## Green Criteria

- Screenshots/demo claims match implemented behavior: Green.
- App Store copy truthful: Green.
- Privacy, ADHD, and subscription claims reviewed: Green.
- No marketing overclaim: Green.
- Investor/demo script truthful: Green.

## Remaining Release Limits

- No final App Store Connect entry was made.
- No final screenshots were generated.
- No live support or privacy URL was verified.
- No signed archive or App Store Connect validation was run.
- No physical-device proof was run.
- No public accessibility verification was claimed.
- No TestFlight, App Store, final release, or RC lock claim is made.

## Next Gate

F27 Final FAANG Handoff Gate Rerun may begin after F26 commit/push if local validation remains Green.
