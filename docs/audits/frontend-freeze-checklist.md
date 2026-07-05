# Frontend Freeze Checklist

Status: Frontend freeze checklist / Implemented Yellow
Date: 2026-07-05
Scope: AMB-1733
Baseline SHA: `e30f3f40043ab995f295643c8d054343b86d15a8`

## Checklist

| Gate | Required rule | Current status | Evidence |
| --- | --- | --- | --- |
| Root IA freeze | No persistent surfaces beyond Today, Goals, Time, You. | installed | `Native/Ambitions/Stage/AmbitionsSurface.swift`; `docs/audits/frontend-screen-route-registry.md` |
| Capture freeze | Capture remains global composer and cannot become a tab. | installed | `Native/Ambitions/Stage/SurfaceOwnershipRegistry.swift`; `docs/audits/frontend-screen-route-registry.md` |
| Motion freeze | Motion remains behavior and cannot become a destination. | installed | `Native/Ambitions/Stage/SurfaceOwnershipRegistry.swift`; `docs/audits/frontend-screen-route-registry.md` |
| Trust freeze | Proof, Source, Privacy, History, Receipts remain contextual inspection. | installed | `Native/Ambitions/Trust/`; `docs/audits/frontend-screen-route-registry.md` |
| Source-owner gate | Implementation leaves must name exact source-owner paths before execution. | installed | `docs/audits/frontend-codex-repo-validation-tasks.md` |
| Route classification gate | Implementation leaves must cite current screen/journey classification. | installed | `docs/audits/frontend-recovery-current-state.md` |
| Visual proof ceiling | Existing screenshots and docs cannot close Visual Green. | installed | `docs/audits/amb-1749-frontend-evidence-harness.md`; `docs/audits/amb-1750-visual-green-app-store-frontend-proof-gate.md` |
| Accessibility proof ceiling | Automation or source presence cannot claim accessibility conformance. | installed | `docs/truth/RELEASE_TRUTH.md`; `docs/audits/frontend-journey-registry.md` |
| Device proof ceiling | Simulator/source proof cannot claim device readiness. | installed | `docs/audits/amb-1750-visual-green-app-store-frontend-proof-gate.md` |
| Release proof ceiling | Frontend work cannot imply TestFlight, App Store, or Release Green readiness. | installed | `docs/truth/RELEASE_TRUTH.md`; `docs/audits/frontend-evidence-intake.md` |
| No-test closeout rule | Current issue completion may proceed without XCTest/UI/simulator testing under user instruction, but proof remains Yellow. | installed | AMB-1733 closeout rule in this file. |

## Ready For Codex Rule

Do not move a frontend implementation leaf to Ready For Codex unless it includes:

- exact source-owner paths
- current registry classification
- expected user journey
- required screenshot states
- required accessibility states
- non-claims and proof ceiling
- rollback path
- validation commands, with test commands clearly marked as not-run when testing
  remains disabled

## Stop Conditions

Stop or keep the leaf Yellow if:

- it adds a fifth root surface
- it turns Capture into a tab
- it turns Motion into a route
- it promotes Trust details into root IA
- it relies on historical screenshots as current proof
- it claims accessibility, device, App Store, or release readiness without current
  proof
- it cannot name the source-owner path it will change
