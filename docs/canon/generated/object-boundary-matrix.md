<!-- markdownlint-disable MD013 -->

# Object Boundary Matrix

> Generated from normative object specifications. Do not edit by hand.

- Canon revision: `2`
- Canon digest: `f3096e6036603fbd9f58b56ddea9d927059b4ee670a612d65750d5f67e54632d`

| Capability | Step | Event | Reminder | Note |
| --- | --- | --- | --- | --- |
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

- **Future Step identity must be singular** (`OBJECT-FUTURE-STEP-IDENTITY-001`): Future Step MUST be specified as exactly one canonical Step role, placement state, path-node subtype, or distinct object before implementation; it MUST NOT create duplicate identity or lineage.
- **Proof choice and advance notice** (`OBJECT-PROOF-REQUIREMENT-001`): User-supplied Proof MAY be optional, suggested, or explicitly required before work begins; required Proof MUST NOT appear as a surprise at completion, and system mutation receipts MUST remain a separate automatic obligation.
- **Reminder acknowledgement is not work completion** (`OBJECT-REMINDER-COMPLETION-001`): A Reminder MUST NOT independently complete user work unless canonical law defines its relationship to a Step; notification acknowledgement, linked-Step completion, Reminder state, and recurrence scope MUST remain distinct transitions.
- **Relationship between object and Time** (`OBJ-SCHEDULE-PLACEMENT-IDENTITY-001`): A Schedule Placement is one stable identified relationship between a canonical capacity-bearing object and Time, containing temporal range/window and zone, authority state, source, fixed/flexible/protected state, fit assumptions, expected revisions, conflicts, history, and reflow rule. Authority distinguishes at least proposed, accepted, external, and stale. It MUST NOT duplicate the Step or Event or acquire its lifecycle/execution identity.
