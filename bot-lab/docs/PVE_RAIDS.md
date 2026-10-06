# PvE raid architecture

## Useful upstream patterns

The pinned OfflineDAoC raid layer keeps real 8-person groups under a separate raid commitment layer. Its current policy allows up to 300 bots, normally waits for 200 staged, can late-start at 180 after 75 minutes, and gives automatic events bounded staging/battle windows. These thresholds are source references, not REOC requirements.

High-value mechanics:
- recruit only eligible live actors
- reserve members before reassignment
- form real parties with role checks
- muster at validated hubs
- allocate safe formation/staging posts per party
- require navmesh + LOS + two-way corridor checks
- one bounded dungeon route planner per expedition, not one full scan per member
- set aside a non-final target after prolonged no-damage progress
- never skip the final boss merely because routing is difficult
- flag genuinely blocked routes after bounded time
- distribute real drops exactly once via a raid loot ledger

## REOC hierarchy

```text
Raid Director
  |- Party 1 (8)
  |- Party 2 (8)
  |- Party 3 (8)
  |- ...
  '- Shared raid services
       |- phase objective
       |- formation posts
       |- encounter memory
       |- cross-party heal/rez budget
       |- CC/interrupt reservations
       |- route front
       '- loot ledger
```

## Phase state machine

`Muster -> Travel -> Stage -> Clear -> BossSetup -> BossFight -> Loot -> Recover -> Complete/Hold`

Never infer completion simply because no convenient target was found.

## Cross-party support

Do not make every healer scan the whole raid. Each party reports a compact health/support summary. Raid support escalates only when a party cannot cover itself.

Rez claims are raid-wide. Critical tank/healer deaths get priority. Heals remain local first, cross-party only when projected local coverage is insufficient.

## Boss mechanics

Boss mechanics remain native DOL mechanics. The AI adapts through observations and encounter policy; historical mechanics remain the final arbiter.

## First milestone

Start with 4 parties (32 bots) and prove rally, formations, tank contact, cross-party heal/rez claims, one boss phase, loot ownership and recovery after a delayed/wiped party. Then scale the same architecture.
