# Ambitions Truth Files

Status: Active repo authority index  
Scope: Product/design, moat, implementation, release/proof, Codex process, shell integration, and repo retention  
Applies to: Humans, Codex, and implementation agents working in the Ambitions repo

`docs/truth/` is the active authority layer for Ambitions. Start here before reading supporting docs, source-adjacent notes, retained skills, scripts, or historical references.

## Mandatory Read Order

1. `PRODUCT_DESIGN_TRUTH.md` - product/design authority.
2. `PRODUCT_MOAT_TRUTH.md` - moat strategy and anti-commodity guardrails.
3. `PRODUCT_EXPERIENCE_CANON.md` - product-experience behavior, feature behavior, scenario gates, and actionability authority.
4. `IMPLEMENTATION_TRUTH.md` - implementation/source authority.
5. `IMPLEMENTATION_ACCEPTANCE_TRUTH.md` - rendered-product acceptance, split status, visual proof, and global shell acceptance authority.
6. `RELEASE_TRUTH.md` - validation, proof, release, and claim authority.
7. `CODEX_PROCESS_TRUTH.md` - Codex operating authority.
8. `HISTORICAL_POLICY.md` - repo retention and stale-file deletion authority.
9. `AGENTS.md`.
10. `README.md`.
11. `docs/README.md`.
12. `project.yml`.
13. `Package.swift`.
14. Relevant source, tests, retained scripts, build docs, and current local logs.
15. Relevant retained `.agents/skills/*/SKILL.md` files only after truth files.

## Active Product Law

```text
Persistent surfaces: Today / Goals / Time / You
Global composer: Capture
Behavior layer: Motion
Trust layer: Proof / Source / Privacy / History / Receipts
```

Motion is behavior, not a root destination. Capture is global composition, not a tab.

## Global Shell Integration Law

The Ambitions shell is a product layer, not a border around the product.

The Context Crown, search, Capture access, route controls, continuity dock, overlays, and surface actions must be functional, modern, and seamlessly integrated into the active surface. Shell chrome may guide, anchor, and act, but it must never appear pasted on, visually boxed off, or detached from the object stage.

Full-bleed means atmosphere bleeds, content remains safe, chrome integrates, and object hierarchy stays clear.

This law applies globally to Today, Goals, Time, You, Capture, Search, Closure, Inspection, and major drilldowns. It is enforced through `IMPLEMENTATION_ACCEPTANCE_TRUTH.md`, manifest evidence, reviewable screenshots, and independent visual acceptance.

## Product Experience Canon

`PRODUCT_EXPERIENCE_CANON.md` exists to bridge product identity, moat strategy, runtime behavior, user-facing feature behavior, QA scenario gates, and future implementation direction. It makes Life Capital, full scheduled goal paths, Future Steps, continuous adjustment, proof/progress transfer, Source Atlas composition, onboarding, reviews, notifications, automation, and actionability testable without claiming the current app has already implemented them.

## Conflict Resolution

| Conflict Type | Winner |
|---|---|
| Product/design direction | `PRODUCT_DESIGN_TRUTH.md` |
| Moat strategy and anti-commodity claims | `PRODUCT_MOAT_TRUTH.md` |
| Product-experience behavior, feature behavior, Life Capital, full goal pathing, Future Steps, continuous adjustment, reviews, onboarding, proof/progress transfer, and actionability | `PRODUCT_EXPERIENCE_CANON.md`, subordinate to `PRODUCT_DESIGN_TRUTH.md` for root IA/privacy/product identity and `PRODUCT_MOAT_TRUTH.md` for moat/anti-commodity guardrails |
| Implementation/source status | Live source/project/test/script evidence, read through `IMPLEMENTATION_TRUTH.md` |
| Global shell integration and rendered product acceptance | `IMPLEMENTATION_ACCEPTANCE_TRUTH.md` plus current reviewable screenshots, manifest evidence, and target rubric |
| Release/readiness/proof claim | Current proof/log evidence, read through `RELEASE_TRUTH.md` |
| Codex process behavior | `CODEX_PROCESS_TRUTH.md` |
| Historical/old-canon conflict | Active truth files and `HISTORICAL_POLICY.md` retention rules |
| README/docs index conflict | Active truth files |
| Skill/script/support-material conflict | Active truth files |

## Retained Supporting Material

Retained non-source material is intentionally small:

- `docs/README.md`
- `docs/native-build-and-release.md`
- root `AGENTS.md`
- root `README.md`
- retained build, validation, privacy, claim, copy, and canon-drift scripts
- at most three repo skills under `.agents/skills/`

Generated Codex state, old artifacts, prompts, trains, stale batch docs, backup truth files, and historical proof matrices are not retained in-repo.

## What Truth Files Do Not Prove

Truth files define authority and standards. They do not by themselves prove implementation completeness, local build success, test success, visual quality, accessibility conformance, performance validation, physical-device validation, TestFlight/App Store readiness, or release approval.

Those claims require current evidence through `RELEASE_TRUTH.md`.
