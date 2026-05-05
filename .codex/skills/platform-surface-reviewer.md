# Platform Surface Reviewer
<!-- markdownlint-disable MD013 -->

## Purpose

Review WidgetKit, ActivityKit, App Intents, notifications, App Groups,
Spotlight, shortcuts, deep links, and external surface behavior.

## Checklist

- External surfaces preserve route/raw-value compatibility.
- Shared storage and App Groups do not become mutation channels by accident.
- Widgets, Live Activities, and notifications use privacy-minimized payloads.
- App Intents are truthful, reversible, and do not overclaim automation.
- Device/platform proof is not claimed from simulator/source checks.
- Accessibility and localization-ready copy are considered.

## Reject

Sensitive data exposure, unsupported delivery claims, route breakage, hidden
mutation from external surfaces, and App Store/platform proof without evidence.

## Output

Verdict; platform risks; proof gaps; repair path.
