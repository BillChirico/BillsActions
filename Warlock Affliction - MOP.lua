--==========================================================
--  Affliction Warlock – MoP Classic
--  Single-Target DPS, Utility, Defensive & Offensive Cooldowns
--  Based on Wowhead guide (https://www.wowhead.com/mop-classic/guide/classes/warlock/affliction/dps-rotation-cooldowns-abilities-pve)
--
--  This file follows the structure used in Hunter_BeastMastery.lua:
--    1.  Global / library imports
--    2.  Specialization constants
--    3.  Spell & racial definitions
--    4.  Helper rotations (Utility / Defensive / Offensive)
--    5.  Core DPS rotation
--    6.  Main entry point that wires everything together
--
--  All sections are clearly delimited with ASCII rulers for easier
--  navigation and future maintenance.
--==========================================================

local A = Action
local Create = A.Create
local TMW = _G.TMW
local Env = TMW.CNDT and TMW.CNDT.Env or nil
local GetGCD = TMW.GetGCD
TMW.GCD = TMW.GCD or GetGCD() -- Fixes nil able compare error because UpdateGlobals launches with delay

local LibStub = _G.LibStub
-- local StdUi = LibStub("StdUi"):NewInstance() -- Uncomment if UI is needed
-- local LibDBIcon = LibStub("LibDBIcon-1.0") -- Uncomment if minimap icon is needed
-- local LSM = LibStub("LibSharedMedia-3.0") -- Uncomment if media is needed

local UnitClass = _G.UnitClass or UnitClass
local UnitLevel = _G.UnitLevel or UnitLevel
local UnitExists = _G.UnitExists or UnitExists
local UnitIsUnit = _G.UnitIsUnit or UnitIsUnit
local UnitHealth = _G.UnitHealth or UnitHealth
local UnitHealthMax = _G.UnitHealthMax or UnitHealthMax

local InCombatLockdown = _G.InCombatLockdown

local Action = _G.Action
-- Action.StdUi = StdUi -- Uncomment if UI is needed
Action.BuildToC = select(4, _G.GetBuildInfo())
Action.PlayerRace = select(2, _G.UnitRace("player"))
Action.PlayerClassName, Action.PlayerClass, Action.PlayerClassID = UnitClass("player")
local CONST = A.Const
local GetToggle = A.GetToggle
local ACTION_CONST_STOPCAST = CONST and CONST.STOPCAST or nil

--[[
Affliction Warlock - MoP Classic
Single Target DPS Rotation
Based on: https://www.wowhead.com/mop-classic/guide/classes/warlock/affliction/dps-rotation-cooldowns-abilities-pve
]]
   --

-- Define specialization constant for Affliction Warlock (MoP Classic)
if not _G.ACTION_CONST_WARLOCK_AFFLICTION then
    _G.ACTION_CONST_WARLOCK_AFFLICTION = 265
end
local ACTION_CONST_WARLOCK_AFFLICTION = _G.ACTION_CONST_WARLOCK_AFFLICTION

-- Spell definitions for Affliction Warlock
Action[ACTION_CONST_WARLOCK_AFFLICTION] = {
    -- Core DoTs
    Agony              = Create({ Type = "Spell", ID = 980 }),
    Corruption         = Create({ Type = "Spell", ID = 172 }),
    UnstableAffliction = Create({ Type = "Spell", ID = 30108 }),
    -- Main filler
    MaleficGrasp       = Create({ Type = "Spell", ID = 103103 }),
    -- Main spender
    DrainSoul          = Create({ Type = "Spell", ID = 1120 }),
    -- Cooldowns
    DarkSoulMisery     = Create({ Type = "Spell", ID = 113860 }),
    SummonTerrorguard  = Create({ Type = "Spell", ID = 112921 }),
    -- Utility
    Haunt              = Create({ Type = "Spell", ID = 48181 }),
    -- Other
    SeedOfCorruption   = Create({ Type = "Spell", ID = 27243 }),
    LifeTap            = Create({ Type = "Spell", ID = 1454 }),
    -- Defensive
    UnendingResolve    = Create({ Type = "Spell", ID = 104773 }),
}

-- Add racial abilities for Affliction Warlock
Action[ACTION_CONST_WARLOCK_AFFLICTION].BloodFury = Create({ Type = "Spell", ID = 20572, isRacial = true, Range = 0 })                           -- Orc
Action[ACTION_CONST_WARLOCK_AFFLICTION].Berserking = Create({ Type = "Spell", ID = 26297, isRacial = true, Range = 0 })                          -- Troll
Action[ACTION_CONST_WARLOCK_AFFLICTION].WarStomp = Create({ Type = "Spell", ID = 20549, isRacial = true, Range = 8 })                            -- Tauren
Action[ACTION_CONST_WARLOCK_AFFLICTION].BullRush = Create({ Type = "Spell", ID = 255654, isRacial = true, Range = 0 })                           -- Highmountain Tauren
Action[ACTION_CONST_WARLOCK_AFFLICTION].WillOfTheForsaken = Create({ Type = "Spell", ID = 7744, isRacial = true, Range = 0 })                    -- Undead
Action[ACTION_CONST_WARLOCK_AFFLICTION].ArcaneTorrent = Create({ Type = "Spell", ID = 50613, isRacial = true, Range = 8 })                       -- Blood Elf
Action[ACTION_CONST_WARLOCK_AFFLICTION].BagOfTricks = Create({ Type = "Spell", ID = 312411, isRacial = true, Range = 30 })                       -- Vulpera
Action[ACTION_CONST_WARLOCK_AFFLICTION].AncestralCall = Create({ Type = "Spell", ID = 274738, isRacial = true, Range = 0 })                      -- Mag'har Orc
Action[ACTION_CONST_WARLOCK_AFFLICTION].Stoneform = Create({ Type = "Spell", ID = 20594, isRacial = true, Range = 0 })                           -- Dwarf
Action[ACTION_CONST_WARLOCK_AFFLICTION].Fireblood = Create({ Type = "Spell", ID = 265221, isRacial = true, Range = 0 })                          -- Dark Iron Dwarf
Action[ACTION_CONST_WARLOCK_AFFLICTION].WillToSurvive = Create({ Type = "Spell", ID = 59752, isRacial = true, Range = 0 })                       -- Human
Action[ACTION_CONST_WARLOCK_AFFLICTION].Haymaker = Create({ Type = "Spell", ID = 287712, isRacial = true, Range = 5 })                           -- Kul Tiran
Action[ACTION_CONST_WARLOCK_AFFLICTION].EscapeArtist = Create({ Type = "Spell", ID = 20589, isRacial = true, Range = 0 })                        -- Gnome
Action[ACTION_CONST_WARLOCK_AFFLICTION].HyperOrganicLightOriginatingShield = Create({ Type = "Spell", ID = 312916, isRacial = true, Range = 0 }) -- Mechagnome
Action[ACTION_CONST_WARLOCK_AFFLICTION].Shadowmeld = Create({ Type = "Spell", ID = 58984, isRacial = true, Range = 0 })                          -- Night Elf
Action[ACTION_CONST_WARLOCK_AFFLICTION].ArcanePulse = Create({ Type = "Spell", ID = 260364, isRacial = true, Range = 20 })                       -- Nightborne
Action[ACTION_CONST_WARLOCK_AFFLICTION].GiftofNaaru = Create({ Type = "Spell", ID = 59544, isRacial = true, Range = 40 })                        -- Draenei
Action[ACTION_CONST_WARLOCK_AFFLICTION].LightsJudgment = Create({ Type = "Spell", ID = 255647, isRacial = true, Range = 30 })                    -- Lightforged Draenei
Action[ACTION_CONST_WARLOCK_AFFLICTION].Darkflight = Create({ Type = "Spell", ID = 68992, isRacial = true, Range = 0 })                          -- Worgen
Action[ACTION_CONST_WARLOCK_AFFLICTION].QuakingPalm = Create({ Type = "Spell", ID = 107079, isRacial = true, Range = 8 })                        -- Pandaren

-- Create metatable for Affliction Warlock
local A = setmetatable(Action[ACTION_CONST_WARLOCK_AFFLICTION], { __index = Action })

--====================================
-- Utility Rotation
--====================================
local function UtilityRotation(icon)
    -- Utility Racials
    if A.WarStomp:IsReady("player") then return A.WarStomp:Show(icon) end
    if A.QuakingPalm:IsReady("target") then return A.QuakingPalm:Show(icon) end
    if A.Haymaker:IsReady("target") then return A.Haymaker:Show(icon) end
    if A.BullRush:IsReady("player") then return A.BullRush:Show(icon) end
    if A.ArcaneTorrent:IsReady("player") then return A.ArcaneTorrent:Show(icon) end
    if A.BagOfTricks:IsReady("target") then return A.BagOfTricks:Show(icon) end
    return false
end

--====================================
-- Defensive Rotation
--====================================
local function DefensiveRotation(icon)
    local playerHealthPercent = (UnitHealth("player") / UnitHealthMax("player")) * 100

    -- Primary defensive
    if A.UnendingResolve:IsReady("player") and playerHealthPercent <= 40 then
        return A.UnendingResolve:Show(icon)
    end

    -- Defensive racials
    if playerHealthPercent <= 60 and A.GiftofNaaru:IsReady("player") then
        return A.GiftofNaaru:Show(icon)
    end

    if playerHealthPercent <= 40 then
        if A.Stoneform:IsReady("player") then
            return A.Stoneform:Show(icon)
        end
        if A.HyperOrganicLightOriginatingShield:IsReady("player") then
            return A.HyperOrganicLightOriginatingShield:Show(icon)
        end
    end

    if playerHealthPercent <= 20 and A.Darkflight:IsReady("player") then
        return A.Darkflight:Show(icon)
    end

    return false
end

--====================================
-- Offensive Cooldowns
--====================================
local function UseOffensiveCooldowns(icon)
    -- Use Summon Terrorguard as a major DPS cooldown
    if A.SummonTerrorguard:IsReady("player") then
        return A.SummonTerrorguard:Show(icon)
    end
    -- Use Dark Soul: Misery as the main DPS cooldown
    if A.DarkSoulMisery:IsReady("player") then
        return A.DarkSoulMisery:Show(icon)
    end
    -- Offensive Racials
    if A.BloodFury:IsReady("player") then return A.BloodFury:Show(icon) end
    if A.Berserking:IsReady("player") then return A.Berserking:Show(icon) end
    if A.Fireblood:IsReady("player") then return A.Fireblood:Show(icon) end
    if A.AncestralCall:IsReady("player") then return A.AncestralCall:Show(icon) end
    -- Trinkets
    if A.Trinket1 and A.Trinket1:IsReady("player") then
        return A.Trinket1:Show(icon)
    end
    if A.Trinket2 and A.Trinket2:IsReady("player") then
        return A.Trinket2:Show(icon)
    end
    return false
end

---
-- Implements the optimal DPS rotation for a single target.
-- Follows a strict priority list to maximize damage output for Affliction Warlock in MoP Classic.
---
local function SingleTargetRotation(icon)
    -- Offensive Cooldowns
    if UseOffensiveCooldowns(icon) then
        return true
    end
    -- 1. Maintain Agony on the target
    if A.Agony:IsReady("target") and A.Unit("target"):HasDeBuffs(A.Agony.ID) < 4 then
        return A.Agony:Show(icon)
    end
    -- 2. Maintain Corruption on the target
    if A.Corruption:IsReady("target") and A.Unit("target"):HasDeBuffs(A.Corruption.ID) < 4 then
        return A.Corruption:Show(icon)
    end
    -- 3. Maintain Unstable Affliction on the target
    if A.UnstableAffliction:IsReady("target") and A.Unit("target"):HasDeBuffs(A.UnstableAffliction.ID) < 4 then
        return A.UnstableAffliction:Show(icon)
    end
    -- 4. Use Haunt on cooldown
    if A.Haunt:IsReady("target") then
        return A.Haunt:Show(icon)
    end
    -- 5. Use Malefic Grasp as the main filler (if talented, otherwise Drain Soul)
    if A.MaleficGrasp:IsReady("target") then
        return A.MaleficGrasp:Show(icon)
    end
    -- 6. Use Drain Soul as filler (if target is below 20% HP or Malefic Grasp not talented)
    if A.DrainSoul:IsReady("target") then
        return A.DrainSoul:Show(icon)
    end
    return false
end

--====================================
-- Core Single-Target Rotation
--====================================
-- Main entry point for the addon's rotation logic
A[3] = function(icon)
    -- Defensive checks
    if DefensiveRotation(icon) then
        return true
    end
    -- Utility checks
    if UtilityRotation(icon) then
        return true
    end
    -- Only run rotation if target is enemy and exists
    if not (A.Unit("target"):IsEnemy() and A.Unit("target"):IsExists()) then
        return false
    end
    return SingleTargetRotation(icon)
end

--[[
Documentation:
- Agony, Corruption, and Unstable Affliction should be kept up at all times.
- Haunt is used on cooldown for increased DoT damage.
- Dark Soul: Misery is the main DPS cooldown.
- Malefic Grasp is the main filler (if talented), otherwise use Drain Soul.
- Drain Soul is also used as an execute filler below 20% target HP.
]]
   --
