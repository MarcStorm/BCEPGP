function BCEPGP_LootFrame_Update()
	if BCEPGP_ElvUI then
		local items = GetNumLootItems()
		local itemList = {};
		local count = 0;
		local numSlots = 0;
		if items > 0 then
			numSlots = numSlots + 1;
			for i = 1, items do
				if GetLootSlotLink(i) ~= nil then
					local texture, item, quantity, quality = GetLootSlotInfo(i)
					local itemLink = GetLootSlotLink(i)
					local color = ITEM_QUALITY_COLORS[quality]
					local itemString = string.find(itemLink, "item[%-?%d:]+");
					if item ~= "Badge of Justice" then
						itemList[i-count] = {
							[1] = texture,
							[2] = item,
							[3] = quality,
							[4] = itemLink,
							[5] = itemString,
							[6] = i,
							[7] = quantity
						};
					else
					count = count + 1;
					end
				else
					count = count + 1;
				end
			end
		end
		for i = 1, table.getn(itemList) do
			if (itemList[i][3] > 2 or BCEPGP_inOverride(items[i][2])) and (UnitInRaid("player") or BCEPGP_debugMode) then
				BCEPGP_frame:Show();
				BCEPGP_mode = "loot";
				BCEPGP_toggleFrame("BCEPGP_loot");
				break;
			end
		end
		BCEPGP_populateFrame(_, itemList, numSlots);
	else
		local items = {};
		local count = 0;
		local numLootItems = LootFrame.numLootItems;
		local texture, item, quantity, quality;
		for index = 1, numLootItems do
			local slot = index;
			if ( slot <= numLootItems ) then	
				if (LootSlotIsItem(slot) or LootSlotIsCoin(slot)) then
					texture, item, quantity, quality = GetLootSlotInfo(slot);
					if tostring(GetLootSlotLink(slot)) ~= "nil" and item ~= "Badge of Justice" and (quality > 2 or BCEPGP_inOverride(item)) then
						items[index-count] = {};
						items[index-count][1] = texture;
						items[index-count][2] = item;
						items[index-count][3] = quality;
						items[index-count][4] = GetLootSlotLink(slot);
						local link = GetLootSlotLink(index);
						local itemString = string.find(link, "item[%-?%d:]+");
						itemString = strsub(link, itemString, string.len(link)-string.len(item)-6);
						items[index-count][5] = itemString;
						items[index-count][6] = slot;
						items[index-count][7] = quantity;
					else
						count = count + 1;
					end
				end
			end
		end
		for k, v in pairs(items) do -- k = loot slot number, v is the table result
			if (UnitInRaid("player") or BCEPGP_debugMode) and not BCEPGP_tContains(itemExceptions, v[2]) then
				BCEPGP_frame:Show();
				BCEPGP_mode = "loot";
				BCEPGP_toggleFrame("BCEPGP_loot");
				break;
			end
		end
		BCEPGP_populateFrame(_, items, numLootItems);
	end
end

function BCEPGP_announce(link, x, slotNum, quantity)
	if BCEPGP_isML() == 0 or BCEPGP_debugMode then
		local iString = BCEPGP_getItemString(link);
		local name, _, _, _, _, _, _, _, slot, tex = GetItemInfo(iString);
		local id = BCEPGP_getItemID(iString);
		BCEPGP_itemsTable = {};
		BCEPGP_distItemLink = link;
		BCEPGP_DistID = id;
		BCEPGP_distSlot = slot;
		tex = {bgFile = tex,};
		gp = _G[BCEPGP_mode..'itemGP'..x]:GetText();
		BCEPGP_lootSlot = slotNum;
		BCEPGP_responses = {};
		BCEPGP_UpdateLootScrollBar();
		BCEPGP_SendAddonMsg("RaidAssistLootDist"..link..","..gp.."\\"..UnitName("player"));
		local rank = 0;
		for i = 1, GetNumRaidMembers() do
			if UnitName("player") == GetRaidRosterInfo(i) then
				_, rank = GetRaidRosterInfo(i);
			end
		end
		SendChatMessage("--------------------------", RAID, BCEPGP_LANGUAGE);
		if rank > 0 then
			if quantity > 1 then
				SendChatMessage("NOW DISTRIBUTING: x" .. quantity .. " " .. link, "RAID_WARNING", BCEPGP_LANGUAGE);
			else
				SendChatMessage("NOW DISTRIBUTING: " .. link, "RAID_WARNING", BCEPGP_LANGUAGE);
			end
		else
			if quantity > 1 then
				SendChatMessage("NOW DISTRIBUTING: x" .. quantity .. " " .. link, "RAID", BCEPGP_LANGUAGE);
			else
				SendChatMessage("NOW DISTRIBUTING: " .. link, "RAID", BCEPGP_LANGUAGE);
			end
		end
		if quantity > 1 then
			SendChatMessage("GP Value: " .. gp .. " (~" .. math.floor(gp/quantity) .. "GP per unit)", RAID, BCEPGP_LANGUAGE);
		else
			SendChatMessage("GP Value: " .. gp, RAID, BCEPGP_LANGUAGE);
		end
		SendChatMessage("Whisper me !need for mainspec only", RAID, BCEPGP_LANGUAGE);
		SendChatMessage("--------------------------", RAID, BCEPGP_LANGUAGE);
		BCEPGP_distribute:Show();
		BCEPGP_loot:Hide();
		_G["BCEPGP_distribute_item_name"]:SetText(link);
		_G["BCEPGP_distribute_item_name_frame"]:SetScript('OnClick', function() SetItemRef(iString) end);
		_G["BCEPGP_distribute_item_tex"]:SetBackdrop(tex);
		_G["BCEPGP_distribute_item_tex"]:SetScript('OnEnter', function() GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT") GameTooltip:SetHyperlink(iString) GameTooltip:Show() end);
		_G["BCEPGP_distribute_item_tex"]:SetScript('OnLeave', function() GameTooltip:Hide() end);
		_G["BCEPGP_distribute_GP_value"]:SetText(gp);
		BCEPGP_distributing = true;
	else
		BCEPGP_print("You are not the Loot Master.", 1);
		return;
	end
end