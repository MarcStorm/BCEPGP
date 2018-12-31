function BCEPGP_handleComms(event, arg1, arg2)
	if event == "CHAT_MSG_WHISPER" and string.lower(arg1) == "!need" and BCEPGP_distributing then
		local duplicate = false;
		for i = 1, table.getn(BCEPGP_responses) do
			if BCEPGP_responses[i] == arg2 then
				duplicate = true;
				if BCEPGP_debugMode then
					BCEPGP_print("Duplicate entry. " .. arg2 .. " not registered (!need)");
				end
			end
		end
		if not duplicate then
			BCEPGP_SendAddonMsg("!need,"..arg2.."`"..BCEPGP_DistID);
			table.insert(BCEPGP_responses, arg2);
			if BCEPGP_debugMode then
				BCEPGP_print(arg2 .. " registered (!need)");
			end
			local _, _, _, _, _, _, _, _, slot = GetItemInfo(BCEPGP_DistID);
			if not slot then
				BCEPGP_print("Unable to retrieve item information from the server. You will not see what the recipients are currently using", true);
			end
			BCEPGP_SendAddonMsg(arg2.."-BCEPGP_distributing-"..BCEPGP_DistID);--.."~"..BCEPGP_distSlot);
			local EP, GP = nil;
			local inGuild = false;
			if BCEPGP_tContains(BCEPGP_roster, arg2, true) then
				EP, GP = BCEPGP_getEPGP(BCEPGP_roster[arg2][5]);
				class = BCEPGP_roster[arg2][2];
				inGuild = true;
			end
			if BCEPGP_distributing then
				if inGuild then
					SendChatMessage(arg2 .. " (" .. class .. ") needs. (" .. math.floor((EP/GP)*100)/100 .. " PR)", RAID, BCEPGP_LANGUAGE);
				else
					local total = GetNumRaidMembers();
					for i = 1, total do
						if arg2 == GetRaidRosterInfo(i) then
							_, _, _, _, class = GetRaidRosterInfo(i);
						end
					end
					SendChatMessage(arg2 .. " (" .. class .. ") needs. (Non-guild member)", RAID, BCEPGP_LANGUAGE);
				end
			end
			if not BCEPGP_vInfo[arg2] then
				BCEPGP_UpdateLootScrollBar();
			end
		end
	elseif event == "CHAT_MSG_WHISPER" and string.lower(arg1) == "!info" then
		if BCEPGP_getGuildInfo(arg2) ~= nil then
			local EP, GP = BCEPGP_getEPGP(BCEPGP_roster[arg2][5]);
			if not BCEPGP_vInfo[arg2] then
				SendChatMessage("EPGP Standings - EP: " .. EP .. " / GP: " .. GP .. " / PR: " .. math.floor((EP/GP)*100)/100, "WHISPER", BCEPGP_LANGUAGE, arg2);
			else
				BCEPGP_SendAddonMsg("!info" .. arg2 .. "EPGP Standings - EP: " .. EP .. " / GP: " .. GP .. " / PR: " .. math.floor((EP/GP)*100)/100, "GUILD");
			end
		end
	elseif event == "CHAT_MSG_WHISPER" and (string.lower(arg1) == "!infoguild" or string.lower(arg1) == "!inforaid" or string.lower(arg1) == "!infoclass") then
		if BCEPGP_getGuildInfo(arg2) ~= nil then
			sRoster = {};
			BCEPGP_updateGuild();
			local gRoster = {};
			local rRoster = {};
			local name, unitClass, class, oNote, EP, GP;
			unitClass = BCEPGP_roster[arg2][2];
			for i = 1, GetNumGuildMembers() do
				gRoster[i] = {};
				name , _, _, _, class, _, _, oNote = GetGuildRosterInfo(i);
				EP, GP = BCEPGP_getEPGP(oNote);
				gRoster[i][1] = name;
				gRoster[i][2] = math.floor((EP/GP)*100)/100;
				gRoster[i][3] = class;
			end
			if string.lower(arg1) == "!infoguild" then
				if BCEPGP_critReverse then
					gRoster = BCEPGP_tSort(gRoster, 2);
					for i = 1, table.getn(gRoster) do
						if gRoster[i][1] == arg2 then
							if not BCEPGP_vInfo[arg2] then
								SendChatMessage("EP: " .. EP .. " / GP: " .. GP .. " / PR: " .. math.floor((EP/GP)*100)/100 .. " / PR rank in guild: #" .. i, "WHISPER", BCEPGP_LANGUAGE, arg2);
							else
								BCEPGP_SendAddonMsg("!info" .. arg2 .. "EP: " .. EP .. " / GP: " .. GP .. " / PR: " .. math.floor((EP/GP)*100)/100 .. " / PR rank in guild: #" .. i, "GUILD");
							end
						end
					end
				else
					BCEPGP_critReverse = true;
					gRoster = BCEPGP_tSort(gRoster, 2);
					for i = 1, table.getn(gRoster) do
						if gRoster[i][1] == arg2 then
							if not BCEPGP_vInfo[arg2] then
								SendChatMessage("EP: " .. EP .. " / GP: " .. GP .. " / PR: " .. math.floor((EP/GP)*100)/100 .. " / PR rank in guild: #" .. i, "WHISPER", BCEPGP_LANGUAGE, arg2);
							else
								BCEPGP_SendAddonMsg("!info" .. arg2 .. "EP: " .. EP .. " / GP: " .. GP .. " / PR: " .. math.floor((EP/GP)*100)/100 .. " / PR rank in guild: #" .. i, "GUILD");
							end
						end
					end
					BCEPGP_critReverse = false;
				end
			else
				local count = 1;
				if string.lower(arg1) == "!infoclass" then
					for i = 1, GetNumRaidMembers() do
						local name = GetRaidRosterInfo(i);
						for x = 1, table.getn(gRoster) do
							if gRoster[x][1] == name and gRoster[x][3] == unitClass then
								rRoster[count] = {};
								rRoster[count][1] = name;
								_, _ ,_, class, oNote = BCEPGP_getGuildInfo(name);
								EP, GP = BCEPGP_getEPGP(oNote);
								rRoster[count][2] = math.floor((EP/GP)*100)/100;
								count = count + 1;
							end
						end
					end
				else --Raid
					for i = 1, GetNumRaidMembers() do
						local name = GetRaidRosterInfo(i);
						for x = 1, BCEPGP_ntgetn(gRoster) do
							if gRoster[x][1] == name then
								rRoster[count] = {};
								rRoster[count][1] = name;
								_, _ ,_, class, oNote = BCEPGP_getGuildInfo(name);
								EP, GP = BCEPGP_getEPGP(oNote);
								rRoster[count][2] = math.floor((EP/GP)*100)/100;
								count = count + 1;
							end
						end
					end
				end
				if count > 1 then
					if BCEPGP_critReverse then
						rRoster = BCEPGP_tSort(rRoster, 2);
						for i = 1, table.getn(rRoster) do
							if rRoster[i][1] == arg2 then
								if string.lower(arg1) == "!infoclass" then
									if not BCEPGP_vInfo[arg2] then
										SendChatMessage("EP: " .. EP .. " / GP: " .. GP .. " / PR: " .. math.floor((EP/GP)*100)/100 .. " / PR rank among " .. unitClass .. "s in raid: #" .. i, "WHISPER", BCEPGP_LANGUAGE, arg2);
									else
										BCEPGP_SendAddonMsg("!info" .. arg2 .. "EP: " .. EP .. " / GP: " .. GP .. " / PR: " .. math.floor((EP/GP)*100)/100 .. " / PR rank among " .. unitClass .. "s in raid: #" .. i, "GUILD");
									end
								else
									if not BCEPGP_vInfo[arg2] then
										SendChatMessage("EP: " .. EP .. " / GP: " .. GP .. " / PR: " .. math.floor((EP/GP)*100)/100 .. " / PR rank in raid: #" .. i, "WHISPER", BCEPGP_LANGUAGE, arg2);
									else
										BCEPGP_SendAddonMsg("!info" .. arg2 .. "EP: " .. EP .. " / GP: " .. GP .. " / PR: " .. math.floor((EP/GP)*100)/100 .. " / PR rank in raid: #" .. i, "GUILD");
									end
								end
							end
						end
					else
						BCEPGP_critReverse = true;
						rRoster = BCEPGP_tSort(rRoster, 2);
						for i = 1, table.getn(rRoster) do
							if rRoster[i][1] == arg2 then
								if string.lower(arg1) == "!infoclass" then
									if not BCEPGP_vInfo[arg2] then
										SendChatMessage("EP: " .. EP .. " / GP: " .. GP .. " / PR: " .. math.floor((EP/GP)*100)/100 .. " / PR rank among " .. unitClass .. "s in raid: #" .. i, "WHISPER", BCEPGP_LANGUAGE, arg2);
									else
										BCEPGP_SendAddonMsg("!info" .. arg2 .. "EP: " .. EP .. " / GP: " .. GP .. " / PR: " .. math.floor((EP/GP)*100)/100 .. " / PR rank among " .. unitClass .. "s in raid: #" .. i, "GUILD");
									end
								else
									if not BCEPGP_vInfo[arg2] then
										SendChatMessage("EP: " .. EP .. " / GP: " .. GP .. " / PR: " .. math.floor((EP/GP)*100)/100 .. " / PR rank in raid: #" .. i, "WHISPER", BCEPGP_LANGUAGE, arg2);
									else
										BCEPGP_SendAddonMsg("!info" .. arg2 .. "EP: " .. EP .. " / GP: " .. GP .. " / PR: " .. math.floor((EP/GP)*100)/100 .. " / PR rank in raid: #" .. i, "GUILD");
									end
								end
							end
						end
						BCEPGP_critReverse = false;
					end
				end
			end
		end
	end
end

function BCEPGP_handleCombat(event, name)
	--local name = arg1; --strsub(arg1, 1, strfind(arg1, " dies")-1);
	local EP;
	local isLead;
	for i = 1, GetNumRaidMembers() do
		if UnitName("player") == GetRaidRosterInfo(i) then
			_, isLead = GetRaidRosterInfo(i);
		end
	end
	if (((GetLootMethod() == "master" and BCEPGP_isML() == 0) or (GetLootMethod() == "group" and isLead == 2)) and BCEPGP_ntgetn(BCEPGP_roster) > 0) or BCEPGP_debugMode then
		local success = getCombatModule(name);
		if BCEPGP_combatModule ~= "" then--BCEPGP_tContains(bossNameIndex, name, true) then -- If the npc is in the boss name index
			this:RegisterEvent("UNIT_HEALTH");
			EP = EPVALS[BCEPGP_combatModule];
			if AUTOEP[BCEPGP_combatModule] and EP > 0 then
				if success then
					if BCEPGP_combatModule ~= "Other" then
						name = BCEPGP_combatModule;
					end
					if BCEPGP_combatModule == "Kalecgos" then
						BCEPGP_AddRaidEP(EP, name .. " has been rescued! " .. EP .. " EP has been awarded to the raid", name);
					elseif BCEPGP_combatModule == "The Eredar Twins" then
						BCEPGP_AddRaidEP(EP, name .. " have been defeated! " .. EP .. " EP has been awarded to the raid", name);
					else
						BCEPGP_AddRaidEP(EP, name .. " has been defeated! " .. EP .. " EP has been awarded to the raid", name);
					end
					if STANDBYEP then
						TRAFFIC[BCEPGP_ntgetn(TRAFFIC)+1] = {"Guild", "Standby EP +" .. EP*(STANDBYPERCENT/100) .. " - " .. name};
						BCEPGP_ShareTraffic("Guild", "Standby EP +" .. EP*(STANDBYPERCENT/100) .. " - " .. name);
						BCEPGP_UpdateTrafficScrollBar();
						if BCEPGP_standby_byrank then
							for k, v in pairs(BCEPGP_roster) do -- The following module handles standby EP
								if not BCEPGP_tContains(BCEPGP_raidRoster, k, true) then -- If the player in question is NOT in the raid group, then proceed
									local pName, rank, _, _, _, _, _, _, online = GetGuildRosterInfo(BCEPGP_roster[k][1]);
									if online == 1 or STANDBYOFFLINE then
										for i = 1, table.getn(STANDBYRANKS) do
											if STANDBYRANKS[i][1] == rank then
												if STANDBYRANKS[i][2] == true then
													BCEPGP_addStandbyEP(pName, EP*(STANDBYPERCENT/100), name);
													BCEPGP_print(STANDBYPERCENT);
												end
											end
										end
									end
								end
							end
						elseif BCEPGP_standby_manual then
							for i = 1, table.getn(BCEPGP_standbyRoster) do
								BCEPGP_addStandbyEP(BCEPGP_standbyRoster[i], EP*(STANDBYPERCENT/100), name);
							end
						end
					end
				end
			end
		end
		BCEPGP_UpdateStandbyScrollBar();
	end
end

function getCombatModule(name)
	--The Opera Event, Karazhan
	if name == "Romulo" or name == "Julianne" or name == "The Crone" or name == "The Big Bad Wolf" then
		BCEPGP_print(BCEPGP_kills);
		BCEPGP_combatModule = "The Opera Event";
		if name == "Romulo" or name == "Julianne" then
			if BCEPGP_kills == 3 then
				BCEPGP_kills = 0;
				return true;
			else
				BCEPGP_kills = BCEPGP_kills + 1;
				return false;
			end
		end
		return true; --Implies that either The Crone or The Big Bad Wolf has been slain
	end
	
	--The Chess Event, Karazhan
	if name == "Warchief Blackhand" or name == "King Llane" then
		if UnitFactionGroup("player") == "Alliance" and name == "Warchief Blackhand" then
			BCEPGP_combatModule = "The Chess Event";
			return true;
		elseif UnitFactionGroup("player") == "Horde" and name == "King Llane" then
			BCEPGP_combatModule = "The Chess Event";
			return true;
		else
			return false;
		end
	end
	
	--Tempest Keep
	if name == "Al'ar" then
		BCEPGP_combatModule = "Al'ar";
		if BCEPGP_kills == 1 then
			BCEPGP_kills = 0;
			return true;
		else
			BCEPGP_kills = 1;
			return false;
		end
	end
	
	--Reliquary of Souls
	if name == "Essence of Anger" then
		BCEPGP_combatModule = "Reliquary of Souls";
		return true;
	end
	
	--Illidari Council
	if name == "Veras Darkshadow" or name == "Gathios the Shatterer" or name == "High Nethermancer Zerevor" or name == "Lady Malande" then
		BCEPGP_combatModule = "Illidari Council";
		if BCEPGP_kills < 3 then
			BCEPGP_kills = BCEPGP_kills + 1;
			return false;
		else
			return true;
		end
	end
	
	--Kalecgos
	if name == "Sathrovarr the Corruptor" then
		BCEPGP_combatModule = "Kalecgos";
		return true;
	end
	
	--The Eredar Twins
	if name == "Lady Sacrolash" or name == "Grand Warlock Alythess" then
		BCEPGP_combatModule = "The Eredar Twins";
		if BCEPGP_kills == 1 then
			return true;
		else
			BCEPGP_kills = 1;
			return false;
		end
	end
	
	--M'uru
	if name == "Entropius" then
		BCEPGP_combatModule = "M'uru";
		return true;
	end
	
	BCEPGP_combatModule = name;
	return true;
end

function BCEPGP_handleLoot(event, arg1, arg2)
	if event == "LOOT_CLOSED" then
		BCEPGP_distributing = false;
		BCEPGP_distItemLink = nil;
		getglobal("distributing"):Hide();
		if BCEPGP_mode == "loot" then
			BCEPGP_cleanTable();
			if BCEPGP_isML() == 0 then
				BCEPGP_SendAddonMsg("RaidAssistLootClosed");
			end
			HideUIPanel(BCEPGP_frame);
		end
		HideUIPanel(BCEPGP_distribute_popup);
		HideUIPanel(BCEPGP_loot_BCEPGP_distributing);
		--HideUIPanel(BCEPGP_button_loot_dist);
		HideUIPanel(BCEPGP_loot);
		HideUIPanel(BCEPGP_distribute);
		HideUIPanel(BCEPGP_loot_BCEPGP_distributing);
		if UnitInRaid("player") then
			BCEPGP_toggleFrame(BCEPGP_raid);
		elseif GetGuildRosterInfo(1) then
			BCEPGP_toggleFrame(BCEPGP_guild);
		else
			HideUIPanel(BCEPGP_frame);
			if BCEPGP_isML() == 0 then
				BCEPGP_loot_BCEPGP_distributing:Hide();
			end
		end
		
		if BCEPGP_distribute:IsVisible() == 1 then
			HideUIPanel(BCEPGP_distribute);
			ShowUIPanel(BCEPGP_loot);
			BCEPGP_responses = {};
			BCEPGP_UpdateLootScrollBar();
		end
	elseif event == "LOOT_OPENED" then --and (UnitInRaid("player") or BCEPGP_debugMode) then
		BCEPGP_LootFrame_Update();
		ShowUIPanel(BCEPGP_button_loot_dist);

	elseif event == "LOOT_SLOT_CLEARED" then
		if BCEPGP_isML() == 0 then
			BCEPGP_SendAddonMsg("RaidAssistLootClosed");
		end
		if BCEPGP_distributing and arg1 == BCEPGP_lootSlot then
			if BCEPGP_distPlayer ~= "" then
				BCEPGP_distributing = false;
				if BCEPGP_distGP then
					SendChatMessage("Awarded " .. getglobal("BCEPGP_distribute_item_name"):GetText() .. " to ".. BCEPGP_distPlayer .. " for " .. BCEPGP_distribute_GP_value:GetText() .. " GP", CHANNEL, BCEPGP_LANGUAGE);
					BCEPGP_addGP(BCEPGP_distPlayer, BCEPGP_distribute_GP_value:GetText(), true, BCEPGP_distItemLink);
				else
					SendChatMessage("Awarded " .. getglobal("BCEPGP_distribute_item_name"):GetText() .. " to ".. BCEPGP_distPlayer .. " for free", CHANNEL, BCEPGP_LANGUAGE);
				end
				BCEPGP_distPlayer = "";
				BCEPGP_distribute_popup:Hide();
				BCEPGP_distribute:Hide();
				getglobal("distributing"):Hide();
				BCEPGP_loot:Show();
			else
				BCEPGP_distributing = false;
				SendChatMessage(getglobal("BCEPGP_distribute_item_name"):GetText() .. " has been distributed without EPGP", CHANNEL, BCEPGP_LANGUAGE);
				BCEPGP_distribute_popup:Hide();
				BCEPGP_distribute:Hide();
				getglobal("distributing"):Hide();
				BCEPGP_loot:Show();
			end
		end
		BCEPGP_LootFrame_Update();
	end	
end