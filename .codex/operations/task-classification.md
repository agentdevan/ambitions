# Task Classification

## Core Task Classes

- `small-edit`: one-file or low-risk maintenance
- `feature-build`: standard multi-file implementation within existing seams
- `domain-sensitive-change`: planner, Today, persistence, routing, or container-sensitive work
- `extension-config-work`: target wiring, plist, entitlements, widgets, Live Activities, Share extensions, App Intents
- `docs-truth-cleanup`: repo truth reconciliation across docs, previews, or copy
- `release-hardening`: merge-readiness, config truth, validation, and shipped-state checks
- `exploratory-planning`: plan without code changes
- `blocked-investigation`: determine what is safe, missing, or environment-blocked

## Front-End Transformation Archetypes

Use these to choose validation scope and closeout expectations:

- `docs-control`: control files, canon truth, execution doctrine, status reconciliation
- `shared-system`: design system, motion primitives, reusable controls, shell-wide foundations
- `surface-rebuild`: Today, Goals, Goal intake, Goal Detail, Plan, Insights, Profile, onboarding surfaces
- `shell-external`: command surfaces, overlays, App Intents, widgets, Live Activities, notifications, routing-heavy seams
- `coherence-pass`: cross-surface command, recall, ambient, or handoff consistency work
- `multi-device`: iPad, Mac, Watch, Apple TV architecture and first implementations
- `finish-quality`: accessibility, performance, release polish, final stabilization

## Classification Hints

- if it touches planner, persistence, routing, or container wiring, treat it as domain-sensitive
- if it touches `project.yml`, plist, entitlements, or extension targets, treat it as extension/config work
- if the main risk is stale claims, treat it as docs truth cleanup
- if the work is an active post-hardening transformation batch, assign one transformation archetype before choosing validation

## Preferred Profile Mapping

- `small-edit` -> `small-edit`
- `feature-build` -> `feature-build`
- `domain-sensitive-change` -> `domain-safe`
- `extension-config-work` -> `domain-safe` or `release-check` near merge
- `docs-truth-cleanup` -> `small-edit` for narrow cleanup, otherwise `feature-build`
- `release-hardening` -> `release-check`

## Execution Consequences

- `docs-control` should almost never trigger full UI validation
- `shared-system` should prove reusable primitives plus targeted downstream checks before broader UI reruns
- `surface-rebuild` should default to focused proof + manual signoff instead of immediate full-suite UI churn
- `shell-external` is the most likely archetype to require broader routing proof
- `finish-quality` may justify the broadest validation, but still use the fixed regression pack first
