# Ambitions 3.0 — Object Ownership And Appearance Matrix

Status: Active Ambitions 3.0 front-end canon contract  
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Last updated: 2026-04-30

---

## Purpose

This matrix prevents duplicate homes, dashboard creep, and cross-surface confusion.

Ambitions can show the same object in multiple places, but every object must have one clear primary owner. Contextual appearance is allowed only when primary ownership remains obvious.

---

## Ownership Principle

```text
One primary home. Many contextual appearances. No duplicate ownership.
```

A contextual appearance is not a new home.

---

## Matrix

| Object | Primary owner | Can appear in | Cannot appear as |
|---|---|---|---|
| Capture | Capture | Today quick capture, Step Session note, Plan add flow | permanent inbox |
| Needs a Place item | Capture / Place | You review, weekly cleanup | overdue inbox item |
| Task / One-Step Goal | Today / Capture | Plan, Goal Detail, Reviews | top-level Tasks tab |
| Step | Goal Detail / Today / Plan | Step Detail, Step Session, Reviews | rootless to-do |
| Recommended Step | Today Day Rail | Plan preview, Goal Detail next step | dashboard of recommendations |
| Step Session | Today / Step Detail | Goal Detail, Plan | Focus mode tab |
| Goal | Goals | Today, Plan, Reviews, You | project board card pile |
| Life Area | Goals / You | Capture routing, Reviews | top-level Life Areas tab |
| North Star / Ambition | Goals | You, Reviews, Goal Detail | mandatory onboarding category |
| Path | Goal Detail | Plan, Reviews | top-level Path tab |
| Milestone | Goal Detail | Plan, Reviews | calendar event by default |
| Plan item | Plan | Today, Reviews | generic calendar event unless user confirms |
| Schedule / Availability | You Planning Setup / Plan | Today context, Plan scopes | onboarding permission wall |
| Vacation / Away Time | You Planning Setup / Plan | Today protected state, Plan Life Shape | free time by default |
| Closure | Action Closure | Today, Goal Detail, Reviews, Trust | failure state |
| Proof | Goal Detail / Reviews | Today, You, Trust | streak token |
| Receipt | Trust Layer / You | Capture, Today, Plan, Goal Detail | disposable toast only |
| Memory | You -> What Ambitions Knows | Trust Center, Reviews | hidden profile |
| Review | You -> Reviews | Today, Plan, Goal Detail | analytics dashboard |
| Automation level | You -> Automation & Trust | Plan, Trust Center | AI command mode |
| Appearance preference | You -> Appearance Studio | onboarding preview only when needed | theme gimmick |

---

## Contextual Appearance Rules

A contextual appearance is allowed only if it:

1. Preserves the object's primary owner.
2. Shows why the object is appearing here.
3. Provides a route to the primary owner when deeper management is needed.
4. Avoids duplicating the same controls in multiple places.
5. Does not turn the current surface into a dashboard.

---

## Surface Ownership Rules

### Today

Owns current execution through `AmbitionsDayRailView`.

Today may show goals, plan items, closure, proof, and receipts only when they affect what matters now.

Today must not become:

- task dump
- calendar clone
- analytics surface
- motivation wall
- dashboard stack

### Goals

Owns direction, goal state, paths, milestones, proof, risks, decisions, and archive.

Goals must not become:

- project-management board
- KPI dashboard
- task database

### Capture

Owns raw intake and placement suggestion.

Capture must not become:

- chat UI
- notes app
- permanent inbox
- triage dashboard before input

### Plan

Owns whether time, commitments, availability, and recovery hold together.

Plan must not become:

- raw calendar clone
- due-date list
- fantasy schedule generator
- silent rescheduler

### You

Owns setup, trust, memory, reviews, data controls, personalization, and support.

You must not become:

- social profile
- junk drawer
- analytics dashboard
- primary execution UI

---

## Duplicate Ownership Red Flags

Stop and revise if:

- the same object can be edited in two unrelated surfaces with different rules
- a contextual card becomes a full management interface
- a top-level screen gains a secondary dashboard
- receipts appear only as toasts and not later in history
- a Step appears without a Goal/Plan/Task relationship
- a Capture item can remain unresolved without a visible state
- a Memory can shape recommendations without being inspectable

---

## Acceptance Criteria

This matrix is satisfied when:

- every object has a primary owner
- contextual surfaces explain why an object appears there
- deep management routes to the owner surface
- no new top-level tabs are introduced
- Today, Goals, Capture, Plan, and You keep distinct jobs
- implementation summaries call out any intentional temporary compatibility violations
