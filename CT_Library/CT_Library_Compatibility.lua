------------------------------------------------
--          CT_Library Compatibility          --
--                                            --
-- Polyfills for APIs missing in Classic/TBC  --
-- Loaded before CT_Library.lua to define     --
-- missing globals that other files expect    --
------------------------------------------------

-- This file provides compatibility shims for APIs that exist in Retail
-- but are missing in Classic Era (Vanilla/TBC). It follows the WeakAuras
-- pattern of centralizing polyfills rather than scattering nil checks.

--------------------------------------------
-- Version Detection (pre-CT_Library load)
--------------------------------------------

-- Get game version before CT_Library loads its own detection
local gameVersion = tonumber((select(1, strsplit(".", GetBuildInfo())))) or 0

-- Only apply polyfills for Classic Era (version 1-2)
-- Version 1 = Vanilla/Classic Era/SoD
-- Version 2 = TBC/TBC Anniversary
-- Version 3+ = Wrath, Cata, Retail
if gameVersion >= 3 then
	return
end

--------------------------------------------
-- Constants
--------------------------------------------

-- NUM_STANCE_SLOTS doesn't exist in TBC (was added in later expansions)
-- Used by CT_BottomBar_Class.lua for iterating stance buttons
if not NUM_STANCE_SLOTS then
	NUM_STANCE_SLOTS = 10
end

--------------------------------------------
-- TextStatusBar Functions (Retail 8.0+)
--------------------------------------------

-- TextStatusBar_Initialize - Called in XML OnLoad for status bars
-- In Retail, this function initializes status bar text functionality
-- In Classic/TBC, we need to set some properties to prevent nil comparisons
if not TextStatusBar_Initialize then
	TextStatusBar_Initialize = function(self)
		-- Set properties that Blizzard's TextStatusBar code expects
		-- These prevent "attempt to compare number with nil" errors
		if self then
			self.lockShow = self.lockShow or 0
			self.textLockable = self.textLockable or nil
			self.forceShow = self.forceShow or false
		end
	end
end

-- SetTextStatusBarTextZeroText - Sets the text to show when bar is at zero
-- In Retail, this is a global function
-- In Classic/TBC, we set the property directly on the frame
if not SetTextStatusBarTextZeroText then
	SetTextStatusBarTextZeroText = function(statusBar, text)
		if statusBar then
			statusBar.zeroText = text
		end
	end
end

--------------------------------------------
-- Flyout System (Cataclysm+)
--------------------------------------------

-- Flyouts (spell button expandable menus) don't exist in Classic/TBC
-- These stubs prevent nil function errors when flyout code executes

if not GetFlyoutInfo then
	GetFlyoutInfo = function(flyoutID)
		-- Returns: name, description, numSlots, isKnown
		return nil, nil, 0, false
	end
end

if not GetFlyoutSlotInfo then
	GetFlyoutSlotInfo = function(flyoutID, slot)
		-- Returns: spellID, overrideSpellID, isKnown, spellName, slotSpecID
		return nil, nil, false, nil, nil
	end
end

if not FlyoutHasSpell then
	FlyoutHasSpell = function(flyoutID, spellID)
		-- Returns: hasSpell
		return false
	end
end

--------------------------------------------
-- Unit Frame Functions
--------------------------------------------

-- RefreshDebuffs - Updates debuff display on unit frames
-- In Retail, this is a global function for aura updates
-- In Classic/TBC, aura handling is different; this is a no-op
if not RefreshDebuffs then
	RefreshDebuffs = function(frame, unit)
		-- Classic/TBC: Aura system works differently
		-- The frame's own OnEvent handler manages debuff display
	end
end

--------------------------------------------
-- Missing Frame Stubs (TBC)
--------------------------------------------

-- ActionBarPageNumber - used by CT_BarMod for paging display
-- This frame shows the current action bar page number in Retail
-- In TBC, it doesn't exist and causes secure snippet errors
if not ActionBarPageNumber then
	ActionBarPageNumber = CreateFrame("Frame", "ActionBarPageNumber", UIParent)
	ActionBarPageNumber:Hide()
	-- Add common frame methods that might be accessed
	ActionBarPageNumber.SetText = ActionBarPageNumber.SetText or function() end
end

-- StanceBarFrame - TBC uses different stance bar structure
-- In Retail, this is the parent frame for stance buttons
-- In TBC/Classic, stance buttons have different organization
if not StanceBarFrame then
	StanceBarFrame = CreateFrame("Frame", "StanceBarFrame", UIParent)
	StanceBarFrame:Hide()
end

--------------------------------------------
-- Micro Menu Functions (Retail only)
--------------------------------------------

-- UpdateMicroButtonsParent - TBC has different micro menu structure
-- In Retail, this reparents the micro menu buttons
-- In TBC, micro buttons are fixed to the main menu bar
if not UpdateMicroButtonsParent then
	UpdateMicroButtonsParent = function(parent)
		-- No-op: TBC micro buttons are managed differently
	end
end

-- MoveMicroButtons - TBC has different micro menu structure
-- In Retail, this repositions micro buttons based on anchor
-- In TBC, micro buttons have fixed positions
if not MoveMicroButtons then
	MoveMicroButtons = function(anchor, anchorTo, relAnchor, x, y, isStacked)
		-- No-op: TBC micro buttons cannot be moved
	end
end

--------------------------------------------
-- End Compatibility Layer
--------------------------------------------
