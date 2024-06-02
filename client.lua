local isFlying = false

print('By Igr0t')



function GetAllNPCs()
    local npcs = {}

    for _, npc in ipairs(GetGamePool("CPed")) do
        if not IsPedAPlayer(npc) and not IsPedDeadOrDying(npc, true) then
            table.insert(npcs, npc)
        end
    end

    return npcs
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

       
        local aimbot = true 

        
        if aimbot then
            -- Loop através de todos os NPCs
            for _, npc in ipairs(GetAllNPCs()) do
                local npcCoords = GetEntityCoords(npc)
                local Exist = DoesEntityExist(npc)
                local Dead = IsEntityDead(npc)

               
                if Exist and not Dead then
                    -- Converte as coordenadas do NPC para as coordenadas de tela
                    local OnScreen, ScreenX, ScreenY = World3dToScreen2d(npcCoords.x, npcCoords.y, npcCoords.z, 0)
                    
                    
                    if IsEntityVisible(npc) and OnScreen then
                       
                        if HasEntityClearLosToEntity(PlayerPedId(), npc, 10000) then
                            -- Obtém as coordenadas da cabeça do NPC
                            local npcHeadCoords = GetPedBoneCoords(npc, 31086, 0, 0, 0)
                            
                          
                            SetPedShootsAtCoord(PlayerPedId(), npcHeadCoords.x, npcHeadCoords.y, npcHeadCoords.z, 1)
                        end
                    end
                end
            end
        end
    end
end)


function GetClosestPed()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local handle, ped = FindFirstPed()
    local success
    local closestPed = 0
    local closestDistance = -1
    
    repeat
        local pedCoords = GetEntityCoords(ped)
        local distance = #(playerCoords - pedCoords)
        
        if closestDistance == -1 or distance < closestDistance then
            closestPed = ped
            closestDistance = distance
        end
        
        success, ped = FindNextPed(handle)
    until not success
    
    EndFindPed(handle)
    
    return closestPed
end

-- ESP

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for _, npc in ipairs(GetAllNPCs()) do
            if not IsEntityDead(npc) then -- Verifica se o NPC não está morto
                local npcCoords = GetEntityCoords(npc)
                local distance = #(playerCoords - npcCoords)

                if distance <= 5000 then
                    -- Verifica se o NPC é um ped humano
                    if IsPedHuman(npc) then
                        -- Desenha a linha do jogador até o NPC
                        DrawLine(playerCoords.x, playerCoords.y, playerCoords.z, npcCoords.x, npcCoords.y, npcCoords.z, 255, 255, 255, 255)

                        -- Calcula os cantos do quadrado em volta do NPC
                        local npcHeading = GetEntityHeading(npc)
                        local npcForward = vector3(math.sin(npcHeading * math.pi / 180.0), math.cos(npcHeading * math.pi / 180.0), 0.0)
                        local npcRight = vector3(-npcForward.y, npcForward.x, 0.0) * 1.0
                        local npcUp = vector3(0.0, 0.0, 1.0) * 1.0
                        local npcTopLeft = npcCoords - npcRight - npcUp
                        local npcTopRight = npcCoords + npcRight - npcUp
                        local npcBottomLeft = npcCoords - npcRight + npcUp
                        local npcBottomRight = npcCoords + npcRight + npcUp

                        -- Desenha o quadrado em volta do NPC
                        DrawLine(npcTopLeft.x, npcTopLeft.y, npcTopLeft.z, npcTopRight.x, npcTopRight.y, npcTopRight.z, 255, 255, 255, 255)
                        DrawLine(npcTopRight.x, npcTopRight.y, npcTopRight.z, npcBottomRight.x, npcBottomRight.y, npcBottomRight.z, 255, 255, 255, 255)
                        DrawLine(npcBottomRight.x, npcBottomRight.y, npcBottomRight.z, npcBottomLeft.x, npcBottomLeft.y, npcBottomLeft.z, 255, 255, 255, 255)
                        DrawLine(npcBottomLeft.x, npcBottomLeft.y, npcBottomLeft.z, npcTopLeft.x, npcTopLeft.y, npcTopLeft.z, 255, 255, 255, 255)
                    end
                end
            end
        end
    end
end)

function GetAllNPCs()
    local npcs = {}

    for _, npc in ipairs(GetGamePool("CPed")) do
        if not IsPedAPlayer(npc) then
            table.insert(npcs, npc)
        end
    end

    return npcs
end


-- Socos explosivos
RegisterCommand("explosivepunch", function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local explosionRadius = 5.0 -- Ajuste conforme necessário

    AddExplosion(playerCoords.x, playerCoords.y, playerCoords.z, 4, 100000.0, true, false, 100.0)
    
    ApplyExplosion(playerCoords, 100000.0, 200.0, 0, true, false, 100.0)

    
    PlaySoundFromCoord(-1, "EXTRASUNNY", playerCoords.x, playerCoords.y, playerCoords.z, "PUSH", 0, 0, 0)

    TriggerEvent("chatMessage", "^*^1Você deu um soco explosivo!")
end, false)

-- Vida infinita
local health = GetEntityHealth(PlayerPedId())
local maxHealth = GetEntityMaxHealth(PlayerPedId())
if health < maxHealth then
    SetEntityHealth(PlayerPedId(), maxHealth)
end

-- Fly Mode
RegisterCommand('igr0t', function()
    isFlying = not isFlying
    if isFlying then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {'[Servidor]', 'Fly Mode Ativado By Igr0t'}
        })
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {'[Servidor]', 'Fly Mode Desativado By Igr0t'}
        })
    end
end)

RegisterCommand("carabine", function(source, args)
    GiveWeaponToPlayer("weapon_carbinerifle", 500)
    TriggerEvent("chatMessage", "^*^1Ak no seu inventario seu bosta!")
end)
