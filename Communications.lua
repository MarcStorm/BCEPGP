function BCEPGP_IncAddonMsg(message, sender)
	if strfind(message, "BCEPGP_distributing") and strfind(message, UnitName("player")) then
		local _, _, _, _, _, _, _, _, slot = GetItemInfo(BCEPGP_DistID);
		if not slot then
			slot = string.sub(message, strfind(message, "~")+1);
		end
		if BCEPGP_DistID then
			if slot then --string.len(slot) > 0 and slot ~= nil then
				local slotName = string.sub(slot, 9);
				local slotid, slotid2 = BCEPGP_SlotNameToID(slotName);
				local currentItem;
				if slotid then
					currentItem = GetInventoryItemLink("player", slotid);
				end
				local currentItem2;
				if slotid2 then
					currentItem2 = GetInventoryItemLink("player", slotid2);
				end
				local itemID;
				local itemID2;
				if currentItem then
					itemID = BCEPGP_getItemID(BCEPGP_getItemString(currentItem));
					itemID2 = BCEPGP_getItemID(BCEPGP_getItemString(currentItem2));
				else
					itemID = "noitem";
				end
				if itemID2 then
					BCEPGP_SendAddonMsg(sender.."-receiving-"..itemID.." "..itemID2);
				else
					BCEPGP_SendAddonMsg(sender.."-receiving-"..itemID);
				end
			elseif slot == "" then
				BCEPGP_SendAddonMsg(sender.."-receiving-noslot");
			elseif itemID == "noitem" then
				BCEPGP_SendAddonMsg(sender.."-receiving-noitem");
			end
		end
		
		
	elseif strfind(message, "receiving") and strfind(message, UnitName("player")) then
		local itemID;
		local itemID2;
		if strfind(message, " ") then
			itemID = string.sub(message, strfind(message, "receiving")+10, strfind(message, " "));
			itemID2 = string.sub(message, strfind(message, " ")+1);
		else
			itemID = string.sub(message, strfind(message, "receiving")+10);
		end
		if itemID == "noitem" then
			BCEPGP_itemsTable[sender] = {};
			BCEPGP_UpdateLootScrollBar();
		elseif itemID == "noslot" then
			BCEPGP_itemsTable[sender] = {};
			BCEPGP_UpdateLootScrollBar();
		else
			local name, iString = GetItemInfo(itemID);
			if itemID2 then
				local name2, iString2 = GetItemInfo(itemID2);
				if name == nil then
					if name2 == nil then
					else
						BCEPGP_itemsTable[sender] = {iString2 .. "[" .. name2 .. "]"};
					end
				else
					BCEPGP_itemsTable[sender] = {iString .. "[" .. name .. "]", iString2 .. "[" .. name2 .. "]"};
				end
			else
				if name == nil then
				else
					BCEPGP_itemsTable[sender] = {iString .. "[" .. name .. "]"};
				end
			end
			BCEPGP_UpdateLootScrollBar();
		end
	elseif strfind(message, UnitName("player").."versioncheck") then
		
		if BCEPGP_vSearch == "GUILD" then
			BCEPGP_groupVersion[sender] = string.sub(message, strfind(message, " ")+1);
		else
			BCEPGP_groupVersion[sender] = string.sub(message, strfind(message, " ")+1);
			BCEPGP_vInfo[sender] = string.sub(message, strfind(message, " ")+1);
		end
		BCEPGP_UpdateVersionScrollBar();
	elseif message == "version-check" then
		BCEPGP_updateGuild();
		if BCEPGP_roster[sender] then
			BCEPGP_SendAddonMsg(sender .. "versioncheck " .. BCEPGP_VERSION, "GUILD");
		else
			BCEPGP_SendAddonMsg(sender .. "versioncheck " .. BCEPGP_VERSION, "RAID");
		end
	elseif strfind(message, "version") then
		local s1, s2, s3, s4 = BCEPGP_strSplit(message, "-");
		if s1 == "update" then
			BCEPGP_updateGuild();
		elseif s1 == "version" then
			local ver2 = string.gsub(BCEPGP_VERSION, "%.", ",");
			local v1, v2, v3 = BCEPGP_strSplit(ver2..",", ",");
			local nv1, nv2, nv3 = BCEPGP_strSplit(s2, ",");
			local s5 = (nv1.."."..nv2.."."..nv3)
			outMessage = "Your addon is out of date. Version " .. s5 .. " is now available for download at https://github.com/Alumian/BCEPGP"
			if not BCEPGP_VERSION_NOTIFIED then
				BCEPGP_VERSION_NOTIFIED = true;
				if v1 > v1 then
					BCEPGP_print(outMessage);
				elseif nv1 == v1 and nv2 > v2 then
					BCEPGP_print(outMessage);
				elseif nv1 == v1 and nv2 == v2 and nv3 > v3 then
					BCEPGP_print(outMessage);
				end
			end
		end
	elseif strfind(message, "RaidAssistLoot") and sender ~= UnitName("player") then
		if strfind(message, "RaidAssistLootDist") then
			local link = string.sub(message, 19, strfind(message, ",")-1);
			local gp = string.sub(message, strfind(message, ",")+1, strfind(message, "\\")-1);
			BCEPGP_RaidAssistLootDist(link, gp);
		else
			BCEPGP_RaidAssistLootClosed();
		end
		
		
	elseif strfind(message, "!need") and sender ~= UnitName("player") then-- and IsRaidOfficer()  then
		local arg2 = string.sub(message, strfind(message, ",")+1, strfind(message, "`")-1);
		table.insert(BCEPGP_responses, arg2);
		local slot = nil;
		BCEPGP_DistID = string.sub(message, 7+string.len(UnitName("player"))+1, string.len(message));
		if BCEPGP_DistID then
			_, _, _, _, _, _, _, _, slot = GetItemInfo(BCEPGP_DistID);
		end
		BCEPGP_updateGuild();
		if slot then
			BCEPGP_SendAddonMsg(arg2.."-BCEPGP_distributing-"..BCEPGP_DistID.."~"..slot);
		else
			BCEPGP_SendAddonMsg(arg2.."-BCEPGP_distributing-nil~nil");
		end
	elseif strfind(message, "STANDBYEP"..UnitName("player")) then
		BCEPGP_print(string.sub(message, strfind(message, ",")+1));
	elseif strfind(message, "!info"..UnitName("player")) then
		BCEPGP_print(string.sub(message, 5+string.len(UnitName("player"))+1));
	elseif message == UnitName("player").."-import" then
		local lane;
		if BCEPGP_raidRoster[arg4] then
			lane = "RAID";
		elseif BCEPGP_roster[arg4] then
			lane = "GUILD";
		end
		BCEPGP_SendAddonMsg(arg4.."-impresponse!CHANNEL~"..CHANNEL, lane);
		BCEPGP_SendAddonMsg(arg4.."-impresponse!MOD~"..MOD, lane);
		BCEPGP_SendAddonMsg(arg4.."-impresponse!COEF~"..COEF, lane);
		BCEPGP_SendAddonMsg(arg4.."-impresponse!BASEGP~"..BASEGP, lane);
		BCEPGP_SendAddonMsg(arg4.."-impresponse!WHISPERMSG~"..BCEPGP_standby_whisper_msg, lane);
		if STANDBYEP then
			BCEPGP_SendAddonMsg(arg4.."-impresponse!STANDBYEP~1", lane);
		else
			BCEPGP_SendAddonMsg(arg4.."-impresponse!STANDBYEP~0", lane);
		end
		if STANDBYOFFLINE then
			BCEPGP_SendAddonMsg(arg4.."-impresponse!STANDBYOFFLINE~1", lane);
		else
			BCEPGP_SendAddonMsg(arg4.."-impresponse!STANDBYOFFLINE~0", lane);
		end
		BCEPGP_SendAddonMsg(arg4.."-impresponse!STANDBYPERCENT~"..STANDBYPERCENT, lane);
		for k, v in pairs(SLOTWEIGHTS) do
			BCEPGP_SendAddonMsg(arg4.."-impresponse!SLOTWEIGHTS~"..k.."?"..v, lane);
		end
		if BCEPGP_standby_byrank then --Implies result for both byrank and manual standby designation
			BCEPGP_SendAddonMsg(arg4.."-impresponse!STANDBYBYRANK~1", lane);
		else
			BCEPGP_SendAddonMsg(arg4.."-impresponse!STANDBYBYRANK~0", lane);
		end
		if BCEPGP_standby_accept_whispers then
			BCEPGP_SendAddonMsg(arg4.."-impresponse!STANDBYALLOWWHISPERS~1", lane);
		else
			BCEPGP_SendAddonMsg(arg4.."-impresponse!STANDBYALLOWWHISPERS~0", lane);
		end
		for k, v in pairs(STANDBYRANKS) do
			if STANDBYRANKS[k][2] then
				BCEPGP_SendAddonMsg(arg4.."-impresponse!STANDBYRANKS~"..k.."?1", lane);
			else
				BCEPGP_SendAddonMsg(arg4.."-impresponse!STANDBYRANKS~"..k.."?0", lane);
			end
		end
		for k, v in pairs(EPVALS) do
			BCEPGP_SendAddonMsg(arg4.."-impresponse!EPVALS~"..k.."?"..v, lane);
		end
		for k, v in pairs(AUTOEP) do
			if AUTOEP[k] then
				BCEPGP_SendAddonMsg(arg4.."-impresponse!AUTOEP~"..k.."?1", lane);
			else
				BCEPGP_SendAddonMsg(arg4.."-impresponse!AUTOEP~"..k.."?0", lane);
			end
		end
		for k, v in pairs(OVERRIDE_INDEX) do
			BCEPGP_SendAddonMsg(arg4.."-impresponse!OVERRIDE~"..k.."?"..v, lane);
		end
		BCEPGP_SendAddonMsg(arg4.."-impresponse!COMPLETE~", lane);
		
	elseif strfind(message, UnitName("player")) and strfind(message, "-impresponse!") then
		local option = string.sub(message, strfind(message, "!")+1, strfind(message, "~")-1);
		
		if option == "SLOTWEIGHTS" or option == "STANDBYRANKS" or option == "EPVALS" or option == "AUTOEP" or option == "OVERRIDE" then
			local field = string.sub(message, strfind(message, "~")+1, strfind(message, "?")-1);
			local val = string.sub(message, strfind(message, "?")+1);
			if option == "SLOTWEIGHTS" then
				SLOTWEIGHTS[field] = tonumber(val);
			elseif option == "STANDBYRANKS" then
				if val == "1" then
					STANDBYRANKS[tonumber(field)][2] = true;
				else
					STANDBYRANKS[tonumber(field)][2] = false;
				end
			elseif option == "EPVALS" then
				EPVALS[field] = tonumber(val);
			elseif option == "AUTOEP" then
				if val == "1" then
					AUTOEP[field] = true;
				else
					AUTOEP[field] = false;
				end
			elseif option == "OVERRIDE" then
				OVERRIDE_INDEX[field] = val;
			end
		else
			local val = string.sub(message, strfind(message, "~")+1);
			if option == "CHANNEL" then
				CHANNEL = val;
			elseif option == "MOD" then
				MOD = tonumber(val);
			elseif option == "COEF" then
				COEF = tonumber(val);
			elseif option == "BASEGP" then
				BASEGP = tonumber(val);
			elseif option == "STANDBYBYRANK" then
				if val == "1" then
					BCEPGP_standby_byrank = true;
					BCEPGP_standby_manual = false;
				else
					BCEPGP_standby_byrank = false;
					BCEPGP_standby_manual = true;
				end
			elseif option == "STANDBYALLOWWHISPERS" then
				if val == "1" then
					BCEPGP_standby_accept_whispers = true;
					BCEPGP_options_standby_ep_accept_whispers_check:SetChecked(true);
				else
					BCEPGP_standby_accept_whispers = false;
					BCEPGP_options_standby_ep_accept_whispers_check:SetChecked(false);
				end
			elseif option == "WHISPERMSG" then
				BCEPGP_standby_whisper_msg = val;
				BCEPGP_options_standby_ep_message_val:SetText(val);
			elseif option == "STANDBYEP" then
				if tonumber(val) == 1 then
					STANDBYEP = true;
				else
					STANDBYEP = false;
				end
			elseif option == "STANDBYOFFLINE" then
				if tonumber(val) == 1 then
					STANDBYOFFLINE = true;
				else
					STANDBYOFFLINE = false;
				end
			elseif option == "STANDBYPERCENT" then
				STANDBYPERCENT = tonumber(val);		
			elseif option == "COMPLETE" then
				BCEPGP_UpdateOverrideScrollBar();
				BCEPGP_print("Import complete");
				BCEPGP_button_options:OnClick();
			end
		end
		
		BCEPGP_button_options:OnClick();
		
	
	elseif strfind(message, "BCEPGP_TRAFFIC") then
		if sender == UnitName("player") then return; end
		local player = string.sub(message, 21, strfind(message, "ACTION")-1);
		local action = string.sub(message, strfind(message, "ACTION")+6, strfind(message, "EPB")-1);
		local EPB = string.sub(message, strfind(message, "EPB")+3, strfind(message, "EPA")-1);
		local EPA = string.sub(message, strfind(message, "EPA")+3, strfind(message, "GPB")-1);
		local GPB = string.sub(message, strfind(message, "GPB")+3, strfind(message, "GPA")-1);
		local GPA = string.sub(message, strfind(message, "GPA")+3, strfind(message, "ITEMID")-1);
		local itemID = string.sub(message, strfind(message, "ITEMID")+6);
		local itemLink = BCEPGP_getItemLink(itemID);
		TRAFFIC[BCEPGP_ntgetn(TRAFFIC)+1] = {
			[1] = player,
			[2] = action,
			[3] = EPB,
			[4] = EPA,
			[5] = GPB,
			[6] = GPA,
			[7] = itemLink
		};
		BCEPGP_UpdateTrafficScrollBar();
	end
end

function BCEPGP_SendAddonMsg(message, channel)
	if channel ~= nil then
		SendAddonMessage("BCEPGP", message, string.upper(channel));
	else
		SendAddonMessage("BCEPGP", message, "RAID");
	end
end

function BCEPGP_ShareTraffic(player, action, EPB, EPA, GPB, GPA, itemID)
	if not player or not action then return; end
	if not itemID then
		itemID = "";
	end
	if not EPB then
		EPB = "";
	end
	if not EPA then
		EPA = "";
	end
	if not GPB then
		GPB = "";
	end
	if not GPA then
		GPA = "";
	end
	if CanEditOfficerNote() then
		BCEPGP_SendAddonMsg("BCEPGP_TRAFFIC-PLAYER" .. player .. "ACTION" .. action .. "EPB" .. EPB .. "EPA" .. EPA .. "GPB" .. GPB .. "GPA" .. GPA .. "ITEMID" .. itemID, "GUILD");
	end
end