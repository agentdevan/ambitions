# Global Batch Optimal Order Review

<!-- markdownlint-disable MD013 -->

Status: Active order review for Ambitions 4.0 plus External Brain expansion.
Date: 2026-05-03

## Classification

Hard dependencies: EB01 before all EB work; EB13 before durable memory; EB25 before UI-heavy EB batches; EB19 before onboarding implementation; EB02 before capture implementation; EB07 after EB13 and before memory implementation; EB31/EB32 after kernel canon; EB38 before EB39/EB40.

Soft dependencies: onboarding before advanced memory exposure; capture receipts before promotion; scenario/risk library before QA closeout; release-claim review after proof.

Unsafe ordering: naive EB02-EB12 memory/capture order before Trust and Accessibility gates.

Redundant ordering: repeated canon scaffolding after integration; EB01 must reconcile, not recreate.

Privacy-before-memory gates: EB13 precedes EB07-EB12 and EB33.

Accessibility-before-UI gates: EB25 precedes EB20-EB30 and UI-heavy EB03-EB06/EB14-EB18.

Trust-before-recommendation gates: EB15 before recommendation exposure.

Onboarding-before-advanced-memory gates: EB19-EB24 precede EB08-EB12 exposure where user comprehension matters.

Capture-before-memory-ingestion gates: EB02-EB06 precede automatic capture-to-memory promotion.

Release-claim-after-proof gates: EB39/EB40 trail QA, privacy, accessibility, and claim scans.

## Optimized EB Order

1. EB01 External Brain Source Truth And Kernel Architecture - Establishes source truth and verifies existing scaffold instead of creating duplicate canon.
2. EB13 Trust Privacy User Control Canon - Trust, privacy, user control, export/delete, correction, and receipt boundaries must precede durable memory.
3. EB25 Accessibility Cognitive Load Canon - Accessibility and cognitive-load rules must precede UI-heavy EB work.
4. EB19 Product Maturity Onboarding Canon - Onboarding maturity gates must precede setup and advanced memory exposure.
5. EB02 Universal Capture Canon And Domain Model - Capture canon must precede capture implementation.
6. EB07 Life Memory Graph Canon And Domain Model - Life Memory canon waits for Trust canon and precedes memory implementation.
7. EB31 Cross Kernel Primitives And Event Receipts - Cross-kernel primitives need core kernel canon before integration.
8. EB32 Cross Kernel Dependency And Gate Integration - Dependency gates follow primitive map before implementation-heavy lanes.
9. EB20 Value Based Onboarding And First Week Success - Value-first onboarding follows onboarding canon and precedes sensitive setup.
10. EB21 Concierge Setup And Planning Defaults Onboarding - Planning defaults follow value-first onboarding.
11. EB22 Privacy Setup And Trust Onboarding - Privacy setup follows Trust and onboarding canon.
12. EB23 Maturity Levels Progressive Disclosure And Life Season Templates - Progressive disclosure follows maturity canon.
13. EB24 Onboarding Receipts Skip Later And Setup Recovery - Onboarding receipts close the onboarding lane.
14. EB03 Universal Capture Composer And Routing - Capture implementation follows Universal Capture, Trust, Accessibility, and gate integration.
15. EB04 Capture Classification And Clarification - Classification follows composer/routing.
16. EB05 Capture Clusters Review Bundles And Open Loops - Clusters follow classification.
17. EB06 Capture Receipts Undo And Reclassification - Capture receipts close capture before promotion.
18. EB14 Trust Center And Data Map - Trust Center follows Trust canon and precedes correction/deletion UI.
19. EB15 Recommendation Evidence And Inference Boundaries - Evidence precedes recommendations.
20. EB16 Private Mode And Sensitive Area Controls - Private mode follows Trust Center/data map.
21. EB17 Undo Correction Audit Trail And Export - Correction/export follows data controls.
22. EB18 Source Freshness Privacy Receipts And Non Claims - Privacy receipts close Trust lane and protect claims.
23. EB26 Cognitive Load Modes And Interface Density - Cognitive modes follow accessibility canon.
24. EB27 Dynamic Type VoiceOver And Reduce Motion - Core accessibility evidence follows modes.
25. EB28 Plain Language Anxiety Safe Copy And Explain This Screen - Plain-language support follows accessibility evidence.
26. EB29 Voice First Operation And Motor Accessibility - Voice/motor operations follow accessibility gate.
27. EB30 Overloaded Day Adaptation And Low Cognitive Load Flows - Overloaded-day adaptation closes accessibility lane.
28. EB08 Memory Source Confidence And Trust Decay - Memory implementation begins only after Trust, Life Memory, and Accessibility gates.
29. EB09 Life Event Decision And Context Recall Memory - Context memory follows source/confidence.
30. EB10 Personal Operating Manual - Personal operating manual follows source-backed memory.
31. EB11 Memory Correction Deletion And Rejection - Memory correction/deletion follows Trust Center controls.
32. EB12 Memory Receipts And Why Remembered This - Memory receipts close memory lane.
33. EB33 External Brain Search And Context Recall - Search follows memory and receipts.
34. EB34 External Brain Command Surface Integration - Command surface follows search/context and capture/trust gates.
35. EB35 External Brain Preview Fixtures And Scenario Library - Scenario library precedes QA closeout.
36. EB36 External Brain QA Regression And Risk Register - Risk register follows scenarios and precedes closeout proof.
37. EB37 External Brain Privacy Threat Model - Threat model follows implementation evidence and precedes handoff.
38. EB38 External Brain Accessibility Evidence Closeout - Accessibility evidence precedes handoff/closeout.
39. EB39 External Brain Handoff And RC Readiness Implications - Handoff trails privacy, accessibility, QA, and claim scans.
40. EB40 Ambitions 4.0 External Brain Closeout - Closeout requires EB01-EB39 Green or accepted Yellow.
