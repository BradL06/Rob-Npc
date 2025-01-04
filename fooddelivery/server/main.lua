local ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('esx_fooddelivery:deliveryComplete')
AddEventHandler('esx_fooddelivery:deliveryComplete', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer then
        local payment = math.random(Config.MinPayment, Config.MaxPayment)
        xPlayer.addMoney(payment)
        TriggerClientEvent('esx:showNotification', source, 'Delivery completed! You earned $' .. payment)
    end
end)
