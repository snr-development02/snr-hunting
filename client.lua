Citizen.CreateThread(function()
	while QBCore == nil do
		TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
		Citizen.Wait(0)
	end

	while QBCore.Functions.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

    PlayerData = QBCore.Functions.GetPlayerData()
end)

local avcilikinfo = false
local targetedEntity = nil
local targetedEntityCoord = nil

local baitDistanceInUnits = 40
local spawnDistanceRadius = 30
local validHuntingZones = {
    ["Paleto Forest"] = true,
    ["Raton Canyon"] = true,
    ["Mount Chiliad"] = true,
    ["Mount Gordo"] = true,
    ["Cassidy Creek"] = true
}

exports("huntingArea", function() -- exports['snr-hunting']:huntingArea()
    return validHuntingZones
end)

DecorRegister("HuntingMySpawn", 2)

Citizen.CreateThread(function()
    while true do
        local idle = 250
        local PlayerPed = PlayerPedId()
        local entity, entityType, entityCoords = GetEntityPlayerIsLookingAt(3.0, 0.2, 286, PlayerPed)

        if entity and entityType ~= 0 then
            if entity ~= CurrentTarget then
                CurrentTarget = entity
                TriggerEvent('target:changed', CurrentTarget, entityType, entityCoords)
            end
        elseif CurrentTarget then
            CurrentTarget = nil
            TriggerEvent('target:changed', CurrentTarget)
        end

        Citizen.Wait(idle)
    end
end)

function GetEntityPlayerIsLookingAt(pDistance, pRadius, pFlag, pIgnore)
    local distance = pDistance or 3.0
    local originCoords = GetPedBoneCoords(PlayerPedId(), 31086)
    local forwardVectors = GetForwardVector(GetGameplayCamRot(2))
    local forwardCoords = originCoords + (forwardVectors * (IsInVehicle and distance + 1.5 or distance))

    if not forwardVectors then return end

    local _, hit, targetCoords, _, targetEntity = RayCast(originCoords, forwardCoords, pFlag or 286, pIgnore, pRadius or 0.2)

    if not hit and targetEntity == 0 then return end

    local entityType = GetEntityType(targetEntity)

    return targetEntity, entityType, targetCoords
end

function GetForwardVector(rotation)
    local rot = (math.pi / 180.0) * rotation
    return vector3(-math.sin(rot.z) * math.abs(math.cos(rot.x)), math.cos(rot.z) * math.abs(math.cos(rot.x)), math.sin(rot.x))
end

function RayCast(origin, target, options, ignoreEntity, radius)
    local handle = StartShapeTestSweptSphere(origin.x, origin.y, origin.z, target.x, target.y, target.z, radius, options, ignoreEntity, 0)
    return GetShapeTestResult(handle)
end

RegisterNetEvent("target:changed")
AddEventHandler("target:changed", function(pEntity, type, coords)
    targetedEntity = pEntity
    targetedEntityCoord = coords
end)

local function isValidZone()
    return validHuntingZones[GetLabelText(GetNameOfZone(GetEntityCoords(PlayerPedId())))] == true
end

function GetClosestPlayerMenu()
	local player, distance = QBCore.Functions.GetClosestPlayer()
	if distance ~= -1 and distance <= 5.0 then
		return true, GetPlayerServerId(player)
	else
		return false
	end
end

local bussy = true
local lastTime = GetGameTimer() + 3000
RegisterNetEvent('snr-hunting:use-item')
AddEventHandler('snr-hunting:use-item', function(item)
    if GetGameTimer() > lastTime then
        lastTime = GetGameTimer() + 3000
        if item == "huntingknife" then
            if GetPedType(targetedEntity) ~= 28 or not IsPedDeadOrDying(targetedEntity) then
                QBCore.Functions.Notify(Config.dontanimallook)
                return
            end

            if GetEntityModel(targetedEntity) ~= -664053099 then
                QBCore.Functions.Notify(Config.onlydeer, "error")
                return
            end

            local found, player = GetClosestPlayerMenu()
            if found then
                QBCore.Functions.Notify(Config.ClosestPlayer, "error")
                return
            end

            if #(targetedEntityCoord - GetEntityCoords(PlayerPedId())) > 3 then
                QBCore.Functions.Notify(Config.youareveryfartoanimal, "error")
                return
            end

            if bussy then
                bussy = false
                local myAnimal = targetedEntity
                TriggerEvent("inventory:drop-weapon", false)
                TaskTurnPedToFaceEntity(PlayerPedId(), myAnimal, -1)
                Citizen.Wait(1500)
                ClearPedTasksImmediately(PlayerPedId())
                TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)

                QBCore.Functions.Progressbar("preparing_animal", Config.Cutting, Config.CuttingTime, false, true, { -- p1: menu name, p2: yazı, p3: ölü iken kullan, p4:iptal edilebilir
                    disableMovement = true,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function() -- Done
                    ClearPedTasksImmediately(PlayerPedId())
                    local mySpawn = DecorExistOn(myAnimal, "HuntingMySpawn") and DecorGetBool(myAnimal, "HuntingMySpawn")
                    TriggerServerEvent("snr-hunting:giveItem", QBCore.Key)
                    TriggerServerEvent("lapdance:delete-ped", NetworkGetNetworkIdFromEntity(myAnimal))
                    bussy = true
                end, function() -- Cancel
                    ClearPedTasksImmediately(PlayerPedId())
                    bussy = true
                end)
            end
        end
    else
        QBCore.Functions.Notify(Config.useitemdelay, "error")
    end
end)


--============================================================

local entities = {}
local huntingRifleHash = `weapon_musket`

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(80000)
        if isValidZone() then
            if GetSelectedPedWeapon(PlayerPedId()) == huntingRifleHash then
                local player = PlayerPedId()
                local pos = GetEntityCoords(player,1)
                local Model = GetHashKey("a_c_deer")

                RequestModel("a_c_deer")
                while not HasModelLoaded("a_c_deer") or not HasCollisionForModelLoaded("a_c_deer") do
                Wait(1)
                end	

                posX = pos.x+math.random(-100,100)
                posY = pos.y+math.random(-100,100)
                Z = pos.z+999.0
                heading = math.random(0,359)+.0
                ground,posZ = GetGroundZFor_3dCoord(posX+.0,posY+.0,Z,1)

                ped = CreatePed(28, "a_c_deer", posX, posY, posZ, heading, true, true)
                dist = GetEntityCoords(ped,1)
                TaskSmartFleePed(ped, PlayerPedId(), 600.0, -1)
                SetPedAsNoLongerNeeded(ped)
                SetModelAsNoLongerNeeded(ped)
                table.insert(entities,ped)
                local blip = AddBlipForEntity(ped)
                SetBlipSprite(blip,0)
                SetBlipColour(blip,0)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("spawned entity")
                EndTextCommandSetBlipName(blip)
                print("Spawned")
                for i, ped in pairs(entities) do
                    if IsEntityInWater(ped) then --if the animal spawns in water it will auto delete
                        local model = GetEntityModel(ped)
                        SetEntityAsNoLongerNeeded(ped)
                        SetModelAsNoLongerNeeded(model)
                        DeleteEntity(ped)
                        table.remove(entities,i)
                    end	
                end
            end
        end
    end
end)

RegisterNetEvent('snr-hunting:hayvantemizle')
AddEventHandler('snr-hunting:hayvantemizle', function(source)
    print("Tüm hayvanlar silindi")
    for i, ped in pairs(entities) do
        local model = GetEntityModel(ped)
        SetEntityAsNoLongerNeeded(ped)
        SetModelAsNoLongerNeeded(model)
        DeleteEntity(ped)
        table.remove(entities,i)	
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if isValidZone() then
            if avcilikinfo == false then
                QBCore.Functions.Notify(Config.HuntingAreaJoin)
                avcilikinfo = true
            end
        else
            if avcilikinfo == true then
                QBCore.Functions.Notify(Config.HuntingAreaLeave)
                avcilikinfo = false
            end
        end
    end
end)


--=====AİM LOCK ======
local hasHuntingRifle = false
local isFreeAiming = false
local function processScope(freeAiming)
  if not isFreeAiming and freeAiming then
    isFreeAiming = true
    --exports["np-ui"]:sendAppEvent("sniper-scope", { show = true })
  elseif isFreeAiming and not freeAiming then
    isFreeAiming = false
    --exports["np-ui"]:sendAppEvent("sniper-scope", { show = false })
  end
end

local blockShotActive = false
local function blockShooting()
    if blockShotActive then return end
    blockShotActive = true
    Citizen.CreateThread(function()
        while hasHuntingRifle do
            local ply = PlayerId()
            local ped = PlayerPedId()
            local ent = nil
            local aiming, ent = GetEntityPlayerIsFreeAimingAt(ply)
            local freeAiming = IsPlayerFreeAiming(ply)
            processScope(freeAiming)
            local et = GetEntityType(ent)
            if not freeAiming
                or IsPedAPlayer(ent)
                or et == 2
                or (et == 1 and IsPedInAnyVehicle(ent))
            then
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 47, true)
                DisableControlAction(0, 58, true)
                DisablePlayerFiring(ped, true)
            end
            Citizen.Wait(0)
        end
        blockShotActive = false
        processScope(false)
    end)
end

Citizen.CreateThread(function()
    local huntingRifleHash = `weapon_musket` -- -646649097

    while true do
        if GetSelectedPedWeapon(PlayerPedId()) == huntingRifleHash then
            hasHuntingRifle = true
            blockShooting()
        else
            hasHuntingRifle = false
        end
        Citizen.Wait(1000)
    end
end)



--======================== ALICI NPC ========================--

QBCore = nil
PlayerData = {}
menu = false

RegisterNetEvent('QBCore:Client:OnJobUptade')
AddEventHandler('QBCore:Client:OnJobUptade', function(job)
    PlayerData.job = job
end)

RegisterNetEvent('soner:client:huntingnpc')
AddEventHandler('soner:client:huntingnpc', function(playerData, actv)
    if Config.MeslekOlsunmu == true then
    if PlayerData.job and PlayerData.job.name == Config.MeslekIsim then
    toptancimenuac()
    Citizen.Wait(120000)
    QBCore.UI.Menu.CloseAll()
    SetNuiFocus(false, false)
    else
        QBCore.Functions.Notify("Tan", "error")
    end
else
    toptancimenuac()
    Citizen.Wait(120000)
    QBCore.UI.Menu.CloseAll()
    SetNuiFocus(false, false)
end
end)


function toptancimenuac()
    QBCore.UI.Menu.CloseAll()
    local elements = {}

    for k,v in pairs(Config.Detaylar) do
        table.insert(elements, {label = v.VerilenEsya.labeltarih, value = k})
    end

	QBCore.UI.Menu.Open('default', GetCurrentResourceName(), 'toptanci_default', {
		title = '',
		align = 'top-left',
        elements = elements
    },function(data, menu)
		if data.current.value then
            QBCore.UI.Menu.Open('dialog', GetCurrentResourceName(), 'toptanci_dialog',
            {
                title = "Ne kadar dönüştüreceksin? (max10)"
            },
            function(data3, menu3)
                local yazilanmiktar = tonumber(data3.value)
                if yazilanmiktar < 11 then
                    TriggerServerEvent('soner:toptanci:item:hunting', data.current.value, yazilanmiktar)
                    menu3.close()
                else
                    QBCore.Functions.Notify("Hatalı Miktar!", "error")
                end
            end, function(data3, menu3)
                menu3.close()
                menuacik = false
            end)
        else
            menu.close()
		end
    end, function(data, menu)
        menu.close()
	end)
end



exports['qb-target']:AddTargetModel("a_m_m_eastsa_02", {  --0xD71FE131
    options = {
        {
            type = "client",
            event = "soner:client:huntingnpc",
            icon = "fas fa-shopping-cart",
            label = Config.NPCTargetName,
        },
    },
    distance = 3.5,
})

Citizen.CreateThread(function()
    if Config.NPCOlsunmu == true then
        RequestModel(Config.NPCKodu)
        while not HasModelLoaded(Config.NPCKodu) do
            Wait(1)
        end
    
        sonerbeysdodoko = CreatePed(1, Config.NPCKodu, Config.NPCKonumu.x, Config.NPCKonumu.y, Config.NPCKonumu.z-1, Config.NPCKonumu.h, false, true)
        SetBlockingOfNonTemporaryEvents(sonerbeysdodoko, true)
        SetPedDiesWhenInjured(sonerbeysdodoko, false)
        SetPedCanPlayAmbientAnims(sonerbeysdodoko, true)
        SetPedCanRagdollFromPlayerImpact(sonerbeysdodoko, false)
        SetEntityInvincible(sonerbeysdodoko, true)
        FreezeEntityPosition(sonerbeysdodoko, true)
        TaskStartScenarioInPlace(sonerbeysdodoko, "WORLD_HUMAN_CLIPBOARD", 0, true);
    end
end)