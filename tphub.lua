local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "TP + ESP Tool",
    LoadingTitle = "TP Script",
    LoadingSubtitle = "Raw Version",
    ConfigurationSaving = {
        Enabled = false,
    }
})

local MainTab = Window:CreateTab("Main", 4483362458)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local selectedPlayer = nil
local highlights = {}

-- Get player list (exclude self)
local function getPlayerList()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(list, plr.Name)
        end
    end
    table.sort(list)
    return list
end

-- Create ESP Highlight
local function createESP(player)
    if highlights[player] or not player.Character then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "TP_ESP"
    highlight.Adornee = player.Character
    highlight.FillColor = Color3.fromRGB(255, 50, 50)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.35
    highlight.OutlineTransparency = 0
    highlight.Parent = player.Character
    
    highlights[player] = highlight
end

-- Remove ESP for a player
local function removeESP(player)
    if highlights[player] then
        highlights[player]:Destroy()
        highlights[player] = nil
    end
end

-- Refresh all ESP
local function refreshESP()
    for player, hl in pairs(highlights) do
        if not player.Character or not player.Parent then
            removeESP(player)
        end
    end
end

-- Teleport to player
local function teleportTo(player)
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        Rayfield:Notify({
            Title = "TP Failed",
            Content = "Player has no character or left the game.",
            Duration = 4,
            Image = 4483362458
        })
        return
    end

    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)  -- slight offset so you don't clip
        Rayfield:Notify({
            Title = "Teleported",
            Content = "TP'd to " .. player.Name,
            Duration = 3,
        })
    end
end

-- Dropdown for players
local playerDropdown = MainTab:CreateDropdown({
    Name = "Select Player",
    Options = getPlayerList(),
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "SelectedPlayer",
    Callback = function(selected)
        if #selected > 0 then
            selectedPlayer = Players:FindFirstChild(selected[1])
        else
            selectedPlayer = nil
        end
    end,
})

-- Buttons
MainTab:CreateButton({
    Name = "🔄 Refresh Player List",
    Callback = function()
        local newList = getPlayerList()
        playerDropdown:Refresh(newList, true)
        Rayfield:Notify({Title = "List Updated", Content = "Players refreshed", Duration = 2})
    end,
})

MainTab:CreateButton({
    Name = "🚀 Teleport to Selected Player",
    Callback = function()
        if not selectedPlayer then
            Rayfield:Notify({Title = "Error", Content = "No player selected", Duration = 3})
            return
        end
        teleportTo(selectedPlayer)
    end,
})

MainTab:CreateToggle({
    Name = "Player ESP (Highlights)",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(value)
        if value then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    createESP(plr)
                end
            end
            Rayfield:Notify({Title = "ESP Enabled", Content = "Red highlights on players", Duration = 3})
        else
            for plr, _ in pairs(highlights) do
                removeESP(plr)
            end
            Rayfield:Notify({Title = "ESP Disabled", Content = "", Duration = 2})
        end
    end,
})

-- Auto refresh list + ESP when players join/leave
Players.PlayerAdded:Connect(function(plr)
    wait(1)
    playerDropdown:Refresh(getPlayerList(), true)
    if Rayfield.Flags.ESP.CurrentValue then
        createESP(plr)
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    wait(0.5)
    playerDropdown:Refresh(getPlayerList(), true)
    removeESP(plr)
end)

-- Initial ESP if already enabled (in case you re-execute)
Rayfield:Notify({
    Title = "TP + ESP Loaded",
    Content = "Select player → Refresh if needed → TP or turn on ESP",
    Duration = 6,
})