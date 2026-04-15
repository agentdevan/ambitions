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

## Classification Hints

- if it touches planner, persistence, routing, or container wiring, treat it as domain-sensitive
- if it touches `project.yml`, plist, entitlements, or extension targets, treat it as extension/config work
- if the main risk is stale claims, treat it as docs truth cleanup

## Preferred Profile Mapping

- `small-edit` -> `small-edit`
- `feature-build` -> `feature-build`
- `domain-sensitive-change` -> `domain-safe`
- `extension-config-work` -> `domain-safe` or `release-check` near merge
- `docs-truth-cleanup` -> `small-edit` for narrow cleanup, otherwise `feature-build`
- `release-hardening` -> `release-check`
