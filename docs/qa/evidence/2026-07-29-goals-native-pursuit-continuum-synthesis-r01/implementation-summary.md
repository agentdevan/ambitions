# Implementation summary

## Native hierarchy

The prototype uses one typed `NavigationStack` path:

```text
Goals root
→ Life Area detail
→ focused Goal
→ Goal-owned relationship or Goal Path inspection
```

The root contains only Life Area identity and area-level truth. `Home` owns the
three fixture Goals. `Welcome our baby home` is the only Goal with bounded
supporting depth in this synthesis fixture. Unsupported peer Goal navigation is
not fabricated.

## Persistent Goal anatomy

Home and focused depth share a local Goal seam carrying:

- stable Goal identity;
- Home ownership;
- current accepted truth;
- Proof provenance;
- current movement;
- open future posture.

Focused depth increases resolution without replacing the object with a document
or a generic card. Proof expands from accepted truth. Current movement is the
native entry into Goal Path. Future and relationship inspection are progressive
disclosures rather than root-level expansion.

## State and restoration

The fixture journey keeps one explicit typed path and validates every stable
identity before navigation. Native Back and interactive Back reconcile state to
the visible depth. Returning from focused Goal restores the selected Home Goal;
returning from Home restores the Home Life Area at the strict root.

All inspection remains local, synthetic, and non-mutating.

## Visual scope

The implementation uses system typography, matte dynamic planes, restrained
semantic seams, SF Symbols, native disclosure, and functional shell chrome.
The grammar is journey-local and provisional. No global tokens, reusable
production component APIs, runtime adapter, or app-entry change was introduced.
