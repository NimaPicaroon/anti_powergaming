--code create nima_picaroon
local picaroonVehicle = nil
local picaroonIsDriver = false
local picaroonTractionLossMult = nil
local picaroonIsModed = false
local picaroonClass = nil
local picaroonIsBlacklisted = false
local picaroonClassMod = {
    [0] = 2.51, -- Compacts 
    [1] = 2.51, -- Sedans
    [2] = 1.01, -- SUVs
    [3] = 2.51, -- Coupes
    [4] = 2.501, -- Muscle
    [5] = 2.51, -- Sports Classics
    [6] = 2.51, -- Sports
    [7] = 2.51, -- Super  
    [8] = 1.51, -- Motorcycles  
    [9] = 0, -- Off-road
    [10] = 0, -- Industrial
    [11] = 0, -- Utility
    [12] = 2.21, -- Vans  
    [13] = 0, -- Cycles  
    [14] = 0, -- Boats  
    [15] = 0, -- Helicopters  
    [16] = 0, -- Planes  
    [17] = 0, -- Service  
    [18] = 2.21, -- Emergency  
    [19] = 0, -- Military  
    [20] = 2.21, -- Commercial  
    [21] = 0 -- Trains  
}
local picaroonBlackListed = {
    788045382, -- "sanchez"
    -1453280962, -- "sanchez2"
    1753414259, -- "enduro"
    2035069708, -- "esskey"
    86520421, -- "bf400"
    -- Here you can add some vehicles hash
}
Citizen.CreateThread(function()
    while true do 
        local ped = GetPlayerPed(-1)      
        if IsPedInAnyVehicle(ped, false) then
            if picaroonVehicle == nil then
                picaroonVehicle = GetVehiclePedIsUsing(ped)
                if GetPedInVehicleSeat(picaroonVehicle, -1) == ped then
                    picaroonIsDriver = true
                    if DecorExistOn(picaroonVehicle, 'picaroonTractionLossMult') then
                        picaroonTractionLossMult = DecorGetFloat(picaroonVehicle, 'picaroonTractionLossMult')
                    else
                        picaroonTractionLossMult = GetVehicleHandlingFloat(picaroonVehicle, 'CHandlingData', 'fTractionLossMult')
                        DecorRegister('picaroonTractionLossMult', 1)
                        DecorSetFloat(picaroonVehicle, 'picaroonTractionLossMult', picaroonTractionLossMult)
                    end
                    picaroonClass = GetVehicleClass(picaroonVehicle)
                    picaroonIsBlacklisted = isModelBlacklisted(GetEntityModel(picaroonVehicle))
                end
            end
        else
            if picaroonVehicle ~= nil then
                if DoesEntityExist(picaroonVehicle) then
                    setTractionLost(picaroonTractionLossMult)
                end
                Citizen.Wait(1000)
                resetVariables()
            end
        end
        Citizen.Wait(2000)
    end
end)
Citizen.CreateThread(function()
    while true do 
        if not picaroonIsBlacklisted then     
            if picaroonVehicle and picaroonIsDriver then
                local speed = GetEntitySpeed(picaroonVehicle) * 3.6
                if not pointingRoad(picaroonVehicle) then
                    if groundAsphalt() or speed <= 35.0 then
                        if picaroonIsModed then
                            picaroonIsModed = false
                            setTractionLost(picaroonTractionLossMult)
                        end
                    else
                        if not picaroonIsModed and speed > 35.0 then
                            picaroonIsModed = true
                            setTractionLost(picaroonTractionLossMult + picaroonClassMod[picaroonClass])
                        end
                    end
                else
                    if picaroonIsModed then
                        picaroonIsModed = false
                        setTractionLost(picaroonTractionLossMult)
                    end
                end
            end
        end
        Citizen.Wait(500)
    end
end)
function setTractionLost(value)
    if not picaroonIsBlacklisted and picaroonVehicle and value then
        SetVehicleHandlingFloat(picaroonVehicle, 'CHandlingData', 'fTractionLossMult', value)
    end
end
function isModelBlacklisted(model)
    for i = 1, #picaroonBlackListed do
        if picaroonBlackListed[i] == model then
            return true
        end
    end
    return false
end
function groundAsphalt()
    local ped = PlayerPedId()
    local playerCoord = GetEntityCoords(ped)
    local target = GetOffsetFromEntityInWorldCoords(ped, vector3(0, 2, -3))
    local testRay = StartShapeTestRay(playerCoord, target, 17, ped, 7) 
    local _, hit, hitLocation, surfaceNormal, material, _ = GetShapeTestResultEx(testRay)
    if hit and material == 282940568 then
        return true
    end
    return false
end
function pointingRoad(veh)
    local pos = GetEntityCoords(veh, true)
    if IsPointOnRoad(pos.x, pos.y, pos.z - 1, false) then
        return true
    end 
    local pos2 = GetOffsetFromEntityInWorldCoords(veh, 1.5, 0, 0)
    local pos3 = GetOffsetFromEntityInWorldCoords(veh, -1.5, 0, 0)
    if IsPointOnRoad(pos2.x, pos2.y, pos2.z - 1, false) then
        return true
    end
    if IsPointOnRoad(pos3.x, pos3.y, pos3.z, false) then 
        return true
    end
    return false
end
function resetVariables()
    picaroonVehicle = nil
    picaroonIsDriver = false
    picaroonTractionLossMult = nil
    picaroonIsModed = false
    picaroonClass = nil
    picaroonIsBlacklisted = false
end 

--code create nima_picaroon
