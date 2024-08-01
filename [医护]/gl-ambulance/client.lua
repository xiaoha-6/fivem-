
local medBag
local isShot = false
local isMeleed = false
local isBurned = false
local isDead = false
local curWound = nil
local stretcher
local vehicle
local emsCount = 0
local npc
local pedSpawned = false
local grandmaSpawned = false
local grandma

-- Do ESX Shit
local ESX = nil

local export, ESX = pcall(function()
    return exports['es_extended']:getSharedObject()
end)

CreateThread(function()
    if not export then
        while not ESX do
            TriggerEvent("esx:getSharedObject", function(obj)
                ESX = obj
            end)
            Wait(500)
        end
        while not ESX.GetPlayerData()?.job do
          Wait(500)
        end
    end
end)


RegisterNetEvent('esx:onPlayerLogout', function()
    ESX.PlayerLoaded = false
    ESX.PlayerData = {}
  end)
  
  RegisterNetEvent('esx:playerLoaded', function(xPlayer)
      ESX.PlayerData = xPlayer
      ESX.PlayerLoaded = true

  end)

CreateThread(function()
    local hospitalBlip = AddBlipForCoord(Config.HospitalBlipCoords)

    SetBlipSprite(hospitalBlip, 61)
    SetBlipScale(hospitalBlip, 1.0)
    SetBlipColour(hospitalBlip, 2)
    SetBlipAsShortRange(hospitalBlip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Pillbox Medical')
    EndTextCommandSetBlipName(hospitalBlip)
--老板菜单
    exports['qtarget']:AddBoxZone("AmbRestock", vector3(306.81, -601.64, 43.28), 2.5, 2.5, {
        name="AmbRestock",
        heading=340.0,
        debugPoly=true,
        minZ=43.0,
        maxZ=44.5
    }, {
        options = {
            {
                event = "gl-ambulance:restockEMS",
                icon = "fas fa-ambulance",
                label = 'Re-Stock',
            },
            {
                event = "gl-ambulance:openBossMenu",
                icon = "fas fa-ambulance",
                label = 'Open Boss Menu',
            },
        },
            job = {"ambulance"},
            distance = 1.5 
    })

    local medical = {`xm_prop_x17_bag_med_01a`}

        exports['qtarget']:AddTargetModel(medical, {
            options = {
                {
                    event = "gl-ambulance:pickUpBag",
                    icon = "fas fa-hand-paper",
                    label = 'Pick Up',
                },
                {
                    event = "gl-ambulance:interactBag",
                    icon = "fas fa-hand-paper",
                    label = 'Interact',
                },
    
            },
            job = {"all"},
            distance = 1.5
        })

local stretch = { `prop_ld_binbag_01`}

        exports['qtarget']:AddTargetModel(stretch, {
            options = {
                {
                    event = "gl-ambulance:LayDown",
                    icon = "fas fa-bed",
                    label = 'Lay Down',
                },
    
            },
            job = {"all"},
            distance = 1.5
        })
end)

RegisterNetEvent('gl-ambulance:restockEMS',function()
    local restockEMS = {}
        for k, v in pairs(Config.Restock) do
            table.insert(restockEMS, 
            {
                id = k,
                header = 'Restock Equipment',
                txt = '1x ' .. v.label,
                params = {
                    event = 'gl-ambulance:getItem',
                    args = {
                        v.item,
                    }                
                }
            })
        end
        exports['gl-ambulance']:CreateMenu(restockEMS)
end)

RegisterNetEvent('gl-ambulance:openBossMenu',function()
    TriggerEvent('esx_society:openBossMenu', 'ambulance', function(data, menu)
        menu.close()
    end)

end)

RegisterNetEvent('gl-ambulance:interactBag',function()
    if ESX.PlayerData.job.name == 'ambulance' or ESX.PlayerData.job.name == 'police' then
        exports['gl-ambulance']:CreateMenu({
            {
                id = 1,
                header = "Medical Bag",
                txt = "Stored Items"
            },
            {
                id = 2,
                header = "Tweezers",
                txt = "Used to Remove Bullets",
                params = {
                    event = "gl-ambulance:getItem",
                    args = {
                        'tweezers'
    
                    }    
                }
            },
            {
                id = 3,
                header = "Suture Kit" ,
                txt = "Used to Stitch Up Wounds",
                params = {
                    event = "gl-ambulance:getItem",
                    args = {
                        'suturekit'
                    }
                }
            },
    
            {
                id = 4,
                header = "Burn Cream",
                txt = "Your moms gonna need it",
                params = {
                    event = "gl-ambulance:getItem",
                    args = {
                        'burncream'
    
                    }
                }
            },
    
            {
                id = 5,
                header = "Defibrillator",
                txt = "For Restoring a Heart Beat",
                params = {
                    event = "gl-ambulance:getItem",
                    args = {
                        'defib'
    
                    }
                }
            },
            {
                id = 6,
                header = "Sedative",
                txt = "Go Night Night ",
                params = {
                    event = "gl-ambulance:getItem",
                    args = {
                        'sedative'
    
                    }
                }
            },
            {
                id = 7,
                header = "Foldable Stretcher",
                txt = "Stretcher",
                params = {
                    event = "gl-ambulance:getItem",
                    args = {
                        'stretcher'
    
                    }
                }
            },
        
        })
    end
end)

RegisterNetEvent('gl-ambulance:getItem',function(data)
    TriggerServerEvent('gl-ambulance:getItemForEMS',data)    
end)

RegisterNetEvent('gl-ambulance:pickUpBag',function()
    -- Do Animation Later Dummy
    local pedCoords = GetEntityCoords(PlayerPedId())
    local closestObject = GetClosestObjectOfType(pedCoords, 3.0, GetHashKey("xm_prop_x17_bag_med_01a"), false)
    local objCoords = GetEntityCoords(closestObject)
    DeleteEntity(closestObject)
    if ESX.PlayerData.job.name == 'ambulance' or ESX.PlayerData.job.name == 'police' then
        TriggerServerEvent('gl-ambulance:getItemForEMS','medbag')
    else
        TriggerServerEvent('gl-ambulance:getItemForEMS','bandage')
    end
    TriggerServerEvent("gl-ambulance:deleteBag", ObjToNet(closestObject))
end)

RegisterNetEvent('gl-ambulance:deleteBag', function(netId)
    if DoesEntityExist(NetToObj(netId)) then
        DeleteObject(NetToObj(netId))
    end   
end)

RegisterNetEvent('gl-ambulance:tryTreatingPlayer',function(wound)
    local player, distance = ESX.Game.GetClosestPlayer()
    if distance ~= -1 and distance <= 3.0 then
        playerID = GetPlayerServerId(player)
        TriggerServerEvent('gl-ambulance:checkPlayerWounds',playerID,wound)
    end
end)

RegisterNetEvent('gl-ambulance:checkPlayerWounds',function(player,wound)
    if curWound == wound then
        TriggerServerEvent('gl-ambulance:treatPlayerWounds',player,curWound)
    end
end)

RegisterNetEvent('gl-ambulance:useStretcher',function()
local hash = GetHashKey('prop_ld_binbag_01')
    local ped = PlayerPedId()
    local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(ped,0.0,3.0,0.5))
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    stretcher = CreateObjectNoOffset(hash, x, y, z, true, false)
    SetModelAsNoLongerNeeded(hash)
    LoadAnimDict("anim@heists@box_carry@")

    AttachEntityToEntity(stretcher, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  28422), 0.0, -0.9, -0.52, 195.0, 180.0, 180.0, 0.0, false, false, true, false, 2, true)

    while IsEntityAttachedToEntity(stretcher, PlayerPedId()) do
        Citizen.Wait(5)

        if not IsEntityPlayingAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 3) then
            TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 8.0, 8.0, -1, 50, 0, false, false, false)
        end

        if IsPedDeadOrDying(PlayerPedId()) then
            DetachEntity(stretcher, true, true)
        end

        if IsControlJustPressed(0, 73) then
            DetachEntity(stretcher, true, true)
            FreezeEntityPosition(stretcher,true)
        end
    end
end)

RegisterCommand('delstretcher',function()
    local pedCoords = GetEntityCoords(PlayerPedId())
    local closestObject = GetClosestObjectOfType(pedCoords, 5.0, GetHashKey("prop_ld_binbag_01"), false)
    if DoesEntityExist(closestObject) then
        TriggerServerEvent('gl-ambulance:delStretcher',ObjToNet(closestObject))
    end
end)

RegisterNetEvent('gl-ambulance:delStretcher',function(netId)
    if DoesEntityExist(NetToObj(netId)) then
        DeleteObject(NetToObj(netId))
    end  
end)

RegisterCommand('takeout',function()
    local hash = GetHashKey('prop_ld_binbag_01')
    local ped = PlayerPedId()
    local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(ped,0.0,3.0,0.5))
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    stretcher = CreateObjectNoOffset(hash, x, y, z, true, false)
    SetModelAsNoLongerNeeded(hash)
    LoadAnimDict("anim@heists@box_carry@")

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

        local player, distance = ESX.Game.GetClosestPlayer()
        if distance ~= -1 and distance <= 5.0 then
            TriggerServerEvent('gl-ambulance:getOutVehicle', GetPlayerServerId(player))
        end


    AttachEntityToEntity(stretcher, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  28422), 0.0, -0.9, -0.52, 195.0, 180.0, 180.0, 0.0, false, false, true, false, 2, true)

    while IsEntityAttachedToEntity(stretcher, PlayerPedId()) do
        Citizen.Wait(5)

        if not IsEntityPlayingAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 3) then
            TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 8.0, 8.0, -1, 50, 0, false, false, false)
        end

        if IsPedDeadOrDying(PlayerPedId()) then
            DetachEntity(stretcher, true, true)
        end

        if IsControlJustPressed(0, 73) then
            DetachEntity(stretcher, true, true)
            FreezeEntityPosition(stretcher,true)
        end
    end

end)

RegisterNetEvent('gl-ambulance:getOutVehicle',function()

    local ped = PlayerPedId()
    if not IsPedSittingInAnyVehicle(ped) then
        return
    end
    local vehicle = GetVehiclePedIsIn(ped, false)
    TaskLeaveVehicle(ped, vehicle, 16)
    Wait(500)
    local pedCoords = GetEntityCoords(PlayerPedId())
    local closestObject = GetClosestObjectOfType(pedCoords, 5.0, GetHashKey("prop_ld_binbag_01"), false)
    local objCoords = GetEntityCoords(closestObject)
    LoadAnimDict("anim@gangops@morgue@table@")
    TaskPlayAnim(PlayerPedId(), "anim@gangops@morgue@table@", "body_search", 8.0, 8.0, -1, 33, 0, 0, 0, 0)
    AttachEntityToEntity(PlayerPedId(), closestObject, 0, 0, 0.0, 1.0, 195.0, 0.0, 180.0, 0.0, false, false, false, false, 2, true)
end)


RegisterCommand('push',function()
    local pedCoords = GetEntityCoords(PlayerPedId())
    local closestObject = GetClosestObjectOfType(pedCoords, 1.0, GetHashKey("prop_ld_binbag_01"), false)
    local objCoords = GetEntityCoords(closestObject)
     LoadAnimDict("anim@heists@box_carry@")

    AttachEntityToEntity(closestObject, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  28422), 0.0, -0.9, -0.52, 195.0, 180.0, 180.0, 0.0, false, false, true, false, 2, true)

    while IsEntityAttachedToEntity(closestObject, PlayerPedId()) do
        Citizen.Wait(5)

        if not IsEntityPlayingAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 3) then
            TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 8.0, 8.0, -1, 50, 0, false, false, false)
        end

        if IsPedDeadOrDying(PlayerPedId()) then
            DetachEntity(closestObject, true, true)
        end

        if IsControlJustPressed(0, 73) then
            DetachEntity(closestObject, true, true)
            FreezeEntityPosition(closestObject,true)
        end
    end


end)

RegisterCommand('emsveh',function()
    local ped = PlayerPedId()
    local pCoords = GetEntityCoords(ped)
    local dst = #(pCoords - Config.HospitalCoords)
    if dst < 100 or IsEntityInWater(ped) then
    local vehicleCat = {}
        for k, v in pairs(Config.EMSVehicles) do
            table.insert(vehicleCat, 
            {
                id = k,
                header = 'Pull Out Vehicle',
                txt = 'Vehicle: ' .. v.label,
                params = {
                    event = 'gl-ambulance:spawnVehicle',
                    args = {
                        v.spawnName,
                        v.spawnLoc
                    }                
                }
            })
        end
         exports['gl-ambulance']:CreateMenu(vehicleCat)
    end
end)

RegisterNetEvent('gl-ambulance:spawnVehicle',function(spawnName,spawnLoc)
    local coords = spawnLoc

    local ModelHash = spawnName -- Use Compile-time hashes to get the hash of this model
    if not IsModelInCdimage(ModelHash) then return end
    RequestModel(ModelHash) -- Request the model
    while not HasModelLoaded(ModelHash) do -- Waits for the model to load with a check so it does not get stuck in an infinite loop
      Citizen.Wait(10)
    end
    if coords == 'atPlayer' then
        x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(),0.0,4.0,0.5))
        local emsCar = CreateVehicle(ModelHash, x,y,z,0, true, false) -- Spawns a networked vehicle on your current coords
    else
        local emsCar = CreateVehicle(ModelHash, coords.x,coords.y,coords.z,coords.w, true, false) -- Spawns a networked vehicle on your current coords
    end
    SetModelAsNoLongerNeeded(ModelHash) -- removes model from game memory as we no longer need it

end)


RegisterCommand('putonstretcher',function()
    local player, distance = ESX.Game.GetClosestPlayer()
    if distance ~= -1 and distance <= 3.0 then
        TriggerServerEvent('gl-ambulance:putOnStretcher', GetPlayerServerId(player))
    end
end)

RegisterCommand('getup',function()
    local pedCoords = GetEntityCoords(PlayerPedId())
    local closestObject = GetClosestObjectOfType(pedCoords, 1.0, GetHashKey("prop_ld_binbag_01"), false)
    local objCoords = GetEntityCoords(closestObject)
    local dst = #(pedCoords - objCoords)
    if dst < 1 then
        DetachEntity(PlayerPedId())
    end
end)

RegisterNetEvent('gl-ambulance:putOnStretcher',function()
    if isDead then
        local pedCoords = GetEntityCoords(PlayerPedId())
        local closestObject = GetClosestObjectOfType(pedCoords, 1.0, GetHashKey("prop_ld_binbag_01"), false)
        local objCoords = GetEntityCoords(closestObject)
        LoadAnimDict("anim@gangops@morgue@table@")
        TaskPlayAnim(PlayerPedId(), "anim@gangops@morgue@table@", "body_search", 8.0, 8.0, -1, 33, 0, 0, 0, 0)
        AttachEntityToEntity(PlayerPedId(), closestObject, 0, 0, 0.0, 1.0, 195.0, 0.0, 180.0, 0.0, false, false, false, false, 2, true)
    end
end)


RegisterCommand('laydown',function()
    local pedCoords = GetEntityCoords(PlayerPedId())
    local closestObject = GetClosestObjectOfType(pedCoords, 1.0, GetHashKey("prop_ld_binbag_01"), false)
    local objCoords = GetEntityCoords(closestObject)
    LoadAnimDict("anim@gangops@morgue@table@")
    TaskPlayAnim(PlayerPedId(), "anim@gangops@morgue@table@", "body_search", 8.0, 8.0, -1, 33, 0, 0, 0, 0)
    AttachEntityToEntity(PlayerPedId(), closestObject, 0, 0, 0.0, 1.0, 195.0, 0.0, 180.0, 0.0, false, false, false, false, 2, true)
    --Wait(15000)
    --DetachEntity(PlayerPedId())

end)


RegisterNetEvent('gl-ambulance:useMedBag',function()
    local hash = GetHashKey('xm_prop_x17_bag_med_01a')
    local ped = PlayerPedId()
    local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(ped,0.0,3.0,0.5))
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    medBag = CreateObjectNoOffset(hash, x, y, z, true, false)
    SetModelAsNoLongerNeeded(hash)
    AttachEntityToEntity(medBag, ped, GetPedBoneIndex(ped, 57005), 0.42, 0, -0.05, 0.10, 270.0, 60.0, true, true, false, true, 1, true)
    iHasDaBag()
end)

RegisterNetEvent('gl-ambulance:treatAnimations',function(wound)

    -- Change Animations later
    if wound == 'bullet' then
        LoadAnimDict("mini@repair") 
        TaskPlayAnim(PlayerPedId(), "mini@repair", "fixing_a_ped", 8.0, 1.0, -1, 17, 0, 0, 0, 0)
        Wait(3000)
        ClearPedTasks(PlayerPedId())
    elseif wound == 'stitch' then
        LoadAnimDict("mini@repair") 
        TaskPlayAnim(PlayerPedId(), "mini@repair", "fixing_a_ped", 8.0, 1.0, -1, 17, 0, 0, 0, 0)
        Wait(3000)
        ClearPedTasks(PlayerPedId())
    elseif wound == 'burn' then
        LoadAnimDict("mini@repair") 
        TaskPlayAnim(PlayerPedId(), "mini@repair", "fixing_a_ped", 8.0, 1.0, -1, 17, 0, 0, 0, 0)
        Wait(3000)
        ClearPedTasks(PlayerPedId())
    end
end)

RegisterNetEvent('gl-ambulance:treatTargetWound',function(wound)
    -- Find better way to do this later
    if wound == 'bullet' then
        TriggerEvent('gl-ambulance:treatBulletWound')
    elseif wound == 'stitch' then
        TriggerEvent('gl-ambulance:treatDeepWound')
    elseif wound == 'burn' then
        TriggerEvent('gl-ambulance:treatBurnWound')
    end
end)


RegisterNetEvent('gl-ambulance:treatBulletWound',function()
    if isShot then
        -- Add Animation Stuff
        isShot = false
        curWound = nil
    end
end)

RegisterNetEvent('gl-ambulance:treatDeepWound',function()
    if isMeleed then
        -- Add Animation Stuff
        isMeleed = false
        curWound = nil
    end
end)

RegisterNetEvent('gl-ambulance:treatBurnWound',function()
    if isBurned then
        -- Add Animation Stuff
        isBurned = false
        curWound = nil
    end
end)


RegisterNetEvent('gl-ambulance:tryRevivePlayer',function()
    local player, distance = ESX.Game.GetClosestPlayer()
    if distance ~= -1 and distance <= 3.0 then
        if ESX.PlayerData.job.name == 'ambulance' or ESX.PlayerData.job.name == 'police' then
            playerID = GetPlayerServerId(player)
            LoadAnimDict('anim@gangops@facility@servers@bodysearch@')
            TaskPlayAnim(PlayerPedId(), "anim@gangops@facility@servers@bodysearch@" ,"player_search" ,8.0, -8.0, -1, 48, 0, false, false, false )
            Wait(5000)
            TriggerServerEvent('gl-ambulance:revivePlayer',playerID)
        else
            local doMath = math.random(1,100)
            if doMath <= 20 then
                playerID = GetPlayerServerId(player)
                LoadAnimDict('anim@gangops@facility@servers@bodysearch@')
                TaskPlayAnim(PlayerPedId(), "anim@gangops@facility@servers@bodysearch@" ,"player_search" ,8.0, -8.0, -1, 48, 0, false, false, false )
                Wait(5000)
                TriggerServerEvent('gl-ambulance:revivePlayer',playerID)
            else
                TriggerEvent("swt_notifications:caption",'Error','You failed to work the defibrillator and broke it.','top',15000,'red-10','grey-1',true)
        
            end
            TriggerServerEvent('gl-ambulance:removeDefib')
        end

    end

end)

RegisterNetEvent('gl-ambulance:revivePlayer',function()
    if isDead then
        local ped = PlayerPedId()
        local maxHealth = GetPedMaxHealth(ped)
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)
        NetworkResurrectLocalPlayer(coords, heading, true, false)
        ClearPedBloodDamage(ped)
        SetEntityInvincible(ped,false)
        Wait(100)
        if isShot then
            SetEntityHealth(ped,150) -- 50 Health
        elseif isMeleed then
            SetEntityHealth(ped,160) -- 60 Health
        elseif isBurned then
            SetEntityHealth(ped,180) -- 80 Health
        else
            SetEntityHealth(ped,200) -- Full health
        end
        TriggerEvent('esx:onPlayerSpawn')
    
        isDead = false
        TriggerEvent('mythic_hospital:client:RemoveBleed')
        TriggerEvent('mythic_hospital:client:ResetLimbs')
        ClearPedTasks(ped)
        FreezeEntityPosition(ped,false)
        DetachEntity(stretcher, true, true)
    end
    
end)

RegisterNetEvent('gl-ambulance:healPlayer',function()
    local ped = PlayerPedId()
    ClearPedBloodDamage(ped)
    SetEntityHealth(ped,200) -- Full health
    TriggerEvent('mythic_hospital:client:RemoveBleed')
    TriggerEvent('mythic_hospital:client:ResetLimbs')

end)

RegisterNetEvent('gl-ambulance:tryTreatWound',function(wound)

    local player, distance = ESX.Game.GetClosestPlayer()
    if distance ~= -1 and distance <= 3.0 then

        TriggerServerEvent('gl-ambulance:treatPlayerWounds',GetPlayerServerId(PlayerId()),GetPlayerServerId(player))
        
    else

    end
end)

RegisterNetEvent('gl-ambulance:useSedative',function()
    local player, distance = ESX.Game.GetClosestPlayer()
    if distance ~= -1 and distance <= 3.0 then

        TriggerServerEvent('gl-ambulance:goNightNight',GetPlayerServerId(player))
        
    else


    end

end)

RegisterNetEvent('gl-ambulance:goNightNight',function()
    local ped = PlayerPedId()
    LoadAnimDict('mini@cpr@char_b@cpr_def')
    TaskPlayAnim(ped, 'mini@cpr@char_b@cpr_def', 'cpr_pumpchest_idle', 8.0, 8.0, -1, 33, 0, 0, 0, 0)
    FreezeEntityPosition(ped,true)
    Wait(20000)
    FreezeEntityPosition(ped,false)
end)

RegisterCommand('putiv',function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    if IsAnyVehicleNearPoint(coords, 5.0) then
        local coordA = GetEntityCoords(ped, 1)
        local coordB = GetOffsetFromEntityInWorldCoords(ped, 0.0, 5.0, 0.0)
        vehicle = getVehicleInDirection(coordA, coordB)
        local player, distance = ESX.Game.GetClosestPlayer()
        if distance ~= -1 and distance <= 3.0 then
            local a = NetworkGetNetworkIdFromEntity(vehicle)
            TriggerServerEvent('gl-ambulance:putInVehicle', GetPlayerServerId(player),NetworkGetNetworkIdFromEntity(vehicle))
            DeleteEntity(stretcher)
        end
    end
end)

RegisterNetEvent('gl-ambulance:tryPutInVehicle',function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    if IsAnyVehicleNearPoint(coords, 5.0) then
        local coordA = GetEntityCoords(ped, 1)
        local coordB = GetOffsetFromEntityInWorldCoords(ped, 0.0, 5.0, 0.0)
        vehicle = getVehicleInDirection(coordA, coordB)
        local player, distance = ESX.Game.GetClosestPlayer()
        if distance ~= -1 and distance <= 3.0 then
            local a = NetworkGetNetworkIdFromEntity(vehicle)
            TriggerServerEvent('gl-ambulance:putInVehicle', GetPlayerServerId(player),NetworkGetNetworkIdFromEntity(vehicle))
            DeleteEntity(stretcher)
        end
    end
end)

RegisterNetEvent('gl-ambulance:putInVehicle',function(veh)
    local vehicleA = NetworkGetEntityFromNetworkId(veh)
    local ped = PlayerPedId()
    DetachEntity(ped)
        local coords = GetEntityCoords(ped)
            if IsAnyVehicleNearPoint(coords, 5.0) then
            if DoesEntityExist(vehicleA) then
                if IsVehicleSeatFree(vehicleA, 1) then
                    TaskWarpPedIntoVehicle(ped, vehicleA, 1)
                else
                    TaskWarpPedIntoVehicle(ped, vehicleA, 2)
                end
            end
        end
end)
SetEntityVisible(PlayerPedId(), true, true)
RegisterNetEvent('gl-ambulance:bodyBag',function()

    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local hash = GetHashKey('xm_prop_body_bag')
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    SetEntityVisible(ped, false, false)
    bodyBag = CreateObject(hash, playerCoords, true, true, true)
    SetModelAsNoLongerNeeded(hash)
    AttachEntityToEntity(bodyBag, ped, 0, -0.2, 0.75, -0.2, 0.0, 0.0, 0.0, false, false, false, false, 20, false)
    LoadAnimDict('mini@cpr@char_b@cpr_def')
    TaskPlayAnim(ped, 'mini@cpr@char_b@cpr_def', 'cpr_pumpchest_idle', 8.0, 8.0, -1, 33, 0, 0, 0, 0)
    disableControls()
end)

RegisterCommand('bodybag',function()
    local player, distance = ESX.Game.GetClosestPlayer()
    if distance ~= -1 and distance <= 3.0 then
        TriggerServerEvent('gl-ambulance:bodyBag',GetPlayerServerId(player))
    end
end)

local wheelchair
RegisterNetEvent('gl-ambulance:useWheelChair',function()
    if DoesEntityExist(wheelchair) then
        DeleteEntity(wheelchair)
    else
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        local hash = 'wheelchair'
        RequestModel(hash)
        while not HasModelLoaded(hash) do Citizen.Wait(0) end
        wheelchair = CreateVehicle(hash,pedCoords,0,true,false)
        Wait(100)
        TaskWarpPedIntoVehicle(ped, wheelchair,-1)
    end
end)

-- Pulse
RegisterCommand('checkpulse',function()
    local player, distance = ESX.Game.GetClosestPlayer()
    if distance ~= -1 and distance <= 3.0 then
        playerID = GetPlayerServerId(player)
        TriggerServerEvent('gl-ambulance:checkPulse',playerID,wound)
    end

end)

RegisterNetEvent('gl-ambulance:getPulse',function()
    local player, distance = ESX.Game.GetClosestPlayer()
    if distance ~= -1 and distance <= 3.0 then
        playerID = GetPlayerServerId(player)
        TriggerServerEvent('gl-ambulance:checkPulse',playerID)
    end
end)

RegisterNetEvent('gl-ambulance:sendPulseBack',function(target)
    local sendToWhom = target
    local minPulse = 60
    local maxPulse = 80
    local status = 'They seem fine'
    if isShot then
        minPulse = 120
        maxPulse = 200
        status = 'Bleeding from apparent gunshot wounds'
    end
    if isMeleed then
        minPulse = 90
        maxPulse = 115
        status = 'Has deep lacerations/bruising'
    end
    
    if isBurned then
        minPulse = 20
        maxPulse = 50
        status = 'Burns all over their body'
    end
    local pulse = math.random(minPulse,maxPulse)
    TriggerServerEvent('gl-ambulance:reportPulseBack',sendToWhom,pulse, status)
end)


RegisterNetEvent('gl-ambulance:receive911',function(message,coords)
    if ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'ambulance' then
        TriggerEvent("swt_notifications:caption",'911 Call',message,'top',15000,'blue-10','grey-1',true)
        handleDaBlips(coords)
    end
end)

CreateThread(function()
    if Config.UseBeds then
        local pillboxBeds = {
            `v_med_bed1`,
        }
    
        exports['qtarget']:AddTargetModel(pillboxBeds, {
            options = {
                {
                    event = "gl-ambulance:useTheBed",
                    icon = "fas fa-bed",
                    label = "Lay in Bed",
                },
    
            },
            job = {"all"},
            distance = 2.5
        })
    end
        
end)


-- Spawn NPC When you get close, delete when you leave

hospitalZone = CircleZone:Create(Config.NancyPos, 50, {
    name = "Hosp_zone",
    debugPoly = false,
})
hospitalZone:onPlayerInOut(function(isPointInside, point)
    if isPointInside then 
        TriggerEvent('gl-ambulance:spawnPed',Config.NancyPos,66.08)
    else 
        DeleteEntity(npc)
    end
end)

grandmaZone = CircleZone:Create(Config.GrandmaCoords, 50, {
    name = "grandma_Zone",
    debugPoly = false,
})
grandmaZone:onPlayerInOut(function(isPointInside, point)
    if isPointInside then 
        TriggerEvent('gl-ambulance:spawnGrandmaPed',Config.GrandmaCoords,134.07)
    else 
        DeleteEntity(grandma)
    end
end)

-- Spawn NPC
RegisterNetEvent('gl-ambulance:spawnPed')
AddEventHandler('gl-ambulance:spawnPed',function(coords,heading)
    local hash = GetHashKey('s_f_y_scrubs_01')
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        Wait(10)
    end
    while not HasModelLoaded(hash) do 
        Wait(10)
    end

    npc = CreatePed(5, hash, coords, heading, false, false)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetModelAsNoLongerNeeded(hash)
    exports['qtarget']:AddTargetEntity(npc, {
                options = {
                    {
                    event = "gl-ambulance:checkInNancy",
                    icon = "far fa-comment",
                    label = "Check In",
                    },                                                                    
                },
                    job = {"all"},
                    distance = 2.5
                })  
end)

RegisterNetEvent('gl-ambulance:spawnGrandmaPed')
AddEventHandler('gl-ambulance:spawnGrandmaPed',function(coords,heading)
    local hash = GetHashKey('ig_mrs_thornhill')
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        Wait(10)
    end
    while not HasModelLoaded(hash) do 
        Wait(10)
    end

    grandma = CreatePed(5, hash, coords, heading, false, false)
    FreezeEntityPosition(grandma, true)
    SetEntityInvincible(grandma, true)
    SetBlockingOfNonTemporaryEvents(grandma, true)
    SetModelAsNoLongerNeeded(hash)
    exports['qtarget']:AddTargetEntity(grandma, {
                options = {
                    {
                    event = "gl-ambulance:useGrandmas",
                    icon = "far fa-comment",
                    label = "Revive",
                    },                                                                    
                },
                    job = {"all"},
                    distance = 2.5
                })  
end)



RegisterNetEvent('gl-ambulance:checkInNancy',function()
    local bed = Config.BedLocs[math.random(#Config.BedLocs)]
    TriggerEvent("swt_notifications:caption",'Being Treated','You have been moved to a bed for Treatment.','top',20000,'green-6','grey-1',true)
    SetEntityCoords(PlayerPedId(), bed.x,bed.y,bed.z+1)
    LoadAnimDict('anim@gangops@morgue@table@')
    TaskPlayAnim(PlayerPedId(), 'anim@gangops@morgue@table@' , 'body_search' ,8.0, -8.0, -1, 1, 0, false, false, false )
    SetEntityHeading(PlayerPedId(), bed.w - 180.0)
    ---[[ -- Set these to whatever wound system you use
    Wait(20000)
    TriggerEvent('mythic_hospital:client:RemoveBleed')
    TriggerEvent('mythic_hospital:client:ResetLimbs')
    TriggerEvent('gl-ambulance:revivePlayer')
    SetEntityHealth(PlayerPedId(),200)
    ClearPedTasks(PlayerPedId())
    TriggerEvent("swt_notifications:caption",'Treated','You are good now, stop getting in trouble.','top',6000,'green-6','grey-1',true)

end)

RegisterNetEvent('gl-ambulance:useGrandmas',function()
    TriggerEvent("swt_notifications:caption",'Grandma',"I'll take care of you sonny",'top',5000,'green-6','grey-1',true)
    Wait(5000)
    TriggerEvent('gl-ambulance:revivePlayer')
end)

RegisterNetEvent('gl-ambulance:useTheBed',function()
    local pedCoords = GetEntityCoords(PlayerPedId())
    local closestObject = GetClosestObjectOfType(pedCoords, 1.0, GetHashKey("v_med_bed1"), false)
    local objCoords = GetEntityCoords(closestObject)
    local objHeading = GetEntityHeading(closestObject)
    TriggerEvent("swt_notifications:caption",'Being Treated','You have been moved to a bed for Treatment.','top',20000,'green-6','grey-1',true)
    SetEntityCoords(PlayerPedId(), objCoords.x,objCoords.y,objCoords.z+1)
    LoadAnimDict('anim@gangops@morgue@table@')
    TaskPlayAnim(PlayerPedId(), 'anim@gangops@morgue@table@' , 'body_search' ,8.0, -8.0, -1, 1, 0, false, false, false )
    SetEntityHeading(PlayerPedId(), objHeading - 180.0)
    ---[[ -- Set these to whatever wound system you use
    Wait(20000)
    TriggerEvent('mythic_hospital:client:RemoveBleed')
    TriggerEvent('mythic_hospital:client:ResetLimbs')
    SetEntityHealth(PlayerPedId(),200)
    ClearPedTasks(PlayerPedId())
    TriggerEvent("swt_notifications:caption",'Treated','You are good now, stop getting in trouble.','top',6000,'green-6','grey-1',true)
end)

RegisterNetEvent('gl-ambulance:adminHeal',function()
    local ped = PlayerPedId()
    local maxHealth = GetPedMaxHealth(ped)
    SetEntityHealth(ped,maxHealth)
    TriggerEvent('mythic_hospital:client:RemoveBleed')
    TriggerEvent('mythic_hospital:client:ResetLimbs')
end)

-- Handlers Below
AddEventHandler('esx:onPlayerDeath', function(data)
    isShot = false
    isMeleed = false
    isBurned = false
    if not isDead then
        ESX.TriggerServerCallback("gl-ambulance:getEMSCount", function(cb)
            emsCount = cb
        end)
        respawnCountdownText()
        isDead = true
        TriggerEvent('mythic_hospital:client:RemoveBleed')
        TriggerEvent('mythic_hospital:client:ResetLimbs')
        for k, v in pairs (Config.Guns) do
            if data.deathCause == v then
                isShot = true
                curWound = 'bullet'
            end
        end
        for k, v in pairs (Config.Melee) do 
            if data.deathCause == v then
                isMeleed = true
                curWound = 'stitch'
            end
        end

        for k, v in pairs(Config.Explosions) do
            if data.deathCause == v then
                isMeleed = true
                curWound = 'burn'
            end
        end

        disableControls()
        playDead()
    end
end)

AddEventHandler('esx:onPlayerSpawn', function()
    local ped = PlayerPedId()
    if isDead then
        LoadAnimDict('get_up@directional@movement@from_knees@action')
        TaskPlayAnim(ped, 'get_up@directional@movement@from_knees@action', 'getup_r_0', 8.0, -8.0, -1, 0, 0, 0, 0, 0)
        isDead = false
    end
end)


-- // End Handlers //

-- Commands


RegisterCommand('911', function(source, args, rawCommand)
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local pedID = GetPlayerServerId(PlayerId())
    args = table.concat(args, ' ')
    TriggerServerEvent('gl-ambulance:send911',args,pedID, pedCoords)
    TriggerEvent("swt_notifications:caption",'911 Call','Your message has been sent.','top',15000,'blue-10','grey-1',true)
end)

RegisterCommand('911r', function(source, args, rawCommand)
    args = table.concat(args, ' ')
    TriggerServerEvent('gl-ambulance:911r',args)
    TriggerEvent("swt_notifications:caption",'911 Response','Your message has been sent to the latest caller.','top',15000,'blue-10','grey-1',true)
end)





-- Functions Below

function handleDaBlips(coords)
    local time = Config.BlipTimer * 20000
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, 126)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 26)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("911 Alert")
    EndTextCommandSetBlipName(blip) 
    CreateThread(function()  
        while time > 0 do
            Wait(1000)
            time = time - 1000
            if time <= 0 then
                RemoveBlip(blip)
                break
            end
        end
    end)
end


function playDead()
    local ped = PlayerPedId()
    local maxHealth = GetPedMaxHealth(ped)
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    NetworkResurrectLocalPlayer(coords, heading, true, false)
    Wait(100)
    SetEntityHealth(ped,maxHealth)
    SetEntityInvincible(ped,true)
    TriggerEvent('mythic_hospital:client:RemoveBleed')
    TriggerEvent('mythic_hospital:client:ResetLimbs')
    LoadAnimDict('mini@cpr@char_b@cpr_def')
    LoadAnimDict("veh@bus@passenger@common@idle_duck")
    TaskPlayAnim(ped, 'mini@cpr@char_b@cpr_def', 'cpr_pumpchest_idle', 8.0, 8.0, -1, 33, 0, 0, 0, 0)
    CreateThread(function()
        while isDead do
            if IsPedInAnyVehicle(ped,false) then
                if not IsEntityPlayingAnim(ped, "veh@bus@passenger@common@idle_duck", "sit", 3) then
                    ClearPedTasks(ped)
                    TaskPlayAnim(ped, "veh@bus@passenger@common@idle_duck", "sit", 8.0, -8, -1, 2, 0, 0, 0, 0)
                end
            else
                if not IsEntityPlayingAnim(ped, 'mini@cpr@char_b@cpr_def', 'cpr_pumpchest_idle', 3) then
                    ClearPedTasks(ped)
                    TaskPlayAnim(ped, 'mini@cpr@char_b@cpr_def', 'cpr_pumpchest_idle', 8.0, 8.0, -1, 33, 0, 0, 0, 0)
                end
                Wait(30000)
                if isDead then
                    ClearPedTasks(ped)
                    TaskPlayAnim(ped, 'mini@cpr@char_b@cpr_def', 'cpr_pumpchest_idle', 8.0, 8.0, -1, 33, 0, 0, 0, 0)
                end
            end
            Wait(1000)
        end
    end)
end

-- Fix when sober you dumb fuck
function disableControls()
    CreateThread(function()
        while isDead do
            Wait(1)
            DisableAllControlActions(0)
            EnableControlAction(0, 1)
            EnableControlAction(0, 2)
            EnableControlAction(0, 26, true)
            EnableControlAction(0, 47, true)
            EnableControlAction(0, 74, true)
            EnableControlAction(0, 245, true)
            EnableControlAction(0, 38, true)
            EnableControlAction(0, 249, true)
            EnableControlAction(0, 0, true)
            EnableControlAction(0, 20, true)
            EnableControlAction(0, 178, true)
            EnableControlAction(0, 167, true)
        end
    end)
end

function LoadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(10)
    end
end

function iHasDaBag()
    local hasBag = true
    CreateThread(function()
        while hasBag do
            Wait(0)
            -- If they press E drop the fucking bag
            if IsControlJustReleased(0,38) then
                hasBag = false
                dropDaBag()
                Citizen.Wait(1000)
            end
        end
    end)
end

function dropDaBag()
    DetachEntity(medBag)
    PlaceObjectOnGroundProperly(medBag)
end

function getVehicleInDirection(coordFrom, coordTo)
    local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, PlayerPedId(), 0)
    local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
    return vehicle
end



function respawnCountdownText()
    local wasHolding = 0
    CreateThread(function()
        while isDead do
            Wait(0)
            local text = _U('respawn',emsCount)
            SetTextFont(0)
            SetTextProportional(1)
            SetTextScale(0.0, 0.3)
            SetTextColour(255, 255, 255, 255)
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextEdge(1, 0, 0, 0, 255)
            SetTextCentre(true)
            SetTextDropShadow()
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentString(text)
            EndTextCommandDisplayText(0.5, 0.8)
            if IsControlPressed(0, 38) and wasHolding > 120 then
                if emsCount > 0 and Config.RemoveItemsOnDeath then
                    -- Lose Items
                    TriggerServerEvent('gl-ambulance:removeDeathItems')
                end
                    SetEntityCoords(PlayerPedId(),Config.RespawnCoords)
                    TriggerEvent('gl-ambulance:revivePlayer')
                break
            end

            if IsControlPressed(0, 38) then
                wasHolding = wasHolding + 1
            end
        end
    end)
end


function amIDead()
    return isDead
end

exports('amIDead',amIDead)
--EntityZone
--[[
exports['qtarget']:AddEntityZone('NAMEHERE', PEDHERE, {
            name="NAMEHERE",
            debugPoly=true,
            useZ = true
              }, {
              options = {
                {
                event = "EVENTHERE",
                icon = "ICONHERE",
                label = 'LABELHERE',
                },
              },
                job = {"all"},
                distance = 1.5
              })
]]

--Boxzone
--[[
    exports['qtarget']:AddBoxZone("ZONENAME", vector3(COORDSHERE), 1, 1, {
        name="ZONENAME",
        heading=300.95,
        debugPoly=true,
        minZ=Z,
        maxZ=Z
    }, {
        options = {
            {
                event = "EVENTHERE",
                icon = "ICONHERE",
                label = 'LABELHERE',
            },
        },
            job = {"all"},
            distance = 1.5 
    })
]]

--TargetModel
--[[
    exports['qtarget']:AddTargetModel(TABLEHERE, {
        options = {
            {
                event = "EVENTHERE",
                icon = "ICONHERE",
                label = 'LABELHERE',
            },

        },
        job = {"all"},
        distance = 1.5
    })
]]
