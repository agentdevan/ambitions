# Object Boundary Matrix

> Generated, non-normative projection of the active canon.

- Schema version: `1`
- Canon revision: `1`
- Authority state: `active`
- Compiler version: `0.2.0`
- Canon content SHA: `4567bff1ab6c758559ca1ffb528984c514c1b20f3ddfbcad78f3c0e4aef20c1c`

- Representation status: `materialized`
- Scope: validated spec-owned semantic boundaries; not implementation proof

| Capability | Step | Event | Reminder | Note |
|---|---|---|---|---|
| Executable / completable | Yes | No | No, unless linked to Step | No |
| Occupies duration | Optional | Required for timed event | No | No |
| Consumes capacity | When scheduled | Yes according to blocking state | No | No |
| Due date | Yes | End time is not a due date | Optional reminder date | No until promoted |
| Recurrence | Repeatable Step series | Event series + exceptions | Reminder repetition | No |
| Substeps | Yes | No | No | No |
| Goal Path node | Yes | May be contextual | May support a Step | No until promoted |
| Proof requirement | Optional/suggested/required | Normally no | No | No |
| Attendees / RSVP | No | Yes | No | No |
| Alerts | Optional | Optional | Core capability | Optional only after promotion |
| Type conversion | Explicit, receipt-backed | Explicit, receipt-backed | Explicit, receipt-backed | Promote explicitly |

## Owning boundary laws

- **Schedule Placement nonduplication** (`OBJ-SCHEDULE-PLACEMENT-IDENTITY-001`): A Schedule Placement is one identified relationship between a canonical capacity-bearing object and Time, containing range/window, fixed/flexible/protected state, fit assumptions, and reflow rule. It MUST NOT duplicate the Step or Event or acquire its lifecycle/execution identity.
- **Future Step singularity** (`OBJECT-FUTURE-STEP-IDENTITY-001`): Future Step MUST be specified as exactly one canonical Step role, placement state, path-node subtype, or distinct object before implementation; it MUST NOT create duplicate identity or lineage.
- **Reminder acknowledgement noncompletion** (`OBJECT-REMINDER-COMPLETION-001`): A Reminder MUST NOT independently complete user work unless canonical law defines its relationship to a Step; notification acknowledgement, linked-Step completion, Reminder state, and recurrence scope MUST remain distinct transitions.
- **Proof / Receipt separation** (`OBJECT-PROOF-REQUIREMENT-001`): User-supplied Proof MAY be optional, suggested, or explicitly required before work begins; required Proof MUST NOT appear as a surprise at completion, and system mutation receipts MUST remain a separate automatic obligation.
