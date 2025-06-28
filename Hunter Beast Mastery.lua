local A = Action
local Create = A.Create
local TMW = _G.TMW
local Env = TMW.CNDT.Env
local GetGCD = TMW.GetGCD
TMW.GCD = TMW.GCD or GetGCD() -- Fixes nil able compare error because UpdateGlobals launches with delay

local LibStub = _G.LibStub
local StdUi = LibStub("StdUi"):NewInstance()
local LibDBIcon = LibStub("LibDBIcon-1.0")
local LSM = LibStub("LibSharedMedia-3.0")
LSM:Register(LSM.MediaType.STATUSBAR, "Flat", [[Interface\Addons\]] .. _G.ACTION_CONST_ADDON_NAME .. [[\Media\Flat]])
local isClassic = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_CLASSIC
StdUi.isClassic = isClassic
local owner = isClassic and "PlayerClass" or "PlayerSpec"

local C_Spell = _G.C_Spell
local GetSpecialization = _G.GetSpecialization
local GetSpellInfo = _G.GetSpellInfo or C_Spell.GetSpellInfo

local UnitClass, UnitLevel, UnitExists, UnitIsUnit, UnitHealth, UnitHealthMax =
    _G.UnitClass, _G.UnitLevel, _G.UnitExists, _G.UnitIsUnit, _G.UnitHealth, _G.UnitHealthMax

local InCombatLockdown = _G.InCombatLockdown

local Action = _G.Action
Action.StdUi = StdUi
Action.BuildToC = select(4, _G.GetBuildInfo())
Action.PlayerRace = select(2, _G.UnitRace("player"))
Action.PlayerClassName, Action.PlayerClass, Action.PlayerClassID = UnitClass("player")
local CONST = A.Const
local GetToggle = A.GetToggle
local ACTION_CONST_STOPCAST = CONST.STOPCAST

-- Buff and Debuff IDs for Beast Mastery Hunter
local BuffIDs = {
    -- Self buffs
    BestialWrath = 19574,
    AspectOfTheWild = 193530,
    BeastCleave = 118455,
    Frenzy = 272790, -- Pet Buff
    Bloodshed = 321530,
    AspectOfTheTurtle = 186265,

    -- Raid buffs
    PowerInfusion = 10060,
    Bloodlust = 2825,
    Heroism = 32182,
    TimeWarp = 80353,
    PrimalRage = 264667,
}

local DebuffIDs = {
    -- Target debuffs to track
    BarbedShot = 217200,
    HuntersMark = 257284,
}

-- Define constants for specialization
if not _G.ACTION_CONST_HUNTER_BEASTMASTERY then
    _G.ACTION_CONST_HUNTER_BEASTMASTERY = 253
end

-- Store specialization constant in a local variable
local ACTION_CONST_HUNTER_BEASTMASTERY = _G.ACTION_CONST_HUNTER_BEASTMASTERY

-- Spell definitions for Beast Mastery Hunter
Action[ACTION_CONST_HUNTER_BEASTMASTERY] = {
    -- Core Abilities
    KillCommand       = Create({ Type = "Spell", ID = 34026 }),
    CobraShot         = Create({ Type = "Spell", ID = 193455 }),
    BarbedShot        = Create({ Type = "Spell", ID = 217200 }),
    KillShot          = Create({ Type = "Spell", ID = 53351 }),
    MultiShot         = Create({ Type = "Spell", ID = 2643 }),

    -- Cooldowns
    BestialWrath      = Create({ Type = "Spell", ID = 19574 }),
    AspectOfTheWild   = Create({ Type = "Spell", ID = 193530 }),
    Bloodshed         = Create({ Type = "Spell", ID = 321530, isTalent = true }),
    CallOfTheWild     = Create({ Type = "Spell", ID = 359844, isTalent = true }),
    DireBeast         = Create({ Type = "Spell", ID = 212382, isTalent = true }),
    ExplosiveShot     = Create({ Type = "Spell", ID = 212431, isTalent = true }),
    BlackArrow        = Create({ Type = "Spell", ID = 194599, isTalent = true }),
    HuntersMark       = Create({ Type = "Spell", ID = 257284 }),

    -- Defensives & Utility
    AspectOfTheTurtle = Create({ Type = "Spell", ID = 186265 }),
    Exhilaration      = Create({ Type = "Spell", ID = 109304 }),
    FeignDeath        = Create({ Type = "Spell", ID = 5384 }),
    CounterShot       = Create({ Type = "Spell", ID = 147362, IsAntiFake = true, Desc = "[2] Kick" }),
    Intimidation      = Create({ Type = "Spell", ID = 19577 }),
    Misdirection      = Create({ Type = "Spell", ID = 34477 }),
}

-- Add racial abilities
Action[ACTION_CONST_HUNTER_BEASTMASTERY].BloodFury = Create({ Type = "Spell", ID = 20572, isRacial = true, Range = 0 })                           -- Orc
Action[ACTION_CONST_HUNTER_BEASTMASTERY].Berserking = Create({ Type = "Spell", ID = 26297, isRacial = true, Range = 0 })                          -- Troll
Action[ACTION_CONST_HUNTER_BEASTMASTERY].WarStomp = Create({ Type = "Spell", ID = 20549, isRacial = true, Range = 8 })                            -- Tauren
Action[ACTION_CONST_HUNTER_BEASTMASTERY].BullRush = Create({ Type = "Spell", ID = 255654, isRacial = true, Range = 0 })                           -- Highmountain Tauren
Action[ACTION_CONST_HUNTER_BEASTMASTERY].WillOfTheForsaken = Create({ Type = "Spell", ID = 7744, isRacial = true, Range = 0 })                    -- Undead
Action[ACTION_CONST_HUNTER_BEASTMASTERY].ArcaneTorrent = Create({ Type = "Spell", ID = 50613, isRacial = true, Range = 8 })                       -- Blood Elf
Action[ACTION_CONST_HUNTER_BEASTMASTERY].BagOfTricks = Create({ Type = "Spell", ID = 312411, isRacial = true, Range = 30 })                       -- Vulpera
Action[ACTION_CONST_HUNTER_BEASTMASTERY].AncestralCall = Create({ Type = "Spell", ID = 274738, isRacial = true, Range = 0 })                      -- Mag'har Orc
Action[ACTION_CONST_HUNTER_BEASTMASTERY].Stoneform = Create({ Type = "Spell", ID = 20594, isRacial = true, Range = 0 })                           -- Dwarf
Action[ACTION_CONST_HUNTER_BEASTMASTERY].Fireblood = Create({ Type = "Spell", ID = 265221, isRacial = true, Range = 0 })                          -- Dark Iron Dwarf
Action[ACTION_CONST_HUNTER_BEASTMASTERY].WillToSurvive = Create({ Type = "Spell", ID = 59752, isRacial = true, Range = 0 })                       -- Human
Action[ACTION_CONST_HUNTER_BEASTMASTERY].Haymaker = Create({ Type = "Spell", ID = 287712, isRacial = true, Range = 5 })                           -- Kul Tiran
Action[ACTION_CONST_HUNTER_BEASTMASTERY].EscapeArtist = Create({ Type = "Spell", ID = 20589, isRacial = true, Range = 0 })                        -- Gnome
Action[ACTION_CONST_HUNTER_BEASTMASTERY].HyperOrganicLightOriginatingShield = Create({ Type = "Spell", ID = 312916, isRacial = true, Range = 0 }) -- Mechagnome
Action[ACTION_CONST_HUNTER_BEASTMASTERY].Shadowmeld = Create({ Type = "Spell", ID = 58984, isRacial = true, Range = 0 })                          -- Night Elf
Action[ACTION_CONST_HUNTER_BEASTMASTERY].ArcanePulse = Create({ Type = "Spell", ID = 260364, isRacial = true, Range = 20 })                       -- Nightborne
Action[ACTION_CONST_HUNTER_BEASTMASTERY].GiftofNaaru = Create({ Type = "Spell", ID = 59544, isRacial = true, Range = 40 })                        -- Draenei
Action[ACTION_CONST_HUNTER_BEASTMASTERY].LightsJudgment = Create({ Type = "Spell", ID = 255647, isRacial = true, Range = 30 })                    -- Lightforged Draenei
Action[ACTION_CONST_HUNTER_BEASTMASTERY].Darkflight = Create({ Type = "Spell", ID = 68992, isRacial = true, Range = 0 })                          -- Worgen
Action[ACTION_CONST_HUNTER_BEASTMASTERY].QuakingPalm = Create({ Type = "Spell", ID = 107079, isRacial = true, Range = 8 })                        -- Pandaren

-- Create metatable for Beast Mastery Hunter
local A = setmetatable(Action[ACTION_CONST_HUNTER_BEASTMASTERY], { __index = Action })

---
-- Manages non-damaging utility spells, primarily stuns and misdirection.
-- This function prioritizes crowd control abilities to help control the flow of combat.
---
local function UtilityRotation(icon)
    -- Racials Stuns
    if A.Unit("target"):IsStunnable() then
        if A.WarStomp:IsReady("player") then return A.WarStomp:Show(icon) end
        if A.QuakingPalm:IsReady("target") then return A.QuakingPalm:Show(icon) end
        if A.Haymaker:IsReady("target") then return A.Haymaker:Show(icon) end
        if A.BullRush:IsReady("player") then return A.BullRush:Show(icon) end
    end

    -- Intimidation for stuns
    if A.Intimidation:IsReady("target") and A.Unit("target"):IsStunnable() then
        return A.Intimidation:Show(icon)
    end

    -- Misdirection on tank
    if A.Misdirection:IsReady("player") and A.Unit("focus"):IsTank() and A.Unit("focus"):IsPlayer() then
        return A.Misdirection:Show(icon, "focus")
    end

    return false
end

---
-- Handles defensive abilities to increase survivability.
-- It triggers abilities like Aspect of the Turtle, Exhilaration, and defensive trinkets
-- based on the player's current health percentage.
---
local function DefensiveRotation(icon)
    if A.IsInValidCombat() then
        local playerHealthPercent = (UnitHealth("player") / UnitHealthMax("player")) * 100

        -- Aspect of the Turtle for critical situations
        if A.AspectOfTheTurtle:IsReady("player") and playerHealthPercent <= 30 then
            return A.AspectOfTheTurtle:Show(icon)
        end

        -- Exhilaration for self-healing
        if A.Exhilaration:IsReady("player") and playerHealthPercent <= 50 then
            return A.Exhilaration:Show(icon)
        end

        -- Defensive Trinkets
        if playerHealthPercent <= 40 then
            if A.Trinket1:GetItemCategory() == "DEFF" and A.Trinket1:IsReady("player") then
                return A.Trinket1:Show(icon)
            end
            if A.Trinket2:GetItemCategory() == "DEFF" and A.Trinket2:IsReady("player") then
                return A.Trinket2:Show(icon)
            end
        end

        -- Defensive Racials
        if playerHealthPercent <= 60 then
            if A.GiftofNaaru:IsReady("player") then return A.GiftofNaaru:Show(icon) end
        end
        if playerHealthPercent <= 40 then
            if A.Stoneform:IsReady("player") then return A.Stoneform:Show(icon) end
            if A.HyperOrganicLightOriginatingShield:IsReady("player") then
                return A.HyperOrganicLightOriginatingShield
                    :Show(icon)
            end
        end
        if playerHealthPercent <= 20 and A.Darkflight:IsReady("player") then
            return A.Darkflight:Show(icon)
        end
    end

    return false
end

---
-- Manages the use of offensive cooldowns, including trinkets and racial abilities.
-- This function ensures that high-damage abilities are used during burst windows,
-- which are typically aligned with the Bestial Wrath buff.
---
local function UseOffensiveCooldowns(icon)
    -- This logic ensures trinkets and offensive racials are used during burst windows, aligned with Bestial Wrath.
    local useBurstCooldowns = A.BestialWrath:IsReady("player") or A.Player:HasBuffs(BuffIDs.BestialWrath) > 0

    if useBurstCooldowns then
        -- Offensive Racials
        if A.BloodFury:IsReady("player") then return A.BloodFury:Show(icon) end
        if A.Berserking:IsReady("player") then return A.Berserking:Show(icon) end
        if A.Fireblood:IsReady("player") then return A.Fireblood:Show(icon) end
        if A.AncestralCall:IsReady("player") then return A.AncestralCall:Show(icon) end

        -- Trinket 1
        if A.Trinket1:GetItemCategory() ~= "DEFF" then
            if A.Trinket1:IsReady("player") then
                return A.Trinket1:Show(icon)
            elseif A.Trinket1:IsReady("target") then
                return A.Trinket1:Show(icon)
            end
        end

        -- Trinket 2
        if A.Trinket2:GetItemCategory() ~= "DEFF" then
            if A.Trinket2:IsReady("player") then
                return A.Trinket2:Show(icon)
            elseif A.Trinket2:IsReady("target") then
                return A.Trinket2:Show(icon)
            end
        end
    end

    -- Non-burst racials
    if A.BagOfTricks:IsReady("target") then
        return A.BagOfTricks:Show(icon)
    end

    return false
end

---
-- Implements the optimal DPS rotation for a single target.
-- It follows a strict priority list to maximize damage output.
---
local function SingleTargetRotation(icon)
    -- Offensive Cooldowns (Trinkets and Racials)
    if UseOffensiveCooldowns(icon) then
        return true
    end

    -- Start: Hunter's Mark
    if A.HuntersMark:IsReady("target") and not A.Unit("target"):HasDebuffs(DebuffIDs.HuntersMark) then
        return A.HuntersMark:Show(icon)
    end

    -- 1. Bestial Wrath
    if A.BestialWrath:IsReady("player") then
        return A.BestialWrath:Show(icon)
    end

    -- From Dark Ranger Hero Talents: Black Arrow is high priority
    if A.BlackArrow:IsReady("target") then
        return A.BlackArrow:Show(icon)
    end

    -- 2. Barbed Shot (maintain Frenzy, <2 charges, etc.)
    local frenzyDuration = A.Pet:GetBuff(BuffIDs.Frenzy)
    if A.BarbedShot:IsReady("target") then
        -- Simplified logic: use if about to cap or frenzy is low. The guide has more complex logic (Howl of the Pack Leader).
        if A.BarbedShot:GetSpellCharges() >= 2 or frenzyDuration < 2 then
            return A.BarbedShot:Show(icon)
        end
    end

    -- 4. Call of the Wild
    if A.CallOfTheWild:IsReady("player") then
        return A.CallOfTheWild:Show(icon)
    end

    -- 5. Bloodshed
    if A.Bloodshed:IsReady("target") then
        return A.Bloodshed:Show(icon)
    end

    -- 6. Dire Beast
    if A.DireBeast:IsReady("player") then
        return A.DireBeast:Show(icon)
    end

    -- 7. Kill Command
    if A.KillCommand:IsReady("target") then
        return A.KillCommand:Show(icon)
    end

    -- 8. Barbed Shot (filler)
    if A.BarbedShot:IsReady("target") then
        return A.BarbedShot:Show(icon)
    end

    -- 9. Cobra Shot
    if A.CobraShot:IsReady("target") then
        return A.CobraShot:Show(icon)
    end

    return false
end

---
-- Implements the optimal DPS rotation for multiple targets (AoE).
-- It focuses on maintaining Beast Cleave while using other AoE abilities and cooldowns.
---
local function MultiTargetRotation(icon)
    -- Offensive Cooldowns (Trinkets and Racials)
    if UseOffensiveCooldowns(icon) then
        return true
    end

    -- 1. Bestial Wrath
    if A.BestialWrath:IsReady("player") then
        return A.BestialWrath:Show(icon)
    end

    -- AoE Racials
    if A.LightsJudgment:IsReady("target") then return A.LightsJudgment:Show(icon) end
    if A.ArcanePulse:IsReady("player") then return A.ArcanePulse:Show(icon) end

    -- 2. Barbed Shot (maintain Frenzy, <2 charges, etc.)
    local frenzyDuration = A.Pet:GetBuff(BuffIDs.Frenzy)
    if A.BarbedShot:IsReady("target") then
        -- Simplified logic: use if about to cap or frenzy is low.
        if A.BarbedShot:GetSpellCharges() >= 2 or frenzyDuration < 2 then
            return A.BarbedShot:Show(icon)
        end
    end

    -- 3. Multi-Shot to keep up Beast Cleave.
    local beastCleaveUptime = A.Player:GetBuff(BuffIDs.BeastCleave)
    if A.MultiShot:IsReady("player") and beastCleaveUptime < 1.5 then
        return A.MultiShot:Show(icon)
    end

    -- From Dark Ranger Hero Talents: Black Arrow is high priority
    if A.BlackArrow:IsReady("target") then
        return A.BlackArrow:Show(icon)
    end

    -- 4. Call of the Wild
    if A.CallOfTheWild:IsReady("player") then
        return A.CallOfTheWild:Show(icon)
    end

    -- 5. Dire Beast
    if A.DireBeast:IsReady("player") then
        return A.DireBeast:Show(icon)
    end

    -- 6. Kill Command with Beast Cleave active.
    if A.KillCommand:IsReady("target") and beastCleaveUptime > 0 then
        return A.KillCommand:Show(icon)
    end

    -- 7. Barbed Shot on different targets (not implemented, using on current target)
    if A.BarbedShot:IsReady("target") then
        return A.BarbedShot:Show(icon)
    end

    -- 8. Cobra Shot to not overcap on Focus.
    if A.CobraShot:IsReady("target") then
        return A.CobraShot:Show(icon)
    end

    -- 9. Explosive Shot
    if A.ExplosiveShot:IsReady("target") then
        return A.ExplosiveShot:Show(icon)
    end

    return false
end

---
-- This function handles spell interruption for the addon.
-- It checks for interruptible casts on the target, focus, and mouseover units
-- and uses Counter Shot or racial abilities to interrupt.
---
A[2] = function(icon)
    local latency = A.GetLatency()
    local units = { "target", "focus", "mouseover" }
    for _, unit in ipairs(units) do
        if UnitExists(unit) and IsUnitEnemy(unit) then
            local useKick, _, _, _, castRemainsTime = Action.InterruptIsValid(unit, nil, true)
            if useKick and castRemainsTime > latency then
                -- Prioritize Arcane Torrent if it's ready and in range, as it's AoE
                if A.ArcaneTorrent:IsReady(unit, nil, nil, true) then
                    return A.ArcaneTorrent:Show(icon)
                end
                if A.CounterShot:IsReadyByPassCastGCD(unit, nil, nil, true) then
                    return A.CounterShot:Show(icon)
                end
            end
        end
    end
    return false
end

---
-- This is the main entry point for the addon's rotation logic.
-- It determines the current combat situation (defensive, utility, single-target, or AoE)
-- and calls the appropriate rotation function.
---
A[3] = function(icon)
    -- Defensive checks
    if DefensiveRotation(icon) then
        return true
    end

    -- Utility checks
    if UtilityRotation(icon) then
        return true
    end

    -- Check for enemy target
    if not (A.Unit("target"):IsEnemy() and A.Unit("target"):IsExists()) then
        return false
    end

    -- AoE rotation for 2 or more targets
    if A.GetEnemyCount(8) >= 2 then
        if MultiTargetRotation(icon) then
            return true
        end
        -- Single target rotation
    else
        if SingleTargetRotation(icon) then
            return true
        end
    end

    return false
end
