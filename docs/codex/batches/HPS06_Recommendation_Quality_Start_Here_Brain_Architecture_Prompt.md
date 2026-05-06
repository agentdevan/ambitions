# HPS06 Recommendation Quality Start Here Brain Architecture Prompt
<!-- markdownlint-disable MD013 -->

Status: Complete / Accepted Yellow as docs-domain architecture.
Date: 2026-05-06
Train: HPS01-HPS12 Human Progress Systems Upgrade Train
Owner: Recommendation Kernel / Today

## Purpose

Define recommendation quality and Start Here Brain architecture for future AOS,
LDI, Today, Goals, Plan, Capture, You, proof, source, memory, privacy, and
evaluation work.

HPS06 is docs-domain architecture only. It does not implement recommendation
runtime, candidate ranking, model logic, personalization, persistence, schema,
sync, cloud, AI runtime, UI, or evaluation automation.

## Allowed Files

- HPS06 canon/prompt/report docs
- HPS train status
- global-order, registry, context, dependency, and run-state docs

## Forbidden Files

- Production Swift
- Persistence/schema/migration files
- Recommendation runtime, candidate ranking, or model logic
- Personalization engine
- Sync/cloud/account/backend
- Hosted AI or local model adapter implementation
- Top-level navigation, Today UI, Start Here UI, widget, notification, Live
  Activity, App Intent, or external-surface recommendation behavior
- Health/legal/financial/crisis/professional advice behavior
- Release/App Store/TestFlight/device/accessibility/acquisition claims

## Required Acceptance

- Candidate families exist.
- Candidate evidence fields exist.
- Eligibility and rejection gates exist.
- Explanation contract exists.
- Recovery behavior exists.
- Regression oracle scenarios exist.
- API contract families exist for generation, rejection, explanation, and
  evaluation.
- Start Here projection remains one primary object, not a many-suggestion surface.
- No confidence score, guaranteed outcome, hidden mutation, professional advice,
  runtime recommendation, AI behavior, or release/platform claim is made.

## Validation

Run docs-only validation and targeted CQS scans. Missing HPS physical advisory
scripts remain accepted Yellow under the HPS Codex OS owner until implemented.
