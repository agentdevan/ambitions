# IOS26 Implementation Order

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Generated from `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.

1. `IOS26-T00-B01` - TRAIN_00 / Repo truth, audit, validation baseline - `prompts/batches/IOS26-T00-B01-repo-source-inventory.md`
2. `IOS26-T00-B02` - TRAIN_00 / Repo truth, audit, validation baseline - `prompts/batches/IOS26-T00-B02-validation-baseline.md`
3. `IOS26-T00-B03` - TRAIN_00 / Repo truth, audit, validation baseline - `prompts/batches/IOS26-T00-B03-naming-api-drift-inventory.md`
4. `IOS26-T01-B01` - TRAIN_01 / iOS 26 minimum migration foundation - `prompts/batches/IOS26-T01-B01-toolchain-confirmation.md`
5. `IOS26-T01-B02` - TRAIN_01 / iOS 26 minimum migration foundation - `prompts/batches/IOS26-T01-B02-deployment-target-bump.md`
6. `IOS26-T01-B03` - TRAIN_01 / iOS 26 minimum migration foundation - `prompts/batches/IOS26-T01-B03-availability-compatibility-cleanup.md`
7. `IOS26-T02-B00` - TRAIN_02 / Design system and Liquid Glass-era shell modernization - `prompts/batches/IOS26-T02-B00-safe-area-root-invariant.md`
8. `IOS26-T02-B01` - TRAIN_02 / Design system and Liquid Glass-era shell modernization - `prompts/batches/IOS26-T02-B01-native-ios26-shell.md`
9. `IOS26-T02-B02` - TRAIN_02 / Design system and Liquid Glass-era shell modernization - `prompts/batches/IOS26-T02-B02-liquid-glass-token-layer.md`
10. `IOS26-T02-B03` - TRAIN_02 / Design system and Liquid Glass-era shell modernization - `prompts/batches/IOS26-T02-B03-icon-screenshot-foundation.md`
11. `IOS26-T03-B01` - TRAIN_03 / Private Life Runtime centralization and proof harness - `prompts/batches/IOS26-T03-B01-broad-suite-yellow-repair.md`
12. `IOS26-T03-B02` - TRAIN_03 / Private Life Runtime centralization and proof harness - `prompts/batches/IOS26-T03-B02-local-only-proof-harness.md`
13. `IOS26-T03-B03` - TRAIN_03 / Private Life Runtime centralization and proof harness - `prompts/batches/IOS26-T03-B03-replayable-decision-traces.md`
14. `IOS26-T04-B01` - TRAIN_04 / Goal intent-to-day compiler - `prompts/batches/IOS26-T04-B01-compiler-input-output-model.md`
15. `IOS26-T04-B02` - TRAIN_04 / Goal intent-to-day compiler - `prompts/batches/IOS26-T04-B02-capacity-aware-compilation.md`
16. `IOS26-T04-B03` - TRAIN_04 / Goal intent-to-day compiler - `prompts/batches/IOS26-T04-B03-compiler-persistence-receipts.md`
17. `IOS26-T04A-B01` - TRAIN_04A / Life Context & Historical Catch-Up Runtime Inputs - `prompts/batches/IOS26-T04A-B01-life-context-domain.md`
18. `IOS26-T04A-B02` - TRAIN_04A / Life Context & Historical Catch-Up Runtime Inputs - `prompts/batches/IOS26-T04A-B02-historical-catchup-intake.md`
19. `IOS26-T04A-B03` - TRAIN_04A / Life Context & Historical Catch-Up Runtime Inputs - `prompts/batches/IOS26-T04A-B03-runtime-effect-proof.md`
20. `IOS26-T04A-B04` - TRAIN_04A / Life Context & Historical Catch-Up Runtime Inputs - `prompts/batches/IOS26-T04A-B04-you-controls-receipts.md`
21. `IOS26-T04A-B05` - TRAIN_04A / Life Context & Historical Catch-Up Runtime Inputs - `prompts/batches/IOS26-T04A-B05-you-life-context-premium-panel.md`
22. `IOS26-T04A-B06` - TRAIN_04A / Life Context & Historical Catch-Up Runtime Inputs - `prompts/batches/IOS26-T04A-B06-anti-bucket-factor-ledger-proof.md`
23. `IOS26-T04B-B01` - TRAIN_04B / Step Optionality, Rejection Replanning & Simulation Proof - `prompts/batches/IOS26-T04B-B01-step-candidate-field.md`
24. `IOS26-T04B-B02` - TRAIN_04B / Step Optionality, Rejection Replanning & Simulation Proof - `prompts/batches/IOS26-T04B-B02-rejection-reasoning-loop.md`
25. `IOS26-T04B-B03` - TRAIN_04B / Step Optionality, Rejection Replanning & Simulation Proof - `prompts/batches/IOS26-T04B-B03-deadline-simulation-engine.md`
26. `IOS26-T04B-B04` - TRAIN_04B / Step Optionality, Rejection Replanning & Simulation Proof - `prompts/batches/IOS26-T04B-B04-approval-receipts-learning.md`
27. `IOS26-T04B-B05` - TRAIN_04B / Step Optionality, Rejection Replanning & Simulation Proof - `prompts/batches/IOS26-T04B-B05-exhaustive-simulation-gauntlet.md`
28. `IOS26-T04B-B06` - TRAIN_04B / Step Optionality, Rejection Replanning & Simulation Proof - `prompts/batches/IOS26-T04B-B06-today-optionality-ui.md`
29. `IOS26-T04C-B01` - TRAIN_04C / Source Atlas -> Runtime Compiler Bridge - `prompts/batches/IOS26-T04C-B01-source-atlas-match-and-pack-selection.md`
30. `IOS26-T04C-B02` - TRAIN_04C / Source Atlas -> Runtime Compiler Bridge - `prompts/batches/IOS26-T04C-B02-capability-graph-to-path-composition.md`
31. `IOS26-T04C-B03` - TRAIN_04C / Source Atlas -> Runtime Compiler Bridge - `prompts/batches/IOS26-T04C-B03-path-to-step-candidate-expansion.md`
32. `IOS26-T04C-B04` - TRAIN_04C / Source Atlas -> Runtime Compiler Bridge - `prompts/batches/IOS26-T04C-B04-runtime-compiler-receipts-replay.md`
33. `IOS26-T04C-B05` - TRAIN_04C / Source Atlas -> Runtime Compiler Bridge - `prompts/batches/IOS26-T04C-B05-source-atlas-coverage-gauntlet.md`
34. `IOS26-T04C-B06` - TRAIN_04C / Source Atlas -> Runtime Compiler Bridge - `prompts/batches/IOS26-T04C-B06-source-atlas-you-inspection-surface.md`
35. `IOS26-T04D-B01` - TRAIN_04D / Capture-to-Runtime Factoring & Future Proof Bridge - `prompts/batches/IOS26-T04D-B01-capture-semantic-extraction.md`
36. `IOS26-T04D-B02` - TRAIN_04D / Capture-to-Runtime Factoring & Future Proof Bridge - `prompts/batches/IOS26-T04D-B02-goal-relevance-scanner.md`
37. `IOS26-T04D-B03` - TRAIN_04D / Capture-to-Runtime Factoring & Future Proof Bridge - `prompts/batches/IOS26-T04D-B03-plan-insertion-approval.md`
38. `IOS26-T04D-B04` - TRAIN_04D / Capture-to-Runtime Factoring & Future Proof Bridge - `prompts/batches/IOS26-T04D-B04-future-proof-context-storage.md`
39. `IOS26-T04D-B05` - TRAIN_04D / Capture-to-Runtime Factoring & Future Proof Bridge - `prompts/batches/IOS26-T04D-B05-receipts-replay-corrections.md`
40. `IOS26-T04D-B06` - TRAIN_04D / Capture-to-Runtime Factoring & Future Proof Bridge - `prompts/batches/IOS26-T04D-B06-capture-runtime-gauntlet.md`
41. `IOS26-T04D-B07` - TRAIN_04D / Capture-to-Runtime Factoring & Future Proof Bridge - `prompts/batches/IOS26-T04D-B07-capture-ui-review-surface.md`
42. `IOS26-T04E-B01` - TRAIN_04E / Core Replacement Contract Harness - `prompts/batches/IOS26-T04E-B01-calendar-p0-contract-harness.md`
43. `IOS26-T04E-B02` - TRAIN_04E / Core Replacement Contract Harness - `prompts/batches/IOS26-T04E-B02-reminders-p0-contract-harness.md`
44. `IOS26-T04E-B03` - TRAIN_04E / Core Replacement Contract Harness - `prompts/batches/IOS26-T04E-B03-todoist-p0-contract-harness.md`
45. `IOS26-T04E-B04` - TRAIN_04E / Core Replacement Contract Harness - `prompts/batches/IOS26-T04E-B04-things-p0-contract-harness.md`
46. `IOS26-T04E-B05` - TRAIN_04E / Core Replacement Contract Harness - `prompts/batches/IOS26-T04E-B05-notion-p0-contract-harness.md`
47. `IOS26-T04E-B06` - TRAIN_04E / Core Replacement Contract Harness - `prompts/batches/IOS26-T04E-B06-cross-app-journey-contract-harness.md`
48. `IOS26-T04E-B07` - TRAIN_04E / Core Replacement Contract Harness - `prompts/batches/IOS26-T04E-B07-contract-closeout-and-downstream-gates.md`
49. `IOS26-T04F-B01` - TRAIN_04F / Time Operations / Calendar Replacement - `prompts/batches/IOS26-T04F-B01-local-schedule-models-and-repositories.md`
50. `IOS26-T04F-B02` - TRAIN_04F / Time Operations / Calendar Replacement - `prompts/batches/IOS26-T04F-B02-eventkit-mirror-and-permission-boundary.md`
51. `IOS26-T04F-B03` - TRAIN_04F / Time Operations / Calendar Replacement - `prompts/batches/IOS26-T04F-B03-recurrence-availability-and-free-time-engine.md`
52. `IOS26-T04F-B04` - TRAIN_04F / Time Operations / Calendar Replacement - `prompts/batches/IOS26-T04F-B04-conflict-pressure-protected-time-engine.md`
53. `IOS26-T04F-B05` - TRAIN_04F / Time Operations / Calendar Replacement - `prompts/batches/IOS26-T04F-B05-schedule-mutation-receipts-and-replay.md`
54. `IOS26-T04F-B06` - TRAIN_04F / Time Operations / Calendar Replacement - `prompts/batches/IOS26-T04F-B06-calendar-replacement-gauntlet.md`
55. `IOS26-T04G-B01` - TRAIN_04G / Reminder Operations / Reminders Replacement - `prompts/batches/IOS26-T04G-B01-reminder-trigger-models-and-repositories.md`
56. `IOS26-T04G-B02` - TRAIN_04G / Reminder Operations / Reminders Replacement - `prompts/batches/IOS26-T04G-B02-local-notification-scheduling-abstraction.md`
57. `IOS26-T04G-B03` - TRAIN_04G / Reminder Operations / Reminders Replacement - `prompts/batches/IOS26-T04G-B03-natural-reminder-capture-parser.md`
58. `IOS26-T04G-B04` - TRAIN_04G / Reminder Operations / Reminders Replacement - `prompts/batches/IOS26-T04G-B04-recurring-reminders-and-followups.md`
59. `IOS26-T04G-B05` - TRAIN_04G / Reminder Operations / Reminders Replacement - `prompts/batches/IOS26-T04G-B05-reminder-closure-recovery-receipts.md`
60. `IOS26-T04G-B06` - TRAIN_04G / Reminder Operations / Reminders Replacement - `prompts/batches/IOS26-T04G-B06-reminders-replacement-gauntlet.md`
61. `IOS26-T04H-B01` - TRAIN_04H / Project Step Operations / Todoist Things Replacement - `prompts/batches/IOS26-T04H-B01-goal-thread-project-commitment-hierarchy.md`
62. `IOS26-T04H-B02` - TRAIN_04H / Project Step Operations / Todoist Things Replacement - `prompts/batches/IOS26-T04H-B02-step-dependencies-deadlines-priority-without-scores.md`
63. `IOS26-T04H-B03` - TRAIN_04H / Project Step Operations / Todoist Things Replacement - `prompts/batches/IOS26-T04H-B03-labels-filters-and-saved-views.md`
64. `IOS26-T04H-B04` - TRAIN_04H / Project Step Operations / Todoist Things Replacement - `prompts/batches/IOS26-T04H-B04-today-upcoming-open-held-view-engine.md`
65. `IOS26-T04H-B05` - TRAIN_04H / Project Step Operations / Todoist Things Replacement - `prompts/batches/IOS26-T04H-B05-bulk-operations-and-low-friction-planning.md`
66. `IOS26-T04H-B06` - TRAIN_04H / Project Step Operations / Todoist Things Replacement - `prompts/batches/IOS26-T04H-B06-project-step-closure-proof-replay.md`
67. `IOS26-T04H-B07` - TRAIN_04H / Project Step Operations / Todoist Things Replacement - `prompts/batches/IOS26-T04H-B07-todoist-things-replacement-gauntlet.md`
68. `IOS26-T04I-B01` - TRAIN_04I / Life Knowledge Operations / Notion Replacement - `prompts/batches/IOS26-T04I-B01-context-entry-collection-template-models.md`
69. `IOS26-T04I-B02` - TRAIN_04I / Life Knowledge Operations / Notion Replacement - `prompts/batches/IOS26-T04I-B02-attachments-links-and-source-records.md`
70. `IOS26-T04I-B03` - TRAIN_04I / Life Knowledge Operations / Notion Replacement - `prompts/batches/IOS26-T04I-B03-relations-backlinks-and-life-knowledge-graph.md`
71. `IOS26-T04I-B04` - TRAIN_04I / Life Knowledge Operations / Notion Replacement - `prompts/batches/IOS26-T04I-B04-local-knowledge-search-and-filters.md`
72. `IOS26-T04I-B05` - TRAIN_04I / Life Knowledge Operations / Notion Replacement - `prompts/batches/IOS26-T04I-B05-knowledge-to-runtime-source-bridge.md`
73. `IOS26-T04I-B06` - TRAIN_04I / Life Knowledge Operations / Notion Replacement - `prompts/batches/IOS26-T04I-B06-notion-replacement-gauntlet.md`
74. `IOS26-T04J-B01` - TRAIN_04J / Unified Capture Search Command and Obviousness - `prompts/batches/IOS26-T04J-B01-universal-quick-capture-router.md`
75. `IOS26-T04J-B02` - TRAIN_04J / Unified Capture Search Command and Obviousness - `prompts/batches/IOS26-T04J-B02-object-action-engine.md`
76. `IOS26-T04J-B03` - TRAIN_04J / Unified Capture Search Command and Obviousness - `prompts/batches/IOS26-T04J-B03-everything-search.md`
77. `IOS26-T04J-B04` - TRAIN_04J / Unified Capture Search Command and Obviousness - `prompts/batches/IOS26-T04J-B04-native-command-surface-without-chat.md`
78. `IOS26-T04J-B05` - TRAIN_04J / Unified Capture Search Command and Obviousness - `prompts/batches/IOS26-T04J-B05-onboarding-empty-states-and-obviousness.md`
79. `IOS26-T04J-B06` - TRAIN_04J / Unified Capture Search Command and Obviousness - `prompts/batches/IOS26-T04J-B06-command-search-obviousness-gauntlet.md`
80. `IOS26-T04K-B01` - TRAIN_04K / Private Life Runtime Integration Over Replacement Foundation - `prompts/batches/IOS26-T04K-B01-foundation-source-adapters.md`
81. `IOS26-T04K-B02` - TRAIN_04K / Private Life Runtime Integration Over Replacement Foundation - `prompts/batches/IOS26-T04K-B02-multi-path-execution-compiler-over-real-life-objects.md`
82. `IOS26-T04K-B03` - TRAIN_04K / Private Life Runtime Integration Over Replacement Foundation - `prompts/batches/IOS26-T04K-B03-accomplishment-proof-adaptation-engine.md`
83. `IOS26-T04K-B04` - TRAIN_04K / Private Life Runtime Integration Over Replacement Foundation - `prompts/batches/IOS26-T04K-B04-personal-operating-model-and-what-ambitions-knows.md`
84. `IOS26-T04K-B05` - TRAIN_04K / Private Life Runtime Integration Over Replacement Foundation - `prompts/batches/IOS26-T04K-B05-start-here-decision-contract-for-t05.md`
85. `IOS26-T04K-B06` - TRAIN_04K / Private Life Runtime Integration Over Replacement Foundation - `prompts/batches/IOS26-T04K-B06-cross-surface-private-life-runtime-gauntlet.md`
86. `IOS26-T04K-B07` - TRAIN_04K / Private Life Runtime Integration Over Replacement Foundation - `prompts/batches/IOS26-T04K-B07-foundation-and-moat-closeout.md`
87. `IOS26-T04L-B01` - TRAIN_04L / Object Frontend Living Chrome Foundation - `prompts/batches/IOS26-T04L-B01-living-chrome-object-purity.md`
88. `IOS26-T05-B01` - TRAIN_05 / Today / Reality Meridian final object - `prompts/batches/IOS26-T05-B01-reality-meridian-recomposition.md`
89. `IOS26-T05-B02` - TRAIN_05 / Today / Reality Meridian final object - `prompts/batches/IOS26-T05-B02-closure-still-counts.md`
90. `IOS26-T05-B03` - TRAIN_05 / Today / Reality Meridian final object - `prompts/batches/IOS26-T05-B03-today-explainability-privacy.md`
91. `IOS26-T06-B01` - TRAIN_06 / Time / LifeShape Field final object - `prompts/batches/IOS26-T06-B01-time-plan-seam-retirement.md`
92. `IOS26-T06-B02` - TRAIN_06 / Time / LifeShape Field final object - `prompts/batches/IOS26-T06-B02-lifeshape-field-surface.md`
93. `IOS26-T06-B03` - TRAIN_06 / Time / LifeShape Field final object - `prompts/batches/IOS26-T06-B03-calendar-reality-provider.md`
94. `IOS26-T07-B01` - TRAIN_07 / Goals / Constellation Atlas final object - `prompts/batches/IOS26-T07-B01-constellation-atlas-root.md`
95. `IOS26-T07-B02` - TRAIN_07 / Goals / Constellation Atlas final object - `prompts/batches/IOS26-T07-B02-goals-language-drift.md`
96. `IOS26-T07-B03` - TRAIN_07 / Goals / Constellation Atlas final object - `prompts/batches/IOS26-T07-B03-goal-relationship-proof.md`
97. `IOS26-T08-B01` - TRAIN_08 / Capture / Atmosphere Composer final object - `prompts/batches/IOS26-T08-B01-atmosphere-composer-dominance.md`
98. `IOS26-T08-B02` - TRAIN_08 / Capture / Atmosphere Composer final object - `prompts/batches/IOS26-T08-B02-capture-placement-receipts.md`
99. `IOS26-T08-B03` - TRAIN_08 / Capture / Atmosphere Composer final object - `prompts/batches/IOS26-T08-B03-external-capture-intake.md`
100. `IOS26-T09-B01` - TRAIN_09 / You / User System Profile behavior-changing settings - `prompts/batches/IOS26-T09-B01-runtime-affecting-profile.md`
101. `IOS26-T09-B02` - TRAIN_09 / You / User System Profile behavior-changing settings - `prompts/batches/IOS26-T09-B02-trust-memory-controls.md`
102. `IOS26-T09-B03` - TRAIN_09 / You / User System Profile behavior-changing settings - `prompts/batches/IOS26-T09-B03-export-delete-accessibility-status.md`
103. `IOS26-T10-B01` - TRAIN_10 / Proof, receipts, closure, recovery, replay - `prompts/batches/IOS26-T10-B01-receipt-lineage-service.md`
104. `IOS26-T10-B02` - TRAIN_10 / Proof, receipts, closure, recovery, replay - `prompts/batches/IOS26-T10-B02-cross-surface-proof-drawer.md`
105. `IOS26-T10-B03` - TRAIN_10 / Proof, receipts, closure, recovery, replay - `prompts/batches/IOS26-T10-B03-recovery-replay.md`
106. `IOS26-T10-B04` - TRAIN_10 / Proof, receipts, closure, recovery, replay - `prompts/batches/IOS26-T10-B04-global-object-purity-sweep.md`
107. `IOS26-T11-B01` - TRAIN_11 / Persistence, migration, export/delete, App Group durability - `prompts/batches/IOS26-T11-B01-versioned-migration-foundation.md`
108. `IOS26-T11-B02` - TRAIN_11 / Persistence, migration, export/delete, App Group durability - `prompts/batches/IOS26-T11-B02-export-delete-reset.md`
109. `IOS26-T11-B03` - TRAIN_11 / Persistence, migration, export/delete, App Group durability - `prompts/batches/IOS26-T11-B03-app-group-atomicity.md`
110. `IOS26-T12-B01` - TRAIN_12 / Widgets, Live Activities, App Intents, share extension - `prompts/batches/IOS26-T12-B01-widget-live-activity-modernization.md`
111. `IOS26-T12-B02` - TRAIN_12 / Widgets, Live Activities, App Intents, share extension - `prompts/batches/IOS26-T12-B02-app-intents-shortcuts-cleanup.md`
112. `IOS26-T12-B03` - TRAIN_12 / Widgets, Live Activities, App Intents, share extension - `prompts/batches/IOS26-T12-B03-share-extension-hardening.md`
113. `IOS26-T13-B01` - TRAIN_13 / Accessibility, Dynamic Type, Reduce Motion, contrast/transparency - `prompts/batches/IOS26-T13-B01-dynamic-type-layouts.md`
114. `IOS26-T13-B02` - TRAIN_13 / Accessibility, Dynamic Type, Reduce Motion, contrast/transparency - `prompts/batches/IOS26-T13-B02-voiceover-traversal.md`
115. `IOS26-T13-B03` - TRAIN_13 / Accessibility, Dynamic Type, Reduce Motion, contrast/transparency - `prompts/batches/IOS26-T13-B03-motion-contrast-transparency-assistive-path.md`
116. `IOS26-T14-B01` - TRAIN_14 / Performance, Instruments, power, launch, scroll, memory - `prompts/batches/IOS26-T14-B01-performance-budgets-scripts.md`
117. `IOS26-T14-B02` - TRAIN_14 / Performance, Instruments, power, launch, scroll, memory - `prompts/batches/IOS26-T14-B02-ui-effect-optimization.md`
118. `IOS26-T14-B03` - TRAIN_14 / Performance, Instruments, power, launch, scroll, memory - `prompts/batches/IOS26-T14-B03-runtime-background-efficiency.md`
119. `IOS26-T15-B01` - TRAIN_15 / Repo hygiene, naming drift, historical quarantine - `prompts/batches/IOS26-T15-B01-active-docs-front-door.md`
120. `IOS26-T15-B02` - TRAIN_15 / Repo hygiene, naming drift, historical quarantine - `prompts/batches/IOS26-T15-B02-historical-quarantine-plan.md`
121. `IOS26-T15-B03` - TRAIN_15 / Repo hygiene, naming drift, historical quarantine - `prompts/batches/IOS26-T15-B03-source-naming-final-sweep.md`
122. `IOS26-T16-B01` - TRAIN_16 / Release proof, App Store readiness, final validation - `prompts/batches/IOS26-T16-B01-full-local-validation-packet.md`
123. `IOS26-T16-B02` - TRAIN_16 / Release proof, App Store readiness, final validation - `prompts/batches/IOS26-T16-B02-privacy-app-store-packet.md`
124. `IOS26-T16-B03` - TRAIN_16 / Release proof, App Store readiness, final validation - `prompts/batches/IOS26-T16-B03-signed-archive-testflight-gate.md`

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
