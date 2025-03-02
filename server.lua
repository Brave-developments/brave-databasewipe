local Core=nil
local ESX=nil
if Config.Framework=="qbcore" then
	Core=exports['qb-core']:GetCoreObject()
elseif Config.Framework=="esx" then
	ESX=exports['es_extended']:getSharedObject()
elseif Config.Framework=="ox" then
	Core=exports['ox_core']:GetCoreObject()
else
	print("Invalid framework configuration.")
	return
end
if Config.Framework=="qbcore" then
	Core.Commands.Add(Config.CleanCommand,Config.CleanCommandInfo,{},false,function(source,args)
		if source~=0 then
			local ply=Core.Functions.GetPlayer(source)
			if ply then TriggerClientEvent('QBCore:Notify',source,"This command is for the console only.",'error') end
			return
		end
		ClearDatabase()
	end)
elseif Config.Framework=="esx" then
	RegisterCommand(Config.CleanCommand,function(source,args)
		if source~=0 then
			local ply=ESX.GetPlayerFromId(source)
			if ply then TriggerClientEvent('esx:showNotification',source,"This command is for the console only.") end
			return
		end
		ClearDatabase()
	end,false)
elseif Config.Framework=="ox" then
	Core.Commands.Add(Config.CleanCommand,Config.CleanCommandInfo,{},false,function(source,args)
		if source~=0 then
			local ply=Core.Functions.GetPlayer(source)
			if ply then TriggerClientEvent('ox:notify',source,"This command is for the console only.") end
			return
		end
		ClearDatabase()
	end)
else
	print("Invalid framework specified in the configuration.")
	return
end
function ClearDatabase()
	local totalRowsDeleted=0
	local deletionDetails=""
	local processedTables=0
	local totalTables=#Config.TablesToWipe
	local dbLibrary=nil
	if Config.DatabaseLibrary=="oxmysql" then
		dbLibrary=exports.oxmysql
	elseif Config.DatabaseLibrary=="ghatmysql" then
		dbLibrary=exports.ghatmysql
	else
		print("Invalid MySQL library specified.")
		return
	end
	for _,tbl in ipairs(Config.TablesToWipe) do
		local sql='DELETE FROM `'..tbl..'`'
		print("Executing query for table: "..tbl)
		local queryFinished=false
		local timer=SetTimeout(5000,function()
			if not queryFinished then
				print("Query for table "..tbl.." timed out.")
				processedTables=processedTables+1
				if processedTables==totalTables then
					print("All deletion callbacks processed. Initiating webhook dispatch.")
					DispatchWebhook(totalRowsDeleted,deletionDetails,function()
						print("Webhook dispatched. Now clearing players.")
						TriggerEvent('Maintenance:clearPlayers')
					end)
				end
			end
		end)
		local success,err=pcall(function()
			dbLibrary:execute(sql,{},function(affectedRows)
				queryFinished=true
				if timer then ClearTimeout(timer) end
				if affectedRows then
					if type(affectedRows)=="number" then
						totalRowsDeleted=totalRowsDeleted+affectedRows
						deletionDetails=deletionDetails..string.format("%s: %d row(s) deleted\n",tbl,affectedRows)
					elseif type(affectedRows)=="table" then
						local count=#affectedRows
						totalRowsDeleted=totalRowsDeleted+count
						deletionDetails=deletionDetails..string.format("%s: %d row(s) deleted\n",tbl,count)
					end
				else
					print("No affected rows returned for table "..tbl)
				end
				processedTables=processedTables+1
				print(string.format("Processed %d/%d for table: %s",processedTables,totalTables,tbl))
				if processedTables==totalTables then
					print("All deletion callbacks processed. Initiating webhook dispatch.")
					DispatchWebhook(totalRowsDeleted,deletionDetails,function()
						print("Webhook dispatched. Now clearing players.")
						TriggerEvent('Maintenance:clearPlayers')
					end)
				end
			end)
		end)
		if not success then
			print("Immediate error executing query for table: "..tbl.." Error: "..tostring(err))
			processedTables=processedTables+1
			if processedTables==totalTables then
				print("All deletion callbacks processed. Initiating webhook dispatch.")
				DispatchWebhook(totalRowsDeleted,deletionDetails,function()
					print("Webhook dispatched. Now clearing players.")
					TriggerEvent('Maintenance:clearPlayers')
				end)
			end
		end
	end
end
function DispatchWebhook(totalRows,details,cb)
	local message=string.format(Config.WebhookMessageTemplate,totalRows,details)
	print("Sending webhook with message:")
	print(message)
	PerformHttpRequest(Config.WebhookURL,function(statusCode,responseText,headers)
		if statusCode==200 then
			print("Webhook sent successfully.")
		else
			print("Webhook failed with status: "..tostring(statusCode))
		end
		if cb then cb() end
	end,'POST',json.encode({username=Config.WebhookUsername,avatar_url=Config.WebhookAvatar,content=message,embeds={}}),{['Content-Type']='application/json'})
end
RegisterNetEvent('Maintenance:clearPlayers',function()
	local players=GetPlayers()
	for _,playerId in ipairs(players) do DropPlayer(playerId,Config.KickMessage) end
	SetTimeout(6000,function() StopResource(GetCurrentResourceName()) end)
end)
