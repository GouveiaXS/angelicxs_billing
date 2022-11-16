----------------------------------------------------------------------
-- Thanks for supporting AngelicXS Scripts!							--
-- Support can be found at: https://discord.gg/tQYmqm4xNb			--
-- More paid scripts at: https://angelicxs.tebex.io/ 				--
-- More FREE scripts at: https://github.com/GouveiaXS/ 				--
----------------------------------------------------------------------
-- Model info: https://docs.fivem.net/docs/game-references/ped-models/
-- Blip info: https://docs.fivem.net/docs/game-references/blips/

Config = {}

Config.UseESX = false						-- Use ESX Framework
Config.UseQBCore = true						-- Use QBCore Framework (Ignored if Config.UseESX = true)

Config.NHInput = false						-- Use NH-Input [https://github.com/nerohiro/nh-keyboard]
Config.NHMenu = false						-- Use NH-Menu [https://github.com/nerohiro/nh-context]
Config.QBInput = true						-- Use QB-Input (Ignored if Config.NHInput = true) [https://github.com/qbcore-framework/qb-input]
Config.QBMenu = true						-- Use QB-Menu (Ignored if Config.NHMenu = true) [https://github.com/qbcore-framework/qb-menu]
Config.OXLib = false						-- Use the OX_lib (Ignored if Config.NHInput or Config.QBInput = true) [https://github.com/overextended/ox_lib]  !! must add shared_script '@ox_lib/init.lua' and lua54 'yes' to fxmanifest!!

Config.UseCustomNotify = false				-- Use a custom notification script, must complete event below.
-- Only complete this event if Config.UseCustomNotify is true; mythic_notification provided as an example
RegisterNetEvent('angelicxs-billing:CustomNotify')
AddEventHandler('angelicxs-billing:CustomNotify', function(message, type)
    --exports.mythic_notify:SendAlert(type, message, 4000)
end)

Config.Command = 'invoices' -- Name of the /command to access UI 

-- Job Configuration
Config.Allowedjobs = { -- Name the job(s), that can send invoices (all paid invoices go to the socitey)
	'police', 
	'ambulance',
}	

-- Language Configuration
Config.LangType = {
	['error'] = 'error',
	['success'] = 'success',
	['info'] = 'primary'
}

Config.Lang = {
	['mainMenuHeader'] = 'Invoice Menu',
	['access_invoice'] = 'Review Current Invoices',
	['send_invoice'] = 'Send Invoice',
	['no_invoices'] = 'You do not have any outstanding invoices.', 
	['invoice_header'] = 'Outsanding Invoices', 
	['pay_me'] = "Pay Me!",
	['current_invoice_amount'] = "Invoice for: $",
	['current_invoice_place'] = "From: ",
	['low_money'] = 'You do not have enough cash on you to pay your invoice!',
	['invoice_pay'] = 'You have paid your invoice of $',
	['invoice_pay2'] = 'from ',
	['wrong_job'] = 'You do not have the correct job to do this!', 
	['set_up_invoice_header'] = "New Invoice Request",
	['set_up_invoice_submit'] = "Submit Invoice Details",
	['set_up_invoice'] = "Invoice Amount",
	['set_up_invoice_id'] = "Citizen ID (Server ID)",
	['not_online'] = 'The player is not online!',
	['invoice_received'] = 'You have received an invoice for $',
	['invoice_sent'] = 'You have sent an invoice for $',
}