# Fixture contract

Fixture ID: `time-flagship/week/protected-family-and-launch/v1`

## Period

- Active range: This week, July 27–August 2
- Selected day: Wednesday, July 29
- Fixture Now: Wednesday at 3:12 PM

## Accepted local truth

- `placement.send-launch-brief.wed-1400`
  - Send the launch brief
  - Wednesday, 2:00–2:30 PM
  - Accepted · Fixed
  - Goal: Ship the launch well
- `placement.family-time.wed-1730`
  - Family time
  - Wednesday, 5:30–6:30 PM
  - Accepted · Protected
  - No work

## Open capacity

- `opening.wed-after-1830`
  - Wednesday after 6:30 PM
  - Open calendar space
  - Personal usability unknown

Open time is not an Event, accepted placement, capacity score, suggestion, or
recommendation.

## External observation

- `external.prenatal-appointment.thu-0900`
  - Prenatal appointment
  - Thursday, 9:00–10:00 AM
  - Apple Calendar observation
  - External observation, not accepted Ambitions truth

## Proposed placement

- `proposal.paint-nursery-wall.thu-1030`
  - Paint the nursery wall
  - Thursday, 10:30–11:30 AM
  - Goal: Welcome our baby home
  - Proposed · Not scheduled

## Conflict review

- `proposal.launch-review.wed-1745`
  - Launch review
  - Wednesday, 5:45–6:15 PM
  - Proposed · Not scheduled
  - Participant: accepted protected Family time, 5:30–6:30 PM
  - Consequence: would consume protected Family time from 5:45–6:15 PM

The prototype supports Cancel and Keep current. Both return without mutation.
