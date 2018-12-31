function BCEPGP_initialise()
	_, _, _, BCEPGP_ElvUI = GetAddOnInfo("ElvUI");
	getglobal("BCEPGP_version_number"):SetText("Running Version: " .. BCEPGP_VERSION);
	local ver2 = string.gsub(BCEPGP_VERSION, "%.", ",");
	if CHANNEL == nil then
		CHANNEL = "GUILD";
	end
	if MOD == nil then
		MOD = 1;
	end
	if COEF == nil then
		COEF = 0.483;
	end
	if BASEGP == nil then
		BASEGP = 1;
	end
	if BCEPGP_ntgetn(AUTOEP) == 0 then
		for k, v in pairs(bossNameIndex) do
			AUTOEP[k] = true;
		end
	end
	if BCEPGP_ntgetn(EPVALS) == 0 then
		for k, v in pairs(bossNameIndex) do
			EPVALS[k] = v;
		end
	end
	if BCEPGP_ntgetn(SLOTWEIGHTS) == 0 then
		SLOTWEIGHTS = {
			["2HWEAPON"] = 2,
			["WEAPONMAINHAND"] = 1.5,
			["WEAPON"] = 1.5,
			["WEAPONOFFHAND"] = 0.5,
			["HOLDABLE"] = 0.5,
			["SHIELD"] = 0.5,
			["RANGED"] = 0.5,
			["RANGEDRIGHT"] = 0.5,
			["THROWN"] = 0.5,
			["RELIC"] = 0.5,
			["HEAD"] = 1,
			["NECK"] = 0.5,
			["SHOULDER"] = 0.75,
			["CLOAK"] = 0.5,
			["CHEST"] = 1,
			["ROBE"] = 1,
			["WRIST"] = 0.5,
			["HAND"] = 0.75,
			["WAIST"] = 0.75,
			["LEGS"] = 1,
			["FEET"] = 0.75,
			["FINGER"] = 0.5,
			["TRINKET"] = 0.75,
			["EXCEPTION"] = 1
		}
	end
	if STANDBYPERCENT ==  nil then
		STANDBYPERCENT = 0;
	end
	if BCEPGP_ntgetn(STANDBYRANKS) == 0 then
		for i = 1, 10 do
			STANDBYRANKS[i] = {};
			STANDBYRANKS[i][1] = GuildControlGetRankName(i);
			STANDBYRANKS[i][2] = false;
		end
	end
	if UnitInRaid("player") then
		for i = 1, GetNumRaidMembers() do
			name = GetRaidRosterInfo(i);
			BCEPGP_raidRoster[name] = name;
		end 
	end
	
	tinsert(UISpecialFrames, "BCEPGP_frame");
	tinsert(UISpecialFrames, "BCEPGP_context_popup");
	tinsert(UISpecialFrames, "BCEPGP_save_guild_logs");
	tinsert(UISpecialFrames, "BCEPGP_restore_guild_logs");
	tinsert(UISpecialFrames, "BCEPGP_settings_import");
	tinsert(UISpecialFrames, "BCEPGP_override");
	tinsert(UISpecialFrames, "BCEPGP_traffic");
	
	BCEPGP_SendAddonMsg("version-check");
	DEFAULT_CHAT_FRAME:AddMessage("|c00FFC100Burning Crusade EPGP Version: " .. BCEPGP_VERSION .. " Loaded|r");
	DEFAULT_CHAT_FRAME:AddMessage("|c00FFC100BCEPGP: Currently reporting to channel - " .. CHANNEL .. "|r");
	
end

function BCEPGP_calcGP(link, quantity, id)
	local name, rarity, ilvl, iType, subType, slot;
	if id then
		name, _, rarity, ilvl, _, iType, subType, _, slot = GetItemInfo(id);
	else
		name, _, rarity, ilvl, _, iType, subType, _, slot = GetItemInfo(link);
	end
	if not ilvl then return 0; end;
	if tokenItemLevels[name] then
		ilvl = tokenItemLevels[name];
	end
	name = string.gsub(string.gsub(string.lower(name), " ", ""), "'", "");
	for k, v in pairs(OVERRIDE_INDEX) do
		if name == string.gsub(string.gsub(string.lower(k), " ", ""), "'", "") then
			return OVERRIDE_INDEX[k];
		end
	end
	--[[if OVERRIDE_INDEX[name] then
		return OVERRIDE_INDEX[name];
	end]]
	if slot == "" or slot == nil then
		if strfind(name, "bootsof") then
			slot = "INVTYPE_FEET";
		elseif strfind(name, "beltof") then
			slot = "INVTYPE_WAIST";
		elseif strfind(name, "helmof") then
			slot = "INVTYPE_HEAD";
		elseif strfind(name, "bracersof") then
			slot = "INVTYPE_WRIST";
		elseif strfind(name, "glovesof") then
			slot = "INVTYPE_HAND";
		elseif strfind(name, "chestguardof") then
			slot = "INVTYPE_CHEST";
		else
			slot = "INVTYPE_EXCEPTION";
		end;
	end
	if BCEPGP_debugMode then
		local quality = rarity == 0 and "Poor" or rarity == 1 and "Common" or rarity == 2 and "Uncommon" or rarity == 3 and "Rare" or rarity == 4 and "Epic" or "Legendary";
		BCEPGP_print("Name: " .. name);
		BCEPGP_print("Rarity: " .. quality);
		BCEPGP_print("Item Type: " .. iType);
		BCEPGP_print("Subtype: " .. subType);
		BCEPGP_print("Slot: " .. slot);
	end
	slot = strsub(slot,strfind(slot,"INVTYPE_")+8,string.len(slot));
	slot = SLOTWEIGHTS[slot];
	if ilvl and rarity and slot then
		return (math.floor((COEF * (2^((ilvl/26) + (rarity-4))) * slot)*MOD)*quantity);
	else
		return 0;
	end
end

function BCEPGP_populateFrame(BCEPGP_criteria, items, lootNum)
	local sorting = nil;
	local subframe = nil;
	if BCEPGP_criteria == "name" or BCEPGP_criteria == "rank" then
		SortGuildRoster(BCEPGP_criteria);
	elseif BCEPGP_criteria == "group" or BCEPGP_criteria == "EP" or BCEPGP_criteria == "GP" or BCEPGP_criteria == "PR" then
		sorting = BCEPGP_criteria;
	else
		sorting = "group";
	end
	if BCEPGP_mode == "loot" then
		BCEPGP_cleanTable();
	elseif BCEPGP_mode ~= "loot" then
		BCEPGP_cleanTable();
	end
	local tempItems = {};
	local total;
	if BCEPGP_mode == "guild" then
		BCEPGP_UpdateGuildScrollBar();
	elseif BCEPGP_mode == "raid" then
		BCEPGP_UpdateRaidScrollBar();
	elseif BCEPGP_mode == "loot" then
		subframe = BCEPGP_loot;
		local count = 0;
		if not items then
			total = 0;
		else
			local i = 1;
			local nils = 0;
			for index,value in pairs(items) do 
				tempItems[i] = value;
				i = i + 1;
				count = count + 1;
			end
		end
		total = count;
	end
	if BCEPGP_mode == "loot" then 
		for i = 1, total do
			local texture, name, quality, gp, colour, iString, link, slot, x, quantity;
			x = i;
			texture = tempItems[i][1];
			name = tempItems[i][2];
			colour = ITEM_QUALITY_COLORS[tempItems[i][3]];
			link = tempItems[i][4];
			iString = tempItems[i][5];
			slot = tempItems[i][6];
			quantity = tempItems[i][7];
			gp = BCEPGP_calcGP(link, quantity);
			backdrop = {bgFile = texture,};
			if _G[BCEPGP_mode..'item'..i] ~= nil then
				_G[BCEPGP_mode..'announce'..i]:Show();
				_G[BCEPGP_mode..'announce'..i]:SetWidth(20);
				_G[BCEPGP_mode..'announce'..i]:SetScript('OnClick', function() BCEPGP_announce(link, x, slot, quantity) BCEPGP_distribute:SetID(this:GetID()) end);
				_G[BCEPGP_mode..'announce'..i]:SetID(slot);
				
				_G[BCEPGP_mode..'tex'..i]:Show();
				_G[BCEPGP_mode..'tex'..i]:SetBackdrop(backdrop);
				_G[BCEPGP_mode..'tex'..i]:SetScript('OnEnter', function() GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT") GameTooltip:SetHyperlink(link) GameTooltip:Show() end);
				_G[BCEPGP_mode..'tex'..i]:SetScript('OnLeave', function() GameTooltip:Hide() end);
				
				_G[BCEPGP_mode..'item'..i]:Show();
				_G[BCEPGP_mode..'item'..i].text:SetText(link);
				_G[BCEPGP_mode..'item'..i].text:SetTextColor(colour.r, colour.g, colour.b);
				_G[BCEPGP_mode..'item'..i].text:SetPoint('CENTER',_G[BCEPGP_mode..'item'..i]);
				_G[BCEPGP_mode..'item'..i]:SetWidth(_G[BCEPGP_mode..'item'..i].text:GetStringWidth());
				_G[BCEPGP_mode..'item'..i]:SetScript('OnClick', function() SetItemRef(iString) end);
				
				_G[BCEPGP_mode..'itemGP'..i]:SetText(gp);
				_G[BCEPGP_mode..'itemGP'..i]:SetTextColor(colour.r, colour.g, colour.b);
				_G[BCEPGP_mode..'itemGP'..i]:SetWidth(35);
				_G[BCEPGP_mode..'itemGP'..i]:SetScript('OnEnterPressed', function() this:ClearFocus() end);
				_G[BCEPGP_mode..'itemGP'..i]:SetAutoFocus(false);
				_G[BCEPGP_mode..'itemGP'..i]:Show();
			else
				subframe.announce = CreateFrame('Button', BCEPGP_mode..'announce'..i, subframe, 'UIPanelButtonTemplate');
				subframe.announce:SetHeight(20);
				subframe.announce:SetWidth(20);
				subframe.announce:SetScript('OnClick', function() BCEPGP_announce(link, x, slot, quantity) BCEPGP_distribute:SetID(this:GetID()); end);
				subframe.announce:SetID(slot);
	
				subframe.tex = CreateFrame('Button', BCEPGP_mode..'tex'..i, subframe);
				subframe.tex:SetHeight(20);
				subframe.tex:SetWidth(20);
				subframe.tex:SetBackdrop(backdrop);
				subframe.tex:SetScript('OnEnter', function() GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT") GameTooltip:SetHyperlink(link) GameTooltip:Show() end);
				subframe.tex:SetScript('OnLeave', function() GameTooltip:Hide() end);
				
				subframe.itemName = CreateFrame('Button', BCEPGP_mode..'item'..i, subframe);
				subframe.itemName:SetHeight(20);
				
				subframe.itemGP = CreateFrame('EditBox', BCEPGP_mode..'itemGP'..i, subframe, 'InputBoxTemplate');
				subframe.itemGP:SetHeight(20);
				subframe.itemGP:SetWidth(35);
				
				if i == 1 then
					subframe.announce:SetPoint('CENTER', _G['BCEPGP_'..BCEPGP_mode..'_announce'], 'BOTTOM', -10, -20);
					subframe.tex:SetPoint('LEFT', _G[BCEPGP_mode..'announce'..i], 'RIGHT', 10, 0);
					subframe.itemName:SetPoint('LEFT', _G[BCEPGP_mode..'tex'..i], 'RIGHT', 10, 0);
					subframe.itemGP:SetPoint('CENTER', _G['BCEPGP_'..BCEPGP_mode..'_GP'], 'BOTTOM', 10, -20);
				else
					subframe.announce:SetPoint('CENTER', _G[BCEPGP_mode..'announce'..(i-1)], 'BOTTOM', 0, -20);
					subframe.tex:SetPoint('LEFT', _G[BCEPGP_mode..'announce'..i], 'RIGHT', 10, 0);
					subframe.itemName:SetPoint('LEFT', _G[BCEPGP_mode..'tex'..i], 'RIGHT', 10, 0);
					subframe.itemGP:SetPoint('CENTER', _G[BCEPGP_mode..'itemGP'..(i-1)], 'BOTTOM', 0, -20);
				end
				
				subframe.tex:SetScript('OnClick', function() SetItemRef(iString) end);
				
				subframe.itemName.text = subframe.itemName:CreateFontString(BCEPGP_mode..'EPGP_i'..name..'text', 'OVERLAY', 'GameFontNormal');
				subframe.itemName.text:SetPoint('CENTER', _G[BCEPGP_mode..'item'..i]);
				subframe.itemName.text:SetText(link);
				subframe.itemName.text:SetTextColor(colour.r, colour.g, colour.b);
				subframe.itemName:SetWidth(subframe.itemName.text:GetStringWidth());
				subframe.itemName:SetScript('OnClick', function() SetItemRef(iString) end);
				
				subframe.itemGP:SetText(gp);
				subframe.itemGP:SetTextColor(colour.r, colour.g, colour.b);
				subframe.itemGP:SetWidth(35);
				subframe.itemGP:SetScript('OnEnterPressed', function() this:ClearFocus() end);
				subframe.itemGP:SetAutoFocus(false);
				subframe.itemGP:Show();
			end
		end
	end
end

function BCEPGP_strSplit(msgStr, c)
	if not msgStr then
		return nil;
	end
	local table_str = {};
	local capture = string.format("(.-)%s", c);
	
	for v in string.gmatch(msgStr, capture) do
		table.insert(table_str, v);
	end
	
	return unpack(table_str);
end

function BCEPGP_stackTrace()
	BCEPGP_print("Call stack: \n" .. debugstack(1, 5, 5));
end

function BCEPGP_print(str, err)
	if not str then return; end;
	if err == nil then
		DEFAULT_CHAT_FRAME:AddMessage("|c006969FFBCEPGP: " .. tostring(str) .. "|r");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|c006969FFBCEPGP:|r " .. "|c00FF0000Error|r|c006969FF - " .. tostring(str) .. "|r");
	end
end

function BCEPGP_cleanTable()
	local i = 1;
	while _G[BCEPGP_mode..'member_name'..i] ~= nil do
		_G[BCEPGP_mode..'member_group'..i].text:SetText("");
		_G[BCEPGP_mode..'member_name'..i].text:SetText("");
		_G[BCEPGP_mode..'member_rank'..i].text:SetText("");
		_G[BCEPGP_mode..'member_EP'..i].text:SetText("");
		_G[BCEPGP_mode..'member_GP'..i].text:SetText("");
		_G[BCEPGP_mode..'member_PR'..i].text:SetText("");
		i = i + 1;
	end
	
	
	i = 1;
	while _G[BCEPGP_mode..'item'..i] ~= nil do
		_G[BCEPGP_mode..'announce'..i]:Hide();
		_G[BCEPGP_mode..'tex'..i]:Hide();
		_G[BCEPGP_mode..'item'..i].text:SetText("");
		_G[BCEPGP_mode..'itemGP'..i]:Hide();
		i = i + 1;
	end
end

function BCEPGP_toggleFrame(frame)
	for i = 1, table.getn(BCEPGP_frames) do
		if BCEPGP_frames[i]:GetName() == frame then
			BCEPGP_frames[i]:Show();
		else
			BCEPGP_frames[i]:Hide();
		end
	end
end

function BCEPGP_rosterUpdate(event)
	if event == "GUILD_ROSTER_UPDATE" then
		BCEPGP_roster = {};
		if CanEditOfficerNote() == 1 then
			ShowUIPanel(BCEPGP_guild_add_EP);
			ShowUIPanel(BCEPGP_guild_decay);
			ShowUIPanel(BCEPGP_guild_reset);
			ShowUIPanel(BCEPGP_raid_add_EP);
			ShowUIPanel(BCEPGP_button_guild_restore);
		else --[[ Hides context sensitive options if player cannot edit officer notes ]]--
			HideUIPanel(BCEPGP_guild_add_EP);
			HideUIPanel(BCEPGP_guild_decay);
			HideUIPanel(BCEPGP_guild_reset);
			HideUIPanel(BCEPGP_raid_add_EP);
			HideUIPanel(BCEPGP_button_guild_restore);
		end
		for i = 1, GetNumGuildMembers() do
			local name, rank, rankIndex, _, class, _, _, officerNote = GetGuildRosterInfo(i);
			if name then
				local EP, GP = BCEPGP_getEPGP(officerNote);
				local PR = math.floor((EP/GP)*100)/100;
				BCEPGP_roster[name] = {
				[1] = i,
				[2] = class,
				[3] = rank,
				[4] = rankIndex,
				[5] = officerNote,
				[6] = PR
				};
			end
		end
		if BCEPGP_mode == "guild" then
			BCEPGP_UpdateGuildScrollBar();
		elseif BCEPGP_mode == "raid" then
			BCEPGP_UpdateRaidScrollBar();
		end
		BCEPGP_UpdateStandbyScrollBar();
	elseif event == "RAID_ROSTER_UPDATE" then
		BCEPGP_vInfo = {};
		BCEPGP_SendAddonMsg("version-check", "RAID");
		BCEPGP_updateGuild();
		BCEPGP_raidRoster = {};
		for i = 1, GetNumRaidMembers() do
			local name = GetRaidRosterInfo(i);
			if BCEPGP_tContains(BCEPGP_standbyRoster, name) then
				for k, v in pairs(BCEPGP_standbyRoster) do
					if v == name then
						table.remove(BCEPGP_standbyRoster, k);
					end
				end
				BCEPGP_UpdateStandbyScrollBar();
			end
			BCEPGP_raidRoster[name] = name;
		end
		if UnitInRaid("player") then
			ShowUIPanel(BCEPGP_button_raid);
			ShowUIPanel(BCEPGP_button_loot_dist);
		else --[[ Hides the raid and loot distribution buttons if the player is not in a raid group ]]--
			HideUIPanel(BCEPGP_raid);
			HideUIPanel(BCEPGP_loot);
			HideUIPanel(BCEPGP_button_raid);
			HideUIPanel(BCEPGP_button_loot_dist);
			HideUIPanel(BCEPGP_distribute_popup);
			HideUIPanel(BCEPGP_context_popup);
			BCEPGP_mode = "guild";
			ShowUIPanel(BCEPGP_guild);
		end
		BCEPGP_vInfo = {};
		BCEPGP_UpdateVersionScrollBar();
		BCEPGP_UpdateRaidScrollBar();
	end
end

function BCEPGP_addToStandby(player)
	if not player then return; end
	player = BCEPGP_standardiseString(player);
	if not BCEPGP_tContains(BCEPGP_roster, player, true) then
		BCEPGP_print(player .. " is not a guild member", true);
		return;
	elseif BCEPGP_tContains(BCEPGP_standbyRoster, player) then
		BCEPGP_print(player .. " is already in the standby roster", true);
		return;
	elseif BCEPGP_tContains(BCEPGP_raidRoster, player, true) then
		BCEPGP_print(player .. " is part of the raid", true);
		return;
	else
		table.insert(BCEPGP_standbyRoster, player);
		BCEPGP_UpdateStandbyScrollBar();
	end
end

function BCEPGP_standardiseString(value)
	--Returns the same string with the first letter as capital
	if not string then return; end
	local first = string.upper(strsub(value, 1, 1)); --The uppercase first character of the string
	local rest = strsub(value, 2, strlen(value)); --The remainder of the string
	return first .. rest;
end

function BCEPGP_toggleStandbyRanks(show)
	if show then
		for i = 1, 10 do
			if STANDBYRANKS[i][1] ~= nil then
				getglobal("BCEPGP_options_standby_ep_rank_"..i):Show();
				getglobal("BCEPGP_options_standby_ep_rank_"..i):SetText(tostring(STANDBYRANKS[i][1]));
				getglobal("BCEPGP_options_standby_ep_check_rank_"..i):Show();
				if STANDBYRANKS[i][2] == true then
					getglobal("BCEPGP_options_standby_ep_check_rank_"..i):SetChecked(true);
				else
					getglobal("BCEPGP_options_standby_ep_check_rank_"..i):SetChecked(false);
				end
			end
			if GuildControlGetRankName(i) == nil then
				getglobal("BCEPGP_options_standby_ep_rank_"..i):Hide();
				getglobal("BCEPGP_options_standby_ep_check_rank_"..i):Hide();
				getglobal("BCEPGP_options_standby_ep_check_rank_"..i):SetChecked(false);
			end
		end
		BCEPGP_options_standby_ep_list_button:Hide();
		BCEPGP_options_standby_ep_accept_whispers_check:Hide();
		BCEPGP_options_standby_ep_accept_whispers:Hide();
	else
		for i = 1, 10 do
			getglobal("BCEPGP_options_standby_ep_rank_"..i):Hide();
			getglobal("BCEPGP_options_standby_ep_check_rank_"..i):Hide();
		end
		BCEPGP_options_standby_ep_list_button:Show();
		BCEPGP_options_standby_ep_accept_whispers_check:Show();
		BCEPGP_options_standby_ep_accept_whispers:Show();
	end
end

function BCEPGP_getGuildInfo(name)
	if BCEPGP_tContains(BCEPGP_roster, name, true) then
		return BCEPGP_roster[name][1], BCEPGP_roster[name][2], BCEPGP_roster[name][3], BCEPGP_roster[name][4], BCEPGP_roster[name][5], BCEPGP_roster[name][6];  -- index, Rank, RankIndex, Class, OfficerNote, PR
	else
		return nil;
	end
end

function BCEPGP_getVal(str)
	local val = nil;
	val = strsub(str, strfind(str, " ")+1, string.len(str));
	return val;
end

function BCEPGP_indexToName(i)
	for index,value in pairs(BCEPGP_roster) do
		if value[1] == i then
			return index;
		end
	end
end

function BCEPGP_getEPGP(offNote)
	if not offNote or not BCEPGP_checkEPGP then
		return 0, BASEGP;
	end
	local EP, GP = nil;
	if not BCEPGP_checkEPGP(offNote) then
		return 0, BASEGP;
	end
	EP = tonumber(strsub(offNote, 1, strfind(offNote, ",")-1));
	GP = tonumber(strsub(offNote, strfind(offNote, ",")+1, string.len(offNote)));
	return EP, GP;
end

function BCEPGP_checkEPGP(note)
	if string.find(note, '[0-9]+,[0-9]+') then
		return true;
	else
		return false;
	end
end

function BCEPGP_getItemString(link)
	if not link then
		return nil;
	end
	local itemString = string.find(link, "item[%-?%d:]+");
	itemString = strsub(link, itemString, string.len(link)-(string.len(link)-2)-6);
	return itemString;
end

function BCEPGP_getItemID(iString)
	if not iString then
		return nil;
	end
	local itemString = string.sub(iString, 6, string.len(iString)-1)--"^[%-?%d:]+");
	return string.sub(itemString, 1, string.find(itemString, ":")-1);
end

function BCEPGP_getItemLink(id)
	local name, _, rarity = GetItemInfo(id);
	if rarity == 0 then -- Poor
		return "\124cff9d9d9d\124Hitem:" .. id .. "::::::::110:::::\124h[" .. name .. "]\124h\124r";
	elseif rarity == 1 then -- Common
		return "\124cffffffff\124Hitem:" .. id .. "::::::::110:::::\124h[" .. name .. "]\124h\124r";
	elseif rarity == 2 then -- Uncommon
		return "\124cff1eff00\124Hitem:" .. id .. "::::::::110:::::\124h[" .. name .. "]\124h\124r";
	elseif rarity == 3 then -- Rare
		return "\124cff0070dd\124Hitem:" .. id .. "::::::::110:::::\124h[" .. name .. "]\124h\124r";
	elseif rarity == 4 then -- Epic
		return "\124cffa335ee\124Hitem:" .. id .. "::::::::110:::::\124h[" .. name .. "]\124h\124r";
	elseif rarity == 5 then -- Legendary
		return "\124cffff8000\124Hitem:" .. id .. "::::::::110:::::\124h[" .. name .. "]\124h\124r";
	end
end

function BCEPGP_SlotNameToID(name)
	if name == nil then
		return nil
	end
	if name == "HEAD" then
		return 1;
	elseif name == "NECK" then
		return 2;
	elseif name == "SHOULDER" then
		return 3;
	elseif name == "CHEST" or name == "ROBE" then
		return 5;
	elseif name == "WAIST" then
		return 6;
	elseif name == "LEGS" then
		return 7;
	elseif name == "FEET" then
		return 8;
	elseif name == "WRIST" then
		return 9;
	elseif name == "HAND" then
		return 10;
	elseif name == "FINGER" then
		return 11, 12;
	elseif name == "TRINKET" then
		return 13, 14;
	elseif name == "CLOAK" then
		return 15;
	elseif name == "2HWEAPON" or name == "WEAPON" or name == "WEAPONMAINHAND" or name == "WEAPONOFFHAND" or name == "SHIELD" or name == "HOLDABLE" then
		return 16, 17;
	elseif name == "RANGED" or name == "RANGEDRIGHT" or name == "RELIC" then
		return 18;
	end
end

function BCEPGP_inOverride(itemName)
	itemName = string.gsub(string.gsub(string.gsub(string.lower(itemName), " ", ""), "'", ""), ",", "");
	for k, _ in pairs(OVERRIDE_INDEX) do
		if itemName == string.gsub(string.gsub(string.gsub(string.lower(k), " ", ""), "'", ""), ",", "") then
			return true;
		end
	end
	return false;
end

function BCEPGP_tContains(t, val, bool)
	if bool == nil then
		for _,value in pairs(t) do
			if value == val then
				return true;
			end
		end
	elseif bool == true then
		for index,_ in pairs(t) do 
			if index == val then
				return true;
			end
		end
	end
	return false;
end

function BCEPGP_isNumber(num)
	return not (string.find(tostring(num), '[^-0-9.]+') or string.find(tostring(num), '[^-0-9.]+$'));
end

function BCEPGP_isML()
	local _, isML = GetLootMethod();
	return isML;
end

function BCEPGP_updateGuild()
	if not IsInGuild() then
		HideUIPanel(BCEPGP_button_guild);
		HideUIPanel(BCEPGP_guild);
		return;
	else
		ShowUIPanel(BCEPGP_button_guild);
	end;
	GuildRoster();
end

function BCEPGP_tSort(t, index)
	if not t then return; end
	local t2 = {};
	table.insert(t2, t[1]);
	table.remove(t, 1);
	local tSize = table.getn(t);
	if tSize > 0 then
		for x = 1, tSize do
			local t2Size = table.getn(t2);
			for y = 1, t2Size do
				if y < t2Size and t[1][index] ~= nil then
					if BCEPGP_critReverse then
						if (t[1][index] >= t2[y][index]) then
							table.insert(t2, y, t[1]);
							table.remove(t, 1);
							break;
						elseif (t[1][index] < t2[y][index]) and (t[1][index] >= t2[(y + 1)][index]) then
							table.insert(t2, (y + 1), t[1]);
							table.remove(t, 1);
							break;
						end
					else
						if (t[1][index] <= t2[y][index]) then
							table.insert(t2, y, t[1]);
							table.remove(t, 1);
							break;
						elseif (t[1][index] > t2[y][index]) and (t[1][index] <= t2[(y + 1)][index]) then
							table.insert(t2, (y + 1), t[1]);
							table.remove(t, 1);
							break;
						end
					end
				elseif y == t2Size and t[1][index] ~= nil then
					if BCEPGP_critReverse then
						if t[1][index] > t2[y][index] then
							table.insert(t2, y, t[1]);
							table.remove(t, 1);
						else
							table.insert(t2, t[1]);
							table.remove(t, 1);
						end
					else
						if t[1][index] < t2[y][index] then
							table.insert(t2, y, t[1]);
							table.remove(t, 1);
						else
							table.insert(t2, t[1]);
							table.remove(t, 1);
						end
					end
				end
			end
		end
	end
	return t2;
end

function BCEPGP_ntgetn(tbl)
	if tbl == nil then
		return 0;
	end
	local n = 0;
	for _,_ in pairs(tbl) do
		n = n + 1;
	end
	return n;
end

function BCEPGP_setCriteria(x, disp)
	if BCEPGP_criteria == x then
		BCEPGP_critReverse = not BCEPGP_critReverse
	end
	BCEPGP_criteria = x;
	if disp == "Raid" then
		BCEPGP_UpdateRaidScrollBar();
	elseif disp == "Guild" then
		BCEPGP_UpdateGuildScrollBar();
	elseif disp == "Loot" then
		BCEPGP_UpdateLootScrollBar();
	elseif disp == "Standby" then
		BCEPGP_UpdateStandbyScrollBar();
	end
end

function BCEPGP_toggleBossConfigFrame(fName)
	for _, frame in pairs(BCEPGP_boss_config_frames) do
		if frame:GetName() ~= fName then
			frame:Hide();
		else
			frame:Show();
		end;
	end
end

function capitaliseFirstLetter(str)
	str = string.gsub(" "..str, "%W%l", string.upper):sub(2)
	return str;
end