# REOC bot architecture target

## Layering

```text
DOL world truth
  -> Observation adapter
  -> Perception / combat memory
  -> Group & raid intent ledger
  -> Role arbitration
  -> Tactical planner
  -> Self-action feasibility (B3)
  -> DOL action request
  -> Native DOL validation / settlement
```

World truth must not feed tactical choice directly unless the player-like bot could legitimately know it.

## Perception and memory

Bots remember observations with timestamp, TTL and confidence: enemy seen, hostile cast, direct attack, ally CC, own CC success, visible Purge/cleanse, weapon switch, stealth transition.

REOC explicitly distinguishes:
- CC currently active;
- CC immunity likely active after the effect ends;
- immunity unknown/expired.

This preserves our Slam logic and avoids the OfflineDAoC limitation where generic melee stun avoidance mainly checks whether the stun effect is still present.

## Group intent ledger

Short-lived reservations prevent duplicated work without creating one omniscient group mind.

Initial intents:
- Mez / Root / Stun
- Heal
- Resurrection
- Interrupt
- Focus target
- Peel / Guard / Protect
- Pull ownership
- Position/formation claim
- Raid movement claim

Exclusive intents use one owner. Additive intents such as heals can coexist and compare projected incoming value.

## Resource authority

```text
brain: wants action X
feasibility: X appears possible
DOL: validates X against real state
DOL: pays the real cost and executes
brain: observes success/failure
```

No AI-side free cast, fake mana/endurance, fake cooldown or simulated progress.

## Tactical melee

The generic style chooser must not exclude positional play. REOC's planner owns deliberate position creation.

```text
need stun
 -> shield set available
 -> Slam usable and target not believed immune
 -> switch 1H+shield
 -> request Slam
 -> observe confirmed stun
 -> choose behind-point
 -> path behind without breaking contact
 -> switch 2H
 -> back positional
 -> follow-up
```

## Scheduling and fidelity

Starting engineering model inspired by the pinned source:
- combat ~250 ms
- player-led/high-interest ~300 ms
- nearby interaction ~600 ms
- travel ~900 ms
- resting ~1800 ms
- planning ~2500 ms

These are profiling starting points, not historical DAoC rules.

Fidelity tiers: `NearbyHuman`, `Standard`, `Efficient`. Population pressure stretches non-combat work only.

## Party and raid ownership

Normal DAoC groups remain 8-person groups. A raid is an overlay across many real groups, never one artificial 200-300 member Group object.

Raid layer owns muster, reservations, phase objective, route front, formation posts, cross-party support budget and loot ledger. Each party retains local combat autonomy.

## Navigation

Separate:
- navmesh legality: can I walk there?
- route policy: should I walk there?
- combat positioning: where should I stand for the next action?

No teleport fallback through walls. Failed routes become bounded HOLD/retry/retarget states.
