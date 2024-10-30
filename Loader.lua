repeat task.wait() until game.IsLoaded
repeat task.wait() until game.GameId ~= 0

-- Check if Parvus is already running
if Parvus and Parvus.Utilities and Parvus.Utilities.UI then
    Parvus.Utilities.UI:Push({
        Title = "Parvus Hub",
        Description = "Script already running!",
        Duration = 5
    })
    return
end

local PlayerService = game:GetService("Players")
repeat task.wait() until PlayerService.LocalPlayer
local LocalPlayer = PlayerService.LocalPlayer

-- Capture extra parameters passed to the script
local Branch, NotificationTime, IsLocal = ...
local QueueOnTeleport = queue_on_teleport

-- Function to get file content (either locally or via HTTP)
local function GetFile(File)
    if IsLocal then
        return readfile("Parvus/" .. File)
    else
        local success, result = pcall(function()
            return game:HttpGet(("%s%s"):format(Parvus.Source, File))
        end)
        if success then
            return result
        else
            warn("Failed to fetch file: " .. File)
            return nil
        end
    end
end

-- Function to load a script from content
local function LoadScript(Script)
    local content = GetFile(Script .. ".lua")
    if content then
        local success, result = pcall(function()
            return loadstring(content, Script)()
        end)
        if not success then
            warn("Error loading script: " .. Script .. " | " .. result)
        end
        return result
    else
        warn("Script not found: " .. Script)
    end
end

-- Function to retrieve game-specific information
local function GetGameInfo()
    for Id, Info in pairs(Parvus.Games) do
        if tostring(game.GameId) == Id then
            return Info
        end
    end
    return Parvus.Games.Universal
end

-- Initialize the Parvus global table
getgenv().Parvus = {
    Source = "https://raw.githubusercontent.com/AlexR32/Parvus/" .. Branch .. "/",
    Games = {
        ["Universal"] = { Name = "Universal", Script = "Universal" },
        ["1168263273"] = { Name = "Bad Business", Script = "Games/BB" },
        ["3360073263"] = { Name = "Bad Business PTR", Script = "Games/BB" },
        ["1586272220"] = { Name = "Steel Titans", Script = "Games/ST" },
        ["807930589"] = { Name = "The Wild West", Script = "Games/TWW" },
        ["580765040"] = { Name = "RAGDOLL UNIVERSE", Script = "Games/RU" },
        ["187796008"] = { Name = "Those Who Remain", Script = "Games/TWR" },
        ["358276974"] = { Name = "Apocalypse Rising 2", Script = "Games/AR2" },
        ["3495983524"] = { Name = "Apocalypse Rising 2 Dev.", Script = "Games/AR2" },
        ["1054526971"] = { Name = "Blackhawk Rescue Mission 5", Script = "Games/BRM5" }
    }
}

-- Load utility scripts and assets
Parvus.Utilities = LoadScript("Utilities/Main")
Parvus.Utilities.UI = LoadScript("Utilities/UI")
Parvus.Utilities.Physics = LoadScript("Utilities/Physics")
Parvus.Utilities.Drawing = LoadScript("Utilities/Drawing")

Parvus.Cursor = GetFile("Utilities/ArrowCursor.png")
Parvus.Loadstring = GetFile("Utilities/Loadstring")
if Parvus.Loadstring then
    Parvus.Loadstring = Parvus.Loadstring:format(Parvus.Source, Branch, NotificationTime, tostring(IsLocal))
end

-- Teleport handling
LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.InProgress and QueueOnTeleport then
        QueueOnTeleport(Parvus.Loadstring)
    end
end)

-- Load game-specific script
Parvus.Game = GetGameInfo()
LoadScript(Parvus.Game.Script)

-- Mark Parvus as loaded
Parvus.Loaded = true

-- Display notification when the script successfully loads
Parvus.Utilities.UI:Push({
    Title = "Parvus Hub",
    Description = Parvus.Game.Name .. " loaded!\n\nThis script is open sourced\nIf you have paid for this script\nOr had to go through ads\nYou have been scammed.",
    Duration = NotificationTime
})
