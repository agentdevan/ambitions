# Return and focus review

The fixture journey uses typed state rather than inferred view position.

- Week → focused Wednesday uses `NavigationStack` and native Back.
- Focused Wednesday → launch brief uses a compact native sheet.
- Dismissing detail returns to the launch brief on the same Wednesday.
- Week → conflict review keeps the proposal identity and accepted participants.
- Keep current and Cancel remove only review depth; accepted Family time and the
  proposal ghost remain unchanged.
- Selecting Thursday updates only the root-local day selection and preserves
  the Week range.

The UI tests prove detail dismissal and Keep current return. Interactive edge
Back, process restoration, and production cross-root transfer are not claimed.
