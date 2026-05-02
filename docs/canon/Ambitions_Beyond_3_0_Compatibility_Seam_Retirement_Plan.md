# Ambitions Beyond 3.0 Compatibility Seam Retirement Plan

<!-- markdownlint-disable MD013 -->

Status: Future planning with CS01 registry evidence; no seam retired

## Current Evidence

- CS01 Compatibility Seam Registry And Risk Map is complete as audit-only evidence.
- CS01 report: `docs/audits/cs01-compatibility-seam-registry-and-risk-map-report.md`.
- No route, raw value, widget payload, App Intent payload, import/export payload, persistence/schema value, accessibility identifier, visible copy, test expectation, or Swift implementation was changed by CS01.

## Candidate Seams

- Profile internal naming behind the You surface
- Insights route/model compatibility for contextual intelligence
- Habits route/model compatibility for Ritual/Plan continuity
- activeFocus, TodayFocus*, and .focus Today compatibility
- internal .failed taxonomy where visible language already stays humane
- Adjacent Capture/Captures and capturesInbox compatibility where repo evidence shows share-extension, route, or import/export risk.

## CS01 Risk Map

| Seam | Risk | Compatibility surfaces | Required future owner |
| --- | --- | --- | --- |
| Profile internal naming behind You | High | App tab routes, widget family identifiers, screen contracts, tests, visible copy leak checks | CS02 with CS07/CS08 proof where relevant |
| Insights contextual intelligence compatibility | High | Routes, shell/screen contracts, tests, legacy deep-link assumptions | CS03 after CS07/CS08 as relevant |
| Habits/Ritual/Plan compatibility | High | Routes, old data payloads, import/export, persistence, tests | CS04 with CS08 proof |
| activeFocus/TodayFocus/.focus | Very High | App Intent routing, widgets, external snapshots, route aliases, tests, visible copy leak checks | CS05 with CS07 proof |
| Internal .failed taxonomy | Medium-High | User-visible copy, accessibility labels, tests, logs, failure-state routing | CS06 |
| Capture/Captures/capturesInbox adjacent seam | High | Share extension, route targets, imports/exports, visible copy, tests | CS07/CS08 or named future CS repair owner |

## Retirement Conditions

Each seam needs replacement map, migration impact review, route impact review, schema/persistence impact review, widget impact review, App Intent/Shortcut impact review, import/export impact review, preview fixture impact review, focused tests, rollback path, and release-claim review.

## Stop Conditions

Route/deep link uncertainty, widget payload uncertainty, App Intent raw value uncertainty, import/export uncertainty, persistence/schema uncertainty, accessibility identifier mismatch, UI test failures not classified, public copy regression, or release claim ambiguity.
