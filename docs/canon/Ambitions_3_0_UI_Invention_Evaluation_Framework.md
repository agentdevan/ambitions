# Ambitions 3.0 — UI Invention Evaluation Framework

Status: Active Ambitions 3.0 invention governance canon  
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Last updated: 2026-04-30

---

## Purpose

Ambitions should invent signature UI where it improves comprehension, trust, execution, recovery, or emotional safety.

Ambitions should not invent UI merely to look novel.

This framework evaluates future Ambitions UI inventions before they become canon or implementation work.

---

## Invention Standard

A new UI invention is worth considering only when it is:

- more understandable than a standard iOS pattern for this specific Ambitions job
- clearly tied to the Golden Launch Loop
- calmer than a dashboard
- more trust-building than a generic card
- accessible without relying on visual novelty
- buildable in SwiftUI without fragile hacks
- explainable in one sentence
- compatible with existing signature objects

---

## Invention Admission Test

A proposed UI invention must answer:

1. What user problem does this solve?
2. Which Golden Launch Loop step does it strengthen?
3. Which surface owns it?
4. Which object owns it?
5. What existing pattern does it replace or improve?
6. Why is a standard iOS pattern insufficient?
7. What is its simplest version?
8. What are its non-goals?
9. How does it preserve trust?
10. How does it remain accessible?
11. What states does it need?
12. What existing Ambitions component might it conflict with?
13. What must it never become?

If these cannot be answered, the invention should not enter canon.

---

## Invention Scorecard

Score each proposed invention from 1-5:

| Dimension | Question |
|---|---|
| Loop strength | Does it make Capture, Place, Plan, Do Today, Close/Recover, or Save Proof stronger? |
| Clarity | Can a user understand it in 3 seconds? |
| Trust | Does it make cause, source, change, correction, or privacy clearer? |
| Restraint | Does it avoid visual noise and dashboard creep? |
| Native fit | Does it still feel iPhone-native? |
| Accessibility | Can it work for VoiceOver, Dynamic Type, Reduce Motion, and non-color state? |
| Buildability | Can it be built in SwiftUI without risky architecture? |
| Distinction | Does it make Ambitions more uniquely Ambitions? |

Minimum score to proceed:

- average 4.0+
- no score below 3 in Trust, Clarity, Accessibility, or Buildability

---

## Invention Classes

### Signature surface object

Examples:

- Ambitions Day Rail
- Ambition Meridian Shell
- Capture Composer
- Month Life Shape

Requires full child doc.

### Micro interaction

Examples:

- receipt peek
- proof saved transition
- closure option reveal
- placement confirmation

Requires state, accessibility, and motion spec.

### Trust pattern

Examples:

- What changed trail
- Why this sheet
- memory source card
- privacy-safe proof summary

Requires Trust / Privacy / Memory alignment.

### Planning visualization

Examples:

- pressure week shape
- protected time bands
- goal path rail
- capacity envelope

Requires Plan/Goal ownership and no fake precision.

---

## Invention Red Flags

Reject or revise if the invention:

- adds a top-level tab
- creates duplicate object ownership
- makes the app feel like a dashboard
- hides ordinary navigation
- prioritizes novelty over comprehension
- introduces AI/model/confidence language
- creates fake urgency
- gamifies recovery
- makes private details more visible
- requires visual interpretation with no accessible equivalent
- breaks native expectations without a clear benefit
- adds motion that reduces clarity
- has no clear SwiftUI implementation path

---

## Required Invention Proposal Format

Use this format before adding a UI invention to canon:

```markdown
# UI Invention Proposal — Name

## One-sentence idea

## User problem solved

## Golden Launch Loop step strengthened

## Owning surface

## Owning object

## Existing pattern improved or replaced

## Why standard iOS is insufficient

## Simplest version

## Signature version

## Non-goals

## Required states

## Trust/privacy implications

## Accessibility requirements

## Motion/haptics requirements

## SwiftUI build notes

## Conflicts to avoid

## Scorecard

## Decision
- accept / revise / reject / defer
```

---

## Invention Backlog Categories

Future invention exploration should organize ideas into:

- Today execution inventions
- Capture placement inventions
- Plan believability inventions
- Goal path/proof inventions
- Trust/memory/control inventions
- Shell/navigation inventions
- Review/reflection inventions
- Accessibility/cognitive-load inventions
- App Store/demo inventions

---

## Current Protected Inventions

These are already protected by Ambitions 3.0 canon:

- Ambitions Day Rail
- Ambition Meridian Shell
- Capture Composer
- Placement Resolver
- Action Closure Sheet
- Proof / Receipts / Reviews distinction
- Month / Life Shape
- Personal System Center

Future inventions must strengthen or complement these, not compete with them.

---

## Acceptance Criteria

This framework is satisfied when future UI inventions are:

- evaluated before implementation
- mapped to the Golden Launch Loop
- checked against signature objects
- checked for trust/privacy/accessibility
- kept deep, not wide
- converted into child docs only when they pass the admission test
