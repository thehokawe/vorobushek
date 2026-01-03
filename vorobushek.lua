script_name('Welcome Vorobushek Squad')
script_author('Vorobushek Squad')
script_version('2.0')
script_description('Приветственное сообщение')

require 'lib.moonloader'
require 'sampfuncs'

local discordLink = "https://discord.gg/rBgQUDqFEm"
local githubRaw = "https://raw.githubusercontent.com/thehokawe/vorobushek/main/vorobushek.lua"
local currentVersion = "2.0"
local messageShown = false
local updateChecked = false

function showWelcomeMessage()
    local timestamp = os.date("%H:%M:%S")
    
    sampAddChatMessage("{FFD700}══════════════════════════════════════════", -1)
    sampAddChatMessage("{FFD700}[{FFA500}" .. timestamp .. "{FFD700}] {FFFFFF}Здравствуй, дорогой пользователь!", -1)
    sampAddChatMessage("{FFFFFF}Вы видите это сообщение, так как скачали", -1)
    sampAddChatMessage("{FFFFFF}сборку от {FF0000}Vorobushek Squad{FFFFFF}!", -1)
    sampAddChatMessage("", -1)
    sampAddChatMessage("{FFFFFF}Спасибо, что остаетесь с нами!", -1)
    sampAddChatMessage("{FFFFFF}Чтобы поддержать разработчика,", -1)
    sampAddChatMessage("{FFFFFF}заходите к нам в Discord сервер:", -1)
    sampAddChatMessage("{00FFFF}" .. discordLink, -1)
    sampAddChatMessage("", -1)
    sampAddChatMessage("{FFFFFF}Там находятся все свежие обновления.", -1)
    sampAddChatMessage("{FFFFFF}Удачной игры и хорошего настроения!", -1)
    sampAddChatMessage("{FFD700}══════════════════════════════════════════", -1)
end

function reloadScript()
    wait(1000)
    thisScript():reload()
end

function checkForUpdates()
    lua_thread.create(function()
        wait(3000)
        sampAddChatMessage("{FFFF00}[Welcome] {FFFFFF}Проверка обновлений...", -1)
        
        local remoteFile = downloadUrlToMemory(githubRaw)
        if not remoteFile or #remoteFile == 0 then
            return
        end
        
        local remoteVersion
        for line in remoteFile:gmatch("[^\r\n]+") do
            local version = line:match('script_version%(["\']([%d%.]+)["\']%)')
            if version then
                remoteVersion = version
                break
            end
        end
        
        if not remoteVersion then
            return
        end
        
        local currentParts = {}
        local remoteParts = {}
        
        for part in currentVersion:gmatch("%d+") do
            table.insert(currentParts, tonumber(part))
        end
        
        for part in remoteVersion:gmatch("%d+") do
            table.insert(remoteParts, tonumber(part))
        end
        
        local updateAvailable = false
        for i = 1, math.max(#currentParts, #remoteParts) do
            local current = currentParts[i] or 0
            local remote = remoteParts[i] or 0
            
            if remote > current then
                updateAvailable = true
                break
            elseif remote < current then
                break
            end
        end
        
        if updateAvailable then
            sampAddChatMessage("{00FF00}[Welcome] {FFFFFF}Найдено обновление!", -1)
            sampAddChatMessage("{00FF00}[Welcome] {FFFFFF}Скачиваю обновление...", -1)
            
            local scriptPath = thisScript().path
            local tempPath = scriptPath .. ".tmp"
            local success = downloadUrlToFile(githubRaw, tempPath)
            
            if success then
                local file = io.open(tempPath, "r")
                if file then
                    local content = file:read("*all")
                    file:close()
                    
                    if content:find("script_name") and content:find("main") then
                        os.remove(scriptPath)
                        os.rename(tempPath, scriptPath)
                        
                        sampAddChatMessage("{00FF00}[Welcome] {FFFFFF}Обновление скачано!", -1)
                        sampAddChatMessage("{00FF00}[Welcome] {FFFFFF}Перезагрузка скрипта...", -1)
                        
                        lua_thread.create(reloadScript)
                        return true
                    end
                end
            end
            sampAddChatMessage("{FF0000}[Welcome] {FFFFFF}Ошибка загрузки обновления", -1)
        end
        return false
    end)
end

function main()
    while not isSampAvailable() do
        wait(100)
    end
    
    while true do
        wait(100)
        
        if not messageShown and sampIsLocalPlayerSpawned() then
            wait(3000)
            showWelcomeMessage()
            messageShown = true
            
            if not updateChecked then
                checkForUpdates()
                updateChecked = true
            end
        end
    end
end
