local ESX = exports["es_extended"]:getSharedObject()
local isOnDuty = false
local currentDelivery = nil
local deliveryBlip = nil
local deliveryVehicle = nil
local deliveryProp = nil

-- Create the initial blip
Citizen.CreateThread(function()
    local blip = AddBlipForCoord(Config.StartPoint)
    SetBlipSprite(blip, 267)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 2)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Food Delivery Job")
    EndTextCommandSetBlipName(blip)
end)

-- Start/Stop Duty
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        
        if #(coords - Config.StartPoint) < 2.0 then
            ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to ' .. (isOnDuty and 'end' or 'start') .. ' work')
            
            if IsControlJustReleased(0, 38) then -- E key
                if isOnDuty then
                    EndWork()
                else
                    StartWork()
                end
            end
        end
    end
end)

-- Function to load animation dictionary
function LoadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

-- Function to handle delivery prop
function HandleDeliveryProp()
    -- Delete existing prop if it exists
    if deliveryProp then
        DeleteEntity(deliveryProp)
        deliveryProp = nil
    end
    
    -- Create new prop
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local prop = CreateObject(GetHashKey(Config.DeliveryProp), coords.x, coords.y, coords.z, true, true, true)
    AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 28422), 0.0, -0.03, 0.0, 5.0, 0.0, 0.0, true, true, false, true, 1, true)
    deliveryProp = prop
    
    -- Play animation
    LoadAnimDict(Config.DeliveryAnimDict)
    TaskPlayAnim(playerPed, Config.DeliveryAnimDict, Config.DeliveryAnim, 8.0, -8.0, -1, 51, 0, false, false, false)
end

function StartWork()
    isOnDuty = true
    ESX.ShowNotification('You have started your delivery job!')
    SpawnDeliveryVehicle()
    StartDelivery()
end

function EndWork()
    isOnDuty = false
    if deliveryBlip then
        RemoveBlip(deliveryBlip)
        deliveryBlip = nil
    end
    if deliveryVehicle then
        DeleteVehicle(deliveryVehicle)
        deliveryVehicle = nil
    end
    if deliveryProp then
        DeleteEntity(deliveryProp)
        deliveryProp = nil
    end
    currentDelivery = nil
    ESX.ShowNotification('You have ended your delivery job!')
end

function SpawnDeliveryVehicle()
    ESX.Game.SpawnVehicle(Config.VehicleModel, Config.VehicleSpawnPoint, 90.0, function(vehicle)
        deliveryVehicle = vehicle
        SetVehicleNumberPlateText(vehicle, "FOOD"..math.random(100, 999))
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    end)
end

function StartDelivery()
    if currentDelivery then return end
    
    local randomPoint = Config.DeliveryPoints[math.random(#Config.DeliveryPoints)]
    currentDelivery = randomPoint
    
    if deliveryBlip then RemoveBlip(deliveryBlip) end
    
    deliveryBlip = AddBlipForCoord(currentDelivery)
    SetBlipSprite(deliveryBlip, 1)
    SetBlipRoute(deliveryBlip, true)
    SetBlipRouteColour(deliveryBlip, 2)
    
    -- Add prop and animation when starting delivery
    HandleDeliveryProp()
    
    ESX.ShowNotification('New delivery point has been marked on your GPS!')
end

-- Check delivery completion
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isOnDuty and currentDelivery then
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            
            if #(coords - currentDelivery) < 3.0 then
                ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to deliver the food')
                
                if IsControlJustReleased(0, 38) then -- E key
                    -- Play delivery animation
                    LoadAnimDict('mp_common')
                    TaskPlayAnim(playerPed, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 0, 0, false, false, false)
                    Citizen.Wait(1500)
                    
                    -- Remove prop after delivery
                    if deliveryProp then
                        DeleteEntity(deliveryProp)
                        deliveryProp = nil
                    end
                    
                    -- Clear animation
                    ClearPedTasks(playerPed)
                    
                    TriggerServerEvent('esx_fooddelivery:deliveryComplete')
                    RemoveBlip(deliveryBlip)
                    currentDelivery = nil
                    Citizen.Wait(1000)
                    StartDelivery()
                end
            end
        end
    end
end)

-- Cleanup when resource stops
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    if deliveryProp then DeleteEntity(deliveryProp) end
end)
