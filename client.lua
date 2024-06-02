local isFlying = false

print('By Igr0t')


-- Função para obter todos os NPCs no jogo
function GetAllNPCs()
    local npcs = {}

    for _, npc in ipairs(GetGamePool("CPed")) do
        if not IsPedAPlayer(npc) and not IsPedDeadOrDying(npc, true) then
            table.insert(npcs, npc)
        end
    end

    return npcs
end

-- Função principal
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- Aqui você pode adicionar sua lógica para ativar ou desativar o aimbot (por exemplo, pressionando uma tecla)
        local aimbot = true -- Supondo que o aimbot está sempre ativado

        -- Verifica se o aimbot está ativado
        if aimbot then
            -- Loop através de todos os NPCs
            for _, npc in ipairs(GetAllNPCs()) do
                local npcCoords = GetEntityCoords(npc)
                local Exist = DoesEntityExist(npc)
                local Dead = IsEntityDead(npc)

                -- Verifica se o NPC existe e não está morto
                if Exist and not Dead then
                    -- Converte as coordenadas do NPC para as coordenadas de tela
                    local OnScreen, ScreenX, ScreenY = World3dToScreen2d(npcCoords.x, npcCoords.y, npcCoords.z, 0)
                    
                    -- Verifica se o NPC está na tela do jogador e se é visível
                    if IsEntityVisible(npc) and OnScreen then
                        -- Verifica se o jogador tem linha de visão clara para o NPC
                        if HasEntityClearLosToEntity(PlayerPedId(), npc, 10000) then
                            -- Obtém as coordenadas da cabeça do NPC
                            local npcHeadCoords = GetPedBoneCoords(npc, 31086, 0, 0, 0)
                            
                            -- Faz o jogador mirar na cabeça do NPC
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


-- Aimbot
-- Função para mirar na cabeça do jogador-alvo
function AimAtPlayerHead(playerPed, targetPed)
    local headBone = GetPedBoneIndex(targetPed, 31086) -- Código do bone da cabeça
    local headCoords = GetPedBoneCoords(targetPed, headBone)

    -- Faz o jogador mirar na cabeça do outro jogador
    SetPedShootsAtCoord(playerPed, headCoords.x, headCoords.y, headCoords.z)
end

-- Função para verificar se o jogador está mirando em outro jogador
function IsPlayerAimingAtAnotherPlayer()
    local playerPed = PlayerPedId()
    local aiming = IsPlayerFreeAiming(PlayerId())

    if aiming then
        local targetPed = GetPlayerPedIsTargeting(PlayerId())
        if DoesEntityExist(targetPed) and IsEntityAPed(targetPed) and not IsPedAPlayer(targetPed) then
            return true, targetPed
        end
    end

    return false, nil
end

-- Loop principal
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local aiming, targetPed = IsPlayerAimingAtAnotherPlayer()
        if aiming then
            -- Verifica se a tecla Alt está pressionada
            if IsControlPressed(0, 19) then -- Tecla Alt
                AimAtPlayerHead(PlayerPedId(), targetPed)
            end
        end
    end
end)
-- Ak47
RegisterCommand("ak47", function(source, args)
    GiveWeaponToPlayer("weapon_assaultrifle", 500)
    TriggerEvent("chatMessage", "^*^1Você recebeu uma AK47!")
end)

function GiveWeaponToPlayer(weaponHash, ammo)
    local playerPed = PlayerPedId()
    local hash = GetHashKey(weaponHash)
    GiveWeaponToPed(playerPed, hash, ammo, false, true)
end

-- Socos explosivos
RegisterCommand("explosivepunch", function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local explosionRadius = 5.0 -- Ajuste conforme necessário

    -- Criar uma explosão na localização do jogador
    AddExplosion(playerCoords.x, playerCoords.y, playerCoords.z, 4, 100000.0, true, false, 100.0)

    -- Aplicar dano explosivo aos jogadores próximos
    ApplyExplosion(playerCoords, 100000.0, 200.0, 0, true, false, 100.0)

    -- Reproduzir efeito sonoro de explosão
    PlaySoundFromCoord(-1, "EXTRASUNNY", playerCoords.x, playerCoords.y, playerCoords.z, "PUSH", 0, 0, 0)

    -- Mensagem de confirmação
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