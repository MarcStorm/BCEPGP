

function BCEPGP_UpdateLootScrollBar()
	local y;
	local yoffset;
	local t;
	local tSize;
	local name;
	local class;
	local rank;
	local EP;
	local GP;
	local offNote;
	local colour;
	t = {};
	tSize = table.getn(BCEPGP_responses);
	BCEPGP_updateGuild();
	for x = 1, tSize do
		name = BCEPGP_responses[x]
		if BCEPGP_debugMode and not UnitInRaid("player") then
			class = UnitClass("player");
		end
		for i = 1, GetNumRaidMembers() do
			if name == GetRaidRosterInfo(i) then
				_, _, _, _, class = GetRaidRosterInfo(i);
			end
		end
		if BCEPGP_tContains(BCEPGP_roster, name, true) then
			rank = BCEPGP_roster[name][3];
			rankIndex = BCEPGP_roster[name][4];
			offNote = BCEPGP_roster[name][5];
			EP, GP = BCEPGP_getEPGP(offNote);
			PR = BCEPGP_roster[name][6];
		end
		if not rank then
			rank = "Not in Guild";
			rankIndex = 10;
			EP = 0;
			GP = BASEGP;
			PR = 0;
		end
		t[x] = {
			[1] = name,
			[2] = class,
			[3] = rank,
			[4] = rankIndex,
			[5] = EP,
			[6] = GP,
			[7] = PR
			}
		rank = nil;
	end
	t = BCEPGP_tSort(t, BCEPGP_criteria)
	FauxScrollFrame_Update(DistributeScrollFrame, tSize, 18, 120);
	for y = 1, 18, 1 do
		yoffset = y + FauxScrollFrame_GetOffset(DistributeScrollFrame);
		if (yoffset <= tSize) then
			if not BCEPGP_tContains(t, yoffset, true) then
				getglobal("LootDistButton" .. y):Hide();
			else
				name = t[yoffset][1];
				class = t[yoffset][2];
				rank = t[yoffset][3];
				EP = t[yoffset][5];
				GP = t[yoffset][6];
				PR = t[yoffset][7];
				local iString = nil;
				local iString2 = nil;
				local tex = nil;
				local tex2 = nil;
				if BCEPGP_itemsTable[name]then
					if BCEPGP_itemsTable[name][1] ~= nil then
						iString = BCEPGP_itemsTable[name][1].."|r";
						_, _, _, _, _, _, _, _, _, tex = GetItemInfo(iString);
						if BCEPGP_itemsTable[name][2] ~= nil then
							iString2 = BCEPGP_itemsTable[name][2].."|r";
							_, _, _, _, _, _, _, _, _, tex2 = GetItemInfo(iString2);
						end
					end
				end
				if class then
					colour = RAID_CLASS_COLORS[string.upper(class)];
				else
					colour = RAID_CLASS_COLORS["WARRIOR"];
				end
				tex = {bgFile = tex,};
				tex2 = {bgFile = tex2,};
				getglobal("LootDistButton" .. y):Show();
				getglobal("LootDistButton" .. y .. "Info"):SetText(name);
				getglobal("LootDistButton" .. y .. "Info"):SetTextColor(colour.r, colour.g, colour.b);
				getglobal("LootDistButton" .. y .. "Class"):SetText(class);
				getglobal("LootDistButton" .. y .. "Class"):SetTextColor(colour.r, colour.g, colour.b);
				getglobal("LootDistButton" .. y .. "Rank"):SetText(rank);
				getglobal("LootDistButton" .. y .. "Rank"):SetTextColor(colour.r, colour.g, colour.b);
				getglobal("LootDistButton" .. y .. "EP"):SetText(EP);
				getglobal("LootDistButton" .. y .. "EP"):SetTextColor(colour.r, colour.g, colour.b);
				getglobal("LootDistButton" .. y .. "GP"):SetText(GP);
				getglobal("LootDistButton" .. y .. "GP"):SetTextColor(colour.r, colour.g, colour.b);
				getglobal("LootDistButton" .. y .. "PR"):SetText(math.floor((EP/GP)*100)/100);
				getglobal("LootDistButton" .. y .. "PR"):SetTextColor(colour.r, colour.g, colour.b);
				getglobal("LootDistButton" .. y .. "Tex"):SetBackdrop(tex);
				getglobal("LootDistButton" .. y .. "Tex2"):SetBackdrop(tex2);
				getglobal("LootDistButton" .. y .. "Tex"):SetScript('OnLeave', function()
																		GameTooltip:Hide()
																	end);
				getglobal("LootDistButton" .. y .. "Tex2"):SetScript('OnLeave', function()
																		GameTooltip:Hide()
																	end);
				if iString then
					getglobal("LootDistButton" .. y .. "Tex"):SetScript('OnEnter', function()	
																			GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT")
																			GameTooltip:SetHyperlink(iString)
																			GameTooltip:Show()
																		end);
					if iString2 then
						getglobal("LootDistButton" .. y .. "Tex2"):SetScript('OnEnter', function()	
														GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT")
														GameTooltip:SetHyperlink(iString2)
														GameTooltip:Show()
													end);				
					else
						getglobal("LootDistButton" .. y .. "Tex2"):SetScript('OnEnter', function() end);
					end
				
				else
					getglobal("LootDistButton" .. y .. "Tex"):SetScript('OnEnter', function() end);
				end
			end
		else
			getglobal("LootDistButton" .. y):Hide();
		end
	end
end

function BCEPGP_UpdateGuildScrollBar()
	local x, y;
	local yoffset;
	local t;
	local tSize;
	local name;
	local class;
	local rank;
	local EP;
	local GP;
	local offNote;
	local colour;
	t = {};
	tSize = BCEPGP_ntgetn(BCEPGP_roster);
	for x = 1, tSize do
		name = BCEPGP_indexToName(x);
		index, class, rank, rankIndex, offNote = BCEPGP_getGuildInfo(name);
		EP, GP = BCEPGP_getEPGP(offNote)
		t[x] = {
			[1] = name,
			[2] = class,
			[3] = rank,
			[4] = rankIndex,
			[5] = EP,
			[6] = GP,
			[7] = math.floor((EP/GP)*100)/100,
			[8] = 0
		}
	end
	t = BCEPGP_tSort(t, BCEPGP_criteria)
	FauxScrollFrame_Update(GuildScrollFrame, tSize, 18, 240);
	for y = 1, 18, 1 do
		
		yoffset = y + FauxScrollFrame_GetOffset(GuildScrollFrame);
		if (yoffset <= tSize) then
			if not BCEPGP_tContains(t, yoffset, true) then
				getglobal("GuildButton" .. y):Hide();
			else
				name = t[yoffset][1]
				class = t[yoffset][2];
				rank = t[yoffset][3];
				EP = t[yoffset][5];
				GP = t[yoffset][6];
				PR = t[yoffset][7];
				if class then
					colour = RAID_CLASS_COLORS[string.upper(class)];
				else
					colour = RAID_CLASS_COLORS["WARRIOR"];
				end
				getglobal("GuildButton" .. y .. "Info"):SetText(name);
				getglobal("GuildButton" .. y .. "Info"):SetTextColor(colour.r, colour.g, colour.b);
				getglobal("GuildButton" .. y .. "Class"):SetText(class);
				getglobal("GuildButton" .. y .. "Class"):SetTextColor(colour.r, colour.g, colour.b);
				getglobal("GuildButton" .. y .. "Rank"):SetText(rank);
				getglobal("GuildButton" .. y .. "Rank"):SetTextColor(colour.r, colour.g, colour.b);
				getglobal("GuildButton" .. y .. "EP"):SetText(EP);
				getglobal("GuildButton" .. y .. "EP"):SetTextColor(colour.r, colour.g, colour.b);
				getglobal("GuildButton" .. y .. "GP"):SetText(GP);
				getglobal("GuildButton" .. y .. "GP"):SetTextColor(colour.r, colour.g, colour.b);
				getglobal("GuildButton" .. y .. "PR"):SetText(PR);
				getglobal("GuildButton" .. y .. "PR"):SetTextColor(colour.r, colour.g, colour.b);
				getglobal("GuildButton" .. y):Show();
			end
		else
			getglobal("GuildButton" .. y):Hide();
		end
	end
end

function BCEPGP_UpdateRaidScrollBar()
	local x, y;
	local yoffset;
	local t;
	local tSize;
	local group;
	local name;
	local rank;
	local EP;
	local GP;
	local offNote;
	local colour;
	t = {};
	tSize = GetNumRaidMembers();
	for x = 1, tSize do
		name, _, group, _, class = GetRaidRosterInfo(x);
		local a = BCEPGP_getGuildInfo(name);
		if BCEPGP_tContains(BCEPGP_roster, name, true) then
			rank = BCEPGP_roster[name][3];
			rankIndex = BCEPGP_roster[name][4];
			offNote = BCEPGP_roster[name][5];
			EP, GP = BCEPGP_getEPGP(offNote);
			PR = BCEPGP_roster[name][6];
		end
		if not BCEPGP_roster[name] then
			rank = "Not in Guild";
			rankIndex = 10;
			EP = 0;
			GP = BASEGP;
			PR = 0;
		end
		t[x] = {
			[1] = name,
			[2] = class,
			[3] = rank,
			[4] = rankIndex,
			[5] = EP,
			[6] = GP,
			[7] = PR,
			[8] = group
		}
	end
	t = BCEPGP_tSort(t, BCEPGP_criteria)
	FauxScrollFrame_Update(RaidScrollFrame, tSize, 18, 240);
	for y = 1, 18, 1 do
		yoffset = y + FauxScrollFrame_GetOffset(RaidScrollFrame);
		if (yoffset <= tSize) then
			if not BCEPGP_tContains(t, yoffset, true) then
				getglobal("RaidButton" .. y):Hide();
			else
				t2 = t[yoffset];
				name = t2[1];
				class = t2[2];
				rank = t2[3];
				EP = t2[5];
				GP = t2[6];
				PR = t2[7];
				group = t2[8];
				if class then
					colour = RAID_CLASS_COLORS[string.upper(class)];
				else
					colour = RAID_CLASS_COLORS["WARRIOR"];
				end
				getglobal("RaidButton" .. y .. "Group"):SetText(group);
				getglobal("RaidButton" .. y .. "Group"):SetTextColor(colour.r, colour.g, colour.b);
				getglobal("RaidButton" .. y .. "Info"):SetText(name);
				getglobal("RaidButton" .. y .. "Info"):SetTextColor(colour.r, colour.g, colour.b);
				getglobal("RaidButton" .. y .. "Rank"):SetText(rank);
				getglobal("RaidButton" .. y .. "Rank"):SetTextColor(colour.r, colour.g, colour.b);
				getglobal("RaidButton" .. y .. "EP"):SetText(EP);
				getglobal("RaidButton" .. y .. "EP"):SetTextColor(colour.r, colour.g, colour.b);
				getglobal("RaidButton" .. y .. "GP"):SetText(GP);
				getglobal("RaidButton" .. y .. "GP"):SetTextColor(colour.r, colour.g, colour.b);
				getglobal("RaidButton" .. y .. "PR"):SetText(PR);
				getglobal("RaidButton" .. y .. "PR"):SetTextColor(colour.r, colour.g, colour.b);
				getglobal("RaidButton" .. y):Show();
			end
		else
			getglobal("RaidButton" .. y):Hide();
		end
	end
end

function BCEPGP_UpdateVersionScrollBar()
	local x, y;
	local yoffset;
	local t;
	local tSize;
	local name;
	local colour;
	local version;
	local online;
	t = {};
	if BCEPGP_vSearch == "GUILD" then
		tSize = GetNumGuildMembers();
	else
		tSize = GetNumRaidMembers();
	end
	if tSize == 0 then
		for y = 1, 18, 1 do
			getglobal("versionButton" .. y):Hide();
		end
	end
	if BCEPGP_vSearch == "GUILD" then
		for x = 1, tSize do
			name, _, _, _, class, _, _, _, online = GetGuildRosterInfo(x);
			t[x] = {
				[1] = name,
				[2] = class,
				[3] = online
			}
		end
	else
		for x = 1, tSize do
			name, _, group, _, class, _, _, online = GetRaidRosterInfo(x);
			t[x] = {
				[1] = name,
				[2] = class,
				[3] = online
			}
		end
	end
	FauxScrollFrame_Update(VersionScrollFrame, tSize, 18, 240);
	for y = 1, 18, 1 do
		yoffset = y + FauxScrollFrame_GetOffset(VersionScrollFrame);
		if (yoffset <= tSize) then
			if not BCEPGP_tContains(t, yoffset, true) then
				getglobal("versionButton" .. y):Hide();
			else
				t2 = t[yoffset];
				name = t2[1];
				class = t2[2];
				online = t2[3];
				if BCEPGP_groupVersion[name] then
					version = BCEPGP_groupVersion[name];
				elseif online == 1 then
					version = "Addon not running";
				else
					version = "Offline";
				end
				if class then
					colour = RAID_CLASS_COLORS[string.upper(class)];
				else
					colour = RAID_CLASS_COLORS["WARRIOR"];
				end
				getglobal("versionButton" .. y .. "name"):SetText(name);
				getglobal("versionButton" .. y .. "name"):SetTextColor(colour.r, colour.g, colour.b);
				getglobal("versionButton" .. y .. "version"):SetText(version);
				getglobal("versionButton" .. y .. "version"):SetTextColor(colour.r, colour.g, colour.b);
				getglobal("versionButton" .. y):Show();
			end
		else
			getglobal("versionButton" .. y):Hide();
		end
	end
end

function BCEPGP_UpdateOverrideScrollBar()
	if OVERRIDE_INDEX == nil then
		return;
	end
	local x, y;
	local yoffset;
	local t;
	local tSize;
	local item;
	local gp;
	local colour;
	local quality;
	t = {};
	tSize = BCEPGP_ntgetn(OVERRIDE_INDEX);
	if tSize == 0 then
		for y = 1, 18, 1 do
			getglobal("BCEPGP_overrideButton" .. y):Hide();
		end
	end
	local count = 1;
	for k, v in pairs(OVERRIDE_INDEX) do
		t[count] = {
			[1] = k,
			[2] = v
		};
		count = count + 1;
	end
	FauxScrollFrame_Update(BCEPGP_overrideScrollFrame, tSize, 18, 240);
	for y = 1, 18, 1 do
		yoffset = y + FauxScrollFrame_GetOffset(BCEPGP_overrideScrollFrame);
		if (yoffset <= tSize) then
			if not BCEPGP_tContains(t, yoffset, true) then
				getglobal("BCEPGP_overrideButton" .. y):Hide();
			else
				t2 = t[yoffset];
				item = t2[1];
				gp = t2[2];
				quality = t2[3];
				getglobal("BCEPGP_overrideButton" .. y .. "item"):SetText(item);
				getglobal("BCEPGP_overrideButton" .. y .. "item"):SetTextColor(1, 1, 1);
				getglobal("BCEPGP_overrideButton" .. y .. "GP"):SetText(gp);
				getglobal("BCEPGP_overrideButton" .. y .. "GP"):SetTextColor(1, 1, 1);
				getglobal("BCEPGP_overrideButton" .. y):Show();
			end
		else
			getglobal("BCEPGP_overrideButton" .. y):Hide();
		end
	end
end

function BCEPGP_UpdateTrafficScrollBar()
	if TRAFFIC == nil then
		return;
	end
	local yoffset;
	local tSize;
	tSize = BCEPGP_ntgetn(TRAFFIC);
	FauxScrollFrame_Update(trafficScrollFrame, tSize, 18, 240);
	for y = 1, 18, 1 do
		yoffset = y + FauxScrollFrame_GetOffset(trafficScrollFrame);
		if (yoffset <= tSize) then
			local name = TRAFFIC[BCEPGP_ntgetn(TRAFFIC) - (yoffset-1)][1];
			local action = TRAFFIC[BCEPGP_ntgetn(TRAFFIC) - (yoffset-1)][2];
			local EPB = TRAFFIC[BCEPGP_ntgetn(TRAFFIC) - (yoffset-1)][3];
			local EPA = TRAFFIC[BCEPGP_ntgetn(TRAFFIC) - (yoffset-1)][4];
			local GPB = TRAFFIC[BCEPGP_ntgetn(TRAFFIC) - (yoffset-1)][5];
			local GPA = TRAFFIC[BCEPGP_ntgetn(TRAFFIC) - (yoffset-1)][6];
			local item = TRAFFIC[BCEPGP_ntgetn(TRAFFIC) - (yoffset-1)][7];
			getglobal("trafficButton" .. y .. "Name"):SetText(name);
			getglobal("trafficButton" .. y .. "Name"):SetTextColor(1, 1, 1);
			if item then
				getglobal("trafficButton" .. y .. "ItemName"):SetText(item);
				getglobal("trafficButton" .. y .. "ItemName"):Show();
				getglobal("trafficButton" .. y .. "Item"):SetScript('OnClick', function() SetItemRef(tostring(BCEPGP_getItemString(item))) end);
			else
				getglobal("trafficButton" .. y .. "ItemName"):SetText("");
				getglobal("trafficButton" .. y .. "ItemName"):Hide();
				getglobal("trafficButton" .. y .. "Item"):SetScript('OnClick', function() end);
			end
			getglobal("trafficButton" .. y .. "Action"):SetText(action);
			getglobal("trafficButton" .. y .. "Action"):SetTextColor(1, 1, 1);
			getglobal("trafficButton" .. y .. "EPBefore"):SetText(EPB);
			getglobal("trafficButton" .. y .. "EPBefore"):SetTextColor(1, 1, 1);
			getglobal("trafficButton" .. y .. "EPAfter"):SetText(EPA);
			getglobal("trafficButton" .. y .. "EPAfter"):SetTextColor(1, 1, 1);
			getglobal("trafficButton" .. y .. "GPBefore"):SetText(GPB);
			getglobal("trafficButton" .. y .. "GPBefore"):SetTextColor(1, 1, 1);
			getglobal("trafficButton" .. y .. "GPAfter"):SetText(GPA);
			getglobal("trafficButton" .. y .. "GPAfter"):SetTextColor(1, 1, 1);
			getglobal("trafficButton" .. y):Show();
		else
			getglobal("trafficButton" .. y):Hide();
		end
	end
end

function BCEPGP_UpdateStandbyScrollBar()
	local x, y;
	local yoffset;
	local t;
	local tSize;
	local name;
	local class;
	local rank;
	local EP;
	local GP;
	local offNote;
	local colour;
	t = {};
	tSize = BCEPGP_ntgetn(BCEPGP_standbyRoster);
	for x = 1, tSize do
		name = BCEPGP_standbyRoster[x];
		index, class, rank, rankIndex, offNote = BCEPGP_getGuildInfo(name);
		EP, GP = BCEPGP_getEPGP(offNote)
		t[x] = {
			[1] = name,
			[2] = class,
			[3] = rank,
			[4] = rankIndex,
			[5] = EP,
			[6] = GP,
			[7] = math.floor((EP/GP)*100)/100,
			[8] = 0
		}
	end
	t = BCEPGP_tSort(t, BCEPGP_criteria)
	FauxScrollFrame_Update(BCEPGP_StandbyScrollFrame, tSize, 18, 240);
	for y = 1, 18, 1 do
		yoffset = y + FauxScrollFrame_GetOffset(BCEPGP_StandbyScrollFrame);
		if (yoffset <= tSize) then
			if not BCEPGP_tContains(t, yoffset, true) then
				getglobal("BCEPGP_StandbyButton" .. y):Hide();
			else
				name = t[yoffset][1]
				class = t[yoffset][2];
				rank = t[yoffset][3];
				EP = t[yoffset][5];
				GP = t[yoffset][6];
				PR = t[yoffset][7];
				if class then
					colour = RAID_CLASS_COLORS[string.upper(class)];
				else
					colour = RAID_CLASS_COLORS["WARRIOR"];
				end
				getglobal("BCEPGP_StandbyButton" .. y .. "Info"):SetText(name);
				getglobal("BCEPGP_StandbyButton" .. y .. "Info"):SetTextColor(colour.r, colour.g, colour.b);
				getglobal("BCEPGP_StandbyButton" .. y .. "Class"):SetText(class);
				getglobal("BCEPGP_StandbyButton" .. y .. "Class"):SetTextColor(colour.r, colour.g, colour.b);
				getglobal("BCEPGP_StandbyButton" .. y .. "Rank"):SetText(rank);
				getglobal("BCEPGP_StandbyButton" .. y .. "Rank"):SetTextColor(colour.r, colour.g, colour.b);
				getglobal("BCEPGP_StandbyButton" .. y .. "EP"):SetText(EP);
				getglobal("BCEPGP_StandbyButton" .. y .. "EP"):SetTextColor(colour.r, colour.g, colour.b);
				getglobal("BCEPGP_StandbyButton" .. y .. "GP"):SetText(GP);
				getglobal("BCEPGP_StandbyButton" .. y .. "GP"):SetTextColor(colour.r, colour.g, colour.b);
				getglobal("BCEPGP_StandbyButton" .. y .. "PR"):SetText(PR);
				getglobal("BCEPGP_StandbyButton" .. y .. "PR"):SetTextColor(colour.r, colour.g, colour.b);
				getglobal("BCEPGP_StandbyButton" .. y):Show();
			end
		else
			getglobal("BCEPGP_StandbyButton" .. y):Hide();
		end
	end
end