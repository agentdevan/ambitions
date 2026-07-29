# Fixture contract

Fixture family: `goals-flagship/home/welcome-baby-home/v1`

The fixture is synthetic evaluation content and does not own product decisions.

## Stable identities

- Selected Life Area: `life-area.home` — Home
- Primary Goal: `goal.welcome-baby-home` — Welcome our baby home
- Supporting Home Goals: `goal.make-home-easier-to-run`, `goal.finish-essential-move-in-work`
- Related Goal: `goal.protect-first-weeks-together` — Protect our first weeks together
- Relationship: `relationship.home-supports-first-weeks`
- Goal Path: `goalpath.welcome-baby-home.v1`
- Current Path node: `goalpath-node.paint-wall`
- Next Path node: `goalpath-node.assemble-crib`

## Accepted fixture truth

- Direction: Make the home ready for the baby without consuming the time and energy the family needs now.
- Current truth: The wall is primed, the color is confirmed, and the crib corner is clear.
- Active thread: Finish the nursery.
- Next meaningful movement: Paint the nursery wall.
- Consequence: Finishing the room now reduces last-minute setup while protecting family time.
- Schedule fit: The next movement currently fits before protected family time.
- Proof posture: Crib corner cleared; Paint color confirmed; Wall primed.

## State behavior

- Exactly one Life Area is expanded.
- Goal selection clears any previously open lens and does not imply rank.
- The Linked Goal Lens opens only for the fixture-backed primary Goal.
- Focused Goal, relationship, and Path routes use stable typed identities.
- Back from relationship or Path restores focused Goal; back from Goal restores the expanded lens, selected Goal, and Home context.
- `hasMutation` remains false throughout.

