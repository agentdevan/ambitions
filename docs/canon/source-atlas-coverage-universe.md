# Source Atlas Coverage Universe

> Supporting note: This file supports current Ambitions work but does not override `docs/truth/`.

Status: Active supporting Source Atlas coverage concept  
Scope: Deterministic coverage generation for Source Atlas scenarios, candidate source packs, fixtures, and reports  
Proof boundary: This document is not implementation proof, runtime proof, release proof, or source-pack approval.

## Definition

Source Atlas Coverage Universe is a deterministic coverage system that expands Ambitions' source-pack space across product objects, life domains, intent shapes, user contexts, time realities, constraints, evidence quality, closure states, recovery paths, privacy boundaries, freshness risks, recommendation failure modes, and runtime proof needs.

Coverage is the goal. Volume is only useful when it improves coverage, exposes high-risk gaps, and promotes a small number of validated, non-duplicate fixtures or source-pack candidates.

## Core Object Types

1. `CoverageDimension`: A named axis of coverage such as product object, life domain, time reality, privacy sensitivity, or runtime proof need.
2. `CoverageAxisValue`: A valid value inside a dimension.
3. `CoverageRecipe`: A deterministic expansion rule that selects dimensions, pairwise/3-wise axes, high-risk values, and promotion intent.
4. `CoverageCell`: One combination of dimension values to test or inspect.
5. `ScenarioSpec`: A generated testable situation with Ambitions-specific expectations.
6. `CandidateSourcePack`: A derivative source-context candidate created from one or more ScenarioSpecs.
7. `CandidateScore`: A local quality score and rejection/quarantine/promotion classification.
8. `PromotionReceipt`: Evidence that a candidate was validated and promoted into a deterministic fixture input.
9. `RuntimeFixture`: A deterministic proof input that can later feed source/runtime tests.
10. `CoverageHeatmap`: A machine-readable report of Green, Yellow, Red, and Gray coverage by dimension.
11. `GapReport`: A human-readable report of highest-risk uncovered or weak areas.

## Critical Boundary

- ScenarioSpec = generated testable situation.
- CandidateSourcePack = derivative source-context candidate.
- RuntimeFixture = deterministic proof input.
- PromotionReceipt = evidence that a candidate was validated/promoted.
- Source pack = context substrate.
- Proof = test/log/replay/validation evidence.
- Canon = product truth.
- Private Life Runtime = deterministic local execution layer.

Generated ScenarioSpecs and CandidateSourcePacks are never canon. They cannot satisfy proof alone. Green status still requires deterministic repo proof such as tests, logs, receipts, replay artifacts, validation output, screenshots where relevant, and local-only/privacy checks.

## Local-First Boundary

Coverage Universe tooling is local-only. It must not require Gemini, OpenAI API, Claude API, API keys, paid external APIs, app runtime network behavior, hosted inference, or a cloud runtime dependency.

ChatGPT may be used manually outside the repo to draft ScenarioSpec JSON. The repo must validate pasted ScenarioSpecs deterministically before candidate generation, scoring, promotion, or reporting.

## Active IA And Language

Coverage artifacts must preserve:

`Today / Goals / Capture / Time / You`

Canonical language:

- Start here
- Recommended step
- Start now
- Open step
- Step

Coverage artifacts must avoid top-level Plan, habit surface language, profile-as-top-level language, generic task-manager language, generic AI dashboard language, chatbot-first language, and cloud-runtime dependency language.

## Promotion Policy

Promotion is intentionally narrow:

- 85+ score: may be promoted to fixture/source-pack candidate.
- 70-84: accepted but not promoted.
- 50-69: quarantined for review.
- Under 50: rejected.

Promotion must create a receipt, source manifest, input hash, scenario links, candidate score, validation output, reason for promotion, and expected test behavior.

Promotion must not make a generated pack canon, make a generated pack proof, bypass runtime tests, bypass validation, or create an app runtime dependency.
