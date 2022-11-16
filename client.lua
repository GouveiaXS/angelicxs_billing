
ESX = nil
QBcore = nil
PlayerJob = nil
PlayerData = nil

CreateThread(function()
    if Config.UseESX then
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Wait(0)
        end

        while not ESX.IsPlayerLoaded() do
            Wait(100)
        end

        PlayerData = ESX.GetPlayerData()
        CreateThread(function()
            while true do
                if PlayerData ~= nil then
                    PlayerJob = PlayerData.job.name
                    break
                end
                Wait(100)
            end
        end)

        RegisterNetEvent('esx:setJob', function(job)
            PlayerJob = job.name
            PlayerGrade = job.grade
        end)
    elseif Config.UseQBCore then
        QBCore = exports['qb-core']:GetCoreObject()

        CreateThread(function ()
			while true do
                PlayerData = QBCore.Functions.GetPlayerData()
				if PlayerData.citizenid ~= nil then
					PlayerJob = PlayerData.job.name
					break
				end
				Wait(100)
			end
		end)

        RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
            PlayerJob = job.name
        end)
    end
end)

RegisterNetEvent('angelicxs-billing:Notify', function(message, type)
	if Config.UseCustomNotify then
        TriggerEvent('angelicxs-billing:CustomNotify',message, type)
	elseif Config.UseESX then
		ESX.ShowNotification(message)
	elseif Config.UseQBCore then
		QBCore.Functions.Notify(message, type)
	end
end)

RegisterCommand(Config.Command, function() TriggerEvent('angelicxs-billing:MainMenu') end, false)

RegisterNetEvent('angelicxs-billing:MainMenu', function()
    local mainMenu = {}
    if Config.NHMenu then
        table.insert(mainMenu, {
            header = Config.Lang['mainMenuHeader'],
        })
        table.insert(mainMenu, {
            header = Config.Lang['access_invoice'], 
            event = 'angelicxs-billing:LookUpCurrentInvoices',
        })
        table.insert(mainMenu, {
            header = Config.Lang['send_invoice'], 
            event = 'angelicxs-billing:SendInvoice', 
        })
    elseif Config.QBMenu then
        table.insert(mainMenu, {
                header = Config.Lang['mainMenuHeader'],
                isMenuHeader = true
            })
        table.insert(mainMenu, {
            header = Config.Lang['access_invoice'], 
            params = {
                event = 'angelicxs-billing:LookUpCurrentInvoices', 
            }
        })
        table.insert(mainMenu, {
            header = Config.Lang['send_invoice'], 
            params = {
                event = 'angelicxs-billing:SendInvoice', 
            }
        })
    elseif Config.OXLib then
        table.insert(mainMenu, {
            label = Config.Lang['access_invoice'],
            args = { select = 1}
        })
        table.insert(mainMenu, {
            label = Config.Lang['send_invoice'],
            args = { select = 2}
        })
    end
    if Config.NHMenu then
        TriggerEvent("nh-context:createMenu", mainMenu)
    elseif Config.QBMenu then
        TriggerEvent("qb-menu:client:openMenu", mainMenu)
    elseif Config.OXLib then
        lib.registerMenu({
            id = 'billingMainMenu_ox',
            title = Config.Lang['mainMenuHeader'],
            options = mainMenu,
            position = 'top-right',
        }, function(selected, scrollIndex, args)
            if args.select == 1 then
                TriggerEvent('angelicxs-billing:LookUpCurrentInvoices')
            elseif args.select == 2 then
                TriggerEvent('angelicxs-billing:SendInvoice')
            end
        end)
        lib.showMenu('billingMainMenu_ox')
    end
end)


RegisterNetEvent('angelicxs-billing:LookUpCurrentInvoices', function()
    local invoiceTable = nil
    local outstandingInvoiceMenu = {}
    if Config.UseESX then
        ESX.TriggerServerCallback('angelicxs-billing:CurrentInvoices:ESX', function(cb)
            invoiceTable = cb
        end)
    elseif Config.UseQBCore then
        QBCore.Functions.TriggerCallback('angelicxs-billing:CurrentInvoices:QBCore', function(cb)
            invoiceTable = cb
        end)
    end
    Wait(300)
    if invoiceTable == nil then
        TriggerEvent('angelicxs-billing:Notify', Config.Lang['no_invoices'], Config.LangType['info'])
    else
        if Config.NHMenu then
            table.insert(outstandingInvoiceMenu, {
                header = Config.Lang['invoice_header'],
            })
        elseif Config.QBMenu then
            table.insert(outstandingInvoiceMenu, {
                    header = Config.Lang['invoice_header'],
                    isMenuHeader = true
                })
        end
        for _, info in pairs(invoiceTable) do
            local invoice = tostring(info.invoice)
            local sender = tostring(info.society)
            if Config.NHMenu then
                table.insert(outstandingInvoiceMenu, {
                    header = Config.Lang['pay_me'], 
                    context = Config.Lang['current_invoice_amount']..invoice..' '..Config.Lang['current_invoice_place']..sender,
                    event = 'angelicxs-billing:PayInvoice',
                    args = { info }
                })
            elseif Config.QBMenu then
                table.insert(outstandingInvoiceMenu, {
                        header = Config.Lang['pay_me'],
                        txt = Config.Lang['current_invoice_amount']..invoice..' '..Config.Lang['current_invoice_place']..sender,
                        params = {
                            event = 'angelicxs-billing:PayInvoice',
                            args = info
                        }
                    })
            elseif Config.OXLib then
                table.insert(outstandingInvoiceMenu, {
                    label = Config.Lang['current_invoice_amount']..invoice..' '..Config.Lang['current_invoice_place']..sender,
                    args = { info = info}
                })
            end
        end
        if Config.NHMenu then
            TriggerEvent("nh-context:createMenu", outstandingInvoiceMenu)
        elseif Config.QBMenu then
            TriggerEvent("qb-menu:client:openMenu", outstandingInvoiceMenu)
        elseif Config.OXLib then
            lib.registerMenu({
                id = 'currentloans_ox',
                title = Config.Lang['invoice_header'],
                options = outstandingInvoiceMenu,
                position = 'top-right',
            }, function(selected, scrollIndex, args)
                TriggerEvent('angelicxs-billing:PayInvoice', args.info)
            end)
            lib.showMenu('currentloans_ox')
        end
    end
end)

RegisterNetEvent('angelicxs-billing:PayInvoice', function(invoice)
    TriggerServerEvent('angelicxs-billing:Server:PayInvoice', invoice)
end)


RegisterNetEvent('angelicxs-billing:SendInvoice', function()
    if AllowedJob() then
        local invoiceInfo = {}
        if Config.NHInput then
            local keyboard, amount = exports["nh-keyboard"]:Keyboard({
                header = Config.Lang['set_up_invoice_header'],
                rows = {Config.Lang['set_up_invoice'], Config.Lang['set_up_invoice_id']} 
            })
            if keyboard then
                if tonumber(amount[1]) >= 0 and tonumber(amount[2]) >= 0 then
                    invoiceInfo.invoice = tonumber(amount[1])
                    invoiceInfo.id = tonumber(amount[2])
                else
                    TriggerEvent('angelicxs-billing:Notify', Config.Lang['zero_error'], Config.LangType['error'])
                end
            end
        elseif Config.QBInput then
            local info = exports['qb-input']:ShowInput({
                header = Config.Lang['set_up_invoice_header'],
                submitText = Config.Lang['set_up_invoice_submit'], 
                inputs = {
                    {
                        type = 'number',
                        isRequired = true,
                        name = 'invoice',
                        text = Config.Lang['set_up_invoice'],
                    },
                    {
                        type = 'number',
                        isRequired = true,
                        name = 'id',
                        text = Config.Lang['set_up_invoice_id'], 
                    }
                }
            })    
            if info then
                if tonumber(info.invoice) >= 0 and tonumber(info.id) >= 0 then
                    invoiceInfo.invoice = tonumber(info.invoice)
                    invoiceInfo.id = tonumber(info.id)
                else
                    TriggerEvent('angelicxs-billing:Notify', Config.Lang['zero_error'], Config.LangType['error'])
                end
            end
        elseif Config.OXLib then
            local input = lib.inputDialog(Config.Lang['set_up_invoice_header'], {Config.Lang['set_up_invoice'], Config.Lang['set_up_invoice_id']})
            if not input then return end
            invoiceInfo.invoice = tonumber(input[1])
            invoiceInfo.id = tonumber(input[2])
        end
        TriggerServerEvent('angelicxs-billing:SendInvoice', PlayerJob, invoiceInfo)
    else
        TriggerEvent('angelicxs-billing:Notify', Config.Lang['wrong_job'], Config.LangType['error'])
    end
end)

function AllowedJob()
    local List = Config.Allowedjobs
    for i = 1, #List do
        if PlayerJob == List[i] then
            return true
        end
    end
    return false
end