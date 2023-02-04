ESX = nil
QBcore = nil

if Config.UseESX then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.UseQBCore then
    QBCore = exports['qb-core']:GetCoreObject()
end

if Config.UseESX then
    ESX.RegisterServerCallback('angelicxs-billing:CurrentInvoices:ESX',function(source, cb)
        local xPlayer = ESX.GetPlayerFromId(source) 
        MySQL.query('SELECT * FROM angelicxs_billing WHERE identifier = ?', {xPlayer.identifier}, function(result)
            if result then
                local var = tonumber(#result)
                if var >= 1 then
                    cb(result)
                end
            end
        end)
    end)
elseif Config.UseQBCore then
    QBCore.Functions.CreateCallback('angelicxs-billing:CurrentInvoices:QBCore', function(source, cb)
        local Player = QBCore.Functions.GetPlayer(source)
        MySQL.query('SELECT * FROM angelicxs_billing WHERE identifier = ?', {Player.PlayerData.citizenid}, function(result)
            if result then
                local var = tonumber(#result)
                if var >= 1 then
                    cb(result)
                end
            end
        end)
    end)
end

RegisterServerEvent('angelicxs-billing:Server:PayInvoice')
AddEventHandler('angelicxs-billing:Server:PayInvoice', function(invoice)
    local owing = tonumber(invoice.invoice)
    local society = tostring(invoice.society)
    local src = source
    local paid = false
    local Player = nil
    local id = nil
    if Config.UseESX then
        Player = ESX.GetPlayerFromId(src)
        id = Player.identifier
        if Player.getMoney() >= owing then
            Player.removeMoney(owing)
            paid = true
        end
    elseif Config.UseQBCore then
        Player = QBCore.Functions.GetPlayer(src)
        id = Player.PlayerData.citizenid
        local cash = Player.PlayerData.money['cash']
        if cash >= owing then
            Player.Functions.RemoveMoney('cash', owing, "Invoice-Payment")
            paid = true
        end
    end
    Wait(300)
    if not paid then
        TriggerClientEvent('angelicxs-billing:Notify', src, Config.Lang['low_money'], Config.Lang['error'])
    elseif paid then
        MySQL.Async.fetchAll('DELETE FROM angelicxs_billing WHERE identifier = @identifier AND invoice = @invoice AND society = @society', {
            ['@identifier'] 	= id,
            ['@invoice'] 	    = owing,
            ['@society'] 	    = society,
        }, function(rowsChanged)   
        end)
        TriggerEvent('angelicxs-billing:PaySociety', society, owing)
        TriggerClientEvent('angelicxs-billing:Notify', src, Config.Lang['invoice_pay']..owing..' '..Config.Lang['invoice_pay2']..' '..society, Config.Lang['success'])
    end
end)

RegisterServerEvent('angelicxs-billing:PaySociety', function(sender, amount)
    if Config.UseESX then
        TriggerServerEvent('esx_society:depositMoney', sender, amount)
    elseif Config.UseQBCore then
        exports['qb-management']:AddMoney(sender, amount)
    end
end)

RegisterServerEvent('angelicxs-billing:SendInvoice')
AddEventHandler('angelicxs-billing:SendInvoice', function(sender, invoiceInfo)
    local src = source
    local amount = invoiceInfo.invoice
    local OtherPlayer = nil
    local id = nil
    local Player = nil
    local PlayerId = nil
    if Config.UseESX then
        OtherPlayer = ESX.GetPlayerFromId(tonumber(invoiceInfo.id))
        id = OtherPlayer.identifier
        Player = ESX.GetPlayerFromId(src)
        PlayerId = Player.identifier
    elseif Config.UseQBCore then
        OtherPlayer = QBCore.Functions.GetPlayer(tonumber(invoiceInfo.id))
        id = OtherPlayer.PlayerData.citizenid
        Player = QBCore.Functions.GetPlayer(src)
        PlayerId = Player.PlayerData.citizenid
    end
    if not OtherPlayer then
        TriggerClientEvent('angelicxs-billing:Notify',src, Config.Lang['not_online'],Config.LangType['error'])
    else
        MySQL.Async.execute('INSERT INTO angelicxs_billing (identifier, invoice, society, sender) VALUES (@identifier, @invoice, @society, @sender)', {
            ['@identifier']   = id,
            ['@invoice']   = amount,
            ['@society'] = sender,
            ['@sender'] = PlayerId,
            }, function(rowsChanged)
        end)
        TriggerClientEvent('angelicxs-billing:Notify', id, Config.Lang['invoice_received']..tostring(amount), Config.Lang['info'])
        TriggerClientEvent('angelicxs-billing:Notify', src, Config.Lang['invoice_sent']..tostring(amount), Config.Lang['success'])
    end
end)
