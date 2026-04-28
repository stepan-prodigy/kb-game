---
title: Math Game Event Taxonomy
type: event-taxonomy
owner: data-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/project_math_game_event_taxonomy.md
as_of_at_import: 2026-04-24
related:
---
Discovery-oriented index of Math Game event families mapped against the common event log's `session_activity` column. Load to find the right event(s) for a DDD question or fact-model domain before consulting the full schema contract. For the 21-column schema and 4-column collapse, see `reference_common_event_log_schema.md`.

## Session-activity categories

~85 event types are currently extracted across these categories.

| `session_activity` | Scope | Representative events |
|---|---|---|
| `login` | Session lifecycle, experiment assignment, boot telemetry | `Session Started`, `Experiment Variation Assigned`, `Game Loading Started/Ended`, `Server Selected/Connected` |
| `battle` | Turn-based combat loop | `Battle Started`, `Battle Action Performed`, `Battle Completed`, `Spell Status Effect Applied/Triggered` |
| `battle_qi` | Question Interface (math gating inside battles) | `Answer Submitted`, `Question Interface Opened/Closed`, `Hint Opened/Closed`, `Drawing Tool Used` |
| `ui` | Generic navigation — interfaces, buttons, tabs, pages | `Button Clicked`, `Interface Opened`, `Tab Clicked`, `Page Viewed` |
| `economy` | Currency/item flows, shop, Magicoin | `Item Received/Removed`, `Shop Item Viewed`, `Shop Purchase Completed`, `Add/Consume Magicoin on Server`, `Insufficient Currency` |
| `world` | Zone→map navigation and discovery | `Map Entered`, `Enemy Discovered`, `Npc Discovered/Clicked`, `Container Discovered/Opened`, `World Object Discovered/Used`, `Screen Transitioned` |
| `pets` | 100+ pet system: rescue, evolve, merge, team | `Pet Rescue Available`, `Pet Captured`, `Pet Details Viewed`, `Team Updated`, `Pet Merged`, `Pet Evolved`, `Pet Evolution Cancelled` |
| `progression` | Multi-track progression (academic / power / world / collection / seasonal) | `Player Progression Advanced`, `Player Progression Restricted`, `Player Progression Points Earned` |
| `dark_tower` | 100-floor gauntlet (member-gated past floor 5) | `Tower Floor Started/Completed`, `Tower Run Started/Completed` |
| `rifts` | End-game endurance battles with pet restrictions | `Rift Selection Menu Opened`, `Rift Run Started/Completed`, `Rift Run Round Started/Completed`, `Boss Rift Started/Completed`, `Rift Run Encounters/Bonus Offered` |
| `conversion` | Purchase funnels, Conversion Jar, segmented offers | `Game Purchase Funnel Trigger Impression/Entered/Step Advanced/Hand Off/Quit/Step Error/Complete`, `Conversion Jar Updated` |
| `gear` | Equippable items | `Item Equipped`, `Item Unequipped`, `Item Used` |
| `treasure_track` / `festival` / `minigames` / `cooldown` / `story` / `video` / `comms` / `social` / `house` / `class` / `avatar` / `funnel` / `misc` | Feature-tagged subdomains, many reached via UI override reclassification | see per-event index below |

## Per-event index

Compact lookup grouped by category. Each line: event — 1-line meaning.

### Login & session lifecycle (`login`)
- `Session Started` — session boot + device/platform context
- `Experiment Variation Assigned` — A/B bucket assignment
- `Server Selected` / `Server Connected` — realtime server handshake
- `Game Loading Started` / `Game Loading Ended` — load success + duration
- `Session Start Currency` — starting gold/magicoin balances
- `Session Start Pet Roster` — starting roster size/uniqueness
- `Technical Loading Completed` — render/connection/technical metrics bundle

### Battle (`battle`)
- `Battle Started` / `Battle Resumed` / `Battle Completed` — battle lifecycle + outcome
- `Battle Action Performed` — turn action (attack/spell); `action_damage` scalar
- `Battle Participant Entered` / `Battle Participant Outcomes` — stat snapshot at entry/exit
- `Battle MP Recovery Attempted` — MP regen attempts + success flag
- `Spell Status Effect Applied` / `Spell Status Effect Triggered` — status-effect lifecycle

### Question interface (`battle_qi`)
- `Answer Submitted` — math answer + `is_correct` + algorithm
- `Question Interface Opened` / `Question Interface Closed` — QI lifecycle
- `Hint Opened` / `Hint Closed` — hint usage
- `Drawing Tool Used` / `Drawing Tool Selected` — scratchpad activity

### UI (`ui`)
- `Button Clicked` — generic button press (subject to UI override)
- `Interface Opened` — UI surface open (subject to UI override)
- `Tab Clicked` — tab switch (subject to UI override)
- `Page Viewed` — in-game book/page view

### Economy (`economy`)
- `Item Received` / `Item Removed` — inventory delta with `source_type`/`sink_type`
- `Shop Item Viewed` / `Shop Purchase Completed` — shop funnel
- `Add Magicoin on Server` / `Consume Magicoin on Server` — server-secured premium currency
- `Insufficient Currency` — purchase blocked by balance

### World / exploration (`world`)
- `Map Entered` — zone/map transition
- `Enemy Discovered` — enemy on-screen
- `Npc Discovered` / `Npc Clicked` — NPC interaction
- `Container Discovered` / `Container Opened` — lootable container
- `World Object Discovered` / `World Object Used` — world objects
- `Screen Transitioned` — non-map screen change

### Pets (`pets`)
- `Pet Rescue Available` — post-battle rescue offer
- `Pet Captured` — pet added to roster
- `Pet Details Viewed` — pet detail screen
- `Team Updated` — active team composition change
- `Pet Merged` / `Pet Merged Cancelled` — merge flow
- `Pet Evolved` / `Pet Evolution Cancelled` — evolution flow

### Progression (`progression`)
- `Player Progression Advanced` — progression tier/step advanced
- `Player Progression Restricted` — gated/blocked
- `Player Progression Points Earned` — XP or point-type accrual

### Dark Tower (`dark_tower`)
- `Tower Run Started` / `Tower Run Completed` — full-run lifecycle
- `Tower Floor Started` / `Tower Floor Completed` — per-floor

### Rifts (`rifts`)
- `Rift Selection Menu Opened` — rift discovery
- `Rift Run Opponent Selection Menu Opened` — opponent pick
- `Rift Run Started` / `Rift Run Completed` — run lifecycle
- `Rift Run Round Started` / `Rift Run Round Completed` — per-round
- `Rift Run Encounters Offered` / `Rift Run Bonus Offered` — mid-run offers
- `Boss Rift Started` / `Boss Rift Completed` — boss rift variant

### Conversion (`conversion`)
- `Game Purchase Funnel Trigger Impression` — funnel trigger shown
- `Game Purchase Funnel Entered` — user entered funnel
- `Game Purchase Funnel Step Advanced` / `Step Error` — step-level
- `Game Purchase Funnel Hand Off` / `Quit` / `Complete` — funnel exit states
- `Conversion Jar Updated` — Conversion Jar progress

### Gear (`gear`)
- `Item Equipped` / `Item Unequipped` — gear/costume change
- `Item Used` — consumable use

### Other / feature-tagged
- `Funnel Advanced` (`funnel`) — generic feature/tutorial funnel step
- `Player Avatar Updated` (`avatar`) — avatar feature change
- `Toast Notification Generated` (`social`) — in-game toast
- `Cooldown Timer Started` / `Cooldown Timer Ended` (`cooldown`) — cooldown lifecycle (duration in hours)
- `Goal Progress Updated` / `Goal Achieved` (`misc`) — goal system
- `Post Viewed` / `Post Opened` (`comms`) — in-game posts
- `Badge Updated` (`misc`) — badge counter change
- `Achievement Completed` (`misc`) — achievement earned
- `Quest Progression Advanced` (`story`) — quest step advanced
- `Prize Wheel Spun` (`misc`) / `Festival Prize Wheel Spun` (`festival`) — wheel reward
- `Video Loading Started/Completed`, `Video Played`, `Video Stopped`, `Video Error` (`video`) — video content
- `Duel Request Sent/Received/Answered` (`battle-duel`) — PvP duel requests
- `Emote Used` (`social`) — emote in-game
- `Class Assignment Received/Completed/Ended` (`class`) — teacher-assigned content
- `Minigame Started` / `Minigame Completed` (`minigames`) — side mini-games
- `House Visited` / `Room Selected` (`house`) — house feature
- `Wizard Dash *` — competitive math-speed mode (waves/stages/runs + math streak)
- `Education*` — education screens (enrichment/targeting)

## Cross-mode reclassification rules (plain English)

Generic UI events (`Button Clicked`, `Interface Opened`, `Tab Clicked`) are re-tagged to a feature-specific `session_activity` using the element text:

- A click/open whose name contains `treasure track` → `treasure_track`
- A click/open whose name contains `festival` → `festival`
- A click/open whose name contains `store` → `economy`
- A click whose `tab_name = 'Gear'` → `gear`
- A click on `map-button` or an open of `world_map` / `zone_goals` → `world`

UI override runs before the base segmentation-sheet value. See `reference_common_event_log_schema.md` for the precedence chain and the full SQL pattern.

## Pointers

- Full 21-column contract + SQL skeleton: `reference_common_event_log_schema.md`
- Raw upstream view: `project_segment_math_game_prod.md`
- DDD authoring conventions: `reference_ddd_template.md`
