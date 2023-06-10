-- Definiere globale Variablen für das Addon
local GuildMotDAddon = {}
GuildMotDAddon.Frame = nil

-- Funktion zum Öffnen des Fensters
function GuildMotDAddon:OpenWindow()
    if not self.Frame then
        -- Erstelle das Fenster und positioniere es
        self.Frame = CreateFrame("Frame", "GuildMotDAddonFrame", UIParent, "BasicFrameTemplate")
        self.Frame:SetSize(300, 200)
        self.Frame:SetPoint("CENTER")
        self.Frame:SetMovable(true)
        self.Frame:EnableMouse(true)
        self.Frame:RegisterForDrag("LeftButton")
        self.Frame:SetScript("OnDragStart", self.Frame.StartMoving)
        self.Frame:SetScript("OnDragStop", self.Frame.StopMovingOrSizing)

        -- Füge Titel hinzu
        self.Frame.title = self.Frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        self.Frame.title:SetPoint("TOP", self.Frame, "TOP", 0, -10)
        self.Frame.title:SetText("Gildennachricht des Tages")

        -- Füge Texteingabefeld hinzu
        self.Frame.editBox = CreateFrame("EditBox", nil, self.Frame, "InputBoxTemplate")
        self.Frame.editBox:SetSize(250, 20)
        self.Frame.editBox:SetPoint("TOP", self.Frame.title, "BOTTOM", 0, -20)
        self.Frame.editBox:SetAutoFocus(false)

        -- Füge Speichern-Button hinzu
        self.Frame.saveButton = CreateFrame("Button", nil, self.Frame, "UIPanelButtonTemplate")
        self.Frame.saveButton:SetSize(80, 25)
        self.Frame.saveButton:SetPoint("BOTTOM", 0, 20)
        self.Frame.saveButton:SetText("Speichern")
        self.Frame.saveButton:SetScript("OnClick", function()
            local motd = self.Frame.editBox:GetText()
            GuildSetMOTD(motd)
            self.Frame:Hide()
        end)
    end

    -- Zeige das Fenster an
    self.Frame:Show()
end

-- Registriere ein Ereignis, um das Fenster zu öffnen
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    SlashCmdList["GUILD_MOTD"] = function()
        GuildMotDAddon:OpenWindow()
    end
    SLASH_GUILD_MOTD1 = "/gmotd"
end)
