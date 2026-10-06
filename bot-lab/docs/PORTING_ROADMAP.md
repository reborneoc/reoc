# Porting roadmap - B4 series

Continue after the validated B3 work; do not replace it.

## B4_R1 - Shared Intent Ledger
Group-scoped short-lived claims for CC, heal, rez, interrupt, focus and pull ownership.

Acceptance: duplicated large heals/CC/rezzes are avoided, aborted actions release claims, claims expire, no DB writes.

## B4_R2 - Perception and Combat Memory
Event-fed observations and TTL memory. First use case: CC immunity memory.

Acceptance: tactical code does not read exact enemy cooldown timers; own successful CC creates post-effect immunity memory; visible Purge can invalidate remembered state; stale observations expire.

## B4_R3 - AI Budget and Fidelity
Decision modes, stable stagger and population-aware non-combat throttling.

Acceptance: combat cadence unaffected by population pressure; planning/travel work staggered; excess decisions are deferred, never simulated; metrics expose queue depth and tick cost.

## B4_R4 - Predictive Group Motion
Followers steer toward formation around predicted leader position.

Acceptance: no stop/start train, bounded catch-up, stable turns/doors, no combat speed cheat.

## B4_R5 - Threat-aware Travel
Bounded route look-ahead choosing pull/detour/retarget.

Acceptance: casters can open from range; dangerous threats can detour/retarget; scans are bounded/shared; no teleport shortcut.

## B4_R6 - PvE Raid Core
Raid overlay across real 8-person parties: recruitment, muster, staging, phase objective, shared route front, cross-party support intents and loot ledger.

Acceptance: one blocked party cannot freeze the raid forever; boss mechanics remain native; route targets have progress watchdogs.

## B4_R7 - Population Scale
Controlled startup ramp, registry snapshots, load metrics and soak profiles.

Recommended test ladder: `32 -> 64 -> 128 -> 256 -> 384 -> 512` live bots.

## B4_R8 - Advanced Class Tactics
Deepen tank peel/protect/guard, positional melee, assassin openings, caster interrupt/CC, healer triage, pet coordination and RvR roles.

REOC Warrior Slam/backstyle behavior is a regression test, not an optional enhancement.
