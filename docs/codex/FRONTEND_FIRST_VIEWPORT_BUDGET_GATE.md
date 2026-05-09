# Frontend First Viewport Budget Gate

<!-- markdownlint-disable MD013 -->

Status: Active FET gate
Date: 2026-05-09
Batch: FET03

## Purpose

The first viewport decides whether Ambitions feels like a composed native product or an inventory of panels. This gate prevents top-level screens from passing because every canonical concept is present while nothing has priority.

## Hard Budget

For top-level surfaces and landing-detail first screens:

- max 1 primary object
- max 2 support objects
- max 4 chips
- max 12 body-copy lines
- max 1 floating control
- max 1 bottom navigation system
- no nested card-on-card inside the primary object
- no architecture, governance, implementation, local-first, source-system, or diagnostic copy above the fold

## Green

Screenshot or preview evidence proves one primary object, bounded support, compressed copy, no generic panel stack, and a clear next action.

## Yellow

Minor density debt exists with screenshot evidence, no hard Red, and named owner.

## Red

More than one primary object, more than two support objects, more than four chips, more than twelve body-copy lines, architecture copy above fold, nested primary-card stacking, or no visual evidence for UI-touching work.

## Required Report Fields

- primary object
- support object count
- chip count
- body-copy line count
- floating control count
- bottom navigation owner
- screenshot/preview path
- Red repair decision
