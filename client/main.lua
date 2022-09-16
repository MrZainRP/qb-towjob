local QBCore = exports['qb-core']:GetCoreObject()
local PlayerJob = {}
local JobsDone = 0
local NpcOn = false
local CurrentLocation = {}
local CurrentBlip = nil
local LastVehicle = 0
local VehicleSpawned = false
local selectedVeh = nil
local showMarker = false
local CurrentBlip2 = nil
local CurrentTow = nil
local drawDropOff = false
local lvl8 = false
local lvl7 = false
local lvl6 = false
local lvl5 = false
local lvl4 = false
local lvl3 = false
local lvl2 = false
local lvl1 = false
local lvl0 = false

-- Functions

local function getRandomVehicleLocation()
    local randomVehicle = math.random(1, #Config.Locations["towspots"])
    while (randomVehicle == LastVehicle) do
        Wait(10)
        randomVehicle = math.random(1, #Config.Locations["towspots"])
    end
    return randomVehicle
end

local function drawDropOffMarker()
    CreateThread(function()
        while drawDropOff do
            DrawMarker(2, Config.Locations["dropoff"].coords.x, Config.Locations["dropoff"].coords.y, Config.Locations["dropoff"].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
            Wait(0)
        end
    end)
end

local function getVehicleInDirection(coordFrom, coordTo)
	local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, PlayerPedId(), 0)
	local _, _, _, _, vehicle = GetRaycastResult(rayHandle)
	return vehicle
end

local function isTowVehicle(vehicle)
    for k in pairs(Config.Vehicles) do
        if GetEntityModel(vehicle) == joaat(k) then
            return true
        end
    end
    return false
end

-- Old Menu Code (being removed)

local function MenuGarage()
    local towMenu = {
        {
            header = Lang:t("menu.header"),
            isMenuHeader = true
        }
    }
    for k in pairs(Config.Vehicles) do
        towMenu[#towMenu+1] = {
            header = Config.Vehicles[k],
            params = {
                event = "qb-tow:client:TakeOutVehicle",
                args = {
                    vehicle = k
                }
            }
        }
    end

    towMenu[#towMenu+1] = {
        header = Lang:t("menu.close_menu"),
        txt = "",
        params = {
            event = "qb-menu:client:closeMenu"
        }

    }
    exports['qb-menu']:openMenu(towMenu)
end

local function CloseMenuFull()
    exports['qb-menu']:closeMenu()
end

local function CreateZone(type, number)
    local coords
    local heading
    local boxName
    local event
    local label
    local size

    if type == "main" then
        event = "qb-tow:client:PaySlip"
        label = Lang:t("label.payslip")
        coords = vector3(Config.Locations[type].coords.x, Config.Locations[type].coords.y, Config.Locations[type].coords.z)
        heading = Config.Locations[type].coords.h
        boxName = Config.Locations[type].label
        size = 3
    elseif type == "vehicle" then
        event = "qb-tow:client:Vehicle"
        label = Lang:t("label.vehicle")
        coords = vector3(Config.Locations[type].coords.x, Config.Locations[type].coords.y, Config.Locations[type].coords.z)
        heading = Config.Locations[type].coords.h
        boxName = Config.Locations[type].label
        size = 5
    elseif type == "towspots" then
        event = "qb-tow:client:SpawnNPCVehicle"
        label = Lang:t("label.npcz")
        coords = vector3(Config.Locations[type][number].coords.x, Config.Locations[type][number].coords.y, Config.Locations[type][number].coords.z)
        heading = Config.Locations[type][number].coords.h
        boxName = Config.Locations[type][number].name
        size = 50
    end

    if Config.UseTarget and type == "main" then
        exports['qb-target']:AddBoxZone(boxName, coords, size, size, {
            minZ = coords.z - 5.0,
            maxZ = coords.z + 5.0,
            name = boxName,
            heading = heading,
            debugPoly = false,
        }, {
            options = {
                {
                    type = "client",
                    event = event,
                    label = label,
                },
            },
            distance = 2
        })
    else
        local zone = BoxZone:Create(
            coords, size, size, {
                minZ = coords.z - 5.0,
                maxZ = coords.z + 5.0,
                name = boxName,
                debugPoly = false,
                heading = heading,
            })

        local zoneCombo = ComboZone:Create({zone}, {name = boxName, debugPoly = false})
        zoneCombo:onPlayerInOut(function(isPointInside)
            if isPointInside then
                if type == "main" then
                    TriggerEvent('qb-tow:client:PaySlip')
                elseif type == "vehicle" then
                    TriggerEvent('qb-tow:client:Vehicle')
                elseif type == "towspots" then
                    TriggerEvent('qb-tow:client:SpawnNPCVehicle')
                end
            end
        end)
        if type == "vehicle" then
            local zoneMark = BoxZone:Create(
                coords, 20, 20, {
                    minZ = coords.z - 5.0,
                    maxZ = coords.z + 5.0,
                    name = boxName,
                    debugPoly = false,
                    heading = heading,
                })

            local zoneComboV = ComboZone:Create({zoneMark}, {name = boxName, debugPoly = false})
            zoneComboV:onPlayerInOut(function(isPointInside)
                if isPointInside then
                    TriggerEvent('qb-tow:client:ShowMarker', true)
                else
                    TriggerEvent('qb-tow:client:ShowMarker', false)
                end
            end)
        elseif type == "towspots" then
            CurrentLocation.zoneCombo = zoneCombo
        end
    end
end

local function deliverVehicle(vehicle)
    DeleteVehicle(vehicle)
    RemoveBlip(CurrentBlip2)
    JobsDone = JobsDone + 1
    VehicleSpawned = false
    if Config.NotifyType == 'qb' then
        QBCore.Functions.Notify(Lang:t("mission.delivered_vehicle"), "success", 3500)
    elseif Config.NotifyType == "okok" then
        exports['okokNotify']:Alert("VEHICLE DELIVERED", Lang:t("mission.delivered_vehicle"), 3500, "success")
    end 
    TriggerServerEvent('qb-tow:server:nano', vehNetID)
    if Config.mzskills then 
        TriggerEvent('qb-towjob:client:mzSkills')
    end 
    if Config.NotifyType == 'qb' then
        QBCore.Functions.Notify(Lang:t("mission.get_new_vehicle"), "primary", 3500)
    elseif Config.NotifyType == "okok" then
        exports['okokNotify']:Alert("NEXT JOB", Lang:t("mission.get_new_vehicle"), 3500, "info")
    end 
    local randomLocation = getRandomVehicleLocation()
    CurrentLocation.x = Config.Locations["towspots"][randomLocation].coords.x
    CurrentLocation.y = Config.Locations["towspots"][randomLocation].coords.y
    CurrentLocation.z = Config.Locations["towspots"][randomLocation].coords.z
    CurrentLocation.model = Config.Locations["towspots"][randomLocation].model
    CurrentLocation.id = randomLocation
    CreateZone("towspots", randomLocation)
    CurrentBlip = AddBlipForCoord(CurrentLocation.x, CurrentLocation.y, CurrentLocation.z)
    SetBlipColour(CurrentBlip, 3)
    SetBlipRoute(CurrentBlip, true)
    SetBlipRouteColour(CurrentBlip, 3)
end

local function CreateElements()
    local TowBlip = AddBlipForCoord(Config.Locations["main"].coords.x, Config.Locations["main"].coords.y, Config.Locations["main"].coords.z)
    SetBlipSprite(TowBlip, 477)
    SetBlipDisplay(TowBlip, 4)
    SetBlipScale(TowBlip, 0.6)
    SetBlipAsShortRange(TowBlip, true)
    SetBlipColour(TowBlip, 15)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Config.Locations["main"].label)
    EndTextCommandSetBlipName(TowBlip)

    local TowVehBlip = AddBlipForCoord(Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z)
    SetBlipSprite(TowVehBlip, 326)
    SetBlipDisplay(TowVehBlip, 4)
    SetBlipScale(TowVehBlip, 0.6)
    SetBlipAsShortRange(TowVehBlip, true)
    SetBlipColour(TowVehBlip, 15)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Config.Locations["vehicle"].label)
    EndTextCommandSetBlipName(TowVehBlip)

    CreateZone("main")
    CreateZone("vehicle")
end

-- Events

RegisterNetEvent('qb-tow:client:SpawnVehicle', function()
    local vehicleInfo = selectedVeh
    local coords = Config.Locations["vehicle"].coords
    QBCore.Functions.TriggerCallback('QBCore:Server:SpawnVehicle', function(netId)
        local veh = NetToVeh(netId)
        SetVehicleNumberPlateText(veh, "TOWR"..tostring(math.random(1000, 9999)))
        SetEntityHeading(veh, coords.w)
        exports['LegacyFuel']:SetFuel(veh, 100.0)
        SetEntityAsMissionEntity(veh, true, true)
        CloseMenuFull()
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
        SetVehicleEngineOn(veh, true, true)
        for i = 1, 9, 1 do
            SetVehicleExtra(veh, i, 0)
        end
    end, vehicleInfo, coords, false)
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
    if PlayerJob.name == "tow" then
        CreateElements()
    end
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
    if PlayerJob.name == "tow" then
        CreateElements()
    end
end)

RegisterNetEvent('jobs:client:ToggleNpc', function()
    if QBCore.Functions.GetPlayerData().job.name == "tow" then
        if CurrentTow ~= nil then
            if Config.NotifyType == 'qb' then
                QBCore.Functions.Notify(Lang:t("error.finish_work"), "info", 3500)
            elseif Config.NotifyType == "okok" then
                exports['okokNotify']:Alert("FINISH WORK", Lang:t("error.finish_work"), 3500, "info")
            end 
            return
        end
        NpcOn = not NpcOn
        if NpcOn then
            local randomLocation = getRandomVehicleLocation()
            CurrentLocation.x = Config.Locations["towspots"][randomLocation].coords.x
            CurrentLocation.y = Config.Locations["towspots"][randomLocation].coords.y
            CurrentLocation.z = Config.Locations["towspots"][randomLocation].coords.z
            CurrentLocation.model = Config.Locations["towspots"][randomLocation].model
            CurrentLocation.id = randomLocation
            CreateZone("towspots", randomLocation)
            CurrentBlip = AddBlipForCoord(CurrentLocation.x, CurrentLocation.y, CurrentLocation.z)
            SetBlipColour(CurrentBlip, 3)
            SetBlipRoute(CurrentBlip, true)
            SetBlipRouteColour(CurrentBlip, 3)
        else
            if DoesBlipExist(CurrentBlip) then
                RemoveBlip(CurrentBlip)
                CurrentLocation = {}
                CurrentBlip = nil
            end
            VehicleSpawned = false
        end
    end
end)

RegisterNetEvent("qb-towjob:client:mzSkills", function()
    if Config.mzskills then 
        local BetterXP = math.random(Config.DriverXPlow, Config.DriverXPhigh)
        local xpmultiple = math.random(1, 4)
        if xpmultiple >= 3 then
            chance = BetterXP
        elseif xpmultiple < 3 then
            chance = Config.DriverXPlow
        end
        exports["mz-skills"]:UpdateSkill("Driving", chance) 
        Wait(1000)
        if Config.BonusChance >= math.random(1, 100) then
            exports["mz-skills"]:CheckSkill("Driving", 12800, function(hasskill)
                if hasskill then
                    lvl8 = true
                end
            end)
            exports["mz-skills"]:CheckSkill("Driving", 6400, function(hasskill)
                if hasskill then
                    lvl7 = true
                end
            end)
            exports["mz-skills"]:CheckSkill("Driving", 3200, function(hasskill)
                if hasskill then
                    lvl6 = true
                end
            end)
            exports["mz-skills"]:CheckSkill("Driving", 1600, function(hasskill)
                if hasskill then
                    lvl5 = true
                end
            end)
            exports["mz-skills"]:CheckSkill("Driving", 800, function(hasskill)
                if hasskill then
                    lvl4 = true
                end
            end)
            exports["mz-skills"]:CheckSkill("Driving", 400, function(hasskill)
                if hasskill then
                    lvl3 = true
                end
            end)
            exports["mz-skills"]:CheckSkill("Driving", 200, function(hasskill)
                if hasskill then
                    lvl2 = true
                end
            end)
            exports["mz-skills"]:CheckSkill("Driving", 0, function(hasskill)
                if hasskill then
                    lvl1 = true
                end
            end)
            if lvl8 == true then
                TriggerServerEvent('qb-towjob:server:NPCBonusLevel8')
                Wait(1500)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify('Best tow truck driver ever, going to give you a 5 star review!', "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("TIP", 'Best tow truck driver ever, going to give you a 5 star review!', 3500, "info")
                end 
                lvl8 = false
            elseif lvl7 == true then
                TriggerServerEvent('qb-towjob:server:NPCBonusLevel7')
                Wait(1500)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify('Best tow truck driver ever, going to give you a 5 star review!', "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("TIP", 'Best tow truck driver ever, going to give you a 5 star review!', 3500, "info")
                end 
                lvl7 = false
            elseif lvl6 == true then
                TriggerServerEvent('qb-towjob:server:NPCBonusLevel6')
                Wait(1500)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify('Hey, do you always drive so well? You got me here quick smart!', "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("TIP", 'Hey, do you always drive so well? You got me here quick smart!', 3500, "info")
                end 
                lvl6 = false
            elseif lvl5 == true then
                TriggerServerEvent('qb-towjob:server:NPCBonusLevel5')
                Wait(1500)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify('Hey, do you always drive so well? You got me here quick smart!', "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("TIP", 'Hey, do you always drive so well? You got me here quick smart!', 3500, "info")
                end 
                lvl5 = false
            elseif lvl4 == true then
                TriggerServerEvent('qb-towjob:server:NPCBonusLevel4')
                Wait(1500)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify('Wow, this is in good condition, keep up the good work.', "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("TIP", 'Wow, this is in good condition, keep up the good work.', 3500, "info")
                end 
                lvl4 = false
            elseif lvl3 == true then
                TriggerServerEvent('qb-towjob:server:NPCBonusLevel3')
                Wait(1500)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify('Wow, this is in good condition, keep up the good work.', "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("TIP", 'Wow, this is in good condition, keep up the good work.', 3500, "info")
                end 
                lvl3 = false
            elseif lvl2 == true then
                TriggerServerEvent('qb-towjob:server:NPCBonusLevel2')
                Wait(1500)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify('Thank you for this, take a little change for your trouble.', "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("TIP", 'Thank you for this, take a little change for your trouble.', 3500, "info")
                end 
                lvl2 = false
            elseif lvl1 == true then 
                TriggerServerEvent('qb-towjob:server:NPCBonusLevel1')
                Wait(1500)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify('Thank you for this, take a little change for your trouble.', "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("TIP", 'Thank you for this, take a little change for your trouble.', 3500, "info")
                end 
                lvl1 = false
            end
        end
    end
end)

RegisterNetEvent('qb-tow:client:TowVehicle', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
    if isTowVehicle(vehicle) then
        if CurrentTow == nil then
            local playerped = PlayerPedId()
            local coordA = GetEntityCoords(playerped, 1)
            local coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 5.0, 0.0)
            local targetVehicle = getVehicleInDirection(coordA, coordB)
            if NpcOn and CurrentLocation then
                if GetEntityModel(targetVehicle) ~= joaat(CurrentLocation.model) then
                    if Config.NotifyType == 'qb' then
                        QBCore.Functions.Notify(Lang:t("error.vehicle_not_correct"), "info", 3500)
                    elseif Config.NotifyType == "okok" then
                        exports['okokNotify']:Alert("WRONG VEHICLE", Lang:t("error.vehicle_not_correct"), 3500, "info")
                    end 
                    return
                end
            end
            if not IsPedInAnyVehicle(PlayerPedId()) then
                if vehicle ~= targetVehicle then
                    local towPos = GetEntityCoords(vehicle)
                    local targetPos = GetEntityCoords(targetVehicle)
                    if #(towPos - targetPos) < 11.0 then
                        QBCore.Functions.Progressbar("towing_vehicle", Lang:t("mission.towing_vehicle"), 5000, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                        }, {
                            animDict = "mini@repair",
                            anim = "fixing_a_ped",
                            flags = 16,
                        }, {}, {}, function() -- Done
                            StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_ped", 1.0)
                            AttachEntityToEntity(targetVehicle, vehicle, GetEntityBoneIndexByName(vehicle, 'bodyshell'), 0.0, -1.5 + -0.85, 0.0 + 1.15, 0, 0, 0, 1, 1, 0, 1, 0, 1)
                            FreezeEntityPosition(targetVehicle, true)
                            CurrentTow = targetVehicle
                            if NpcOn then
                                RemoveBlip(CurrentBlip)
                                if Config.NotifyType == 'qb' then
                                    QBCore.Functions.Notify(Lang:t("mission.goto_depot"), "info", 5000)
                                elseif Config.NotifyType == "okok" then
                                    exports['okokNotify']:Alert("GO TO THE DEPOT", Lang:t("mission.goto_depot"), 5000, "info")
                                end 
                                CurrentBlip2 = AddBlipForCoord(Config.Locations["dropoff"].coords.x, Config.Locations["dropoff"].coords.y, Config.Locations["dropoff"].coords.z)
                                SetBlipColour(CurrentBlip2, 3)
                                SetBlipRoute(CurrentBlip2, true)
                                SetBlipRouteColour(CurrentBlip2, 3)
                                drawDropOff = true
                                drawDropOffMarker()
                                local vehNetID = NetworkGetNetworkIdFromEntity(targetVehicle)
                                --remove zone
                                CurrentLocation.zoneCombo:destroy()
                            end
                            if Config.NotifyType == 'qb' then
                                QBCore.Functions.Notify(Lang:t("mission.vehicle_towed"), "success", 5000)
                            elseif Config.NotifyType == "okok" then
                                exports['okokNotify']:Alert("VEHICLE TOWED", Lang:t("mission.vehicle_towed"), 5000, "success")
                            end 
                        end, function() -- Cancel
                            StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_ped", 1.0)
                            if Config.NotifyType == 'qb' then
                                QBCore.Functions.Notify(Lang:t("error.failed"), "error", 3500)
                            elseif Config.NotifyType == "okok" then
                                exports['okokNotify']:Alert("FAILIED", Lang:t("error.failed"), 3500, "error")
                            end 
                        end)
                    end
                end
            end
        else
            QBCore.Functions.Progressbar("untowing_vehicle", Lang:t("mission.untowing_vehicle"), 5000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {
                animDict = "mini@repair",
                anim = "fixing_a_ped",
                flags = 16,
            }, {}, {}, function() -- Done
                StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_ped", 1.0)
                FreezeEntityPosition(CurrentTow, false)
                Wait(250)
                AttachEntityToEntity(CurrentTow, vehicle, 20, -0.0, -15.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
                DetachEntity(CurrentTow, true, true)
                if NpcOn then
                    local targetPos = GetEntityCoords(CurrentTow)
                    if #(targetPos - vector3(Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z)) < 25.0 then
                        deliverVehicle(CurrentTow)
                    end
                end
                RemoveBlip(CurrentBlip2)
                CurrentTow = nil
                drawDropOff = false
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify(Lang:t("mission.vehicle_takenoff"), "success", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("UNMOUNTED", Lang:t("mission.vehicle_takenoff"), 3500, "success")
                end 
            end, function() -- Cancel
                StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_ped", 1.0)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify(Lang:t("error.failed"), "error", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("FAILED", Lang:t("error.failed"), 3500, "error")
                end 
            end)
        end
    else
        if Config.NotifyType == 'qb' then
            QBCore.Functions.Notify(Lang:t("error.not_towing_vehicle"), "error", 3500)
        elseif Config.NotifyType == "okok" then
            exports['okokNotify']:Alert("NOT TOWING", Lang:t("error.not_towing_vehicle"), 3500, "error")
        end 
    end
end)

RegisterNetEvent('qb-tow:client:TakeOutVehicle', function(data)
    local coords = Config.Locations["vehicle"].coords
    coords = vector3(coords.x, coords.y, coords.z)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    if #(pos - coords) <= 5 then
        local vehicleInfo = data.vehicle
        TriggerServerEvent('qb-tow:server:DoBail', true, vehicleInfo)
        selectedVeh = vehicleInfo
    else
        if Config.NotifyType == 'qb' then
            QBCore.Functions.Notify(Lang:t("error.too_far_away"), "error", 3500)
        elseif Config.NotifyType == "okok" then
            exports['okokNotify']:Alert("TOO FAR", Lang:t("error.too_far_away"), 3500, "error")
        end 
    end
end)

RegisterNetEvent('qb-tow:client:Vehicle', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if not CurrentTow then
        if vehicle and isTowVehicle(vehicle) then
            DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
            TriggerServerEvent('qb-tow:server:DoBail', false)
        else
            MenuGarage()
        end
    else
        if Config.NotifyType == 'qb' then
            QBCore.Functions.Notify(Lang:t("error.finish_work"), "error", 3500)
        elseif Config.NotifyType == "okok" then
            exports['okokNotify']:Alert("FINISH WORK", Lang:t("error.finish_work"), 3500, "error")
        end 
    end
end)

RegisterNetEvent('qb-tow:client:PaySlip', function()
    if JobsDone > 0 then
        RemoveBlip(CurrentBlip)
        TriggerServerEvent("qb-tow:server:11101110", JobsDone)
        JobsDone = 0
        NpcOn = false
    else
        QBCore.Functions.Notify(Lang:t("error.no_work_done"), "error")
        if Config.NotifyType == 'qb' then
            QBCore.Functions.Notify(Lang:t("error.no_work_done"), "error", 3500)
        elseif Config.NotifyType == "okok" then
            exports['okokNotify']:Alert("NO WORK?", Lang:t("error.no_work_done"), 3500, "error")
        end 
    end
end)

RegisterNetEvent('qb-tow:client:SpawnNPCVehicle', function()
    if not VehicleSpawned then
        QBCore.Functions.TriggerCallback('QBCore:Server:SpawnVehicle', function(netId)
            local veh = NetToVeh(netId)
            exports['LegacyFuel']:SetFuel(veh, 0.0)
            VehicleSpawned = true
        end, CurrentLocation.model, CurrentLocation, false)
    end
end)

RegisterNetEvent('qb-tow:client:ShowMarker', function(active)
    if PlayerJob.name == "tow" then
        showMarker = active
    end
end)

-- Threads

CreateThread(function()
    while true do
        if showMarker then
            DrawMarker(2, Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
            --DrawMarker(2, Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 200, 200, 222, false, false, false, true, false, false, false)
            Wait(0)
        else
            Wait(1000)
        end
    end
end)
