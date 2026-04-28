---
title: Math Game — Pets
type: design-doc
owner: game-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/project_math_game_pets.md
as_of_at_import: 2026-04-24
related:
---
Parent overview: `project_math_game_product.md`.

Covers the pet collection mechanic — the single strongest long-term motivator and the largest conversion funnel. Load when designing pet-related DDDs, modeling capture/evolution funnels, or reasoning about Magicoin sinks.

## Role

Pets are the central long-term collection hook. The pet lifecycle touches every core system (battle, economy, progression, conversion). Reductions in pet Magicoin costs increase both evolution activity and Magicoin-spender counts. Sign positive; magnitudes parked.

## Pet families

Three functional categories:

| Family | Source | Role |
|---|---|---|
| Tutorial starters | Granted during onboarding | 5 evo1 pets given at tutorial start. Dominant through early-game, abandoned near level caps. Non-evolving past their given stage in typical play. |
| Gearsite | Member-only tutorial bonus | Evo2 pet granted to members during tutorial. Higher stat ceiling than starters; persists to endgame. Single strongest member-vs-non-member onboarding asymmetry. |
| Base pets | Wild captures, evolvable | Non-starter species; the endgame team composition. Evo2+ captures are near-exclusively member due to capture gates. |

Roster size is member-driven: members carry substantially larger rosters than non-members (magnitudes parked).

## Lifecycle

**Capture → Level → Evolve → Merge → Team.**

### Capture

Triggered post-battle when a wild creature is rescuable. A rescue prompt opens; completion requires currency (Magicoin for higher-rarity pets). Capture pricing is under active experimentation. Evo2+ capture is a hard conversion wall (near-exclusively member).

Rescue-event volume substantially exceeds capture-event volume — most rescues do not convert to captures. Pet-rescue is the **#1 Magicoin insufficiency** trigger, exceeding all non-pet sinks combined.

### Level

Pets gain XP from battle participation. Members generate meaningfully more pet-XP events than non-members (magnitude parked). Level caps by evolution stage (approximately 20 at evo1, 40 at evo2, 60 at evo3, higher at evo4 — structural, exact caps drift with balancing).

Level-cap events are heavily non-member-skewed — hitting a cap drives the core friction surface for evolution prompts.

### Evolve

Advances a pet to its next evolution stage (evo1 → evo2 → evo3 → evo4). **Costs Magicoin.** Evolution cancellation rate is high — most evolution prompts do not complete. This is the core pet-driven conversion wall. The ratio of completed evolutions member vs non-member is strongly member-skewed (magnitude parked).

### Merge

Combining duplicate pets. **Free mechanic** — no currency cost. Participation rates are comparable between members and non-members — one of the few pet systems without a monetization asymmetry.

### Team

Active battle team supports the wizard plus up to 2 pets. Team management (swap, equip gear) is ongoing throughout the session.

## Conversion role

Pet rescue/evolution is the dominant conversion pressure point in the game. The main conversion triggers surfaced post-battle (Member Jar, hard-lock prompts) are frequently pet-framed. See `project_math_game_economy.md` for the Member Jar trigger catalog and `project_math_game_activities.md` for where the prompts surface within session flow.

## Key experimental findings (directional)

Magnitudes parked; structural findings only:

- Reducing pet costs **increased** evolution rate and Magicoin-spender counts. Sign positive on both.
- First Pet Rescue (Magicoin tutorial during onboarding) is a distinct onboarding moment — DDD exists.
- Roster size and evolution-completion rate are primary member-vs-non-member behavioral separators.

## Related files

- `project_math_game_product.md` — parent overview.
- `project_math_game_economy.md` — Magicoin mechanics, conversion triggers.
- `project_math_game_combat.md` — pet stats in the Combat Formula.
- `project_math_game_activities.md` — pet-use restrictions in Rifts, pet capture moments in other modes.
- `project_math_game_sessions.md` — pets in onboarding / tutorial flow.
