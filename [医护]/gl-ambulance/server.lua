ESX = nil

    local export, ESX = pcall(function()
        return exports['es_extended']:getSharedObject()
    end)

    if not export then
        TriggerEvent("esx:getSharedObject", function(obj)
            ESX = obj
        end)
    end


local lastResponder = 0

TriggerEvent('esx_society:registerSociety', 'ambulance', 'Ambulance', 'society_ambulance', 'society_ambulance', 'society_ambulance', {type = 'public'})


RegisterServerEvent('gl-ambulance:getItemForEMS',function(item)
	local xPlayer = ESX.GetPlayerFromId(source)
	local count = xPlayer.getInventoryItem(item).count

	if count < 1 then 
		xPlayer.addInventoryItem(item,1)
	end
end)

RegisterServerEvent('gl-ambulance:treatPlayerWounds',function(player,wound)
	local player = ESX.GetPlayerFromId(player).source
		TriggerClientEvent('gl-ambulance:treatAnimations',player,wound)
		TriggerClientEvent('gl-ambulance:treatTargetWound',source,wound)
		if wound == 'bullet' then
			local xPlayer = ESX.GetPlayerFromId(player)
			xPlayer.addInventoryItem('recoveredbullet',1)
		end
end)

RegisterServerEvent('gl-ambulance:checkPlayerWounds',function(target,wound)
	local player = ESX.GetPlayerFromId(source).source
	local targetPlayer = ESX.GetPlayerFromId(target).source

	TriggerClientEvent('gl-ambulance:checkPlayerWounds',targetPlayer,player,wound)

end)

RegisterServerEvent('gl-ambulance:revivePlayer',function(target)
TriggerClientEvent('gl-ambulance:revivePlayer',target)
end)


RegisterServerEvent('gl-ambulance:deleteBag', function(netId)
    TriggerClientEvent("gl-ambulance:deleteBag", -1, netId)
end)

RegisterServerEvent('gl-ambulance:delStretcher', function(netId)
    TriggerClientEvent("gl-ambulance:delStretcher", -1, netId)
end)


RegisterServerEvent('gl-ambulance:goNightNight',function(player)
	local player = ESX.GetPlayerFromId(player).source
	TriggerClientEvent('gl-ambulance:goNightNight',player)
end)

RegisterServerEvent('gl-ambulance:putInVehicle',function(target,vehicle)

	TriggerClientEvent('gl-ambulance:putInVehicle', target,vehicle)
end)

RegisterServerEvent('gl-ambulance:getOutVehicle',function(target)
	TriggerClientEvent('gl-ambulance:getOutVehicle', target)
end)

RegisterServerEvent('gl-ambulance:putOnStretcher',function(target)
	TriggerClientEvent('gl-ambulance:putOnStretcher', target)
end)

RegisterServerEvent('gl-ambulance:bodyBag',function(target)
	TriggerClientEvent('gl-ambulance:bodyBag', target)
end)

RegisterServerEvent('gl-ambulance:checkPulse',function(target)

	TriggerClientEvent('gl-ambulance:sendPulseBack',target,source)
end)

RegisterServerEvent('gl-ambulance:reportPulseBack',function(target,pulse,status)
	TriggerClientEvent("swt_notifications:caption",target,status,"Pulse: " .. pulse,'top',15000,'blue-10','grey-1',true)
end)

RegisterServerEvent('gl-ambulance:removeDefib',function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('defib',1)
end)

RegisterServerEvent('gl-ambulance:removeDeathItems',function()
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerEvent('linden_inventory:clearPlayerInventory', xPlayer)


--[[	
	if xPlayer.getMoney() > 0 then
		xPlayer.removeMoney(xPlayer.getMoney())
	end
	if xPlayer.getAccount('black_money').money > 0 then
		xPlayer.setAccountMoney('black_money', 0)
	end
	]]


end)


RegisterServerEvent('gl-ambulance:send911',function(message,pedID, coords)
	lastResponder = pedID
	TriggerClientEvent('gl-ambulance:receive911',-1,message,coords)
end)


RegisterServerEvent('gl-ambulance:911r', function(message)
	if message ~= nil then
		TriggerClientEvent("swt_notifications:default",lastResponder,"Emergency Responder: " .. message ,'top','red','white',15000,true)
	end
end)

-- Callbacks


ESX.RegisterServerCallback("gl-ambulance:getEMSCount", function(source, cb)
	local ambulanceCount = 0
	local xPlayers = ESX.GetExtendedPlayers('job', 'ambulance')
	for _, xPlayer in pairs(xPlayers) do
		ambulanceCount = ambulanceCount + 1
	end
    cb(ambulanceCount)
end)

-- 可用物品注册下面都是
ESX.RegisterUsableItem('tweezers',function(source)
	TriggerClientEvent('gl-ambulance:tryTreatingPlayer',source,'bullet')
end)


ESX.RegisterUsableItem('suturekit',function(source)
	TriggerClientEvent('gl-ambulance:tryTreatingPlayer',source,'stitch')
end)

ESX.RegisterUsableItem('burncream',function(source)
	TriggerClientEvent('gl-ambulance:tryTreatingPlayer',source,'burn')
end)

ESX.RegisterUsableItem('defib',function(source)
	TriggerClientEvent('gl-ambulance:tryRevivePlayer',source)
end)

ESX.RegisterUsableItem('medbag',function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('medbag',1)
	TriggerClientEvent('gl-ambulance:useMedBag',source)
end)

ESX.RegisterUsableItem('sedative',function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('sedative',1)
	TriggerClientEvent('gl-ambulance:useSedative',source)
end)

ESX.RegisterUsableItem('stretcher',function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('stretcher',1)
	TriggerClientEvent('gl-ambulance:useStretcher',source)
end)

ESX.RegisterUsableItem('wheelchair',function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('gl-ambulance:useWheelChair',source)
end)

ESX.RegisterUsableItem('medikit', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('medikit', 1)
end)

ESX.RegisterUsableItem('bandage', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('bandage', 1)
end)
--到这里
-- 命令注册

ESX.RegisterCommand('revive', 'admin', function(source, args)
	args = table.concat(args, ' ')
	TriggerClientEvent('gl-ambulance:revivePlayer',args)
end, true)


ESX.RegisterCommand('heal', 'admin', function(source, args)
	args = table.concat(args, ' ')
	TriggerClientEvent('gl-ambulance:adminHeal',args)
end, true)


