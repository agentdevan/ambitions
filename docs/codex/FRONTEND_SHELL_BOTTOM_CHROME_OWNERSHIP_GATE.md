# Frontend Shell Bottom Chrome Ownership Gate

<!-- markdownlint-disable MD013 -->

Status: Active FET gate
Date: 2026-05-09
Batch: FET04

## Purpose

Ambitions must have one coherent bottom navigation owner. Native tab chrome, a custom Meridian rail, floating global add, toolbar controls, receipt trays, and header actions cannot compete for the same visual job.

## Gate Rules

- Native `TabView` chrome and custom Meridian rail cannot both read as active product navigation.
- Floating global plus cannot conflict with tab navigation, receipt overlay, keyboard/composer, or home indicator.
- Header, search, avatar, and repeated toolbar controls must be justified by the surface.
- Bottom chrome must have a single named owner.
- Global add must be contextual, deeply integrated, or explicitly suppressed when it competes with the active surface.
- Chrome screenshots must prove no overlap, no buried tab, no ambiguous selected state, and no inaccessible bottom controls.

## Required Scan Targets

- `Native/Ambitions/App/AmbitionsRootView.swift`
- app shell/scaffold/chrome files
- tab, nav, Meridian, floating plus, receipt overlay, safe-area, and toolbar usages

## Red

Competing nav systems, visually active double chrome, floating plus over tab/chrome/composer, repeated top controls without purpose, or missing screenshot evidence for shell/chrome changes.
