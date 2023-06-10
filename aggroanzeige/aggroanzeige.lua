-- Erstellen des Frames für die Aggro-Anzeige
local AggroFrame = CreateFrame("Frame", "AggroFrame", UIParent)
AggroFrame:SetWidth(150)
AggroFrame:SetHeight(30)
AggroFrame:SetPoint("CENTER", 0, 0)
AggroFrame:EnableMouse(true)
AggroFrame:SetMovable(true)
AggroFrame:RegisterForDrag("LeftButton")
AggroFrame:SetScript("OnDragStart", AggroFrame.StartMoving)
AggroFrame:SetScript("OnDragStop", AggroFrame.StopMovingOrSizing)

-- Hintergrundtextur des Frames
AggroFrame.texture = AggroFrame:CreateTexture(nil, "BACKGROUND")
AggroFrame.texture:SetAllPoints(AggroFrame)
AggroFrame.texture:SetColorTexture(0, 0, 0, 0.7)

-- Funktion zum Aktualisieren der Aggro-Anzeige
local function UpdateAggroDisplay()
    local numTargets = 0
    local targetsData = {}

    -- Durchlaufe alle Einheiten im Kampf und sammle Aggro-Daten
    for i = 1, 40 do -- Maximale Anzahl von Zielen anpassen, falls erforderlich
        local unit = "nameplate" .. i -- Einheitentyp anpassen, falls erforderlich
        if UnitExists(unit) and not UnitIsDead(unit) then
            local _, _, threatPercentage = UnitDetailedThreatSituation("player", unit)
            if threatPercentage then
                local aggroData = math.floor(threatPercentage)
                local targetName = UnitName(unit)
                table.insert(targetsData, {name = targetName, aggro = aggroData})
                numTargets = numTargets + 1
            end
        end
    end

    -- Sortiere die Zieldaten nach Aggro in absteigender Reihenfolge
    table.sort(targetsData, function(a, b)
        return a.aggro > b.aggro
    end)

    -- Aktualisiere die Anzeige mit den Zieldaten
    local displayText = "Aggro: "
    for i, targetData in ipairs(targetsData) do
        local targetName = targetData.name
        local aggroPercent = targetData.aggro
        displayText = displayText .. targetName .. " (" .. aggroPercent .. "%)"
        if i < numTargets then
            displayText = displayText .. ", "
        end
    end
    AggroFrame.text:SetText(displayText)
end


-- Text für die Aggro-Anzeige
AggroFrame.text = AggroFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
AggroFrame.text:SetPoint("CENTER", 0, 0)
AggroFrame.text:SetText("Aggro: ")
AggroFrame.text:SetTextColor(1, 1, 1)



-- Funktion zum Überprüfen, ob der Spieler eine Tankspezialisierung hat
local function IsPlayerTankSpec()
    local class = select(2, UnitClass("player"))
    local specIndex = GetSpecialization()
    if specIndex then
        local role = GetSpecializationRole(specIndex)
        if class == "WARRIOR" and role == "TANK" then
            return true
        elseif class == "DRUID" and role == "TANK" then
            return true
        elseif class == "MONK" and role == "TANK" then
            return true
        elseif class == "DEMONHUNTER" and role == "TANK" then
            return true
        elseif class == "PALADIN" and role == "TANK" then
            return true
        elseif class == "DEATHKNIGHT" and role == "TANK" then
            return true
        end
    end
    return false
end

-- Ereignisbehandlung für Aggro-Änderungen
AggroFrame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
AggroFrame:SetScript("OnEvent", function(_, event)
    if event == "UNIT_THREAT_LIST_UPDATE" then
        UpdateAggroDisplay()
    end
end)

-- Funktion zum Ein- und Ausschalten des Addons
local function ToggleAddon(enabled)
    if enabled then
        AggroFrame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
        UpdateAggroDisplay()
        AggroFrame:Show()
    else
        AggroFrame:UnregisterAllEvents()
        AggroFrame:Hide()
    end
end


-- Initialisierung des Addons
ToggleAddon(true) -- Aktiviere das Addon beim Start (kann anpassen, wie das Addon aktiviert/deaktiviert wird)

-- Funktion zum Abrufen des aktuellen Addon-Status
local function IsAddonEnabled()
    return AggroFrame:IsEventRegistered("PLAYER_REGEN_ENABLED")
end

-- Funktion zum Speichern des Addon-Status
local function SetAddonEnabled(enabled)
    AggroAddonSettings.Enabled = enabled
end

-- Funktion zum Laden des Addon-Status
local function GetAddonEnabled()
    return AggroAddonSettings.Enabled
end

-- Registrieren des Addons im Interface-AddOns-Menü
local addonName = "AggroAddon"
local addon = CreateFrame("Frame")
addon:RegisterEvent("PLAYER_LOGIN")
addon:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        local frame = CreateFrame("Frame", addonName, UIParent)
        frame.name = addonName
        frame:SetScript("OnShow", function(self)
            self.checkbox:SetChecked(GetAddonEnabled())
        end)
        frame:SetScript("OnHide", function(self)
            SetAddonEnabled(self.checkbox:GetChecked())
        end)

        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        frame.title:SetPoint("TOPLEFT", 16, -16)
        frame.title:SetText(addonName)

        frame.checkbox = CreateFrame("CheckButton", addonName.."Checkbox", frame, "ChatConfigCheckButtonTemplate")
        frame.checkbox:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -8)
        frame.checkbox:SetScript("OnClick", function(self)
            self:SetChecked(not self:GetChecked())
        end)

        frame.checkbox.text = frame.checkbox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.checkbox.text:SetPoint("LEFT", frame.checkbox, "RIGHT", 0, 1)
        frame.checkbox.text:SetText("Addon aktivieren")

        InterfaceOptions_AddCategory(frame)
    end
end)

-- Laden des Addon-Status beim Login
local function LoadAddonStatus()
    if AggroAddonSettings == nil then
        AggroAddonSettings = {}
    end
    if AggroAddonSettings.Enabled == nil then
        AggroAddonSettings.Enabled = true
    end
    ToggleAddon(GetAddonEnabled())
end

-- Registrieren des Events zum Laden des Addon-Status
addon:RegisterEvent("ADDON_LOADED")
addon:SetScript("OnEvent", function(self, event, addonLoaded)
    if event == "ADDON_LOADED" and addonLoaded == addonName then
        LoadAddonStatus()
    end
end)