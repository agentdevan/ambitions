# SI File Size Component Boundary Reviewer
<!-- markdownlint-disable MD013 -->

## Purpose

Prevent Signature Interface work from creating new giant visual owner files,
vague utilities, or unreviewable component diffs.

## When It Applies

Use for every SI implementation batch and any PD/AOS24 UI batch composing SI
primitives.

## Source-Truth Hierarchy

User prompt, `AGENTS.md`, ME standards, ME10 architecture gate, SI canon,
current SwiftUI file sizes, and batch prompt budgets.

## Review Inputs

Before/after line counts, changed Swift files, new component names, preview
files, tests, diff size, and responsibility map.

## Review Checklist

- Each file has a clear owner responsibility.
- View files do not accumulate domain logic.
- New primitives are split before crossing review thresholds.
- No vague `Utilities`, `CardView`, or all-purpose component bucket.
- File-size increase has owner and validation.

## Green / Yellow / Red Criteria

- Green: sizes are stable/improved or justified, files are focused, and diff is
  reviewable.
- Yellow: modest growth has named owner and near-term extraction path.
- Red: large-file regression, broad one-off component, logic in view file,
  unreviewable diff, or file-size snapshot missing for code work.

## Forbidden Approvals

Do not approve giant UI owner files, style-only wrappers, broad cleanup mixed
with feature work, or missing file-size evidence.

## Required Evidence

Before/after line counts, ownership map, diff-size category, validation lane,
and rollback path.

## Repair Guidance

Split components, move projection logic out of views, reduce scope, or stop on
Red if maintainability is worsened.

## Claims

May claim file-size/component-boundary review for current scope. Must not claim
ME extraction complete unless an ME batch proves it.
