# CTMod (TBC Anniversary Fork)

<p align="center">
  <img src="https://cloaked.agency/static/CloakedAgency.png" alt="cloaked.agency" width="300"/>
</p>

<p align="center">
  <img src="https://cloaked.agency/static/panda.png" alt="The Pandaverse" width="150"/>
</p>

<p align="center"><em>Maintained by the pandaverse at cloaked.agency</em></p>

---

## About This Fork

CTMod is one of the oldest and most respected addon compilations in World of Warcraft history. Originally created by **Cide** and **TS** during the Vanilla era, it has been maintained by dedicated community members ever since.

**Resike** joined the project in 2014, and **Dahk Celes** (DDCorkum) has been the primary maintainer since 2017. The WoW addon community hasn't heard from Dahk in a while - wherever he is, we hope he's doing well.

**Upstream repository:** https://github.com/DDCorkum/CTMod

This fork exists for a specific purpose: **TBC Anniversary Edition compatibility**. The official CTMod repository targets Retail, Classic Era, and Wrath Classic, but several modules break on the TBC Anniversary servers due to UI API differences.

---

## What's Included

CTMod consists of 13 modules that can be enabled independently:

| Module | Description |
|--------|-------------|
| **CT_Library** | Core framework and shared functions used by all CT modules |
| **CT_Core** | General UI tweaks - chat enhancements, tooltip positioning, quest tracking |
| **CT_BarMod** | Action bar management - create and customize additional action bars |
| **CT_BottomBar** | Repositions and separates elements of the main menu bar |
| **CT_BuffMod** | Buff and debuff display customization with timer bars |
| **CT_ExpenseHistory** | Tracks gold income and expenses across characters |
| **CT_MailMod** | Mail enhancements - mass open, send to alts, mail log |
| **CT_MapMod** | World map improvements - coordinates, notes, gathering tracking |
| **CT_PartyBuffs** | Shows party member buffs near their unit frames |
| **CT_RaidAssist** | Raid frames and click-casting with support for Clique |
| **CT_Timer** | Customizable timer bars and stopwatch functionality |
| **CT_UnitFrames** | Modifications to player, target, and party frames |
| **CT_Viewport** | Adjusts the rendered game area for custom screen layouts |

---

## TBC Anniversary Fixes

This section documents the specific changes made to achieve TBC Anniversary compatibility. Each fix targets a specific error that occurs when running the unmodified CTMod on TBC Anniversary servers.

### Fix 1: KeyRing Button

**File:** `CT_BottomBar/CT_BottomBar_ClassicKeyRingButton.lua`

**Error message:**
```
attempt to call method 'Layout' (a nil value)
```

**Root cause:**

When CT_BottomBar repositions the KeyRingButton to a custom frame, Blizzard's `Keyring.lua` in the TBC Anniversary client calls `self:GetParent():Layout()` on the button's parent. This expects the parent frame to implement a `Layout()` method. CTMod's custom positioning frame doesn't provide this method, causing a Lua error whenever the KeyRingButton becomes visible.

**The fix (lines 19-23):**

```lua
-- Skip on TBC/Classic Era - Blizzard's Keyring.lua expects parent to have Layout() method
-- which CTMod's frame doesn't provide, causing errors when KeyRingButton is shown
if module:getGameVersion() < 3 then
	return
end
```

**Why this approach:**

CTMod's `getGameVersion()` function returns:
- `2` for TBC and Classic Era
- `3` for Wrath of the Lich King
- Higher values for later expansions

By returning early when `getGameVersion() < 3`, the entire KeyRing positioning module never initializes on TBC Anniversary. The KeyRing button remains functional in its default Blizzard position - you just can't reposition it through CT_BottomBar.

---

### Fix 2: Micro Menu Bar

**File:** `CT_BottomBar/CT_BottomBar_Menu.lua`

**Error message:**
```
EditModeManager errors referencing MicroMenuContainer
```

**Root cause:**

CT_BottomBar hooks into the micro buttons' `SetPoint` and `SetParent` methods to intercept Blizzard's positioning and apply custom layouts. In TBC Anniversary, these hooks trigger code paths that reference `EditModeManager` and `MicroMenuContainer` - UI systems that were introduced in Dragonflight and don't exist in the TBC interface architecture.

**The fix (lines 37-41):**

```lua
-- Skip on TBC/Classic Era - Micro button manipulation triggers EditModeManager errors
-- in MicroMenuContainer due to incompatible UI architecture
if module:getGameVersion() < 3 then
	return
end
```

**Why this approach:**

The micro menu repositioning functionality relies on UI infrastructure that simply doesn't exist in TBC. Rather than trying to patch around every incompatible API call, disabling the entire module is the clean solution. The micro buttons work normally in their default positions.

---

### Fix 3: Spell Learning Event

**File:** `CT_RaidAssist/CT_RaidAssist.lua`

**Error message:**
```
Couldn't find event LEARNED_SPELL_IN_TAB
```

**Root cause:**

CT_RaidAssist registers for the `LEARNED_SPELL_IN_TAB` event to automatically refresh click-cast spell bindings when the player learns new abilities. This event doesn't exist in TBC - it was added in a later expansion to support the redesigned spellbook.

**The fix (lines 2364-2367):**

```lua
-- LEARNED_SPELL_IN_TAB doesn't exist in TBC/Classic Era
if (module:getGameVersion() >= 3) then
	module:regEvent("LEARNED_SPELL_IN_TAB", updateSpells);
end
```

**Why this approach:**

Unlike the previous fixes, we don't need to disable the entire CT_RaidAssist module. The raid frames, click-casting, and all other functionality work correctly on TBC. We only need to skip registering for this one non-existent event.

The same pattern is applied to `ACTIVE_TALENT_GROUP_CHANGED` registration (line 2368-2370), which handles dual-spec talent swaps - another feature that didn't exist in original TBC.

---

## Features Disabled on TBC Anniversary

Due to the UI architecture differences, these specific features are automatically disabled when running on TBC Anniversary:

**Disabled:**
- Key Ring button repositioning (CT_BottomBar)
- Micro Menu bar repositioning (CT_BottomBar)
- Automatic spell refresh on learning new spells (CT_RaidAssist)

**Working normally:**
- All action bar features (CT_BarMod)
- Buff and debuff tracking (CT_BuffMod)
- Mail enhancements (CT_MailMod)
- Map improvements (CT_MapMod)
- Raid frames and click-casting (CT_RaidAssist)
- Unit frame modifications (CT_UnitFrames)
- Viewport adjustments (CT_Viewport)
- All other CT_Core and CT_Library functionality

---

## Installation

1. Download the latest release from GitHub or clone the repository
2. Copy all `CT_*` folders to your `Interface/AddOns` directory
3. Restart World of Warcraft or reload the UI

**Configuration commands:**
- `/ct` - Opens the main CTMod settings panel
- `/ctra` - Opens CT_RaidAssist configuration
- `/ctbar` - Opens CT_BarMod configuration

---

## Credits

CTMod exists because of the dedication of its maintainers across two decades of WoW history:

- **Cide** and **TS** - Original creators (Vanilla era)
- **Resike** - Contributor and maintainer (2014)
- **Dahk Celes / DDCorkum** - Primary maintainer (2017-2025)
- **Ozy** - TBC Anniversary compatibility fork (2025)

---

## Links

- **This fork:** https://github.com/Ozy311/CTMod
- **Upstream:** https://github.com/DDCorkum/CTMod

---

<p align="center">
  <em>Part of the pandaverse at</em> <a href="https://cloaked.agency">cloaked.agency</a>
</p>
