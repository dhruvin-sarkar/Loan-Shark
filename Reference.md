================================================================================
 ================================================================================
  LOAN SHARK — COMPLETE GAME DESIGN DOCUMENT (AGENT EDITION)
  Version 3.0 — Ultra-Detailed Reference for AI Coding Agent
================================================================================

  Game Title    : Loan Shark
  Engine        : Godot 4.x (GDScript only)
  Export Target : HTML5 (itch.io)
  Genre         : Fishing Roguelite
  Jam Theme     : Beneath the Surface
  Event         : HackClub Campfire Dubai
  Build Time    : 7 days
  Project Root  : C:\Game projects\Loan-Shark\

--------------------------------------------------------------------------------
  HOW TO READ THIS DOCUMENT
--------------------------------------------------------------------------------

  This document is written for an AI coding agent. Every system is described
  in enough detail that you can implement it without asking clarifying questions.
  Where a design decision could go multiple ways, the chosen approach is stated
  explicitly. Where numbers appear (prices, timings, probabilities), use those
  exact numbers unless the document says "approximately" or "around."

  Sections are ordered by dependency — foundational systems come first, then
  systems that rely on them. When implementing, follow the 7-Day Build Schedule
  at the end of this document.

  All GDScript files use Godot 4.x syntax (not Godot 3.x). All paths are
  written as res:// paths. All autoloads are singletons accessed globally.


================================================================================
  SECTION 1 — CORE CONCEPT & PILLARS
================================================================================

  PREMISE
  -------
  The player is a fisherman who has borrowed money from a loan shark (a literal
  shark character who runs the local shop). They start the game with $500 of
  debt and only $20 in their pocket. Every day that passes without clearing the
  debt, interest compounds and the loan shark gets meaner. The only way out is
  to fish, process the catch, and sell it for enough money to pay down the debt
  before time runs out.

  The game takes place over exactly 7 in-game days. Each in-game day is
  10 minutes of real time. This means a full playthrough from start to finish
  takes no longer than 70 minutes — by design, for the hackathon audience.

  THEME CONNECTION
  ----------------
  "Beneath the Surface" is explored on two levels simultaneously:

    1. LITERAL: The player physically descends deeper into the ocean. Each zone
       goes further beneath the surface of the water. The deepest zone — The
       Bioluminescent Deep — is pitch black and can only be reached at great
       expense and risk.

    2. METAPHORICAL: The player is "beneath the surface" of debt. The financial
       pressure mounts each day. The loan shark's dialogue hints at a dark world
       beneath the cheerful fishing town — underground debt, desperation, danger.
       The deeper the player digs into the ocean, the more they discover just how
       deep the rabbit hole goes.

  CORE PILLARS
  ------------
  The game is built on three design pillars that every feature must serve:

  PILLAR 1 — ESCALATING TENSION
    Every day that passes should feel more urgent than the last. The debt grows,
    the loan shark's dialogue gets more threatening, and the player must take
    bigger risks (deeper zones) to earn enough money. The game should feel like
    a slowly tightening vice.

  PILLAR 2 — SATISFYING SKILL EXPRESSION
    All four minigames (Cast, Reel, Catch, Filet) reward timing and precision.
    A skilled player who masters all four minigames earns significantly more
    than a casual player. The skill ceiling should be high enough that a skilled
    player can pay off the debt by Day 4–5, while an average player barely
    scrapes by on Day 6–7.

  PILLAR 3 — EMERGENT BUILD VARIETY
    The roguelite modifier system (Rod + Enchantment + Bait + Charm) means each
    day feels different. A player who gets the right combination of modifiers can
    create powerful synergies. No two runs should feel identical. This system
    creates replayability even in a jam game.


================================================================================
  SECTION 2 — GAME LOOP (MACRO)
================================================================================

  THE DAILY CYCLE
  ---------------
  Each in-game day follows this fixed sequence. The player cannot change this
  order — they can only decide how long to spend in each phase.

  PHASE 1: MORNING (Day Start)
    - A "Day X of 7" card fades in on screen.
    - The loan shark's shopkeeper dialogue triggers automatically (brief, 2–3
      lines that get more threatening as days pass).
    - GameState.day_night_cycle begins ticking. Time is now passing.
    - The player starts in Town. They can immediately go to the Shop, the Beach,
      or the Dock. There is no forced tutorial after Day 1.

  PHASE 2: PREPARATION (Town/Dock phase)
    - The player visits the Shop (run by the loan shark shopkeeper NPC).
    - They can buy rods, bait, knives, and charms with their available cash.
    - They can pay down debt directly from the shop (a "Pay Debt" button).
    - They can visit the Beach to forage for crafting materials before fishing.
    - They can access the Crafting Menu to combine materials into charms.

  PHASE 3: FISHING (Ocean phase)
    - The player walks to the Dock and descends into the ocean.
    - Inside the ocean, they choose a zone based on their rod's capability.
    - They perform the Cast minigame to launch their hook.
    - They wait a brief moment (1–3 seconds) while the hook sinks.
    - A fish bites — the Reel minigame begins.
    - If the reel is successful, the Catch minigame begins.
    - If the catch is successful, the fish enters the player's inventory.
    - The player repeats this loop until their inventory is full (12 slots) or
      time pressure forces them back to shore.

  PHASE 4: PROCESSING (Dock phase)
    - The player returns to the Dock from the ocean.
    - For each fish in their inventory, they can optionally run the Filet
      minigame to increase the fish's sell value by up to 1.5x.
    - Unfileted fish can still be sold but at their base value only.

  PHASE 5: SELLING (Shop phase)
    - The player sells fish to the loan shark shopkeeper.
    - Each fish's sale price is calculated: Base Price × Size Multiplier ×
      Reel Success % × Filet Multiplier × any active Charm multipliers.
    - The total cash earned goes into GameState.cash.

  PHASE 6: DEBT TICK (End of Day)
    - When the day timer reaches zero, a "Day End Summary" screen appears.
    - It shows: fish caught, total earned, debt remaining, days left.
    - If debt > 0 AND player did not pay it down to zero today, 5% interest
      is added to the current debt total. This compounds — $500 becomes $525
      on Day 2, $551.25 on Day 3 (if never paid), etc.
    - If debt > $1000 at any end-of-day check, the game immediately triggers
      the Game Over screen (debt spiral — player has lost control).
    - The next day begins automatically after a short fade.

  WIN CONDITION
    The player wins if their debt reaches exactly $0 at any point before or
    during Day 7. Debt can be paid in partial amounts at any time at the shop.
    The win is checked immediately when a payment is made, not only at end of
    day. If the player pays the last dollar on Day 7 with one minute to spare,
    they still win.

  LOSE CONDITIONS (two ways to lose)
    1. Debt exceeds $1000 at any end-of-day tick (financial spiral).
    2. Day 7 ends with debt still > $0 (time ran out).
    Both conditions show the Game Over screen with different flavour text.


================================================================================
  SECTION 3 — SCENES & WORLD LAYOUT
================================================================================

  The game world is a small coastal town. The player navigates between four
  distinct locations by walking horizontally (the game is a 2D side-scroller).
  There are no loading screens between Town, Beach, and Dock — they are
  seamlessly connected. The Ocean is a separate scene loaded when the player
  descends from the Dock.

  SCENE: TOWN
  -----------
  The Town is the hub. It uses BackDrops/an orange city.png as the daytime
  background and BackDrops/Nightcity.png as the nighttime background. The
  day/night overlay system smoothly transitions between these based on the
  in-game time of day (morning = bright, afternoon = warm orange tint,
  evening = dark blue overlay).

  What exists in Town:
    - The SHOP BUILDING: Entrance to the shop scene. Has a sign that reads
      "Finn's Loans & Bait" (the loan shark's name is Finn). The door flashes
      red if the player hasn't paid debt today, as a subtle visual reminder.
    - NPC ROAMERS: 3–4 townsfolk NPCs who walk back and forth. They have
      short one-liner dialogues that change based on what day it is. They are
      purely atmospheric — they don't sell anything.
    - THE MAILBOX: Shows the current debt amount as a floating number above it.
      This is a permanent UI reminder so the player always knows how much they
      owe. Tapping it opens the debt breakdown popup.

  SCENE: BEACH
  -----------
  The Beach connects Town to the Dock. It uses BackDrops/Jungle.png and/or
  BackDrops/somethinginthemiddle.png as the background (layered for parallax).

  What exists on the Beach:
    - FORAGING SPAWNS: Collectible material nodes spawn randomly across the
      beach each morning. They are simple click/interact objects (shells, coral
      fragments, sea glass, driftwood, algae, etc.). The player walks up to them
      and presses interact to collect. Each material goes into the inventory.
    - THE CRAFTING TABLE: A workbench on the beach where the player can open
      the Crafting Menu and combine materials into charms.
    - VISUAL DETAIL: Seagulls as background sprites, waves animating at the
      water's edge, the sound of SeaBreeze.m4a playing as ambient audio.

  SCENE: DOCK
  -----------
  The Dock is at the far right of the Beach. It uses the same background as
  the Beach but with the dock pier structure in the foreground.

  What exists on the Dock:
    - THE FISHERMAN NPC: A veteran fisherman who gives gameplay hints. His
      dialogue changes based on day and player progress. He is the tutorial
      voice for Day 1 and the source of optional hints on later days.
    - THE DIVE POINT: Marked with a glowing buoy. Interacting with it
      transitions to the Ocean scene and begins the fishing session.
    - THE FILET TABLE: Where the player processes fish after returning from
      ocean. It is only interactable when the player has fish in their
      inventory and has returned from the ocean.
    - THE FISH CRATE: Displays how many fish are currently in the player's
      inventory (0–12 slots shown as a simple counter).

  SCENE: OCEAN (Zone Loader)
  --------------------------
  The Ocean scene is a loader/manager. When the player enters the ocean, this
  scene checks which rod they have equipped, then loads the appropriate zone
  subscene as a child. The player can travel between zones by swimming deeper
  (moving down on screen) if their rod permits.

  The camera follows the player and pans smoothly. There is a depth indicator
  on the HUD showing which zone the player is currently in (Z1–Z4) and a faint
  visual fog that gets denser at greater depths.

  ZONE 1 — THE SHALLOWS
    Visual: Bright teal water, visible sunbeams casting god-ray effects from
    the Sinky_Sub_GodRays.png layer. The water is clear and inviting. Sandy
    floor visible. Schools of small fish visually swim in the background as
    decoration (not catchable ambient fish — separate from the spawned catchable
    fish).
    Background layers (parallax, slowest to fastest):
      - Sinky_Sub_BG.png (farthest background, barely moves)
      - Sinky_Sub_GodRays.png (god rays, slow scroll)
      - Sinky_Sub_Floor.png (seafloor, fastest)
    Fish Tier: Common. Low value, easy to catch, good for early days.
    Unlock: Always unlocked. Player starts here every run.
    Hazard rate: Low. Occasional jellyfish hazard.

  ZONE 2 — THE KELP FOREST
    Visual: Deep green water. Dense kelp strands sway in a simulated current
    (animated sprites oscillating with a sine wave). Visibility is lower than
    Zone 1 — a green tint overlay is applied to the camera. Light filtering
    through from above creates dappled shadow patterns.
    Background layers:
      - Sinky_Sub_BG.png (shared with Zone 1)
      - Sinky_Sub_Cliffs.png (rocky cliffs mid-ground)
      - Sinky_Sub_CloseRockKelp.png (close foreground kelp, fastest layer)
      - Sinky_Sub_Floor.png (floor, slightly different tint)
    Fish Tier: Uncommon. Higher value, harder minigames (faster, tighter).
    Unlock: Requires the player to own an Intermediate tier rod (Kelp Rod,
    Deep Rod, or Fossil Rod). If the player enters the ocean with a Starter or
    Amateur rod, Zone 2 is blocked by a visible "Current Too Strong" barrier.
    Hazard rate: Medium. Eels and occasional octopus.

  ZONE 3 — THE SUNKEN RUINS
    Visual: Dark blue-black water. Ancient stone ruins of an underwater
    structure (columns, arches, broken walls) visible in the background layer.
    Glowing moss and coral provide the only light sources — bioluminescent
    green and blue patches on the ruins. Very low ambient visibility. The depth
    fog effect (DepthFog.tscn) is active at 40% opacity.
    Background layers:
      - Sinky_Sub_BG.png (very dark tinted version)
      - Sinky_Sub_Ruins_Whale.png (ruins and a distant whale silhouette)
      - Sinky_Sub_Floor.png (dark rocky floor)
    Fish Tier: Rare. High value, the minigames are significantly harder here.
    The Catch minigame's red zone moves faster. The Reel bar oscillates more
    violently.
    Unlock: Requires a Pro tier rod (Abyss Rod, Leviathan Rod, or Oracle Rod).
    Hazard rate: High. Sharks patrol here. The Leviathan can appear rarely.

  ZONE 4 — THE BIOLUMINESCENT DEEP
    Visual: Pitch black water. The ONLY light comes from the creatures
    themselves. Everything glows — fish leave light trails, the player's hook
    has a faint glow, the BiolumParticle.tscn effect spawns floating particles
    of light that drift upward. The underwater-fantasy-files PNG layers provide
    the abstract, glowing deep-sea background. This zone feels alien and
    dangerous.
    Background: underwater-fantasy-files/underwater-fantasy-files/Assets/PNG/layers/
    Fish Tier: Ultra-rare. Extremely high value. The Midnight Leviathan lives
    here. The minigames are at maximum difficulty.
    Unlock: Requires a Pro tier rod AND the player must have Deep Bait equipped.
    Without Deep Bait (Luminous Lure or Deep Sea Lure), Zone 4 is inaccessible
    even with a Pro rod. This is a deliberate late-game gate.
    Hazard rate: Very High. Constant threat. Do not spend too long here.


================================================================================
  SECTION 4 — PLAYER CHARACTER
================================================================================

  The player character is a simple fisherman sprite using charfree/global.png
  as the spritesheet. The character is controlled with left/right movement keys
  (WASD or arrow keys) and an interact key (E or Space).

  MOVEMENT
    - Horizontal walk speed: 120 pixels/second.
    - No jumping in the overworld (town, beach, dock). The world is flat.
    - In the ocean, the player swims in all four directions:
        Horizontal speed: 80 px/s
        Vertical speed: 60 px/s (going up is faster than going down — fighting
        buoyancy is harder, going down is easier conceptually but the fish are
        worth more, so it's a risk/reward feeling not a gameplay inconvenience)
    - The player cannot leave the screen boundaries. Invisible walls at edges.

  ANIMATIONS (AnimatedSprite2D, from charfree/global.png)
    - idle_right: standing still, facing right
    - idle_left: idle_right flipped horizontally
    - walk_right: walking animation, facing right (4-6 frames)
    - walk_left: walk_right flipped
    - swim_right / swim_left / swim_up / swim_down: ocean movement
    - cast: animation played during Cast minigame
    - reel: looping animation during Reel minigame

  INVENTORY
    The player has 12 inventory slots for fish. This represents a physical
    limit — they can only carry 12 fish at once. Each slot shows the fish icon,
    fish name, and a small quality star rating (1–5 stars based on size and
    catch quality). When inventory is full, the fishing loop is blocked (the
    Cast minigame won't start) until the player returns to the dock to sell.

  EQUIPMENT SLOTS
    The player has three equipment slots that persist across the session:
    - ROD SLOT: One rod equipped at a time. Cannot be changed while in ocean.
    - BAIT SLOT: One type of bait loaded. Quantity tracked separately.
    - KNIFE SLOT: One knife equipped. Determines filet minigame difficulty/reward.
    Additionally, up to 2 CHARM SLOTS for daily active charms.


================================================================================
  SECTION 5 — GAMESTATE AUTOLOAD
================================================================================

  GameState.gd is the single source of truth for ALL persistent game data.
  It is the first autoload registered. Everything else reads from and writes to
  GameState. It never unloads — it persists for the entire session.

  VARIABLES (all must be initialized in _ready())

    # Financial
    var debt: float = 500.0          # Starting debt. Ticks +5% per unpaid day.
    var cash: float = 20.0           # Starting cash in hand.

    # Time
    var current_day: int = 1         # 1 through 7.
    var day_duration: float = 600.0  # 10 minutes per day in seconds.
    var time_remaining: float = 600.0 # Ticking down each frame.
    var is_day_active: bool = false  # False during transitions and day-end screen.

    # Inventory
    var fish_inventory: Array = []    # Array of FishInstance dictionaries.
                                      # Max 12 entries. Each dict has:
                                      # { id, name, base_price, size_mult,
                                      #   reel_quality, fileted, filet_mult }
    var materials_inventory: Dict = {} # Key = material_id, Value = quantity.

    # Equipment
    var equipped_rod: String = "rod_driftwood"    # Resource ID string.
    var equipped_bait: String = ""                # Empty = no bait.
    var bait_quantity: int = 0
    var equipped_knife: String = "knife_rusty"    # Starts with rusty knife.
    var active_charms: Array = []                 # Max 2 charm resource IDs.

    # Roguelite
    var rod_enchantment: String = ""     # Current enchantment on the rod. Empty = none.
    var daily_modifier_log: Array = []   # Log of modifiers active today (for Day End Summary).

    # Flags
    var tutorial_completed: bool = false
    var codex_discovered: Dictionary = {}  # fish_id: true/false for discovered fish.
    var days_without_payment: int = 0     # Tracks consecutive unpaid days.

  KEY METHODS

    func pay_debt(amount: float) -> void:
      # Subtracts from debt. If debt hits 0 or below, clamp to 0 and call win().
      # Subtracts amount from cash first. Check cash >= amount before calling.
      cash -= amount
      debt -= amount
      if debt <= 0:
        debt = 0
        SceneManager.show_win_screen()

    func end_of_day() -> void:
      # Called by day_night_cycle.gd when timer hits 0.
      # Apply interest if debt unpaid.
      if debt > 0:
        debt *= 1.05  # 5% compound interest.
        days_without_payment += 1
      else:
        days_without_payment = 0
      # Check lose condition.
      if debt > 1000.0:
        SceneManager.show_game_over("debt_spiral")
        return
      # Advance day.
      current_day += 1
      if current_day > 7 and debt > 0:
        SceneManager.show_game_over("time_out")
        return
      # Reset daily variables.
      time_remaining = day_duration
      active_charms.clear()  # Charms reset daily.
      daily_modifier_log.clear()
      SceneManager.show_day_end_summary()

    func add_fish(fish_data: Dictionary) -> bool:
      # Returns false if inventory full.
      if fish_inventory.size() >= 12:
        return false
      fish_inventory.append(fish_data)
      codex_discovered[fish_data.id] = true
      return true

    func sell_all_fish() -> float:
      # Calculates total sale value of all fish. Clears inventory. Returns total.
      var total = 0.0
      for fish in fish_inventory:
        var price = fish.base_price
        price *= fish.size_mult
        price *= fish.reel_quality
        if fish.fileted:
          price *= fish.filet_mult
        price = ModifierStack.apply_sell_multipliers(price, fish)
        total += price
      fish_inventory.clear()
      cash += total
      return total

    func save() -> void:
      # Saves all state to a JSON file via SaveSystem.
      SaveSystem.save_state(self)

    func load_save() -> void:
      SaveSystem.load_state(self)


================================================================================
  SECTION 6 — FISH DATABASE
================================================================================

  FishDatabase.gd is a global autoload that holds the data for all 38 fish.
  It does NOT contain spawn logic — that is handled by spawn_table.gd. Its job
  is purely to be a lookup table: "give me the data for fish ID X."

  Each fish is defined as a Dictionary with these keys:

    {
      "id": "sardine",              # Unique string ID, matches resource file name.
      "name": "Sardine",            # Display name shown in UI.
      "zone": 1,                    # Which zone this fish appears in (1–4).
      "base_price": 4,              # Base sell price in dollars, unmodified.
      "size_range": [0.8, 1.8],     # Random size multiplier range on catch.
      "rarity": "common",           # "common", "uncommon", "rare", "ultra-rare", "legendary".
      "night_only": false,          # If true, only spawns during nighttime hours.
      "family": "pelagic",          # Fish family for rod affinity matching.
                                    # Families: pelagic, crustacean, reef, bony, deep, eel, cephalopod
      "reel_speed": 1.0,            # Multiplier on how fast the reel bar oscillates.
                                    # 1.0 = normal, 1.5 = 50% faster (harder).
      "catch_speed": 1.0,           # Multiplier on catch minigame red zone speed.
      "modifier_effect": "",        # Special modifier effect on catch. See Modifier Fish.
      "description": "...",         # Flavour text shown in the Codex.
      "sprite_region": Rect2(...)   # Region in the spritesheet for this fish's icon.
    }

  COMPLETE FISH ROSTER

  --- ZONE 1: THE SHALLOWS (10 fish) ---

  1.  ID: sardine       | Name: Sardine           | Price: $4    | Rarity: common
      Family: pelagic   | Reel speed: 0.8 (slow)  | Night only: no
      Description: "A tiny silver fish that travels in massive schools. The bread
      and butter of the fishing trade — mostly useful for selling in bulk."

  2.  ID: bass          | Name: Sea Bass           | Price: $14   | Rarity: common
      Family: bony      | Reel speed: 1.0 (normal) | Night only: no
      Description: "A reliable catch. Sea bass are the backbone of any fishing
      operation. Not glamorous, but not nothing."

  3.  ID: crab          | Name: Shore Crab         | Price: $18   | Rarity: common
      Family: crustacean| Reel speed: 1.2 (slightly fast) | Night only: no
      Description: "Tries to walk sideways even when being reeled in. Can't quite
      figure out which way is up."

  4.  ID: clownfish     | Name: Clownfish          | Price: $22   | Rarity: uncommon
      Family: reef      | Reel speed: 0.9           | Night only: no
      Description: "Brightly coloured and surprisingly popular with buyers who
      want something cheerful. Don't ask why."

  5.  ID: seahorse      | Name: Seahorse            | Price: $28   | Rarity: uncommon
      Family: reef      | Reel speed: 0.7 (very slow) | Night only: no
      Description: "Barely resists being caught — not because it wants to come
      willingly, but because it's just not very fast."

  6.  ID: pufferfish    | Name: Pufferfish          | Price: $20   | Rarity: uncommon
      Family: bony      | Reel speed: 1.3            | Night only: no
      Description: "Inflates itself in protest when caught. Still sells well.
      Handle with care during filet."

  7.  ID: flounder      | Name: Flounder            | Price: $16   | Rarity: common
      Family: bony      | Reel speed: 1.0            | Night only: no
      Description: "Flat as a pancake and twice as bland. Dependable."

  8.  ID: perch         | Name: River Perch         | Price: $10   | Rarity: common
      Family: bony      | Reel speed: 0.9            | Night only: no
      Description: "Wandered in from the river mouth. Didn't think this through."

  9.  ID: shrimp        | Name: Rock Shrimp         | Price: $12   | Rarity: common
      Family: crustacean| Reel speed: 0.8            | Night only: no
      Description: "Technically not a fish. Nobody seems to care."

  10. ID: jellyfish     | Name: Moon Jellyfish      | Price: $8    | Rarity: uncommon
      Family: pelagic   | Reel speed: 0.6 (very slow) | Night only: no
      Description: "Almost floats onto the hook on its own. Very little sporting
      challenge. Very little of anything, really."

  --- ZONE 2: THE KELP FOREST (10 fish) ---

  11. ID: snapper       | Name: Red Snapper         | Price: $32   | Rarity: uncommon
      Family: bony      | Reel speed: 1.2            | Night only: no

  12. ID: moray_small   | Name: Moray Eel (Young)   | Price: $38   | Rarity: uncommon
      Family: eel       | Reel speed: 1.5            | Night only: no
      Description: "Fights like it's twice its size. Will bite the hook, then
      bite you. Not technically a fish (it's an eel) but the market doesn't care."

  13. ID: grouper       | Name: Giant Grouper       | Price: $45   | Rarity: rare
      Family: bony      | Reel speed: 1.4            | Night only: no

  14. ID: trumpet_fish  | Name: Trumpetfish         | Price: $35   | Rarity: uncommon
      Family: reef      | Reel speed: 1.0            | Night only: no

  15. ID: spiny_lobster | Name: Spiny Lobster       | Price: $55   | Rarity: rare
      Family: crustacean| Reel speed: 1.6            | Night only: no
      Description: "Worth nearly three times a sardine and it fights back.
      The extra effort is worth it — buyers pay premium for lobster."

  16. ID: stonefish     | Name: Stonefish           | Price: $60   | Rarity: rare
      Family: bony      | Reel speed: 1.3            | Night only: no
      Description: "Venomous spines. Sells well precisely because catching it
      is genuinely dangerous. Your knife hand will feel it."

  17. ID: octopus_small | Name: Young Octopus       | Price: $40   | Rarity: uncommon
      Family: cephalopod| Reel speed: 1.5 (tentacles) | Night only: no

  18. ID: needlefish    | Name: Needlefish          | Price: $28   | Rarity: common
      Family: pelagic   | Reel speed: 1.8 (very fast) | Night only: no
      Description: "Thin as a needle and three times as annoying. Incredibly fast
      on the reel."

  19. ID: batfish       | Name: Batfish             | Price: $30   | Rarity: uncommon
      Family: reef      | Reel speed: 1.1            | Night only: YES
      Description: "Only emerges from the kelp at night. Has the face of someone
      who has made many bad decisions."

  20. ID: ghost_crab    | Name: Ghost Crab          | Price: $65   | Rarity: rare
      Family: crustacean| Reel speed: 1.4            | Night only: YES
      modifier_effect: "ghost_crab_night_bonus"
      Description: "Almost translucent. Worth significantly more if sold at night
      — buyers who want ghost crabs are very specific about freshness timing.
      Catching one at night triggers a +1.5x price multiplier on the next sale."

  --- ZONE 3: THE SUNKEN RUINS (10 fish) ---

  21. ID: anglerfish    | Name: Anglerfish          | Price: $90   | Rarity: rare
      Family: deep      | Reel speed: 1.6            | Night only: no

  22. ID: moray_large   | Name: Giant Moray         | Price: $75   | Rarity: rare
      Family: eel       | Reel speed: 1.8            | Night only: no

  23. ID: oarfish       | Name: Oarfish             | Price: $110  | Rarity: rare
      Family: bony      | Reel speed: 1.3 (long, slow) | Night only: no
      Description: "Enormous. Takes up two inventory slots when caught. Yes,
      two slots. Worth it — buyers treat it as a spectacle."
      NOTE: Oarfish is the only fish that takes 2 inventory slots.

  24. ID: viperfish     | Name: Viperfish           | Price: $95   | Rarity: rare
      Family: deep      | Reel speed: 2.0 (max normal) | Night only: no

  25. ID: dragonfish_juv| Name: Dragonfish (Juvenile) | Price: $120 | Rarity: rare
      Family: deep      | Reel speed: 1.7            | Night only: no

  26. ID: rugose_crab   | Name: Rugose Crab         | Price: $85   | Rarity: rare
      Family: crustacean| Reel speed: 1.5            | Night only: no

  27. ID: coelacanth    | Name: Coelacanth          | Price: $200  | Rarity: legendary
      Family: bony      | Reel speed: 1.2 (deceptively calm) | Night only: no
      Description: "A living fossil. Has been in the deep for 400 million years
      and seems mildly annoyed to be here. The scarcity alone makes it worth a
      small fortune. Spawn chance: 2% base. Only 1 can appear per day."

  28. ID: abyssal_shrimp| Name: Abyssal Shrimp      | Price: $70   | Rarity: uncommon
      Family: crustacean| Reel speed: 1.0            | Night only: no

  29. ID: stone_crab    | Name: Stone Crab          | Price: $65   | Rarity: uncommon
      Family: crustacean| Reel speed: 1.3            | Night only: no

  30. ID: phantom_eel   | Name: Phantom Eel         | Price: $130  | Rarity: rare
      Family: eel       | Reel speed: 2.2 (hardest reel in Z3) | Night only: YES
      Description: "Bioluminescent. Only comes out at night even in the ruins.
      Sells for a premium because nobody believes they exist until you show them."

  --- ZONE 4: THE BIOLUMINESCENT DEEP (10 fish) ---

  31. ID: gulper_eel    | Name: Gulper Eel          | Price: $160  | Rarity: ultra-rare
      Family: eel       | Reel speed: 2.0            | Night only: no

  32. ID: dragonfish_adult | Name: Dragonfish (Adult)| Price: $180 | Rarity: ultra-rare
      Family: deep      | Reel speed: 2.2            | Night only: no

  33. ID: deep_angler   | Name: Deep Anglerfish     | Price: $150  | Rarity: ultra-rare
      Family: deep      | Reel speed: 1.8            | Night only: no

  34. ID: barreleye     | Name: Barreleye Fish      | Price: $170  | Rarity: ultra-rare
      Family: deep      | Reel speed: 1.5 (strange, floaty) | Night only: no
      Description: "Has transparent, rotating eyes that track everything. Including
      you. Unsettling to filet."

  35. ID: fangtooth     | Name: Fangtooth Fish      | Price: $140  | Rarity: rare
      Family: deep      | Reel speed: 2.1            | Night only: no

  36. ID: frilled_shark | Name: Frilled Shark       | Price: $220  | Rarity: ultra-rare
      Family: deep      | Reel speed: 2.3 (second hardest) | Night only: no
      Description: "Ancient lineage. Looks like someone combined a shark with an
      eel and got angry at both. The frills are not decorative."

  37. ID: goldfish_modifier | Name: Deepwater Goldfish | Price: $300 | Rarity: ultra-rare
      Family: deep      | Reel speed: 1.0 (very easy, deceptive) | Night only: no
      modifier_effect: "goldfish_next_sale_bonus"
      Description: "Mysteriously easy to catch for how valuable it is. Catching
      one applies a +50% bonus to the very next fish sale (one fish only).
      The deep holds surprises."

  38. ID: lanternfish   | Name: Lanternfish Swarm   | Price: $40   | Rarity: common
      Family: pelagic   | Reel speed: 0.8            | Night only: no
      Description: "Technically you're catching a swarm, not one fish. Each catch
      yields 5 lanternfish ($40 each = $200 total value), but they take 5 inventory
      slots. High volume, manageable value — useful if your inventory is nearly empty."
      NOTE: Lanternfish spawns as a swarm — it adds 5 fish to inventory at once,
      each worth $40. If fewer than 5 slots are available, the swarm is only
      partially caught (1 slot = 1 fish caught from the swarm).

  39. ID: sea_angel     | Name: Sea Angel           | Price: $250  | Rarity: ultra-rare
      Family: deep      | Reel speed: 1.3 (gentle)  | Night only: no
      modifier_effect: "sea_angel_charm_double"
      Description: "Not an angel. Not particularly angelic. But glowing and
      beautiful enough that buyers pay a premium just to look at one.
      Catching a Sea Angel doubles the effect of both active charms for the
      rest of the current day."

  40. ID: midnight_leviathan | Name: Midnight Leviathan | Price: $800+ | Rarity: legendary
      Family: deep      | Reel speed: 3.0 (extreme) | Night only: YES (Zone 4 only)
      modifier_effect: "leviathan_debt_clear"
      Description: "This is it. The apex predator of the deep. Catching the
      Midnight Leviathan instantly clears 20% of whatever debt remains at the
      time of the catch. Additionally, it sells for $800 base (modified by size
      and quality as normal). Spawn chance: 1% per cast in Zone 4 at night only.
      The Reel minigame plays at 3.0x speed — the hardest possible. The
      Leviathan can also appear as a HAZARD (non-catchable) in Zone 3 and Zone 4,
      where it tries to break your line and must be escaped from."


================================================================================
  SECTION 7 — MINIGAMES (ALL FOUR)
================================================================================

  There are exactly four minigames in Loan Shark. They run sequentially for
  each fish: Cast → (wait) → Reel → Catch → (optional) Filet. Understanding
  all four is essential because they determine the quality and value of every
  fish the player earns.

  ============================================================
  MINIGAME 1: CAST MINIGAME
  ============================================================

  PURPOSE: Determines how far the player casts their line. A better cast
  reaches better fish positions and slightly increases the chance of a bite
  from a rare species (not mechanically, but narratively — the further cast
  puts the hook in calmer, deeper water).

  HOW IT WORKS:
    1. A vertical power bar appears in the center of the screen. It has a
       visible "sweet spot" zone marked in green (top 20% of the bar).
    2. A filling bar rises from bottom to top, filling over 2 seconds.
    3. The player must press and hold the Cast button when the bar is in or
       rising toward the green zone, then RELEASE to cast.
    4. The bar continues to fill past the sweet spot if held — releasing
       in the sweet spot gives maximum cast. Releasing below the sweet spot
       gives a weak cast. Releasing above the sweet spot (overshoot) gives
       a short, tangled cast.
    5. The sweet spot's exact position shifts every cast. On Day 1 it is
       always at the top 20%. From Day 2 onward it shifts between 15–30%
       from the top randomly. This prevents players from memorizing the
       exact position.

  CAST QUALITY TIERS:
    - PERFECT: Released in the sweet spot. Line flies far. Visual: splash at
      max distance. Slight bonus to rare fish spawn weight this cast only (+10%).
    - GOOD: Released slightly below sweet spot (50–80% bar). Decent cast.
      No modifier.
    - WEAK: Released below 50%. Short cast. Fish are more common species.
    - OVERSHOT: Released and held past the sweet spot. Line knots. Cast
      must be retried — a 1-second "untangle" animation plays.

  SCENE: scenes/minigames/CastMinigame.tscn
  SCRIPT: scripts/minigames/cast_minigame.gd

  SIGNALS EMITTED:
    cast_complete(quality: String)  # "perfect", "good", "weak"
    cast_failed()                   # On overshot — retries automatically.

  ============================================================
  MINIGAME 2: REEL MINIGAME
  ============================================================

  PURPOSE: Tests the player's timing and reaction speed while "reeling in"
  the fish. Success percentage directly affects the fish's final sale price.

  HOW IT WORKS:
    1. A vertical bar appears on the right side of the screen. The bar is
       divided into four colour zones from bottom to top:
         RED (bottom 20%)  — danger zone, line tension too high
         ORANGE (20–40%)   — strain zone, okay but not ideal
         YELLOW (40–70%)   — good zone, decent tension
         GREEN (70–90%)    — optimal zone, perfect reel
         RED (top 10%)     — snapped zone, line breaks
    2. A marker (a small fish icon) oscillates up and down on this bar. The
       oscillation follows a sine wave. The frequency and amplitude depend on:
         - The fish's reel_speed value (higher = faster oscillation).
         - The current zone (deeper zones add amplitude variance — the marker
           jerks unpredictably as if the fish is pulling hard).
    3. The player controls a "reel tension" value by holding the Reel button.
       Holding the button raises the marker upward. Not holding lets gravity
       pull it down. The goal is to keep the marker in the GREEN zone.
    4. Time limit: The reel lasts 8–15 seconds depending on the fish species.
       Larger fish (oarfish) take 15 seconds. Small fish (sardine) take 5.
    5. If the marker enters the top RED zone and stays there for 1 second
       continuously, the line snaps and the fish escapes. The cast is wasted.

  REEL QUALITY CALCULATION:
    The game tracks how many seconds the marker spends in each zone across
    the entire reel duration. At the end:
      reel_quality = (green_time * 1.0 + yellow_time * 0.7 +
                      orange_time * 0.4 + red_time * 0.1) / total_duration
    This gives a float between ~0.1 and 1.0. This becomes fish.reel_quality
    and directly multiplies the final sale price. A perfect reel (all green)
    gives 1.0x, a poor reel (mostly red) gives ~0.1x.

  SCENE: scenes/minigames/ReelMinigame.tscn
  SCRIPT: scripts/minigames/reel_minigame.gd

  SIGNALS EMITTED:
    reel_complete(quality: float)   # Float 0.0–1.0.
    line_snapped()                  # Fish escaped. Inventory not changed.

  ============================================================
  MINIGAME 3: CATCH MINIGAME
  ============================================================

  PURPOSE: The final securing of the fish. Success determines whether the
  fish is actually added to the inventory. Failure loses the fish despite
  the reel succeeding.

  HOW IT WORKS:
    1. A horizontal bar appears at the bottom of the screen. A red "danger
       zone" (about 20% width) slides back and forth. It bounces between
       the left and right edges, accelerating slightly each time it bounces.
    2. A circular crosshair is displayed above the bar. The player moves it
       left and right with the movement keys.
    3. The player must keep the crosshair AWAY from the red zone. If the
       crosshair overlaps the red zone for more than 0.5 seconds cumulatively,
       the fish escapes (not lost instantly — has a slight forgiveness window).
    4. The minigame lasts 5 seconds. If the player survives the 5 seconds
       without the fish escaping, the catch is successful.
    5. Deep zone fish: In Zone 3 and Zone 4, a second, smaller red zone
       appears independently. Both must be avoided simultaneously.

  SCENE: scenes/minigames/CatchMinigame.tscn
  SCRIPT: scripts/minigames/catch_minigame.gd

  SIGNALS EMITTED:
    catch_success()
    catch_failed()     # Fish escapes. Inventory not changed.

  ============================================================
  MINIGAME 4: FILET MINIGAME
  ============================================================

  PURPOSE: An optional post-catch processing step performed at the Dock's
  Filet Table. Success multiplies the fish's sell value by up to 1.5x.
  Failure reduces it below base value. The player can skip fileting and
  sell fish raw (losing the multiplier bonus).

  HOW IT WORKS:
    1. A top-down view of the fish appears on a cutting board.
    2. Dashed lines show the "cut path" — a curved line running along the
       fish from head to tail. The player must trace their mouse/finger
       along this dashed path.
    3. A "sharpness zone" shown as a highlighted band ±15px from the dashed
       line. Moving within the sharpness zone scores points. Moving outside
       penalises.
    4. At random intervals (every 2–4 seconds), a QTE (Quick Time Event)
       prompt appears: a random key icon (A, S, D, or F on keyboard). The
       player must press it within 0.8 seconds or lose points.
    5. A "Filet Score" bar fills as the player traces correctly. Final score
       maps to filet_mult:
         Score 90–100%: filet_mult = 1.5 (perfect — also drops a bonus material)
         Score 70–90%:  filet_mult = 1.3
         Score 50–70%:  filet_mult = 1.1
         Score 30–50%:  filet_mult = 0.9 (worse than raw — messed it up)
         Score 0–30%:   filet_mult = 0.5 (very bad — nearly ruined it)
    6. The knife equipped determines sharpness zone width and QTE timing:
         Rusty Knife:   ±5px zone,  0.6s QTE window,  max 1.2x filet mult
         Amateur Knife: ±12px zone, 0.9s QTE window,  max 1.4x filet mult
         Pro Knife:     ±22px zone, 1.3s QTE window,  max 1.5x + bonus material on perfect

  NOTE: The Pro Knife's "bonus material drop on perfect" means that
  perfectlly fileting with a Pro Knife drops one random material item
  into the player's materials inventory (same as beach foraging).

  SCENE: scenes/minigames/FiletMinigame.tscn
  SCRIPT: scripts/minigames/filet_minigame.gd

  SIGNALS EMITTED:
    filet_complete(mult: float)   # The filet_mult value (0.5–1.5).


================================================================================
  SECTION 8 — ROGUELITE MODIFIER SYSTEM
================================================================================

  The modifier system is the roguelite heart of Loan Shark. It stacks four
  sources of modifiers together to create synergistic daily builds. No two days
  play identically because the player must work with what they can afford to buy.

  THE FOUR MODIFIER SOURCES (applied in this order)

  SOURCE 1: ROD (base layer — zone access + species affinity)
    The equipped rod determines:
    a) Which zones the player can enter.
    b) A species affinity multiplier applied to spawn weights.
    Detailed in Section 9 (Rod System).

  SOURCE 2: ENCHANTMENT (permanent rod modifier until re-enchanted)
    A single enchantment can be applied to the equipped rod. It stays on the
    rod permanently until a new enchantment is applied (replacing the old one).
    Enchantments are applied by consuming an Enchantment Charm at the Crafting
    Table. The enchantment modifies the rod's behaviour in specific ways.
    Detailed in Section 9 (Rod Enchantments).

  SOURCE 3: BAIT (single-use, consumed per cast)
    Bait is consumed with every cast. It applies a modifier for that single
    cast only — adjusting spawn weights toward specific families or rarities.
    Detailed in Section 10 (Bait System).

  SOURCE 4: CHARM (daily aura — up to 2 active simultaneously)
    Charms are crafted from foraged materials. Up to 2 charms can be active at
    once. They apply persistent bonuses for the entire day. Charms reset at the
    start of each new day (they expire, not carry over).
    Detailed in Section 11 (Charm System).

  HOW MODIFIERS STACK

  The spawn weight table is the key data structure. For each zone, every fish
  has a base integer spawn weight (defined in the spawn_table resource).
  Higher weight = more likely to be chosen when a fish "bites."

  Each cast, the following process runs in spawn_table.gd:
    1. Load the base weight table for the current zone.
    2. Apply rod affinity multipliers (multiply weights of matching family fish).
    3. Apply enchantment modifier (if applicable — some enchantments shift weights).
    4. Apply bait modifier (multiply weights of matching fish/family for this cast).
    5. Apply charm modifiers (multiply weights of matching fish/family all day).
    6. Normalize the table (all weights still sum to 100% after modification).
    7. Roll a random number against the normalized table to select a fish species.

  EXAMPLE STACKED BUILD
  Rod: Kelp Rod (Zone 2 access, +25% crustacean weight)
  Enchantment: Blood Tide (+30% to all rare fish weights, -10% to common)
  Bait: Soft Plastic Lure (+20% to bony and reef fish)
  Charm 1: Crustacean Call (+30% crustacean spawn chance)
  Charm 2: Fortune Bait (+15% to all spawn weights for rare+)

  Combined result: Crustacean fish in Zone 2 get their weight multiplied by
  approximately 1.25 × 1.30 × 1.30 = 2.11x their base weight. Spiny Lobster
  and Ghost Crab dominate the catch pool for that day. This is a valid
  "crustacean build" that generates strong income from high-value crustaceans.

  SAME-FAMILY CHARM RULE
  If both active charms belong to the same family/category, they do NOT stack
  additively. Instead, a flat 1.5x is applied to that family rather than the
  sum of both charms. This prevents degenerate builds that trivialize the game.


================================================================================
  SECTION 9 — ROD SYSTEM
================================================================================

  There are 10 rods organised into 4 tiers. The player always starts with the
  Driftwood Rod. Higher tier rods cost more, grant zone access, and provide
  species affinity bonuses.

  TIER 1: STARTER (given for free at game start)

    DRIFTWOOD ROD
      Zone access: Zone 1 only.
      Affinity: None. No species multiplier.
      Description: "Found on the beach. Barely held together by hope and
      fishing line. Gets the job done for the shallow water."

  TIER 2: AMATEUR ($60 each — affordable by end of Day 1 if fishing goes well)

    SHELL ROD
      Zone access: Zone 1.
      Affinity: +20% crustacean spawn weight in Zone 1.
      Best for: Early-game crustacean farming (crabs, shrimp).

    CORAL ROD
      Zone access: Zone 1.
      Affinity: +20% reef spawn weight in Zone 1.
      Best for: Clownfish, seahorse runs.

    BONE ROD
      Zone access: Zone 1.
      Affinity: +25% bony fish spawn weight in Zone 1.
      Best for: Bass, flounder, perch volume runs.

  TIER 3: INTERMEDIATE ($180 each — requires saving from Day 1–2 fishing)

    KELP ROD
      Zone access: Zones 1–2.
      Affinity: +25% to all fish in Zone 2 (not species-specific — flat bonus
      to being in Zone 2 gives access to higher-value fish).
      Best for: Zone 2 general exploration.

    DEEP ROD
      Zone access: Zones 1–2.
      Affinity: +30% to rare-tier fish spawn weight in Zone 3... WAIT.
      NOTE: Deep Rod opens Zone 2, and inside Zone 2 it adds +30% weight to
      the rare-tier fish specifically (grouper, spiny lobster, stonefish).
      Best for: Targeting Zone 2 rare fish specifically.

    FOSSIL ROD
      Zone access: Zones 1–2.
      Affinity: None directly on spawns. Instead: +20% to all fish sale prices
      (not a spawn modifier — a sell multiplier applied in ModifierStack). However,
      the reel minigame marker oscillates 10% faster — harder to use but more
      profitable.
      Best for: Players confident in the Reel minigame.

  TIER 4: PRO ($450 each — requires significant mid-game investment, Day 3–4)

    ABYSS ROD
      Zone access: Zones 1–3.
      Affinity: +35% to ultra-rare spawn weight in Zone 4 (does NOT unlock Zone
      4 alone — still need Deep Bait for Zone 4 access, but pre-loads the affinity).
      Best for: Preparing a Zone 4 ultra-rare run.

    LEVIATHAN ROD
      Zone access: Zones 1–3.
      Affinity: +40% to trophy-size fish (fish where size_mult rolls high).
      Mechanically: when a fish is caught with this rod, the size_mult random
      roll uses a skewed distribution weighted toward the upper half of the range.
      Best for: Maximising sell value of each individual fish.

    ORACLE ROD
      Zone access: Zones 1–3.
      Affinity: +15% to ALL fish spawn weights (flat, all families). Additionally,
      +10% to all sell prices. However: hazard encounter rate +30%. More fish
      but more danger.
      Best for: Experienced players who can handle hazards.

  ROD ENCHANTMENTS (8 total — applied by consuming enchantment charms)

    These permanently modify the equipped rod. Only one enchantment at a time.
    Enchantments are tied to the rod, not the player — if you switch rods,
    the enchantment on the old rod stays on it.

    TIDE BLESSING     : +20% to Zone 1 and Zone 2 common fish value (sell price).
                        Synergises with high-volume shallow fishing.

    DEEP LURE        : +40% spawn weight to Zone 3 and Zone 4 rare+ fish.
                        Essentially a permanent bait effect for the deep zones.

    FORTUNE HOOK     : Every 7th cast in a session is guaranteed to produce a
                        rare or better fish (not ultra-rare, just rare). The
                        counter resets each day.

    GHOST BAIT       : Night-only fish become catchable during daytime hours.
                        Removes the night_only restriction on all night fish.
                        Ghost Crab, Batfish, Phantom Eel, etc. can now spawn
                        any time with this enchantment.

    CALM WATERS      : Reel minigame oscillation amplitude reduced by 30%.
                        Much easier reels. Lower risk of losing fish.
                        No spawn modifier — purely a skill assist enchantment.

    BLOOD TIDE       : +30% rare+ spawn weight, but hazard encounter rate +50%.
                        High reward, high risk.

    ECHO LINE        : After each successful catch, the spawn weight for that
                        specific fish species is increased by +15% for the next
                        3 casts. "Like calling to like." Rewards catching the
                        same species repeatedly.

    WEIGHTED SINK    : Hook sinks 40% faster after cast. Reduces wait time
                        between cast and bite. No direct spawn modifier, but
                        means more casts per minute and thus more total fish.


================================================================================
  SECTION 10 — BAIT SYSTEM
================================================================================

  Bait is consumed every cast (one unit per cast). The player must buy bait
  from the shop before fishing. If they run out of bait, they can still fish
  but get no bait modifier — just the rod's base spawn weights.

  Bait comes in two categories: NATURAL and LURES.

  NATURAL BAIT (attracts fish that actually eat the thing)

    EARTHWORM        : $8 for 10 units. +25% bony fish spawn weight.
    MAGGOT           : $10 for 8 units. +30% to small/common fish. Not glamorous.
    INSECT           : $14 for 6 units. +20% reef fish and +15% pelagic fish.
    LIVE SHRIMP      : $20 for 5 units. +35% crustacean spawn weight.
    SAND CRAB        : $20 for 5 units. +30% eel and deep family fish.
    SMALLFISH        : $25 for 4 units. +40% to predator fish (moray, shark family,
                        grouper, anglerfish, dragonfish, viperfish, frilled shark).

  LURES (artificial — attracts fish by movement, not smell)

    SOFT PLASTIC     : $18 for 6 units. +20% bony and +15% reef fish.
    JERKBAIT         : $24 for 5 units. +25% to active hunters (needlefish,
                        viperfish, fangtooth). These fish respond to movement.
    JIG              : $24 for 5 units. +25% deep family fish.
    SPINNER          : $30 for 4 units. +30% to crustaceans and cephalopods.
    DEEP SEA LURE    : $40 for 3 units. Unlocks Zone 2 access for Pro rods to
                        push toward Zone 4. +25% Zone 3 and Zone 4 fish.
                        NOTE: Deep Sea Lure is one of the two baits that enables
                        Zone 4 access (the other is Luminous Lure).
    LUMINOUS LURE    : $45 for 3 units. THE Zone 4 bait. +40% Zone 4 ultra-rare
                        spawn weight. Also enables Zone 4 entry. The most
                        expensive bait, but unlocks the highest-value fishing.


================================================================================
  SECTION 11 — CHARM SYSTEM
================================================================================

  Charms are crafted (not bought) from foraged materials. Up to 2 active per day.
  They provide passive bonuses for the entire current day and expire at midnight.

  Charms are divided into three categories based on their effect type.

  CATEGORY 1: SELL PRICE CHARMS (8 total)
  These increase the sale value of specific fish or categories.

    SHELL CHARM      : +25% sell price on all crustacean fish.
                        Crafting: Shell × 3 + Sea Glass × 1
    CORAL CHARM      : +30% sell price on all reef fish.
                        Crafting: Coral × 3 + Algae × 1
    DEEP CHARM       : +35% sell price on all deep family fish.
                        Crafting: Deep Crystal × 2 + Small Bone × 1
    TIDE CHARM       : +20% sell price on ALL fish. Universal but lower bonus.
                        Crafting: Driftwood × 2 + Coral × 1
    GOLD CHARM       : +50% sell price on the next 3 fish sold (not all fish —
                        just the next 3 in the session). Tracked as a counter.
                        Crafting: Gold Sand × 3 + Sea Glass × 2
    NIGHT CHARM      : +40% sell price on all night-only fish.
                        Crafting: Night Kelp × 2 + Ghost Fin × 1
    BLOOD CHARM      : +60% sell price on rare and ultra-rare fish specifically.
                        No effect on common/uncommon.
                        Crafting: Shark Tooth × 2 + Small Bone × 2
    INK CHARM        : +25% sell price on cephalopod fish (octopus).
                        Crafting: Ghost Crab Shell × 2 + Algae × 1

  CATEGORY 2: SPAWN RATE CHARMS (8 total)
  These adjust the spawn weight table to make certain fish more common.

    EEL WARD         : -50% eel family spawn weight. Eels are difficult and
                        worth avoiding on easy days. This prevents them appearing.
                        Crafting: Ghost Fin × 2 + Driftwood × 1
    SIREN CHARM      : +30% pelagic fish spawn weight. More sardines, needlefish,
                        lanternfish swarms.
                        Crafting: Sea Glass × 3 + Algae × 1
    CRUSTACEAN CALL  : +40% crustacean spawn weight.
                        Crafting: Shell × 2 + Sand Crab × 2
    BONY LURE        : +35% bony fish spawn weight.
                        Crafting: Small Bone × 3 + Driftwood × 1
    DEPTH PULSE      : +40% deep family spawn weight. Affects Zones 3 and 4 only.
                        Crafting: Deep Crystal × 3 + Echo Coral × 1
    FORTUNE BAIT     : +20% spawn weight to rare-tier and above (all species).
                        Crafting: Gold Sand × 2 + Sea Glass × 1
    CALM TIDE        : -30% to all hazard spawn rates. Safer fishing.
                        Crafting: Coral × 2 + Algae × 2
    FRENZY CHARM     : +50% to ALL spawn weights, but line snapping chance in
                        Reel minigame +20%. More fish, more risk.
                        Crafting: Shark Tooth × 1 + Ghost Fin × 1 + Night Kelp × 1

  CATEGORY 3: ENCHANTMENT CHARMS (8 total)
  These are consumed at the Crafting Table to permanently apply an enchantment
  to the currently equipped rod. They don't function as daily auras — they
  are one-time consumables. When crafted and applied, the charm is destroyed
  and the rod gains the enchantment permanently.

    One enchantment charm exists for each of the 8 rod enchantments listed in
    Section 9. Each requires rare materials:
    Example — Tide Blessing Charm: Shell × 5 + Echo Coral × 2 + Gold Sand × 1

  NOTE: A player can only use 2 charm slots per day, so they must choose
  between two sell price charms, two spawn charms, or one of each. Planning
  this choice each morning is a meaningful strategic decision.


================================================================================
  SECTION 12 — FORAGING MATERIALS
================================================================================

  Materials are collected on the Beach each day. The beach gets 8–14 random
  material nodes spawned at morning start. Materials persist until collected
  — they don't disappear if the player doesn't collect them, but they DO
  reset at the start of each new day (new nodes spawn, old ones are gone).

  The foraging_spawner.gd places nodes randomly within the beach's playfield
  bounds. Nodes are simple Area2D with a sprite and collision. The player
  walks over them to collect (no button press needed — autodetect on overlap).

  14 MATERIAL TYPES

    SHELL           : Common. Used in crustacean-related charms and enchantments.
    CORAL           : Common. Used in reef charms and universal charms.
    SEA GLASS       : Common. Used in multiple recipes as a filler/binder.
    DRIFTWOOD       : Common. Used in structural/stable charm recipes.
    ALGAE           : Common. Low-value filler. Many recipes use 1–2 algae.
    NIGHT KELP      : Uncommon. Only spawns if it's currently nighttime on beach.
                      Nocturnal spawn — appears at dusk, gone by morning.
    GOLD SAND       : Uncommon. Rare beach spawn (2–3 per day max).
                      Used in high-value sell-price charms.
    DEEP CRYSTAL    : Rare. Only 1–2 spawn per day. Required for deep fish charms.
    ECHO CORAL      : Rare. Special coral that resonates. Required for Echo Line
                      enchantment charm.
    SMALL BONE      : Uncommon. Fish bone fragments. Used in aggressive/rare charms.
    SAND CRAB       : Uncommon. A live sand crab that can ALSO be used as bait
                      (goes into bait slot instead of materials if used as bait).
                      Or crafted into Spinner bait substitute. Versatile.
    GHOST FIN       : Rare. Translucent fin fragment. Used in eel and night charms.
    SHARK TOOTH     : Rare. Only spawns on beach starting Day 3.
                      Required for Blood Charm and Frenzy Charm — the aggressive,
                      high-risk charms.
    GHOST CRAB SHELL: Uncommon. The shed shell of a ghost crab. Appears at night.
                      Used in the Ink Charm and as a decorative codex item.


================================================================================
  SECTION 13 — HAZARD SYSTEM
================================================================================

  Hazards are non-catchable entities that spawn in the ocean and interfere
  with fishing. They are not enemies (there is no combat) but they are threats
  that must be avoided or managed. They add tension and danger to deeper zones.

  HOW HAZARDS SPAWN
    The hazard_spawner.gd runs independently from fish_spawner.gd. It has its
    own timer. Hazard spawn rates increase in deeper zones:
      Zone 1: 5% chance per 30 seconds of a hazard appearing.
      Zone 2: 15% chance per 20 seconds.
      Zone 3: 30% chance per 15 seconds.
      Zone 4: 50% chance per 10 seconds.

  HAZARD EFFECTS (what they do when encountered)

    JELLYFISH
      Sprite: octopus-jellyfish.../2/ sprites.
      Zone: Primarily Zone 1 and Zone 2.
      Effect: If the player swims through a jellyfish, it stuns them for 1.5
      seconds (can't move or fish). Non-lethal but disruptive. Predictable —
      jellyfish float upward in a fixed arc. Easy to avoid once you see the
      pattern.

    ELECTRIC EEL (visual hazard)
      Sprite: fishing_free/global.png eel frame.
      Zone: Zone 2 and Zone 3.
      Effect: Shoots an electricity burst in a horizontal line. If the line
      hits the fishing line while the Reel or Catch minigame is active, it
      causes an automatic line snap (fish lost). The player character is
      stunned for 0.5s. The eel is easily spotted by its glow.

    SHARK
      Sprite: octopus-jellyfish.../3/ sprites.
      Zone: Zone 3 primarily. Rare in Zone 2.
      Effect: Swims across the screen toward the player. If the shark reaches
      the player, it bites the fishing line — automatic fish loss if reeling.
      If not currently reeling, the shark charges past and the player must
      dodge (swim out of its path). The SharkWarningVignette.tscn effect
      (red vignette pulse) plays 3 seconds before the shark appears to give
      the player warning time.

    OCTOPUS (large)
      Sprite: octopus-jellyfish.../1/ sprites.
      Zone: Zone 2 and Zone 3.
      Effect: Releases an ink cloud that temporarily blacks out the Reel
      minigame bar — the player can't see the zone colours for 2 seconds and
      must reel by feel/memory. Does not directly cause fish loss but makes
      the reel much harder.

    TURTLE
      Sprite: octopus-jellyfish.../4/ sprites.
      Zone: Zone 1 and Zone 2.
      Effect: Harmless to the player but swims through and tangles the fishing
      line. This interrupts the current cast — the line goes slack and the
      hook must be recast. It's more of a nuisance than a danger. Turtles are
      slow and very visible, so most experienced players swim around them.

    MIDNIGHT LEVIATHAN (as hazard, non-catchable variant)
      Zone: Zone 3 (very rare) and Zone 4.
      Effect: The LeviathanShake.tscn screen shake effect triggers first.
      Then a massive shadow passes across the background. If the leviathan's
      shadow overlaps the player's fishing line, it applies a crushing force
      — automatic line snap AND the player is pushed back toward Zone 1 by
      100 pixels. Very rare. In Zone 4 at night it can instead be the
      catchable version (see Fish #40 above).


================================================================================
  SECTION 14 — SHOP SYSTEM
================================================================================

  The Shop is run by Finn, the loan shark. It is accessible from Town. The
  shop is a scene (Shop.tscn) with a grid of purchasable items and a
  separate "Pay Debt" button.

  SHOP INVENTORY (always in stock unless otherwise noted)

    RODS:
      Driftwood Rod   : Free (given at start, not purchasable again)
      Shell Rod       : $60
      Coral Rod       : $60
      Bone Rod        : $60
      Kelp Rod        : $180
      Deep Rod        : $180
      Fossil Rod      : $180
      Abyss Rod       : $450
      Leviathan Rod   : $450
      Oracle Rod      : $450

    BAIT (sold in packs as defined in Section 10):
      Earthworm ×10   : $8
      Maggot ×8       : $10
      Insect ×6       : $14
      Live Shrimp ×5  : $20
      Sand Crab ×5    : $20
      Smallfish ×4    : $25
      Soft Plastic ×6 : $18
      Jerkbait ×5     : $24
      Jig ×5          : $24
      Spinner ×4      : $30
      Deep Sea Lure ×3: $40
      Luminous Lure ×3: $45

    KNIVES:
      Rusty Knife     : Free (given at start)
      Amateur Knife   : $55
      Pro Knife       : $200

    NOTE: Charms are NOT sold in the shop. They can only be crafted.

  SHOP UI BEHAVIOUR
    - Hovering over an item shows its tooltip: name, cost, zone access (for
      rods), and a brief description.
    - The "Pay Debt" button shows current debt. Player can type any amount
      up to their cash balance. Minimum payment: $1.
    - Finn's dialogue changes based on how much debt remains:
        > $400 : "Still digging your hole, I see."
        $200–400 : "Making progress. Slowly."
        $100–200 : "Don't celebrate yet."
        $50–100  : "You might actually make it."
        < $50    : "Pay the rest, or I'll be very disappointed."
    - If the player tries to buy something they can't afford, the button
      shakes and Finn says a line about them being too broke.


================================================================================
  SECTION 15 — DEBT SYSTEM (DETAILED)
================================================================================

  The debt system is managed by debt_system.gd and reads/writes to GameState.

  STARTING STATE
    debt = $500.00
    cash = $20.00
    Interest rate = 5% compound per unpaid day.

  INTEREST CALCULATION
    At end of each day where debt > 0:
      new_debt = debt * 1.05
    This is applied BEFORE checking if debt > $1000 loss condition.
    The interest is rounded to 2 decimal places.

  DEBT TRAJECTORY (if player earns nothing)
    Day 1 end: $525.00
    Day 2 end: $551.25
    Day 3 end: $578.81
    Day 4 end: $607.75
    Day 5 end: $638.14
    Day 6 end: $670.05
    Day 7 end: GAME OVER (time ran out)
    The player never hits the $1000 cap from interest alone — they would need
    to actively lose fish sales or make no progress for multiple days. The
    $1000 cap is a safety valve for catastrophic debt spirals.

  PARTIAL PAYMENTS
    Players are encouraged to make partial payments throughout the week.
    Paying $100 on Day 2 prevents $5 of interest per day from accruing on
    that $100 (saving roughly $25 over the remaining days — meaningful!).
    The UI should communicate this clearly in the debt breakdown popup.

  THE LOAN SHARK'S DIALOGUE (Finn, days 1–7)
    Day 1: "Seven days, five hundred dollars. Simple math. Good luck — you'll
    need it more than you think."
    Day 2 (debt unpaid): "I gave you one day and already you come back
    empty-handed? The interest doesn't sleep, friend."
    Day 3 (debt > $550): "The numbers are going the wrong direction. I'm
    starting to wonder if you're serious."
    Day 4 (debt > $550): "Four days gone. Half your time. You'd better
    start catching something impressive."
    Day 5 (debt > $400): "Getting nervous? You should be."
    Day 6 (debt > $200): "One day left after today. I hope you've been saving."
    Day 7 (debt > $0): "This is your last day. Don't make me come find you."


================================================================================
  SECTION 16 — ECONOMY BALANCE
================================================================================

  This section outlines how much money a player should be earning per day
  under different conditions so you can verify the game is balanced.

  ZONE 1 AVERAGE FISH VALUES (base, no modifiers, average reel/catch quality)
    Sardine: $4 × 1.3 avg size × 0.6 avg reel = ~$3
    Bass:    $14 × 1.3 × 0.7 = ~$13
    Crab:    $18 × 1.3 × 0.6 = ~$14
    Average Zone 1 fish: ~$8–$14

  DAILY INCOME EXPECTATIONS
    Day 1 (Zone 1 only, Driftwood rod, no modifiers, casual play):
      8–10 fish × $8 avg = $64–$80 earned
      After buying $8 earthworms: $56–$72 net
      Target: Start making small debt payments by end of Day 1.

    Day 1 (optimised — good reel, smart bait, maxing casts):
      12 fish × $12 avg = $144 earned
      After expenses: ~$120–$130 net

    Day 3–4 (Zone 2 rod, intermediate bait, no charms):
      10 fish × $40 avg = $400 earned
      After expenses: ~$330–$360 net

    Day 4–5 (Zone 2 with charms and good enchantment, skilled play):
      12 fish × $65 avg = $780 earned
      After expenses: ~$680 net (could pay off the debt by Day 4!)

    Day 6–7 (Zone 3, Pro rod, Blood Charm, Deep Lure enchantment):
      8 fish × $120 avg = $960 earned
      After expenses: ~$840 net

  WIN TIMING TARGETS
    Average player (modest minigame skill, basic upgrades): Clears debt Day 6–7.
    Skilled player (good reels, optimal purchases): Clears debt Day 4–5.
    Optimal player (perfect play, best builds): Possible Day 3 (very hard).
    First-time player (still learning): Might barely scrape Day 7, tension maintained.


================================================================================
  SECTION 17 — TUTORIAL (DAY 1 ONLY)
================================================================================

  The tutorial runs exclusively on Day 1. It is managed by TutorialManager.gd
  (the sixth autoload). On Day 2 and beyond, TutorialManager does nothing —
  all prompts are hidden and all tutorial blocking is removed.

  HOW THE TUTORIAL WORKS
    TutorialManager uses an enum TutorialStep with 15 values. The tutorial
    advances one step at a time, in order, and each step blocks the player
    from proceeding until they perform the required action.

    The tutorial uses TWO UI elements simultaneously:
    - TutorialArrow.tscn: A glowing animated arrow that points at the relevant
      UI element or world object. Floats with a gentle bobbing animation.
    - TutorialPrompt.tscn: A small speech bubble popup with instructional text.
      Appears near the object being highlighted, not as a full-screen takeover.

  THE 15 TUTORIAL STEPS

    STEP 1 — INTRO DIALOGUE
      Trigger: Automatic on Day 1 start.
      Action: Finn's dialogue box opens. He explains the situation in 3 lines.
      "You owe me $500. You have 7 days. Go fish."
      Player must click/press to dismiss.

    STEP 2 — SHOW THE DEBT METER
      TutorialArrow points to the debt display (mailbox or HUD element).
      Prompt: "This is your debt. It goes up if you don't pay. Don't let
      it go up."
      Player must click the debt display to confirm they've seen it.

    STEP 3 — GO TO THE SHOP
      TutorialArrow points to the shop door.
      Prompt: "Visit the shop to buy bait. You'll need it."
      Player must enter the shop.

    STEP 4 — BUY BAIT
      Inside the shop. TutorialArrow points to Earthworm ×10.
      Prompt: "Buy some bait. It makes fish more likely to bite."
      Player must purchase at least one bait item.

    STEP 5 — LEAVE THE SHOP
      Prompt: "Good. Now go to the beach and look for materials."
      Player must exit the shop.

    STEP 6 — GO TO BEACH
      TutorialArrow points toward the beach direction.
      Player must walk to the beach scene.

    STEP 7 — COLLECT A MATERIAL
      A glowing highlight appears on one of the beach foraging nodes.
      Prompt: "These materials wash up each morning. Collect them — they're
      used to craft charms later."
      Player must collect at least 1 material.

    STEP 8 — GO TO THE DOCK
      TutorialArrow points toward the dock.
      Prompt: "Head to the dock. That's where the fishing starts."

    STEP 9 — TALK TO THE FISHERMAN
      TutorialArrow points to the Fisherman NPC.
      Prompt: "That old fisherman knows a thing or two. Have a word."
      Player must interact with the Fisherman NPC (triggers his tutorial hint).

    STEP 10 — DIVE IN
      TutorialArrow glows on the dive point (the buoy).
      Prompt: "Jump in. The fish aren't going to catch themselves."
      Player must interact with the dive point.

    STEP 11 — CAST (Cast Minigame Tutorial)
      The CastMinigame opens. An additional TutorialPrompt appears WITHIN
      the minigame UI, overlaid at the top: "Hold the button to fill the bar.
      Release when it reaches the green zone."
      Player must complete the cast (any quality — even a weak cast advances).

    STEP 12 — REEL (Reel Minigame Tutorial)
      ReelMinigame opens. Prompt: "Keep the marker in the green zone by
      holding the button. Don't let it snap!"
      Player must complete the reel (any outcome — even losing the fish
      advances the tutorial to prevent soft-locks).

    STEP 13 — CATCH (Catch Minigame Tutorial)
      If a fish was reeled in: CatchMinigame opens. Prompt: "Keep your
      crosshair away from the red zone. Five seconds. You've got this."
      If fish was lost in reel: Skip to step 14 automatically.

    STEP 14 — RETURN TO DOCK
      Prompt: "Good! Now head back to the dock. You can filet and sell there."
      Player must exit the ocean and return to dock area.

    STEP 15 — FILET (Optional Tutorial)
      If fish in inventory: TutorialArrow points to the Filet Table.
      Prompt: "You can process your fish here to get a better price. Try it."
      Player can either filet or skip (pressing a skip button advances).
      Prompt includes: "Trace along the dotted line. Press the key when prompted."

    TUTORIAL COMPLETE
      TutorialManager sets tutorial_completed = true in GameState.
      All tutorial UI hides. A brief fade plays. Day continues normally.
      From Day 2, TutorialManager._ready() checks tutorial_completed and
      immediately returns without doing anything.


================================================================================
  SECTION 18 — AUDIO SYSTEM
================================================================================

  AudioManager.gd (autoload #4) handles all music and SFX. It uses Godot's
  AudioStreamPlayer nodes internally. Music crossfades smoothly (1.5 second
  fade). SFX play as one-shots.

  TWO AUDIO BUSES
    MUSIC bus: Default volume 70%. Can be adjusted in SettingsMenu.
    SFX bus: Default volume 85%. Can be adjusted in SettingsMenu.

  MUSIC TRACKS (all .ogg files from CozyTunes Pro — use ogg/Tracks/)

    Town (Daytime)      : GentleBreeze.ogg
    Town (Night)        : EveningHarmony.ogg
    Beach / Dock        : FloatingDream.ogg
    Dock fishing idle   : fresh-water-tiles-music/ (whatever track exists there)
    Ocean Zone 1        : WhisperingWoods.ogg
    Ocean Zone 2        : ForgottenBiomes.ogg
    Ocean Zone 3        : StrangeWorlds.ogg
    Ocean Zone 4        : PolarLights.ogg
    Leviathan encounter : WanderersTale.ogg (interrupts zone music, fades back after)
    Shop / menus        : GoldenGleam.ogg
    Win screen          : CuddleClouds.ogg
    Game over screen    : DriftingMemories.ogg
    Day 1 tutorial      : SunlightThroughLeaves.ogg

  AMBIENT SFX (from CozyTunes ogg/SoundEffects/)
    NPC dialogue blip A : alienremarks.ogg   (plays per dialogue line, NPC A)
    NPC dialogue blip B : alienremarks2.ogg  (NPC B)
    NPC dialogue blip C : alienremarks3.ogg  (NPC C / Finn)
    Zone 3/4 sting      : phantom.ogg        (plays entering deep zones)
    Hazard warning      : presencebehind.ogg (plays when hazard is 3s away)
    Shark approach      : shadow.ogg         (plays when shark spawns)
    Leviathan warning   : stalker.ogg        (plays before Leviathan appears)
    Ocean ambient loop  : underwaterworld.ogg (quiet loop under zone music)

  UI SFX (from JDSherbert-UltimateUISFXPack/Free/Mono/ogg/)
    Button click, button hover, confirm purchase, cancel, menu open, menu close,
    inventory slot click, fish caught pop, debt paid chime — all drawn from
    JDSherbert pack. Map these by feel to appropriate sounds.

  AUDIO_MANAGER METHODS
    func play_music(track_name: String) -> void    # Crossfade to new track.
    func play_sfx(sfx_name: String) -> void        # One-shot SFX.
    func set_music_volume(val: float) -> void       # 0.0–1.0.
    func set_sfx_volume(val: float) -> void


================================================================================
  SECTION 19 — SAVE SYSTEM
================================================================================

  The save system is intentionally minimal. Since this is a 7-day hackathon
  game (10 min/day × 7 = 70 min max), a full save isn't strictly necessary.
  However, the system should save to a JSON file so that if the browser
  refreshes, progress isn't lost.

  SaveSystem.gd serialises the relevant GameState variables to JSON and writes
  them to user://save.json using Godot's FileAccess.

  WHAT IS SAVED
    - current_day, time_remaining
    - debt, cash
    - fish_inventory (array of fish dicts)
    - materials_inventory
    - equipped_rod, equipped_bait, bait_quantity, equipped_knife
    - rod_enchantment
    - active_charms
    - codex_discovered
    - tutorial_completed
    - days_without_payment

  WHAT IS NOT SAVED (recalculated fresh each session load)
    - NPC positions (they respawn)
    - Hazard positions (they respawn)
    - Beach foraging nodes (re-randomised on day start)

  AUTO-SAVE TRIGGERS
    - End of each day (before day_end_summary shows).
    - When the player sells fish.
    - When the player exits the shop.
    - On every scene transition.

  SAVE FILE FORMAT (JSON, stored at user://save.json)
    {
      "version": 1,
      "day": 2,
      "time_remaining": 423.7,
      "debt": 525.0,
      "cash": 47.50,
      "fish_inventory": [...],
      "materials": { "shell": 3, "coral": 1 },
      "rod": "rod_kelp",
      "rod_enchantment": "calm_waters",
      "bait": "live_shrimp",
      "bait_qty": 3,
      "knife": "knife_amateur",
      "charms": ["charm_crustacean_call"],
      "codex": { "sardine": true, "bass": true },
      "tutorial_done": true,
      "days_no_payment": 0
    }


================================================================================
  SECTION 20 — UI SCREENS (ALL)
================================================================================

  MAIN MENU (MainMenu.tscn)
    Background: BackDrops/Undersea.png (underwater scene, atmospheric).
    Title: "LOAN SHARK" in ThaleahFat font, large, white with a drop shadow.
    Buttons: "New Game", "Continue" (greyed out if no save), "Settings".
    Finn's silhouette visible in the corner. Not animated — just a static
    scary shadow.

  HUD (HUD.tscn — always visible during gameplay)
    Top-left:  Day counter ("Day 3 / 7") and time remaining (countdown timer).
    Top-right: Current cash ($XX.XX) and current debt ($XXX.XX in red).
    Bottom:    Active charm indicators (up to 2 small icons).
    Inventory bar at bottom: 12 slots showing fish icons or empty slots.
    The HUD uses Free-Basic-Pixel-Art-UI PNG frames for the panel backgrounds.

  FISH CAUGHT POPUP (FishCaughtPopup.tscn)
    Appears for 2 seconds after a successful Catch minigame.
    Shows: Fish name, fish icon, quality stars, estimated sale price.
    Slides in from the right side of the screen and auto-dismisses.

  DAY END SUMMARY (DayEndSummary.tscn)
    Full-screen popup at day end.
    Shows: Day number, fish caught today (list with values), total earned,
    debt paid today (if any), new debt total, interest added (if any).
    "Next Day" button to continue.

  WIN SCREEN (WinScreen.tscn)
    Background: animated celebration particles (CoinParticle.tscn bursting).
    Text: "DEBT CLEARED! You paid off Finn!"
    Shows final stats: Day cleared on, total fish caught, total earned.
    Finn dialogue: "...Fine. You win. Don't come back." Then winks.
    "Play Again" button returns to main menu.

  GAME OVER SCREEN (GameOverScreen.tscn)
    Two variants based on cause:
    1. debt_spiral: "Your debt exceeded $1,000. Finn owns your boat now."
    2. time_out:    "Seven days. Seven chances. All squandered."
    Shows debt remaining, days used, total earned across the run.
    "Try Again" button resets to new game.

  CODEX (Codex.tscn)
    A collection book. Each fish discovered (caught at least once) gets an
    entry showing its name, zone, description, and rarity. Undiscovered fish
    show as silhouettes ("???"). 38 entries total + 2 legendary (total 40).
    Players are rewarded for discovering all fish with a small visual badge.

  SETTINGS MENU (SettingsMenu.tscn)
    Sliders for Music Volume and SFX Volume.
    Keybinding display (read-only for the jam — no remapping).
    Language: English only.
    "Back" button.


================================================================================
  SECTION 21 — SCENE MANAGER
================================================================================

  SceneManager.gd (autoload #5) handles all scene transitions. It wraps
  Godot's get_tree().change_scene_to_file() with fade animations.

  TRANSITION TYPES
    fade_black  : Fades to black, loads scene, fades back in. Used for major
                  transitions (Town to Ocean, Game Over screen, Day End).
    slide_right : The new scene slides in from the right. Used for same-world
                  lateral movement (Town → Beach → Dock).
    instant     : No animation. Used only for development and minigame opens.

  KEY METHODS
    func go_to_town() -> void
    func go_to_beach() -> void
    func go_to_dock() -> void
    func go_to_ocean(zone: int) -> void
    func show_shop() -> void            # Opens shop as overlay on current scene.
    func show_inventory() -> void
    func show_crafting() -> void
    func show_codex() -> void
    func show_day_end_summary() -> void # Called by GameState.end_of_day().
    func show_win_screen() -> void
    func show_game_over(reason: String) -> void
    func start_minigame(type: String) -> void  # "cast", "reel", "catch", "filet"
    func end_minigame() -> void                # Returns to ocean/dock.

  The SceneManager keeps Main.tscn always loaded as the root. The HUD and
  TransitionLayer are children of Main.tscn and never unload. All other scenes
  are loaded as children of a "WorldContainer" Node2D inside Main.


================================================================================
  SECTION 22 — 7-DAY BUILD SCHEDULE
================================================================================

  This schedule maps each real day to the systems that must be complete and
  working by the end of that day.

  DAY 1 (REAL) — FOUNDATION
  Goal: The skeleton is alive. The game runs in a browser.
  Must ship:
    - project.godot configured with all 6 autoloads registered in order.
    - Main.tscn with WorldContainer and TransitionLayer.
    - GameState.gd: debt, cash, day, time variables. end_of_day() working.
    - FishDatabase.gd: All 38 fish defined as dictionaries. No scenes yet.
    - SceneManager.gd: go_to_town(), go_to_ocean(), show_day_end_summary().
    - AudioManager.gd: play_music(), play_sfx(). At least music plays.
    - SaveSystem.gd: save/load to JSON working.
    - HTML5 export profile set up. Game opens in browser without crashing.
  Test: Start the game, timer ticks down, day ends, summary screen shows,
  Day 2 begins. Save and reload works.

  DAY 2 (REAL) — WORLD
  Goal: The player can walk around and talk to NPCs.
  Must ship:
    - Town.tscn with BackDrops/an orange city.png background.
    - Player.tscn: left/right movement, idle/walk animations from charfree/global.png.
    - Shopkeeper NPC (static, dialogue box works for 2 lines).
    - Two roaming townsfolk NPCs (looping walk, one-liner dialogue on interact).
    - Beach.tscn with foraging node spawning (ForagingSpawner working, 8 nodes).
    - Dock.tscn with Dive Point interaction (just a placeholder for ocean entry).
    - Day/night overlay tint (DayNightOverlay.tscn — simple ColorRect opacity).
    - HUD.tscn showing debt, cash, day, timer.
  Test: Walk Town → Beach → Dock. Collect 3 materials on beach. Talk to NPC.
  HUD updates. Day/night tint visible as timer progresses.

  DAY 3 (REAL) — FISHING CORE (Cast + Zone 1 + Catch)
  Goal: The core fishing loop works end-to-end for Zone 1.
  Must ship:
    - Ocean.tscn and OceanZone1_Shallows.tscn with Underwater_Parallax layers.
    - FishSpawner: rolls from Zone 1 spawn table, selects a fish.
    - CastMinigame.tscn + cast_minigame.gd: Power bar, sweet spot, cast quality.
    - Camera pan to show hook sinking after cast.
    - CatchMinigame.tscn + catch_minigame.gd: Red zone bar, crosshair, 5-second timer.
    - FishCaughtPopup.tscn on successful catch.
    - fish_inventory updated in GameState on successful catch.
    - Inventory bar in HUD shows caught fish icons.
  Test: Enter ocean, cast, hook sinks, fish bites, catch minigame plays, fish
  added to inventory, inventory slot filled in HUD.

  DAY 4 (REAL) — FULL LOOP (Reel + Filet + Shop + Debt)
  Goal: Full single-day loop playable from start to debt payment.
  Must ship:
    - ReelMinigame.tscn + reel_minigame.gd: Zone bar, oscillating marker, reel_quality.
    - Fishing sequence correct: Cast → Reel → Catch (in order).
    - FiletMinigame.tscn + filet_minigame.gd: Mouse trace, QTE prompts, filet_mult.
    - Filet Table on Dock interactable, opens filet minigame for each fish.
    - Shop.tscn: Rod, bait, knife purchasable. Pay Debt button works.
    - GameState.sell_all_fish() working with full price formula.
    - Debt ticks +5% at end of day. GameState.end_of_day() fully functional.
    - DayEndSummary.tscn shows correct data.
  Test: Full playthrough of Day 1. Catch fish, filet them, sell them, pay some
  debt, day ends, interest applied, Day 2 starts. No crashes.

  DAY 5 (REAL) — MODIFIERS
  Goal: The roguelite system is live. Builds feel different.
  Must ship:
    - ModifierStack.gd: apply_spawn_multipliers(), apply_sell_multipliers().
    - SpawnTable.tres for Zone 1 with base weights.
    - Rod affinity system: Shell/Coral/Bone rods modify spawn weights.
    - Bait system: Earthworm bait modifies spawn weights per cast.
    - 2 craftable charms minimum (Crustacean Call and Sell Price charm).
    - CraftingMenu.tscn: Shows available recipes, allows crafting.
    - Charm slots in HUD visible and functional.
    - Rod Enchantment: At least Calm Waters enchantment working (reel oscillation
      reduced when enchanted). Enchantment Charm crafting works.
  Test: Equip Shell Rod + Earthworm bait + Crustacean Call charm. Verify crabs
  and shrimp appear more frequently than default. Compare fish distribution
  against a run with no modifiers.

  DAY 6 (REAL) — CONTENT PASS
  Goal: All 4 zones, all 38 fish, all hazards, tutorial, win/lose working.
  Must ship:
    - OceanZone2, OceanZone3, Ocea
  LOAN SHARK — GDD v3 CONTINUATION (FROM DAY 6 OF BUILD SCHEDULE)
  Picks up exactly where the shared document ended.
================================================================================

  NOTE TO AGENT: This file is the direct continuation of the GDD v3 document
  you already have. Append this after the last line of that file:
  "    - OceanZone2, OceanZone3, Ocea i will share more info later"
  Everything below continues from that cut-off point.

--------------------------------------------------------------------------------

    - OceanZone2_KelpForest.tscn with Sinky_Sub_Cliffs + CloseRockKelp layers.
    - OceanZone3_SunkenRuins.tscn with Sinky_Sub_Ruins_Whale layer and depth fog.
    - OceanZone4_BiolumDeep.tscn with underwater-fantasy-files PNG layers and
      BiolumParticle.tscn effect active as a persistent ambient particle system.
    - All 38 fish scenes created (FishBase.tscn instanced with each fish's
      .tres resource loaded). Sprites pulled from fishing_free/global.png
      and free-fishing-game-assets-pixel-art-pack/3Objects/Catch/ as appropriate.
    - Zone locking enforced: Zone 2 blocked without Intermediate rod. Zone 4
      blocked without Pro rod AND Deep Bait (Deep Sea Lure or Luminous Lure).
    - All 5 hazard scenes active and spawning: Jellyfish (Z1–Z2), Electric Eel
      (Z2–Z3), Shark (Z3), Octopus (Z2–Z3), Turtle (Z1–Z2). Midnight Leviathan
      as hazard in Z3–Z4 (not the catchable version — the shadow pass variant).
    - All hazard effects functional: stun, line snap, ink blackout, push-back.
    - SharkWarningVignette.tscn playing 3 seconds before shark arrives.
    - LeviathanShake.tscn screen shake triggering on Leviathan hazard pass.
    - TutorialManager.gd: All 15 tutorial steps wired up and running on Day 1.
      TutorialArrow and TutorialPrompt scenes working. Day 2+ tutorial dormant.
    - WinScreen.tscn: Full win display with CoinParticle burst, Finn dialogue,
      final stats, Play Again button.
    - GameOverScreen.tscn: Both debt_spiral and time_out variants working.
    - Codex.tscn: 40 entries (38 fish + 2 legendary). Silhouette display for
      undiscovered fish. codex_discovered dict in GameState tracking correctly.
    - All 12 music tracks assigned to correct scenes via AudioManager.
    - All ambient SFX (CozyTunes SoundEffects) triggered at correct moments.
    - All UI SFX (JDSherbert pack) wired to buttons, confirms, fish caught, etc.

  Test for Day 6: Play all 4 zones. Verify hazards in each. Complete tutorial
  on Day 1. Catch a Coelacanth (Zone 3 legendary — confirm 2% spawn, confirm
  "only 1 per day" cap). Catch a Midnight Leviathan in Zone 4 at night —
  confirm 20% debt clear triggers. Win screen appears when debt hits zero.
  Game Over screen appears when debt > $1000. Codex fills correctly.

  DAY 7 (REAL) — SHIP
  Goal: The game is polished, optimised, and submitted to itch.io.
  Must ship:
    - All particle effects tuned (WaterSplash, BubbleTrail, CatchFlash, etc.)
    - DepthFog.tscn opacity correctly set per zone (Z1: 0%, Z2: 15%, Z3: 40%,
      Z4: 80% — near total darkness broken only by bioluminescent particles).
    - DayNightOverlay.tscn smooth colour gradient: morning yellow → afternoon
      orange → evening dark blue → night near-black, cycling over 600 seconds.
    - Touch input: All minigames playable via touchscreen. Cast: tap and hold.
      Reel: tap and hold. Catch: drag. Filet: finger trace + screen QTE tap.
    - Frame rate target: stable 60fps in HTML5 export. Profile and remove any
      heavy _process() calls that aren't necessary. Use _physics_process() only
      for physics. Use timers instead of frame counters.
    - HTML5 export profile confirmed: "Export With Debug" OFF, "Threads" OFF
      (threads cause issues in some browsers), VRAM texture compression ON.
    - Tested in Chrome, Firefox, and Safari (minimum). No console errors.
    - itch.io page set up: game title, description, screenshots, tag "jam".
    - export_presets.cfg committed. Game uploaded to itch.io and set to public.

  Test for Day 7: Fresh browser session (no save file). Play from main menu
  through a full 7-day run. Win or lose — doesn't matter. Verify no crashes,
  no console errors, all audio plays, all transitions work, touch input works
  on a phone or tablet if available. Submit.


================================================================================
  SECTION 23 — PRIORITY TIERS (P0 → P3)
================================================================================

  If time runs short during the build week, cut lower-priority features first.
  P0 must ship. P1 should ship. P2 ship if time allows. P3 is polish only.

  P0 — MUST HAVE (game is unplayable without these)
    - GameState (debt, cash, day, time, fish_inventory)
    - FishDatabase (all 38 fish defined)
    - SceneManager (scene transitions)
    - AudioManager (basic music play/stop)
    - Cast minigame
    - Reel minigame
    - Catch minigame
    - Shop (buy bait, pay debt, buy rod)
    - Debt tick system (5% interest per day, $1000 cap)
    - DayEndSummary screen
    - WinScreen and GameOverScreen
    - Zone 1 fully functional
    - Save/load system (JSON)

  P1 — SHOULD HAVE (core experience is shallow without these)
    - Filet minigame
    - Beach foraging and material system
    - Crafting menu and at least 4 craftable charms
    - Zone 2 (Kelp Forest) with correct fish pool
    - Amateur and Intermediate rods purchasable and working
    - Bait system (at least 4 bait types affecting spawn weights)
    - Tutorial (Day 1 only, at least 8 of the 15 steps)
    - SaveSystem auto-saving at day end

  P2 — NICE TO HAVE (adds depth and replayability)
    - Zone 3 and Zone 4
    - All remaining fish (zones 3–4)
    - All hazards (shark, octopus, leviathan hazard variant)
    - Rod enchantments (all 8)
    - All remaining charms (full 24 charm set)
    - Pro rod tier
    - Codex (fish discovery system)
    - Full NPC dialogue for all 7 days (Finn's escalating threats)
    - Night-only fish mechanics (Ghost Crab, Phantom Eel, Midnight Leviathan)
    - Leviathan as catchable fish in Zone 4

  P3 — POLISH (only if Day 7 has spare time)
    - Particle effects tuned (BubbleTrail, CatchFlash, CoinParticle)
    - Key remapping in settings
    - Full touch input polish (tested on real mobile device)
    - Finn's win/lose unique dialogue variants
    - Codex completion badge
    - Oarfish two-slot mechanic
    - Lanternfish swarm partial-catch mechanic
    - DayNightOverlay smooth colour gradient (vs. simple snap)
    - Animated title screen with Finn's shadow


================================================================================
  SECTION 24 — MODIFIER FISH (SPECIAL CATCH EFFECTS)
================================================================================

  Four fish in the roster have a modifier_effect field that triggers a special
  gameplay event when caught. These are documented in Section 6 (Fish Database)
  but deserve extra implementation detail here.

  GOLDFISH MODIFIER (Zone 4 — deepwater_goldfish)
    modifier_effect: "goldfish_next_sale_bonus"

    When the Midnight Leviathan fight ends with a successful Catch and this fish
    enters inventory, ModifierStack sets a flag:
      ModifierStack.goldfish_next_sale_active = true
      ModifierStack.goldfish_next_sale_fish_index = 0  # Counter.

    When the player sells fish, the sell loop checks this flag. The FIRST fish
    sold after a goldfish catch gets its final calculated price multiplied by
    1.5 (that one fish only). After that fish is sold:
      ModifierStack.goldfish_next_sale_active = false

    The HUD shows a small "GOLDEN SALE" indicator while this bonus is pending.
    If the player dies or the day ends before selling, the bonus is lost.
    The goldfish itself also sells for $300 base and goes through the normal
    price formula — the bonus only applies to the NEXT fish after the goldfish.

  GHOST CRAB (Zone 2 — ghost_crab)
    modifier_effect: "ghost_crab_night_bonus"

    Ghost Crab is a night-only fish ($65 base). Its modifier effect is simpler:
    When sold at NIGHT (checked via GameState time — night = last 25% of day
    timer), its sale price is multiplied by 1.5x BEFORE any charm multipliers
    are applied. This is in addition to the Night Charm bonus if active.

    Implementation: In GameState.sell_all_fish(), for each ghost_crab fish,
    check if current time qualifies as night. If yes, apply 1.5x price before
    other multipliers. The FishCaughtPopup can display "NIGHT BONUS!" text
    when a ghost crab is caught during qualifying hours to hint at this mechanic.

  SEA ANGEL (Zone 4 — sea_angel)
    modifier_effect: "sea_angel_charm_double"

    When a Sea Angel is caught and added to inventory, ModifierStack immediately
    applies a temporary 2x multiplier to BOTH active charm effects for the rest
    of the current day. Specifically:
      - All sell-price charms: their percentage bonus doubles.
        Example: A Coral Charm (+30% reef fish) becomes +60% reef fish.
      - All spawn-rate charms: their weight multiplier doubles.
        Example: Crustacean Call (+40% crustacean) becomes +80%.
      - The same-family cap (1.5x instead of 2x) is recalculated AFTER doubling.

    This is the most powerful modifier fish effect. A player with the right
    charms active who catches a Sea Angel on the last day can generate
    enormous income from a single fishing session. This is an intentional
    high-skill, high-reward moment.

    The HUD charm indicators should glow or pulse visually when this effect
    is active to communicate the change.

  MIDNIGHT LEVIATHAN (Zone 4 — midnight_leviathan)
    modifier_effect: "leviathan_debt_clear"

    When the Leviathan is caught (extremely rare — 1% per cast in Zone 4 at
    night only), before the FishCaughtPopup shows, a special cinematic plays:
      1. LeviathanShake.tscn — full screen shake for 2 seconds.
      2. Screen goes black for 0.5 seconds.
      3. Text appears: "THE DEEP HAS NOTICED YOU."
      4. Another 0.5-second pause.
      5. FishCaughtPopup slides in showing "MIDNIGHT LEVIATHAN — $800+ BASE"
         with a special golden border (not the normal fish popup style).
      6. Simultaneously: GameState.debt is reduced by 20%.
         A "DEBT -20%!" notification slides in from the left side of screen.

    The Leviathan adds 1 inventory slot and sells for $800 base (modified by
    size and reel quality as normal). The 20% debt clear is applied immediately
    on catch, not at sell time — so even if the player somehow loses the fish
    from their inventory, the debt reduction stays.

    Note: The Midnight Leviathan also appears as a HAZARD (non-catchable, a
    shadow pass) in Zones 3 and 4. The HAZARD version does not trigger the
    modifier effect — only the catchable fish version (when you reel it in and
    win the Catch minigame) triggers it. The hazard version only breaks your
    line and pushes you 100px toward Zone 1.


================================================================================
  SECTION 25 — GREED METER (OPTIONAL STRETCH SYSTEM)
================================================================================

  NOTE: This is a P2 feature. Implement only after all P0 and P1 features
  are complete. If cut for time, the game functions without it.

  PURPOSE
  The Greed Meter is a hidden pressure mechanic that makes staying in deeper
  zones for too long increasingly dangerous. It prevents players from farming
  Zone 4 indefinitely by escalating the hazard rate the longer they stay.

  HOW IT WORKS
    greed_meter.gd tracks a variable: greed_level (0.0 to 1.0, starts at 0).
    Every second the player spends in Zone 3 or Zone 4, greed_level increases:
      Zone 3: +0.005 per second (fills in ~200 seconds / ~3.3 minutes)
      Zone 4: +0.010 per second (fills in ~100 seconds / ~1.7 minutes)
    When the player surfaces (leaves the ocean), greed_level resets to 0.

    As greed_level rises, hazard spawn rates are multiplied:
      greed_level 0.0–0.3: No modifier (normal hazard rate).
      greed_level 0.3–0.6: Hazard spawn rate × 1.5.
      greed_level 0.6–0.9: Hazard spawn rate × 2.5. Shadow.ogg starts looping.
      greed_level 0.9–1.0: Hazard spawn rate × 4.0. Screen vignette pulses red.

    At greed_level 1.0 (maximum): The Midnight Leviathan HAZARD is guaranteed
    to spawn. It will chase the player toward the surface. This is the "you've
    stayed too long" moment. The player must surface or lose their fishing line
    and be ejected from the ocean scene.

  VISUAL INDICATOR
    A small depth pressure gauge is shown in the HUD corner (only visible in
    Zone 3 and Zone 4). It shows a stylised fathom gauge that fills from bottom
    to top as greed_level rises. At 0.6+ it starts glowing amber. At 0.9+ it
    glows red and pulses.

  DESIGN INTENT
    The Greed Meter enforces the core tension loop. Players are rewarded for
    taking the risk of going deep, but punished for overstaying their welcome.
    A skilled player learns to dip into Zone 4, catch 4–6 fish, and surface
    before the meter fills. A greedy player who stays too long loses fish to
    hazards — sometimes losing more value than they gained by staying.

    This system is named after the thematic interpretation of "greed" — wanting
    more than you can safely take. It reinforces the loan shark metaphor: the
    deeper you dig into debt (the ocean), the more dangerous it gets.


================================================================================
  SECTION 26 — COMPLETE CRAFTING RECIPE TABLE
================================================================================

  This is the definitive recipe list for all craftable charms.
  Implement these exactly in crafting_recipes.tres files.
  Material quantities must be met exactly (not "at least" — exact amounts).

  FORMAT: Charm Name → Required Materials → Result

  --- SELL PRICE CHARMS ---

  SHELL CHARM        : Shell ×3, Sea Glass ×1
                       → +25% sell price on crustacean fish.

  CORAL CHARM        : Coral ×3, Algae ×1
                       → +30% sell price on reef fish.

  DEEP CHARM         : Deep Crystal ×2, Small Bone ×1
                       → +35% sell price on deep family fish.

  TIDE CHARM         : Driftwood ×2, Coral ×1
                       → +20% sell price on ALL fish.

  GOLD CHARM         : Gold Sand ×3, Sea Glass ×2
                       → +50% sell price on next 3 fish sold only.

  NIGHT CHARM        : Night Kelp ×2, Ghost Fin ×1
                       → +40% sell price on night-only fish.

  BLOOD CHARM        : Shark Tooth ×2, Small Bone ×2
                       → +60% sell price on rare and ultra-rare fish.

  INK CHARM          : Ghost Crab Shell ×2, Algae ×1
                       → +25% sell price on cephalopod fish (octopus).

  --- SPAWN RATE CHARMS ---

  EEL WARD           : Ghost Fin ×2, Driftwood ×1
                       → -50% eel family spawn weight.

  SIREN CHARM        : Sea Glass ×3, Algae ×1
                       → +30% pelagic fish spawn weight.

  CRUSTACEAN CALL    : Shell ×2, Sand Crab ×2
                       → +40% crustacean spawn weight.

  BONY LURE          : Small Bone ×3, Driftwood ×1
                       → +35% bony fish spawn weight.

  DEPTH PULSE        : Deep Crystal ×3, Echo Coral ×1
                       → +40% deep family spawn weight (Zones 3–4 only).

  FORTUNE BAIT       : Gold Sand ×2, Sea Glass ×1
                       → +20% spawn weight to rare-tier and above.

  CALM TIDE          : Coral ×2, Algae ×2
                       → -30% all hazard spawn rates.

  FRENZY CHARM       : Shark Tooth ×1, Ghost Fin ×1, Night Kelp ×1
                       → +50% all spawn weights. Reel snap chance +20%.

  --- ENCHANTMENT CHARMS (one-time use, permanently enchants equipped rod) ---

  TIDE BLESSING CHARM   : Shell ×5, Echo Coral ×2, Gold Sand ×1
                          → Enchants rod with Tide Blessing.
                            (+20% sell price on Zone 1 and Zone 2 common fish.)

  DEEP LURE CHARM       : Deep Crystal ×4, Small Bone ×2
                          → Enchants rod with Deep Lure.
                            (+40% spawn weight to Zone 3 and Zone 4 rare+ fish.)

  FORTUNE HOOK CHARM    : Gold Sand ×4, Sea Glass ×3
                          → Enchants rod with Fortune Hook.
                            (Every 7th cast guaranteed rare+ fish.)

  GHOST BAIT CHARM      : Ghost Fin ×3, Night Kelp ×3
                          → Enchants rod with Ghost Bait.
                            (Night-only fish spawn during daytime too.)

  CALM WATERS CHARM     : Coral ×4, Algae ×3, Sea Glass ×2
                          → Enchants rod with Calm Waters.
                            (Reel oscillation amplitude -30%.)

  BLOOD TIDE CHARM      : Shark Tooth ×4, Small Bone ×3
                          → Enchants rod with Blood Tide.
                            (Rare+ spawn weight +30%, hazard rate +50%.)

  ECHO LINE CHARM       : Echo Coral ×3, Sea Glass ×2, Driftwood ×2
                          → Enchants rod with Echo Line.
                            (After each catch, +15% weight for same species
                            on next 3 casts.)

  WEIGHTED SINK CHARM   : Small Bone ×2, Driftwood ×3, Deep Crystal ×1
                          → Enchants rod with Weighted Sink.
                            (Hook sinks 40% faster. More casts per minute.)


================================================================================
  SECTION 27 — SPAWN TABLE WEIGHTS (ZONE BY ZONE)
================================================================================

  These are the BASE integer weights for each fish in each zone's spawn table.
  Higher weight = higher probability. The table is normalised each cast.
  Modifiers multiply these base weights, then the table is renormalised.

  All weights below assume: no bait, no rod affinity, no charms, no enchantment.

  --- ZONE 1 BASE SPAWN TABLE ---
  Fish              | Base Weight | Notes
  ------------------|-------------|------------------------------------------
  Sardine           |     25      | Most common fish in Zone 1.
  Perch             |     20      | Second most common.
  Rock Shrimp       |     18      | Common crustacean.
  Flounder          |     15      | Reliable common bony.
  Sea Bass          |     12      | Standard bony fish.
  Moon Jellyfish    |     10      | Uncommon but notable.
  Shore Crab        |      8      | Less common than shrimp.
  Pufferfish        |      6      | Uncommon.
  Clownfish         |      5      | Uncommon reef.
  Seahorse          |      4      | Least common Zone 1 fish.
  NIGHT-ONLY        |      0      | (No Zone 1 night-only fish.)
  Total base weight : 123 (normalise to %).

  --- ZONE 2 BASE SPAWN TABLE ---
  Fish              | Base Weight | Notes
  ------------------|-------------|------------------------------------------
  Needlefish        |     20      | Most common Zone 2 fish.
  Snapper           |     18      | Common bony.
  Trumpetfish       |     15      | Common reef.
  Young Octopus     |     12      | Uncommon cephalopod.
  Moray Eel (Young) |     10      | Uncommon eel.
  Grouper           |      8      | Rare-tier, but still spawns.
  Stonefish         |      6      | Rare.
  Spiny Lobster     |      5      | Rare crustacean.
  Abyssal Shrimp    |      4      | (Rare crustacean from Z3 but peeks in Z2.)
                                     NOTE: Abyssal Shrimp is primarily Z3 but
                                     has a tiny crossover spawn weight in Z2.
  Batfish           |      3      | Night only — weight applies only at night.
  Ghost Crab        |      2      | Night only — weight applies only at night.
  Total base weight : 103 (normalise to %).

  NIGHT TIMING NOTE: "Night" is defined as the last 25% of the day timer.
  At 600 seconds/day, night begins at 150 seconds remaining.
  Night-only fish have weight 0 during the day. At night their weights are
  inserted as listed above and the table is renormalised including them.

  --- ZONE 3 BASE SPAWN TABLE ---
  Fish              | Base Weight | Notes
  ------------------|-------------|------------------------------------------
  Stone Crab        |     18      | Most accessible rare-tier.
  Abyssal Shrimp    |     15      | Common for Zone 3.
  Rugose Crab       |     12      | Crustacean heavy zone.
  Anglerfish        |     10      | Iconic deep fish.
  Moray (Giant)     |      8      | Rare eel.
  Oarfish           |      6      | Rare bony — takes 2 slots.
  Viperfish         |      5      | Rare deep.
  Dragonfish (Juv.) |      4      | Rare deep.
  Coelacanth        |      2      | Legendary — 2% base weight. Max 1/day.
  Phantom Eel       |      3      | Night only.
  Total base weight : 83 (normalise to %).

  COELACANTH CAP: Implemented via a flag in GameState:
    GameState.coelacanth_caught_today: bool = false
  In spawn_table.gd, before adding Coelacanth to the active weight table,
  check this flag. If true, set Coelacanth weight to 0 for all remaining casts
  that day. Reset the flag at start of next day.

  --- ZONE 4 BASE SPAWN TABLE ---
  Fish              | Base Weight | Notes
  ------------------|-------------|------------------------------------------
  Lanternfish Swarm |     25      | Most common Zone 4 — volume catch.
  Fangtooth         |     18      | Relatively common deep predator.
  Deep Anglerfish   |     14      | Ultra-rare but most frequent Z4 fish.
  Barreleye         |     12      | Ultra-rare floater.
  Gulper Eel        |      8      | Difficult eel.
  Dragonfish (Adult)|      6      | Ultra-rare deep predator.
  Frilled Shark     |      4      | Second rarest Z4 fish.
  Sea Angel         |      3      | Ultra-rare modifier fish.
  Deepwater Goldfish|      2      | Ultra-rare modifier fish.
  Midnight Leviathan|      1      | Night only. 1% base weight at night only.
  Total base weight : 93 (normalise to %).

  MIDNIGHT LEVIATHAN NOTE: Its base weight of 1 is only inserted into the
  table during night hours (last 25% of day timer). During daytime in Zone 4,
  the Leviathan weight is 0 — it literally cannot spawn as a catchable fish.
  It can still appear as a hazard at any time in Zone 4.


================================================================================
  SECTION 28 — NPC DIALOGUE SCRIPTS (COMPLETE)
================================================================================

  This section provides complete dialogue for all NPCs for all 7 days.
  Finn's dialogue escalates in threat. Townsfolk dialogue changes based on day.
  All dialogue uses the DialogueBox.tscn component.

  --- FINN (THE LOAN SHARK SHOPKEEPER) ---

  Finn's opening dialogue plays automatically each morning when the player
  first enters the shop. He also has reactive lines when the player pays debt.

  DAY 1 OPENING (tutorial integration — plays as STEP 1 of tutorial):
    "Ahh, our newest customer. Fresh face, empty pockets, and a fishing rod
    you found on the beach. Classic.
    Listen up: you owe me five hundred dollars. You have exactly seven days.
    Every day you don't pay, I add five percent. Easy math. Painful math.
    The fish are out there. Get to work."

  DAY 2 OPENING (if debt unpaid yesterday):
    "Still here? I was half expecting you to flee town overnight.
    The interest has been added. Tick tock.
    You'll find the numbers on your account... unfavorable."

  DAY 2 OPENING (if player paid something Day 1):
    "You made a payment. Good. A small one, but it shows character.
    Don't let that become a habit of thinking small."

  DAY 3 OPENING (debt > $550):
    "Three days gone. Your debt is going the wrong direction.
    I've seen this before. I don't enjoy what usually happens next.
    For your sake — catch something valuable today."

  DAY 3 OPENING (debt ≤ $400, making good progress):
    "Making progress. I'm almost impressed.
    Don't slow down now. The ocean gets more interesting the deeper you go."

  DAY 4 OPENING (debt > $500):
    "Four days. Half your time.
    I'll be honest — I'm starting to make plans for your boat.
    It's a nice boat. Shame if something happened to it."

  DAY 4 OPENING (debt ≤ $300):
    "Well, well. You might actually pull this off.
    I've had people make it this far and then choke in the final stretch.
    Don't be one of them."

  DAY 5 OPENING (debt > $400):
    "Getting nervous? You should be.
    Two days after today. That's not a lot of fish."

  DAY 5 OPENING (debt ≤ $200):
    "The finish line is in sight for you.
    Don't get cocky — I've seen people throw away a winning hand."

  DAY 6 OPENING (debt > $200):
    "One day left after today. I hope you have a plan.
    Something big. Zone 4 big, if you know what I mean."

  DAY 6 OPENING (debt ≤ $100):
    "Almost done. One good haul and you're free.
    I almost don't want you to make it — you've been an interesting customer."

  DAY 7 OPENING:
    "This is it. Last day.
    If the sun sets and you still owe me money...
    let's just say I prefer not to discuss what happens next.
    Go fish. Make it count."

  --- FINN REACTIVE LINES (during shop interaction) ---

  On Pay Debt (small payment, debt > $300 remaining):
    "A trickle. Better than nothing. Barely."

  On Pay Debt (significant payment, debt reduced by > $100):
    "Now that's more like it. Keep that up."

  On Pay Debt (debt reaches 0):
    "...Fine. A deal is a deal.
    You're paid up. Get out of my shop.
    [pauses]
    ...Come back if you need another loan. I'll be here."
    → Win screen triggers immediately after this dialogue.

  On trying to buy something player can't afford:
    "Your pockets are lighter than your brain, apparently.
    Come back when you have actual money."

  On buying a Pro rod (first time):
    "The deep ones. Bold choice.
    Bring back something worth my time."

  --- THE FISHERMAN NPC (DOCK) ---

  Day 1 (Tutorial Step 9):
    "New to these waters, eh? Let me tell you something.
    The shallow end will keep you alive. The deep end will make you rich.
    But the deep takes more than it gives, if you're not careful.
    Start slow. Learn the zones. Don't get greedy."

  Day 2:
    "Saw you come back with a decent haul yesterday.
    The kelp forest isn't far if you've got the right rod.
    Stonefish are worth good money — nasty things, but valuable."

  Day 3:
    "You hear that? Below the kelp there are ruins.
    Nobody's mapped them properly. Things live there that don't have names yet.
    Good money for anyone brave enough. Or foolish enough."

  Day 4:
    "Word of advice — watch for the shark.
    You'll know it's coming by the colour of the water changing.
    Red vignette at the edge of your vision. That's your warning. Swim fast."

  Day 5:
    "The deep. Zone Four. You considered it?
    You'll need a proper rod and the right bait. Luminous lures or deep-sea rigs.
    And go at night. That's when the real things come out."

  Day 6:
    "One day left after today, I hear.
    If you've got the gear, Zone Four tonight is your best shot.
    Leviathan's down there. Catch it and you'll write off half your trouble."

  Day 7:
    "Last chance. You know what to do.
    The deep doesn't forgive hesitation."

  --- TOWNSFOLK NPC A (loops through day-appropriate lines) ---

  Day 1: "Nice morning for fishing. Or so I've heard."
  Day 2: "Saw you heading out early. That Finn character makes me nervous."
  Day 3: "The kelp forest smells strange today. Good kind of strange."
  Day 4: "Someone said they saw the shadow of something enormous, deeper down."
  Day 5: "Three days left! You've got this! ...probably."
  Day 6: "Night fishing tonight? The ghost crabs are worth it."
  Day 7: "Everyone's watching to see if you make it. No pressure."

  --- TOWNSFOLK NPC B ---

  Day 1: "Fresh fish for sale? I mean... not yet. You just arrived."
  Day 2: "Finn was asking about you this morning. Didn't sound casual."
  Day 3: "Have you tried the coelacanth? Ancient thing. Worth a fortune."
  Day 4: "My cousin owed Finn once. He doesn't fish anymore."
  Day 5: "Deep water fishing at your stage? Respect."
  Day 6: "Almost there. The whole town's rooting for you."
  Day 7: "Go. Don't talk to me. GO."

  --- TOWNSFOLK NPC C (near the mailbox, gives debt hints) ---

  Day 1: "Debt grows faster than fish. Fun fact."
  Day 2: "Five percent doesn't sound like much until it's your money."
  Day 3: "Partial payments help. Even a little reduces tomorrow's interest."
  Day 4: "The deeper fish are worth three times the shallow ones. Do the math."
  Day 5: "Charms are underrated. Craft something before you dive today."
  Day 6: "Night Kelp only appears at dusk. Gather it before it's gone."
  Day 7: "...I can't watch. Tell me how it ends."


================================================================================
  SECTION 29 — CODEX ENTRY DESCRIPTIONS (COMPLETE)
================================================================================

  The Codex (Codex.tscn) shows a fish description and flavour text when the
  player discovers a fish. These should be stored in each fish's .tres resource
  under the "description" field. Shown here for completeness.

  Zone 1 entries (not listed in Section 6, expanded here):
    Snapper (Z2):       "A popular table fish with a misleading name — it doesn't
                         actually snap. The buyers don't care. They just like the taste."
    Grouper (Z2):       "Gets its name from its habit of loitering in groups. Large,
                         meaty, stubborn on the line. Worth the fight."
    Trumpetfish (Z2):   "Thin, long, and surprisingly graceful for something that
                         looks like a floating stick. Reef fish. Buyers use them
                         for display as much as for eating."
    Spiny Lobster (Z2): "Worth nearly four times a sardine. The spines are
                         decorative. The fight is not."
    Stonefish (Z2):     "Camouflages as a rock until you try to pull it out of the
                         water. The venom in its spines is the most potent of any
                         fish. Wear gloves. Sell quickly."
    Octopus (Z2):       "Intelligent enough to recognize your face. Judges you
                         silently as you reel it in. Sells well to buyers who
                         prefer not to think about that."
    Needlefish (Z2):    "Moves like a thought. Thin enough to miss entirely. The
                         fastest reel in the shallows."
    Gulper Eel (Z4):    "Has a jaw approximately 25% of its total body length.
                         Can swallow prey larger than itself. This is not a comforting
                         fact when you are in Zone Four."
    Barreleye (Z4):     "The transparent dome on its head is not its skull. It's
                         a liquid-filled lens for its enormous upward-pointing eyes.
                         It is looking at you. It is always looking at you."
    Fangtooth (Z4):     "Has the largest teeth relative to body size of any known
                         fish. Cannot close its mouth fully. This is by design.
                         The design is terrifying."
    Lanternfish Swarm:  "Not one fish. A coordinated mass of bioluminescent bodies
                         moving as one. Each individual is small and unremarkable.
                         Together they are worth $200 if your inventory can hold them."


================================================================================
  SECTION 30 — IMPLEMENTATION NOTES FOR CODING AGENT
================================================================================

  This section collects specific implementation decisions that would otherwise
  require clarifying questions. Use these as definitive answers.

  1. SCENE TREE STRUCTURE
     Main.tscn is the persistent root. Its children:
       - WorldContainer (Node2D): Current world scene loaded here.
       - HUD (CanvasLayer): Always visible, z-index above everything.
       - TransitionLayer (CanvasLayer): Black ColorRect for fades, z-index highest.
       - DialogueBox (CanvasLayer): Dialogue UI, hidden when not in use.
     Scene changes: SceneManager removes the old child from WorldContainer
     and adds the new scene as a child. This keeps HUD and transitions intact.

  2. MINIGAME INTEGRATION
     Minigames are NOT separate scenes loaded into WorldContainer.
     They are CanvasLayer scenes that appear ON TOP of the current world scene.
     SceneManager.start_minigame("cast") adds CastMinigame as a child of Main,
     then removes it when the minigame emits its completion signal.
     This means the ocean background is still visible behind the cast minigame UI.

  3. FISH INSTANCE DICTIONARIES
     When a fish is caught, create a dictionary immediately:
       var fish_instance = {
         "id": fish_data.id,
         "name": fish_data.name,
         "base_price": fish_data.base_price,
         "size_mult": randf_range(fish_data.size_range[0], fish_data.size_range[1]),
         "reel_quality": 0.0,      # Filled in after reel minigame completes.
         "fileted": false,
         "filet_mult": 1.0,        # Updated if filet minigame is run.
         "zone_caught": current_zone,
         "caught_at_night": is_night  # For ghost crab bonus check at sell time.
       }
     reel_quality is attached to this dict in the reel_complete signal handler.
     filet_mult is updated if the player runs the filet minigame on this fish.

  4. MODIFIER STACK ORDER
     ModifierStack.apply_spawn_multipliers(base_table, zone) → modified_table
     ModifierStack.apply_sell_multipliers(price, fish_instance) → final_price
     The spawn multiplier runs in this exact order: rod → enchantment → bait → charm.
     The sell multiplier runs: base × size × reel_quality × filet × charm × special.
     "Special" = goldfish bonus, ghost crab night bonus, sea angel charm double.

  5. REEL MINIGAME TIMING
     The reel duration is fish-specific. Use this formula:
       duration = lerp(5.0, 15.0, (fish_data.base_price - 4) / 246.0)
     This maps $4 (sardine, cheapest) to 5 seconds and $250 (sea angel) to ~15s.
     The Midnight Leviathan is hardcoded at 20 seconds reel duration.
     Clamp the result: min 5.0, max 20.0.

  6. DAY/NIGHT TIMING
     Day is 600 seconds total.
     Morning:   600 → 450 seconds remaining (first 25% = bright, warm tint).
     Afternoon: 450 → 300 seconds remaining (middle 25% = neutral).
     Dusk:      300 → 150 seconds remaining (last 50% first half = orange tint).
     Night:     150 → 0   seconds remaining (last 25% = dark blue/black tint).
     Night-only fish spawn during the Night phase (0–150 seconds remaining).
     Night Kelp spawns on the beach only during Night phase.
     Ghost Crab Shell spawns on beach only during Night phase.

  7. FONT USAGE
     ThaleahFat.ttf is the ONLY font used anywhere in the game.
     All text — HUD, dialogue, UI buttons, menus, popups — uses ThaleahFat.
     Sizes: Title text = 48pt. HUD labels = 20pt. Dialogue = 18pt. Tooltips = 14pt.
     Do not use Godot's default font anywhere. Set ThaleahFat as the project
     default font in Project Settings → Theme.

  8. INVENTORY UI
     The 12-slot inventory bar at the bottom of the HUD uses
     Free-Basic-Pixel-Art-UI-for-RPG/PNG/ panel frames as the slot backgrounds.
     Each slot is a TextureButton (64×64px). When a fish is in the slot:
       - Slot background = filled frame texture.
       - Slot icon = fish sprite region from fishing_free/global.png.
       - Small quality indicator: 1–5 small star icons below the fish icon.
     Quality star calculation: round(reel_quality × 5). So 0.9 reel = 4.5 → 5 stars.

  9. PRICE DISPLAY
     All prices always show exactly 2 decimal places. Use:
       "$%.2f" % price
     In UI labels and popups. Never show "$500" — always "$500.00".
     The debt display in HUD should visually pulse (brief red flash) when
     interest is added at end of day.

  10. ERROR HANDLING IN MINIGAMES
      All four minigames must handle the case where they are interrupted mid-play
      (player pauses, browser loses focus, etc.). On resume, the minigame
      resets to its initial state (power bar refills, reel marker resets).
      Fish are NOT added to inventory if a minigame is interrupted — only on
      the completion signal. This prevents exploits via pause-quit-reload.

  11. PARALLAX BACKGROUND SETUP
      All ocean zones use a ParallaxBackground node with multiple
      ParallaxLayer children. Layer settings for Zone 1:
        Layer 1 (Sinky_Sub_BG.png):       motion_scale = Vector2(0.05, 0.0)
        Layer 2 (Sinky_Sub_GodRays.png):   motion_scale = Vector2(0.15, 0.05)
        Layer 3 (Sinky_Sub_Floor.png):     motion_scale = Vector2(0.4, 0.0)
      For zones 2–3, replace layers with appropriate sprites. Keep same scale
      ratios. Zone 4 uses a single layer with underwater-fantasy-files PNGs —
      they tile seamlessly (confirm when importing, enable repeat texture mode).

  12. HTML5 EXPORT GOTCHAS
      - FileAccess works in HTML5 for user:// path (browser localStorage is used
        by Godot internally). Save/load will work without extra code.
      - Audio: OGG files work in all browsers via HTML5 export. Do NOT use MP3
        (patent issues in some browsers). Do NOT use WAV (large file size for HTML5).
        SeaBreeze.m4a must be converted to OGG before import into Godot.
      - Threads: Set "Export With Threads" to OFF in export preset. Threads
        require special browser headers (COOP/COEP) that itch.io doesn't serve.
      - Input: Ensure all inputs have both keyboard and touch equivalents.
        ui_accept should map to both Enter/Space and touch tap.

  13. SCENE PATH REFERENCE (res:// paths for all key scenes)
      res://scenes/Main.tscn
      res://scenes/world/Town.tscn
      res://scenes/world/Beach.tscn
      res://scenes/world/Dock.tscn
      res://scenes/world/ocean/Ocean.tscn
      res://scenes/world/ocean/OceanZone1_Shallows.tscn
      res://scenes/world/ocean/OceanZone2_KelpForest.tscn
      res://scenes/world/ocean/OceanZone3_SunkenRuins.tscn
      res://scenes/world/ocean/OceanZone4_BiolumDeep.tscn
      res://scenes/minigames/CastMinigame.tscn
      res://scenes/minigames/ReelMinigame.tscn
      res://scenes/minigames/CatchMinigame.tscn
      res://scenes/minigames/FiletMinigame.tscn
      res://scenes/ui/HUD.tscn
      res://scenes/ui/MainMenu.tscn
      res://scenes/ui/Shop.tscn
      res://scenes/ui/Inventory.tscn
      res://scenes/ui/CraftingMenu.tscn
      res://scenes/ui/Codex.tscn
      res://scenes/ui/DayEndSummary.tscn
      res://scenes/ui/WinScreen.tscn
      res://scenes/ui/GameOverScreen.tscn
      res://scenes/ui/FishCaughtPopup.tscn
      res://scenes/ui/TutorialArrow.tscn
      res://scenes/ui/TutorialPrompt.tscn
      res://scenes/ui/DialogueBox.tscn

  14. AUTOLOAD REGISTRATION ORDER (must be in this exact order)
      Project Settings → Autoload:
        1. GameState    → res://scripts/autoloads/GameState.gd
        2. FishDatabase → res://scripts/autoloads/FishDatabase.gd
        3. ItemDatabase → res://scripts/autoloads/ItemDatabase.gd
        4. AudioManager → res://scripts/autoloads/AudioManager.gd
        5. SceneManager → res://scripts/autoloads/SceneManager.gd
        6. TutorialManager → res://scripts/autoloads/TutorialManager.gd
      The order matters because GameState initialises first and others read from it.

  15. STARTING SCENE
      Set Main.tscn as the main scene in:
      Project Settings → Application → Run → Main Scene → res://scenes/Main.tscn
      Main.tscn's _ready() calls SceneManager.go_to_main_menu() on first load.
      If a save file exists at user://save.json, the "Continue" button on
      the main menu becomes active and calls GameState.load_save() then
      SceneManager.go_to_town().


================================================================================
  END OF LOAN SHARK GDD v3 — AGENT EDITION
================================================================================

  DOCUMENT SUMMARY
  Total sections: 30
  Total fish: 38 (40 including legendary variants counted separately)
  Total rods: 10 (4 tiers)
  Total enchantments: 8
  Total bait types: 12
  Total charms: 24 (8 sell price + 8 spawn rate + 8 enchantment)
  Total materials: 14
  Total hazards: 6 (5 regular + Leviathan hazard variant)
  Total NPC characters: 5 (Finn + Fisherman + 3 Townsfolk)
  Total tutorial steps: 15
  Total music tracks assigned: 13
  Total ambient SFX assigned: 8
  Build schedule: 7 real days → 70-minute playthrough target

  If any section contradicts another, the later section takes precedence.
  If a value is not specified here, use the nearest reasonable approximation
  from context and document your assumption in a code comment.

================================================================================