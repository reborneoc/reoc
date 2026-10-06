# Scaling to several hundred live bots

## Useful source patterns

The pinned OfflineDAoC source keeps autonomous progression on real loaded world actors. Its properties include a 4 ms autonomous decision budget per game-loop slice and a 15-minute startup ramp; its ramp brings roughly the first third in during the first five minutes.

Its fidelity policy keeps combat fast while remote planning/travel/rest run less often, and it staggers non-combat decisions by stable bot identity.

These are engineering references, not REOC production tuning.

## REOC scale rules

1. No per-bot full-world scans.
2. Wake relevant brains on real events.
3. Slow only background work.
4. Stable stagger, not fresh random jitter.
5. Bound candidate counts.
6. Shared group perception/services where possible.
7. Coalesce and spread persistence.
8. Cache proven corridors and failed route probes.
9. Never simulate XP/loot for throttled bots.

## Required metrics

- live autonomous actor count
- decisions executed/deferred per second
- decision queue depth
- mean/p95/p99 game-loop duration
- CPU time by AI subsystem
- navigation probes/sec and cache hit rate
- DB save queue depth and age
- active groups/raids
- combat brains at fast cadence
- bots by fidelity tier
- stuck watchdog interventions/hour

## Soak ladder

- 32: correctness/combat logs
- 64: first group distribution
- 128: navigation/persistence contention
- 256: sustained PvE + RvR mix
- 384: raid plus background world
- 512: target stress profile

Each rung must run long enough to catch memory growth, route stalls and save backlog.
