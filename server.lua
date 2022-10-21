QBCore = nil
TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

QBCore.Functions.CreateUseableItem("huntingknife", function(source, item)
    TriggerClientEvent("snr-hunting:use-item", source, "huntingknife")
end)

RegisterNetEvent("snr-hunting:giveItem")
AddEventHandler("snr-hunting:giveItem", function(key)
    local src = source
    if QBCore.Functions.kickHacKer(src, key) then -- QBCore.Key
        local xPlayer = QBCore.Functions.GetPlayer(src)
        local quality = math.random(1,5)
        local info = {
            type = "et",
            quality = quality
        }
        xPlayer.Functions.AddItem("geyiketi", 1, nil, info)
        xPlayer.Functions.AddItem("geyikderisi", 1, nil, info)
    end
end)

QBCore.Commands.Add("hayvansil", "AVCILIK HAYVANLARINI SİLER", {{name="text", help="Tekst enzo"}}, false, function(source, args)
    TriggerClientEvent("snr-hunting:hayvantemizle", source)
end, "god")


--============================== NPC SİDE ==============================--
local DISCORDS_NAME = "SNR DEVELOPMENT"
local DISCORDS_IMAGE = ""

RegisterServerEvent('soner:toptanci:item:hunting')
AddEventHandler('soner:toptanci:item:hunting', function(item, miktar)
    local xPlayer = QBCore.Functions.GetPlayer(source)

    for k,v in pairs(Config.Detaylar[item].GerekliItemler) do
        if xPlayer.Functions.GetItemByName(v.Esya).amount >= miktar then
            paramiktar = Config.Detaylar[item].VerilenEsya.Miktar * miktar
			temizyarrak = Config.Detaylar[item].VerilenEsya.TemizParaMiktar * miktar
			xPlayer.Functions.RemoveItem(v.Esya, miktar)
			--xPlayer.Functions.AddItem('ipara', paramiktar)
			xPlayer.Functions.AddMoney('cash', temizyarrak)
			TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['cash'],'add', paramiktar)
			TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[v.Esya],'remove', miktar)

            sendToDiscord("HUNTİNG - Satış", " **"..getPlayerInfo(source).."** kişisi toptancıya **".. miktar .. "x " ..item .."** sattı, **" .. paramiktar .. "$** kazandı.", 16744576, Config.NPCLOGwebhook)
			TriggerClientEvent("QBCore:Notify", source, ''.. miktar ..'x '.. item .. ' sattın, ' .. paramiktar .. '$ kazandın.', "success")
        else
			TriggerClientEvent("QBCore:Notify", source, 'Üzerinizde '..miktar..'x ' ..item..' yok!', "error")
        end
    end
end)

function sendToDiscord(name, message, color, selam)
	local connect = {
		  {
			  ["color"] = color,
			  ["title"] = "**".. name .."**",
			  ["description"] = message,
			  ["footer"] = {
			  ["text"] = os.date('!%Y-%m-%d - %H:%M:%S') .. " - SNR DEVELOPMENT",
			  },
		  }
	  }
	PerformHttpRequest(selam, function(err, text, headers) end, 'POST', json.encode({username = DISCORDS_NAME, embeds = connect, avatar_url = DISCORDS_IMAGE}), { ['Content-Type'] = 'application/json' })
end

function getPlayerInfo(player)
	local _player = player
	local infoString = GetPlayerName(_player) .. " (" .. _player .. ")"
	-- if Config.BilgileriPaylas then
		for k,v in pairs(GetPlayerIdentifiers(_player)) do
			if string.sub(v, 1, string.len("discord:")) == "discord:" then
				infoString = infoString .. "\n<@" .. string.gsub(v,"discord:","") .. ">"
			else
				infoString = infoString .. "\n" .. v
			end
		end
	-- end
	return infoString
end