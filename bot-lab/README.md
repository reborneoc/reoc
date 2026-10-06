# REOC Bot Lab - OfflineDAoC acceleration depot

This branch is a development/reference workspace for the REOC bot system. It is intentionally separated from production server code.

## Purpose

Use the strongest ideas found in `shadowofze/OfflineDAoC` to accelerate REOC without replacing the REOC/BIFROST brain already validated through the B3 series.

The target is broader than companion combat: hundreds of live world bots, autonomous groups, PvE raids, RvR forces, resource-realistic combat, human-like perception, and bounded CPU cost.

## Non-regression rules

- DOL remains authoritative for actual action legality, mana/endurance/health costs, cooldowns, effects, interrupts, movement and combat results.
- The bot brain may choose or predict an action; it must not fabricate success or progression.
- Keep REOC positional melee logic. In particular, do not regress `Slam -> confirmed stun -> move behind -> 2H -> backstyle -> follow-up`.
- Track stun/mez/root immunity as remembered combat state, not only the currently displayed CC effect.
- Preserve the B3 feasibility gates and role arbitration below the new coordination layers.
- Do not make the bot omniscient. Shared knowledge must come from observations, explicit group intents or bounded inference.
- Population scaling may slow planning/travel/background work, never normal combat reaction.

## Upstream reference

Pinned reference: `shadowofze/OfflineDAoC` commit `38aef23dadfe2f1659fec2a382ffde427879f475` (2026-10-06).

OfflineDAoC is GPL-3.0. This branch does not vendor its source by default. Use `tools/Sync-OfflineDAoC.ps1` to create a local ignored reference copy when needed.

## Start here

1. `docs/ARCHITECTURE.md`
2. `docs/PORTING_ROADMAP.md`
3. `docs/SCALING_500_BOTS.md`
4. `docs/PVE_RAIDS.md`
5. `manifests/offlinedaoc-reference.txt`
6. `tools/Sync-OfflineDAoC.ps1`
