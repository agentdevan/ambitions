# Ambitions 4 External Brain Dedupe And Merge Map

<!-- markdownlint-disable MD013 -->

Status: PASS WITH YELLOW; safe-reference dedupe map for active Ambitions 4.0 External Brain integration.

| Existing file path | Overlap | Decision | Reason | Owner kernel | Risk | Required validation | Active source truth | Historical/audit truth | New file allowed |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| docs/canon/PXOS_Capture_Experience_Canon.md | Universal Capture | reference | PXOS owns Capture expression; EB adds kernel/source-truth and later implementation gates. | Universal Capture | Medium | EB dedupe scan plus prompt owner check | yes | no | yes |
| docs/canon/TRUST_PRIVACY_MEMORY.md | Trust and memory controls | reference | Older trust/privacy/memory canon remains supporting where not superseded; do not overwrite. | Trust, Privacy, And User Control | High | privacy boundary scan | supporting | no | yes |
| docs/canon/PXOS_Trust_Proof_Receipts_Canon.md | Trust receipts | reference | PXOS owns user-facing trust/proof expression; EB adds external-brain control gates. | Trust, Privacy, And User Control | High | release-claim and privacy scans | yes | no | yes |
| docs/canon/PXOS_Onboarding_Setup_And_Personalization.md | Onboarding/setup | reference | PXOS owns setup expression; EB adds first-week maturity kernel. | Product Maturity And Onboarding | Medium | dedupe and onboarding gates | yes | no | yes |
| docs/canon/PXOS_Accessibility_Cognitive_Load_And_Emotional_Safety.md | Accessibility/cognitive load | reference | PXOS accessibility canon remains active; EB adds kernel train gates. | Accessibility And Cognitive Load | High | accessibility cognitive-load scan | yes | no | yes |
| docs/canon/AmbitionsOS_Life_Graph_Kernel.md | Life graph internals | reference | AmbitionsOS owns internal architecture; EB owns user-controlled memory product boundary. | Life Memory Graph | Very High | memory claim scan | yes | no | yes |
| docs/canon/Ambitions_3_0_Primitive_Architecture.md | Capture, trust, accessibility primitives | do not touch | 3.0 baseline source truth remains locked. | All kernels | High | source-truth scan | yes | no | yes |
| docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md | Global active order | update | Canonical order owner must register EB01-EB40 active expansion. | All kernels | Medium | active train integration gate | yes | no | no |
| docs/codex/BATCH_REGISTRY.md | Status truth | update | Registry owns status and active planned counts. | All kernels | Medium | status and count scan | yes | no | no |
| docs/audits/** | Historical audit truth | do not touch | Audit history must not be overwritten. New EB audit files are allowed. | All kernels | High | changed-file boundary review | no | yes | yes |

Yellow advisory: some older files contain external brain source material, but active EB canon is added as Ambitions 4.0 scope without overwriting historical truth.
