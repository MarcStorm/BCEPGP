--[[ Globals ]]--
BCEPGP = CreateFrame("Frame");
_G = getfenv(0);
BCEPGP_VERSION = "2.0.8";
SLASH_BCEPGP1 = "/bcepgp";
SLASH_BCEPGP2 = "/bce";
BCEPGP_VERSION_NOTIFIED = false;
BCEPGP_mode = "guild";
BCEPGP_recordholder = "";
BCEPGP_distPlayer = "";
BCEPGP_combatModule = "";
BCEPGP_distGP = false;
BCEPGP_lootSlot = nil;
BCEPGP_target = nil;
BCEPGP_DistID = nil;
BCEPGP_distSlot = nil;
BCEPGP_distItemLink = nil;
BCEPGP_debugMode = false;
BCEPGP_critReverse = false; --Criteria reverse
BCEPGP_distributing = false;
BCEPGP_overwritelog = false;
BCEPGP_override_confirm = false;
BCEPGP_confirmrestore = false;
BCEPGP_looting = false;
BCEPGP_traffic_clear = false;
BCEPGP_criteria = 4;
BCEPGP_kills = 0;
BCEPGP_frames = {BCEPGP_guild, BCEPGP_raid, BCEPGP_loot, BCEPGP_distribute, BCEPGP_options, BCEPGP_options_page_2, BCEPGP_distribute_popup, BCEPGP_context_popup, BCEPGP_save_guild_logs, BCEPGP_restore_guild_logs, BCEPGP_settings_import, BCEPGP_override, BCEPGP_traffic, BCEPGP_standby};
BCEPGP_boss_config_frames = {BCEPGP_options_page_2_karazhan, BCEPGP_options_page_2_mag_gruul_tk, BCEPGP_options_page_2_ssc, BCEPGP_options_page_2_hyjal, BCEPGP_options_page_2_bt, BCEPGP_options_page_2_swp};
BCEPGP_LANGUAGE = GetDefaultLanguage("player");
BCEPGP_responses = {};
BCEPGP_itemsTable = {};
BCEPGP_roster = {};
BCEPGP_standbyRoster = {};
BCEPGP_raidRoster = {};
BCEPGP_vInfo = {};
BCEPGP_vSearch = "GUILD";
BCEPGP_groupVersion = {};
BCEPGP_ElvUI = nil; --nil or 1

--[[ SAVED VARIABLES ]]--
CHANNEL = nil;
MOD = nil;
COEF = nil;
BASEGP = nil;
STANDBYEP = false;
STANDBYOFFLINE = false;
BCEPGP_standby_accept_whispers = false;
BCEPGP_standby_whisper_msg = "!standby";
BCEPGP_standby_byrank = true;
BCEPGP_standby_manual = false;
STANDBYPERCENT = nil;
STANDBYRANKS = {};
SLOTWEIGHTS = {};
DEFSLOTWEIGHTS = {["2HWEAPON"] = 2,["WEAPONMAINHAND"] = 1.5,["WEAPON"] = 1.5,["WEAPONOFFHAND"] = 0.5,["HOLDABLE"] = 0.5,["SHIELD"] = 0.5,["RANGED"] = 0.5,["RANGEDRIGHT"] = 0.5,["RELIC"] = 0.5,["HEAD"] = 1,["NECK"] = 0.5,["SHOULDER"] = 0.75,["CLOAK"] = 0.5,["CHEST"] = 1,["ROBE"] = 1,["WRIST"] = 0.5,["HAND"] = 0.75,["WAIST"] = 0.75,["LEGS"] = 1,["FEET"] = 0.75,["FINGER"] = 0.5,["TRINKET"] = 0.75};
AUTOEP = {};
EPVALS = {};
RECORDS = {};
OVERRIDE_INDEX = {};
TRAFFIC = {};



--[[ EVENT AND COMMAND HANDLER ]]--

function BCEPGP_OnEvent()
	if event == "ADDON_LOADED" and arg1 == "BCEPGP" then --arg1 = addon name
		BCEPGP_initialise();
		
	elseif event == "GUILD_ROSTER_UPDATE" or event == "RAID_ROSTER_UPDATE" then
		BCEPGP_rosterUpdate(event);
		
	elseif event == "CHAT_MSG_WHISPER" and string.lower(arg1) == BCEPGP_standby_whisper_msg and BCEPGP_standby_manual and BCEPGP_standby_accept_whispers then
		if not BCEPGP_tContains(BCEPGP_standbyRoster, arg2)
		and not BCEPGP_tContains(BCEPGP_raidRoster, arg2, true)
		and BCEPGP_tContains(BCEPGP_roster, arg2, true) then
			BCEPGP_addToStandby(arg2);
		end
			
	
	elseif (event == "CHAT_MSG_WHISPER" and string.lower(arg1) == "!need" and BCEPGP_distributing) or
		(event == "CHAT_MSG_WHISPER" and string.lower(arg1) == "!info") or
		(event == "CHAT_MSG_WHISPER" and (string.lower(arg1) == "!infoguild" or string.lower(arg1) == "!inforaid" or string.lower(arg1) == "!infoclass")) then
			BCEPGP_handleComms(event, arg1, arg2);
	
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		if arg2 == "UNIT_DIED" or arg2 == "UNIT_DESTROYED" then
			BCEPGP_handleCombat(event, arg7);
		end
		
	elseif (event == "LOOT_OPENED" or event == "LOOT_CLOSED" or event == "LOOT_SLOT_CLEARED") then
		BCEPGP_handleLoot(event, arg1, arg2);
		
	elseif (event == "CHAT_MSG_ADDON") then
		if (arg1 == "BCEPGP")then
			BCEPGP_IncAddonMsg(arg2, arg4);
		end
	elseif event == "UNIT_HEALTH" then -- Player has been removed from combat. Shouldn't trigger for feign death / vanish / combat res
		if not UnitAffectingCombat("player") and not UnitIsDead("player") then
			if BCEPGP_debugMode then
				BCEPGP_print("Combat reset");
			end
			BCEPGP_kills = 0;
			this:UnregisterEvent("UNIT_HEALTH");
		end
	end
end

function SlashCmdList.BCEPGP(msg, editbox)
	msg = string.lower(msg);
	
	if msg == "" then
		BCEPGP_print("Burning Crusade EPGP Usage");
		BCEPGP_print("|cFF80FF80show|r - |cFFFF8080Manually shows the BCEPGP window|r");
		BCEPGP_print("|cFF80FF80setDefaultChannel channel|r - |cFFFF8080Sets the default channel to send confirmation messages. Default is Guild|r");
		BCEPGP_print("|cFF80FF80version|r - |cFFFF8080Checks the version of the addon everyone in your raid is running|r");
		
	elseif msg == "show" then
		BCEPGP_populateFrame();
		ShowUIPanel(BCEPGP_frame);
		BCEPGP_updateGuild();
	
	elseif msg == "version" then
		BCEPGP_vInfo = {};
		BCEPGP_SendAddonMsg("version-check", BCEPGP_vSearch);
		ShowUIPanel(BCEPGP_version);
	
	elseif strfind(msg, "currentchannel") then
		BCEPGP_print("Current channel to report: " .. getCurChannel());
		
	elseif strfind(msg, "debug") then
		BCEPGP_debugMode = not BCEPGP_debugMode;
		if BCEPGP_debugMode then
			BCEPGP_print("Debug Mode Enabled");
		else
			BCEPGP_print("Debug Mode Disabled");
		end
	
	elseif strfind(msg, "setdefaultchannel") then
		if msg == "setdefaultchannel" or msg == "setdefaultchannel " then
			BCEPGP_print("|cFF80FFFFPlease enter a valid  channel. Valid options are:|r");
			BCEPGP_print("|cFF80FFFFsay, yell, party, raid, guild, officer|r");
			return;
		end
		local newChannel = BCEPGP_getVal(msg);
		newChannel = strupper(newChannel);
		local valid = false;
		local channels = {"SAY","YELL","PARTY","RAID","GUILD","OFFICER"};
		local i = 1;
		while channels[i] ~= nil do
			if channels[i] == newChannel then
				valid = true;
			end
			i = i + 1;
		end
		
		if valid then
			CHANNEL = newChannel;
			BCEPGP_print("Default channel set to: " .. CHANNEL);
		else
			BCEPGP_print("Please enter a valid chat channel. Valid options are:");
			BCEPGP_print("say, yell, party, raid, guild, officer");
		end
	else
		BCEPGP_print("|cFF80FF80" .. msg .. "|r |cFFFF8080is not a valid request. Type /bcepgp to check addon usage|r", true);
	end
end

--[[ LOOT COUNCIL FUNCTIONS ]]--

function BCEPGP_RaidAssistLootClosed()
	if IsRaidOfficer() then
		HideUIPanel(BCEPGP_distribute_popup);
		HideUIPanel(BCEPGP_distribute);
		HideUIPanel(BCEPGP_loot_BCEPGP_distributing);
		HideUIPanel(distributing);
		BCEPGP_distribute_item_tex:SetBackdrop(nil);
		_G["BCEPGP_distribute_item_tex"]:SetScript('OnEnter', function() end);
		_G["BCEPGP_distribute_item_name_frame"]:SetScript('OnClick', function() end);
		for y = 1, 18 do
			getglobal("LootDistButton"..y):Hide();
			getglobal("LootDistButton" .. y .. "Info"):SetText("");
			getglobal("LootDistButton" .. y .. "Class"):SetText("");
			getglobal("LootDistButton" .. y .. "Rank"):SetText("");
			getglobal("LootDistButton" .. y .. "EP"):SetText("");
			getglobal("LootDistButton" .. y .. "GP"):SetText("");
			getglobal("LootDistButton" .. y .. "PR"):SetText("");
			getglobal("LootDistButton" .. y .. "Tex"):SetBackdrop(nil);
			getglobal("LootDistButton" .. y .. "Tex2"):SetBackdrop(nil);
		end
	end
end

function BCEPGP_RaidAssistLootDist(link, gp)
	if IsRaidOfficer() then
		local y = 1;
		for y = 1, 18 do
			getglobal("LootDistButton"..y):Hide();
			getglobal("LootDistButton" .. y .. "Info"):SetText("");
			getglobal("LootDistButton" .. y .. "Class"):SetText("");
			getglobal("LootDistButton" .. y .. "Rank"):SetText("");
			getglobal("LootDistButton" .. y .. "EP"):SetText("");
			getglobal("LootDistButton" .. y .. "GP"):SetText("");
			getglobal("LootDistButton" .. y .. "PR"):SetText("");
			getglobal("LootDistButton" .. y .. "Tex"):SetBackdrop(nil);
			getglobal("LootDistButton" .. y .. "Tex2"):SetBackdrop(nil);
			y = y + 1;
		end
		BCEPGP_itemsTable = {};
		local name, iString, _, _, _, _, _, _, slot, tex = GetItemInfo(BCEPGP_getItemString(link));
		BCEPGP_DistID = BCEPGP_getItemID(iString);
		BCEPGP_distSlot = slot;
		if not BCEPGP_DistID then
			BCEPGP_print("Item not found in game cache. You must see the item in-game before item info can be retrieved and CEPGP will not be able to retrieve what items recipients are wearing in that slot", true);
		end
		tex = {bgFile = tex,};
		

		BCEPGP_responses = {};
		ShowUIPanel(distributing);
		_G["BCEPGP_distribute_item_name"]:SetText(link);
		if iString then
			_G["BCEPGP_distribute_item_tex"]:SetScript('OnEnter', function() GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT") GameTooltip:SetHyperlink(iString) GameTooltip:Show() end);
			_G["BCEPGP_distribute_item_tex"]:SetBackdrop(tex);
			_G["BCEPGP_distribute_item_name_frame"]:SetScript('OnClick', function() SetItemRef(iString) end);
		else
			_G["BCEPGP_distribute_item_tex"]:SetScript('OnEnter', function() end);
		end
		_G["BCEPGP_distribute_item_tex"]:SetScript('OnLeave', function() GameTooltip:Hide() end);
		_G["BCEPGP_distribute_GP_value"]:SetText(gp);
	end
end

--[[ ADD EPGP FUNCTIONS ]]--

function BCEPGP_AddRaidEP(amount, msg, encounter)
	amount = math.floor(amount);
	if not GetGuildRosterShowOffline() then
		SetGuildRosterShowOffline(true);
		local total = GetNumRaidMembers();
		if total > 0 then
			for i = 1, total do
				local name = GetRaidRosterInfo(i);
				if BCEPGP_tContains(BCEPGP_roster, name, true) then
					local index = BCEPGP_getGuildInfo(name);
					if not BCEPGP_checkEPGP(BCEPGP_roster[name][5]) then
						GuildRosterSetOfficerNote(index, amount .. "," .. BASEGP);
					else
						EP,GP = BCEPGP_getEPGP(BCEPGP_roster[name][5]);
						EP = tonumber(EP);
						GP = tonumber(GP);
						EP = EP + amount;
						if GP < BASEGP then
							GP = BASEGP;
						end
						if EP < 0 then
							EP = 0;
						end
						GuildRosterSetOfficerNote(index, EP .. "," .. GP);
					end
				end
			end
		end
		SetGuildRosterShowOffline(false);
	else
		local total = GetNumRaidMembers();
		if total > 0 then
			for i = 1, total do
				local name = GetRaidRosterInfo(i);
				if BCEPGP_tContains(BCEPGP_roster, name, true) then
					local index = BCEPGP_getGuildInfo(name);
					if not BCEPGP_checkEPGP(BCEPGP_roster[name][5]) then
						GuildRosterSetOfficerNote(index, amount .. "," .. BASEGP);
					else
						EP,GP = BCEPGP_getEPGP(BCEPGP_roster[name][5]);
						EP = tonumber(EP);
						GP = tonumber(GP);
						EP = EP + amount;
						if GP < BASEGP then
							GP = BASEGP;
						end
						if EP < 0 then
							EP = 0;
						end
						GuildRosterSetOfficerNote(index, EP .. "," .. GP);
					end
				end
			end
		end
	end
	if msg then
		BCEPGP_SendAddonMsg("update");
		TRAFFIC[BCEPGP_ntgetn(TRAFFIC)+1] = {"Raid", "Add Raid EP +" .. amount .. " - " .. encounter};
		BCEPGP_ShareTraffic("Raid", "Add Raid EP +" .. amount .. " - " .. encounter);
		SendChatMessage(msg, "RAID", BCEPGP_LANGUAGE);
	else
		BCEPGP_SendAddonMsg("update");
		TRAFFIC[BCEPGP_ntgetn(TRAFFIC)+1] = {"Raid", "Add Raid EP +" .. amount};
		BCEPGP_ShareTraffic("Raid", "Add Raid EP +" .. amount);
		SendChatMessage(amount .. " EP awarded to all raid members", CHANNEL, BCEPGP_LANGUAGE);
	end
	BCEPGP_UpdateTrafficScrollBar();
end

function BCEPGP_addGuildEP(amount)
	if amount == nil then
		BCEPGP_print("Please enter a valid number", 1);
		return;
	end
	if GetGuildRosterShowOffline() == nil then
		SetGuildRosterShowOffline(true);
		local total = BCEPGP_ntgetn(BCEPGP_roster);
		local EP, GP = nil;
		amount = math.floor(amount);
		if total > 0 then
			for name,_ in pairs(BCEPGP_roster)do
				offNote = BCEPGP_roster[name][5];
				index = BCEPGP_roster[name][1];
				if offNote == "" or offNote == "Click here to set an Officer's Note" then
					BCEPGP_print("Initialising EPGP values for " .. name);
					GuildRosterSetOfficerNote(index, amount .. "," .. BASEGP);
				else
					EP,GP = BCEPGP_getEPGP(BCEPGP_roster[name][5]);
					EP = tonumber(EP) + amount;
					GP = tonumber(GP);
					if GP < BASEGP then
						GP = BASEGP;
					end
					if EP < 0 then
						EP = 0;
					end
					GuildRosterSetOfficerNote(index, EP .. "," .. GP);
				end
			end
		end
		SetGuildRosterShowOffline(false);
	else
		local total = BCEPGP_ntgetn(BCEPGP_roster);
		local EP, GP = nil;
		amount = math.floor(amount);
		if total > 0 then
			for name,_ in pairs(BCEPGP_roster)do
				offNote = BCEPGP_roster[name][5];
				index = BCEPGP_roster[name][1];
				if offNote == "" or offNote == "Click here to set an Officer's Note" then
					BCEPGP_print("Initialising EPGP values for " .. name);
					GuildRosterSetOfficerNote(index, amount .. "," .. BASEGP);
				else
					EP,GP = BCEPGP_getEPGP(BCEPGP_roster[name][5]);
					EP = tonumber(EP) + amount;
					GP = tonumber(GP);
					if GP < BASEGP then
						GP = BASEGP;
					end
					if EP < 0 then
						EP = 0;
					end
					GuildRosterSetOfficerNote(index, EP .. "," .. GP);
				end
			end
		end		
	end
	BCEPGP_SendAddonMsg("update");
	TRAFFIC[BCEPGP_ntgetn(TRAFFIC)+1] = {"Guild", "Add Guild EP +" .. amount};
	BCEPGP_ShareTraffic("Guild", "Add Guild EP +" .. amount);
	BCEPGP_UpdateTrafficScrollBar();
	SendChatMessage(amount .. " EP awarded to all guild members", CHANNEL, BCEPGP_LANGUAGE);
end

function BCEPGP_addStandbyEP(player, amount, boss)
	if amount == nil then
		BCEPGP_print("Please enter a valid number", 1);
		return;
	end
	local EP, GP = nil;
	amount = (math.floor(amount*100))/100;
	local name = BCEPGP_getGuildInfo(player);
	EP,GP = BCEPGP_getEPGP(BCEPGP_roster[player][5]);
	EP = tonumber(EP) + amount;
	GP = tonumber(GP);
	if GP < BASEGP then
		GP = BASEGP;
	end
	if EP < 0 then
		EP = 0;
	end
	if offNote == "" or offNote == "Click here to set an Officer's Note" then
		BCEPGP_print("Initialising EPGP values for " .. BCEPGP_roster[player][1]);
		GuildRosterSetOfficerNote(BCEPGP_roster[player][1], EP .. "," .. BASEGP);
	else
		GuildRosterSetOfficerNote(BCEPGP_roster[player][1], EP .. "," .. GP);
	end
	BCEPGP_SendAddonMsg("update");
	BCEPGP_SendAddonMsg("STANDBYEP"..player..",You have been awarded "..amount.." standby EP for encounter " .. boss, "GUILD");
end

function BCEPGP_addGP(player, amount, item, itemLink)
	if amount == nil then
		BCEPGP_print("Please enter a valid number", 1);
		return;
	end
	local EP, GP = nil;
	amount = math.floor(amount);
	if BCEPGP_tContains(BCEPGP_roster, player, true) then
		offNote = BCEPGP_roster[player][5];
		index = BCEPGP_roster[player][1];
		if offNote == "" or offNote == "Click here to set an Officer's Note" then
			BCEPGP_print("Initialising EPGP values for " .. player);
			GuildRosterSetOfficerNote(index, "0," .. BASEGP);
			offNote = "0," .. BASEGP;
		end
		EP,GP = BCEPGP_getEPGP(offNote);
		TRAFFIC[BCEPGP_ntgetn(TRAFFIC)+1] = {
			[1] = player,
			[2] = "Add GP +" .. amount,
			[3] = EP,
			[4] = EP,
			[5] = GP,
			[6] = GP + amount
		};
		if itemLink then
			TRAFFIC[BCEPGP_ntgetn(TRAFFIC)][7] = itemLink;
		end
		BCEPGP_ShareTraffic(player, "Add GP +" .. amount, EP, EP, GP, GP + amount, BCEPGP_getItemID(BCEPGP_getItemString(itemLink)));
		BCEPGP_UpdateTrafficScrollBar();
		GP = tonumber(GP) + amount;
		EP = tonumber(EP);
		if GP < BASEGP then
			GP = BASEGP;
		end
		if EP < 0 then
			EP = 0;
		end
		GuildRosterSetOfficerNote(index, EP .. "," .. GP);
		BCEPGP_SendAddonMsg("update");
		if not item then
			SendChatMessage(amount .. " GP added to " .. player, CHANNEL, BCEPGP_LANGUAGE, CHANNEL);
		end
	else
		BCEPGP_print(player .. " not found in guild BCEPGP_roster - no GP given");
		BCEPGP_print("If this was a mistake, you can manually award them GP via the CEPGP guild menu");
	end
end

function BCEPGP_addEP(player, amount)
	if amount == nil then
		BCEPGP_print("Please enter a valid number", 1);
		return;
	end
	amount = math.floor(amount);
	local EP, GP = nil;
	if BCEPGP_tContains(BCEPGP_roster, player, true) then
		offNote = BCEPGP_roster[player][5];
		index = BCEPGP_roster[player][1];
		if offNote == "" or offNote == "Click here to set an Officer's Note" then
			BCEPGP_print("Initialising EPGP values for " .. player);
			GuildRosterSetOfficerNote(index, "0," .. BASEGP);
			offNote = "0," .. BASEGP;
		end
		EP,GP = BCEPGP_getEPGP(offNote);
		TRAFFIC[BCEPGP_ntgetn(TRAFFIC)+1] = {
			[1] = player,
			[2] = "Add EP +" .. amount,
			[3] = EP,
			[4] = EP + amount,
			[5] = GP,
			[6] = GP
		};
		BCEPGP_ShareTraffic(player, "Add EP +" .. amount, EP, EP + amount, GP, GP);
		BCEPGP_UpdateTrafficScrollBar();
		EP = tonumber(EP) + amount;
		GP = tonumber(GP);
		if GP < BASEGP then
			GP = BASEGP;
		end
		if EP < 0 then
			EP = 0;
		end
		GuildRosterSetOfficerNote(index, EP .. "," .. GP);
		BCEPGP_SendAddonMsg("update");
		SendChatMessage(amount .. " EP added to " .. player, CHANNEL, BCEPGP_LANGUAGE, CHANNEL);
	else
		BCEPGP_print("Player not found in guild BCEPGP_roster.", true);
	end
end

function BCEPGP_decay(amount)
	if amount == nil then
		BCEPGP_print("Please enter a valid number", 1);
		return;
	end
	if GetGuildRosterShowOffline() == nil then
		SetGuildRosterShowOffline(true);
		BCEPGP_updateGuild();
		local EP, GP = nil;
		for name,_ in pairs(BCEPGP_roster)do
			EP, GP = BCEPGP_getEPGP(BCEPGP_roster[name][5]);
			index = BCEPGP_roster[name][1];
			--[[if offNote == "" then
				GuildRosterSetOfficerNote(index, 0 .. "," .. BASEGP);
			else]]
				--EP,GP = BCEPGP_getEPGP(offNote);
				EP = math.floor(tonumber(EP)*(1-(amount/100)));
				GP = math.floor(tonumber(GP)*(1-(amount/100)));
				if GP < BASEGP then
					GP = BASEGP;
				end
				if EP < 0 then
					EP = 0;
				end
				GuildRosterSetOfficerNote(index, EP .. "," .. GP);
			--end
		end
		SetGuildRosterShowOffline(false);
	else
		BCEPGP_updateGuild();
		local EP, GP = nil;
		for name,_ in pairs(BCEPGP_roster)do
			EP, GP = BCEPGP_getEPGP(BCEPGP_roster[name][5]);
			index = BCEPGP_roster[name][1];
			--[[if offNote == "" then
				GuildRosterSetOfficerNote(index, 0 .. "," .. BASEGP);
			else]]
				--EP,GP = BCEPGP_getEPGP(offNote);
				EP = math.floor(tonumber(EP)*(1-(amount/100)));
				GP = math.floor(tonumber(GP)*(1-(amount/100)));
				if GP < BASEGP then
					GP = BASEGP;
				end
				if EP < 0 then
					EP = 0;
				end
				GuildRosterSetOfficerNote(index, EP .. "," .. GP);
			--end
		end
	end
	BCEPGP_SendAddonMsg("update");
	TRAFFIC[BCEPGP_ntgetn(TRAFFIC)+1] = {"Guild", "Decay EPGP -" .. amount .. "%"}; 
	BCEPGP_ShareTraffic("Guild", "Decay EPGP -" .. amount .. "%");
	BCEPGP_UpdateTrafficScrollBar();
	SendChatMessage("Guild EPGP decayed by " .. amount .. "%", CHANNEL, BCEPGP_LANGUAGE, CHANNEL);
	
end

function BCEPGP_resetAll()
	if GetGuildRosterShowOffline() == nil then
		SetGuildRosterShowOffline(true);
		local total = BCEPGP_ntgetn(BCEPGP_roster);
		if total > 0 then
			for i = 1, total, 1 do
				GuildRosterSetOfficerNote(i, "0,"..BASEGP);
			end
		end
		SetGuildRosterShowOffline(false);
	else
		local total = BCEPGP_ntgetn(BCEPGP_roster);
		if total > 0 then
			for i = 1, total, 1 do
				GuildRosterSetOfficerNote(i, "0,"..BASEGP);
			end
		end
	end
	BCEPGP_SendAddonMsg("update");
	TRAFFIC[BCEPGP_ntgetn(TRAFFIC)+1] = {"Guild", "Cleared EPGP standings"};
	BCEPGP_ShareTraffic("Guild", "Cleared EPGP standings");
	BCEPGP_UpdateTrafficScrollBar();
	SendChatMessage("All EPGP standings have been cleared!", "GUILD", BCEPGP_LANGUAGE);
end