local QBCore = exports['qb-core']:GetCoreObject()
local PaymentTax = Config.Paymenttax
local Bail = {}

RegisterNetEvent('qb-tow:server:DoBail', function(bool, vehInfo)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if bool then
        if Player.PlayerData.money.cash >= Config.BailPrice then
            Bail[Player.PlayerData.citizenid] = Config.BailPrice
            Player.Functions.RemoveMoney('cash', Config.BailPrice, "tow-paid-bail")
            if Config.NotifyType == 'qb' then
                TriggerClientEvent('QBCore:Notify', src, Lang:t("success.paid_with_cash", {value = Config.BailPrice}), 'success')
            elseif Config.NotifyType == "okok" then
                TriggerClientEvent('okokNotify:Alert', source, "PAID WITH CASH", Lang:t("success.paid_with_cash", {value = Config.BailPrice}), 3500, 'success')
            end
            TriggerClientEvent('qb-tow:client:SpawnVehicle', src, vehInfo)
        elseif Player.PlayerData.money.bank >= Config.BailPrice then
            Bail[Player.PlayerData.citizenid] = Config.BailPrice
            Player.Functions.RemoveMoney('bank', Config.BailPrice, "tow-paid-bail")
            if Config.NotifyType == 'qb' then
                TriggerClientEvent('QBCore:Notify', src, Lang:t("success.paid_with_bank", {value = Config.BailPrice}), 'success')
            elseif Config.NotifyType == "okok" then
                TriggerClientEvent('okokNotify:Alert', source, "PAID WITH BANK", Lang:t("success.paid_with_bank", {value = Config.BailPrice}), 3500, 'success')
            end
            TriggerClientEvent('qb-tow:client:SpawnVehicle', src, vehInfo)
        else
            if Config.NotifyType == 'qb' then
                TriggerClientEvent('QBCore:Notify', src, Lang:t("error.no_deposit", {value = Config.BailPrice}), 'error')
            elseif Config.NotifyType == "okok" then
                TriggerClientEvent('okokNotify:Alert', source, "NO DEPOSIT", Lang:t("error.no_deposit", {value = Config.BailPrice}), 3500, 'error')
            end
        end
    else
        if Bail[Player.PlayerData.citizenid] ~= nil then
            Player.Functions.AddMoney('bank', Bail[Player.PlayerData.citizenid], "tow-bail-paid")
            Bail[Player.PlayerData.citizenid] = nil
            if Config.NotifyType == 'qb' then
                TriggerClientEvent('QBCore:Notify', src, Lang:t("success.refund_to_cash", {value = Config.BailPrice}), 'success')
            elseif Config.NotifyType == "okok" then
                TriggerClientEvent('okokNotify:Alert', source, "PAID WITH BANK", Lang:t("success.refund_to_cash", {value = Config.BailPrice}), 3500, 'success')
            end
        end
    end
end)

RegisterNetEvent('qb-tow:server:nano', function(vehNetID)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local targetVehicle = NetworkGetEntityFromNetworkId(vehNetID)
    if not Player then return end
    local playerPed = GetPlayerPed(src)
    local playerVehicle = GetVehiclePedIsIn(playerPed, true)
    local playerVehicleCoords = GetEntityCoords(playerVehicle)
    local targetVehicleCoords = GetEntityCoords(targetVehicle)
    local dist = #(playerVehicleCoords - targetVehicleCoords)
    local chance = math.random(1,100)
    if Config.bonus then
        if chance <= Config.bonuschance then
            Player.Functions.AddItem(Config.bonusitem, 1, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.bonusitem], "add")
        end
    end
end)

RegisterNetEvent('qb-tow:server:11101110', function(drops)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local playerPed = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)
    if Player.PlayerData.job.name ~= "tow" or #(playerCoords - vector3(Config.Locations["main"].coords.x, Config.Locations["main"].coords.y, Config.Locations["main"].coords.z)) > 6.0 then
        return DropPlayer(src, Lang:t("info.skick"))
    end
    drops = tonumber(drops)
    local bonus = 0
    local DropPrice = math.random(Config.Lowpay, Config.Highpay)
    if drops > 5 then
        bonus = math.ceil((DropPrice / 10) * 5)
    elseif drops > 10 then
        bonus = math.ceil((DropPrice / 10) * 6)
    elseif drops > 15 then
        bonus = math.ceil((DropPrice / 10) * 7)
    elseif drops > 20 then
        bonus = math.ceil((DropPrice / 10) * 8)
    end
    local price = (DropPrice * drops) + bonus
    local taxAmount = math.ceil((price / 100) * PaymentTax)
    local payment = price - taxAmount
    Player.Functions.AddJobReputation(1)
    Player.Functions.AddMoney("bank", payment, "tow-salary")
    if Config.NotifyType == 'qb' then
        TriggerClientEvent('QBCore:Notify', src, Lang:t("success.you_earned", {value = payment}), 'success')
    elseif Config.NotifyType == "okok" then
        TriggerClientEvent('okokNotify:Alert', source, "YOU BEEN PAID", Lang:t("success.you_earned", {value = payment}), 3500, 'success')
    end
end)

QBCore.Commands.Add("npc", Lang:t("info.toggle_npc"), {}, false, function(source)
	TriggerClientEvent("jobs:client:ToggleNpc", source)
end)

QBCore.Commands.Add("tow", Lang:t("info.tow"), {}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "tow"  or Player.PlayerData.job.name == "mechanic" then
        TriggerClientEvent("qb-tow:client:TowVehicle", source)
    end
end)

RegisterNetEvent('qb-towjob:server:NPCBonusLevel1', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Bonus = math.random(Config.Level1Low, Config.Level1High)
    Player.Functions.AddMoney('cash', Bonus)
end)

RegisterNetEvent('qb-towjob:server:NPCBonusLevel2', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Bonus = math.random(Config.Level2Low, Config.Level2High)
    Player.Functions.AddMoney('cash', Bonus)
end)

RegisterNetEvent('qb-towjob:server:NPCBonusLevel3', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Bonus = math.random(Config.Level3Low, Config.Level3High)
    Player.Functions.AddMoney('cash', Bonus)
end)

RegisterNetEvent('qb-towjob:server:NPCBonusLevel4', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Bonus = math.random(Config.Level4Low, Config.Level4High)
    Player.Functions.AddMoney('cash', Bonus)
end)

RegisterNetEvent('qb-towjob:server:NPCBonusLevel5', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Bonus = math.random(Config.Level5Low, Config.Level5High)
    Player.Functions.AddMoney('cash', Bonus)
end)

RegisterNetEvent('qb-towjob:server:NPCBonusLevel6', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Bonus = math.random(Config.Level6Low, Config.Level6High)
    Player.Functions.AddMoney('cash', Bonus)
end)

RegisterNetEvent('qb-towjob:server:NPCBonusLevel7', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Bonus = math.random(Config.Level7Low, Config.Level7High)
    Player.Functions.AddMoney('cash', Bonus)
end)

RegisterNetEvent('qb-towjob:server:NPCBonusLevel8', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Bonus = math.random(Config.Level8Low, Config.Level8High)
    Player.Functions.AddMoney('cash', Bonus)
end)