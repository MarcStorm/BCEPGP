function BCEPGP_ListButton_OnClick()
	local obj = this:GetName();
	
	if strfind(obj, "Delete") then
		local name = getglobal("BCEPGP_overrideButton" .. this:GetParent():GetID() .. "item"):GetText();
		OVERRIDE_INDEX[name] = nil;
		BCEPGP_print(name .. " removed from GP BCEPGP_override");
		BCEPGP_UpdateOverrideScrollBar();
		return;
	end
	
	if CanEditOfficerNote() == nil and not BCEPGP_debugMode then
		BCEPGP_print("You don't have access to modify EPGP", 1);
		return;
	end
	
	--[[ Distribution Menu ]]--
	if strfind(obj, "LootDistButton") then --A player in the distribution menu is clicked
		ShowUIPanel(BCEPGP_distribute_popup);
		BCEPGP_distribute_popup_title:SetText(getglobal(this:GetName() .. "Info"):GetText());
		BCEPGP_distPlayer = getglobal(this:GetName() .. "Info"):GetText();
		BCEPGP_distribute_popup:SetID(BCEPGP_distribute:GetID()); --BCEPGP_distribute:GetID gets the ID of the LOOT SLOT. Not the player.
	
		--[[ Guild Menu ]]--
	elseif strfind(obj, "GuildButton") then --A player from the guild menu is clicked (awards EP)
		local name = getglobal(this:GetName() .. "Info"):GetText();
		ShowUIPanel(BCEPGP_context_popup);
		ShowUIPanel(BCEPGP_context_amount);
		ShowUIPanel(BCEPGP_context_popup_EP_check);
		ShowUIPanel(BCEPGP_context_popup_GP_check);
		getglobal("BCEPGP_context_popup_EP_check_text"):Show();
		getglobal("BCEPGP_context_popup_GP_check_text"):Show();
		BCEPGP_context_popup_EP_check:SetChecked(1);
		BCEPGP_context_popup_GP_check:SetChecked(nil);
		BCEPGP_context_popup_header:SetText("Guild Moderation");
		BCEPGP_context_popup_title:SetText("Add EP/GP to " .. name);
		BCEPGP_context_popup_desc:SetText("Adding EP");
		BCEPGP_context_amount:SetText("0");
		BCEPGP_context_amount:SetNumeric(true);
		BCEPGP_context_popup_confirm:SetScript('OnClick', function()
															PlaySound("gsTitleOptionExit");
															HideUIPanel(BCEPGP_context_popup);
															if BCEPGP_context_popup_EP_check:GetChecked() then
																BCEPGP_addEP(name, tonumber(BCEPGP_context_amount:GetText()));
															else
																BCEPGP_addGP(name, tonumber(BCEPGP_context_amount:GetText()));
															end
														end);
		
	elseif strfind(obj, "BCEPGP_guild_add_EP") then --Click the Add Guild EP button in the Guild menu
		ShowUIPanel(BCEPGP_context_popup);
		ShowUIPanel(BCEPGP_context_amount);
		ShowUIPanel(BCEPGP_context_popup_EP_check);
		HideUIPanel(BCEPGP_context_popup_GP_check);
		getglobal("BCEPGP_context_popup_EP_check_text"):Show();
		getglobal("BCEPGP_context_popup_GP_check_text"):Hide();
		BCEPGP_context_popup_EP_check:SetChecked(1);
		BCEPGP_context_popup_GP_check:SetChecked(nil);
		BCEPGP_context_popup_header:SetText("Guild Moderation");
		BCEPGP_context_popup_title:SetText("Add Guild EP");
		BCEPGP_context_popup_desc:SetText("Adds EP to all guild members");
		BCEPGP_context_amount:SetText("0");
		BCEPGP_context_amount:SetNumeric(true);
		BCEPGP_context_popup_confirm:SetScript('OnClick', function()
															PlaySound("gsTitleOptionExit");
															HideUIPanel(BCEPGP_context_popup);
															BCEPGP_addGuildEP(tonumber(BCEPGP_context_amount:GetText()));
														end);
	
	elseif strfind(obj, "BCEPGP_guild_decay") then --Click the Decay Guild EPGP button in the Guild menu
		ShowUIPanel(BCEPGP_context_popup);
		ShowUIPanel(BCEPGP_context_amount);
		HideUIPanel(BCEPGP_context_popup_EP_check);
		HideUIPanel(BCEPGP_context_popup_GP_check);
		getglobal("BCEPGP_context_popup_EP_check_text"):Hide();
		getglobal("BCEPGP_context_popup_GP_check_text"):Hide();
		BCEPGP_context_popup_EP_check:SetChecked(nil);
		BCEPGP_context_popup_GP_check:SetChecked(nil);
		BCEPGP_context_popup_header:SetText("Guild Moderation");
		BCEPGP_context_popup_title:SetText("Decay Guild EPGP");
		BCEPGP_context_popup_desc:SetText("Decays EPGP standings by a percentage\nValid Range: 0-100");
		BCEPGP_context_amount:SetText("0");
		BCEPGP_context_amount:SetNumeric(true);
		BCEPGP_context_popup_confirm:SetScript('OnClick', function()
															PlaySound("gsTitleOptionExit");
															HideUIPanel(BCEPGP_context_popup);
															BCEPGP_decay(tonumber(BCEPGP_context_amount:GetText()));
														end);
		
	elseif strfind(obj, "BCEPGP_guild_reset") then --Click the Reset All EPGP Standings button in the Guild menu
		ShowUIPanel(BCEPGP_context_popup);
		HideUIPanel(BCEPGP_context_amount);
		HideUIPanel(BCEPGP_context_popup_EP_check);
		HideUIPanel(BCEPGP_context_popup_GP_check);
		getglobal("BCEPGP_context_popup_EP_check_text"):Hide();
		getglobal("BCEPGP_context_popup_GP_check_text"):Hide();
		BCEPGP_context_popup_EP_check:SetChecked(nil);
		BCEPGP_context_popup_GP_check:SetChecked(nil);
		BCEPGP_context_popup_header:SetText("Guild Moderation");
		BCEPGP_context_popup_title:SetText("Reset Guild EPGP");
		BCEPGP_context_popup_desc:SetText("Resets the Guild EPGP standings\n|c00FF0000Are you sure this is what you want to do?\nThis cannot be reversed!\nNote: This will report to Guild chat|r");
		BCEPGP_context_popup_confirm:SetScript('OnClick', function()
															PlaySound("gsTitleOptionExit");
															HideUIPanel(BCEPGP_context_popup);
															BCEPGP_resetAll();
														end)
		
		--[[ Raid Menu ]]--
	elseif strfind(obj, "RaidButton") then --A player from the raid menu is clicked (awards EP)
		local name = getglobal(this:GetName() .. "Info"):GetText();
		if not BCEPGP_getGuildInfo(name) then
			BCEPGP_print(name .. " is not a guild member - Cannot award EP or GP", true);
			return;
		end
		ShowUIPanel(BCEPGP_context_popup);
		ShowUIPanel(BCEPGP_context_amount);
		ShowUIPanel(BCEPGP_context_popup_EP_check);
		ShowUIPanel(BCEPGP_context_popup_GP_check);
		getglobal("BCEPGP_context_popup_EP_check_text"):Show();
		getglobal("BCEPGP_context_popup_GP_check_text"):Show();
		BCEPGP_context_popup_EP_check:SetChecked(1);
		BCEPGP_context_popup_GP_check:SetChecked(nil);
		BCEPGP_context_popup_header:SetText("Raid Moderation");
		BCEPGP_context_popup_title:SetText("Add EP/GP to " .. name);
		BCEPGP_context_popup_desc:SetText("Adding EP");
		BCEPGP_context_amount:SetText("0");
		BCEPGP_context_amount:SetNumeric(true);
		BCEPGP_context_popup_confirm:SetScript('OnClick', function()
															PlaySound("gsTitleOptionExit");
															HideUIPanel(BCEPGP_context_popup);
															if BCEPGP_context_popup_EP_check:GetChecked() then
																BCEPGP_addEP(name, tonumber(BCEPGP_context_amount:GetText()));
															else
																BCEPGP_addGP(name, tonumber(BCEPGP_context_amount:GetText()));
															end
														end);
	
	elseif strfind(obj, "BCEPGP_raid_add_EP") then --Click the Add Raid EP button in the Raid menu
		ShowUIPanel(BCEPGP_context_popup);
		ShowUIPanel(BCEPGP_context_amount);
		HideUIPanel(BCEPGP_context_popup_EP_check);
		HideUIPanel(BCEPGP_context_popup_GP_check);
		getglobal("BCEPGP_context_popup_EP_check_text"):Hide();
		getglobal("BCEPGP_context_popup_GP_check_text"):Hide();
		BCEPGP_context_popup_EP_check:SetChecked(nil);
		BCEPGP_context_popup_GP_check:SetChecked(nil);
		BCEPGP_context_popup_header:SetText("Raid Moderation");
		BCEPGP_context_popup_title:SetText("Award Raid EP");
		BCEPGP_context_popup_desc:SetText("Adds an amount of EP to the entire raid");
		BCEPGP_context_amount:SetText("0");
		BCEPGP_context_amount:SetNumeric(true);
		BCEPGP_context_popup_confirm:SetScript('OnClick', function()
															PlaySound("gsTitleOptionExit");
															HideUIPanel(BCEPGP_context_popup);
															BCEPGP_AddRaidEP(tonumber(BCEPGP_context_amount:GetText()));
														end);
	elseif strfind(obj, "BCEPGP_standby_ep_list_add") then
		BCEPGP_context_popup_EP_check:Hide();
		BCEPGP_context_popup_GP_check:Hide();
		getglobal("BCEPGP_context_popup_EP_check_text"):Hide();
		getglobal("BCEPGP_context_popup_GP_check_text"):Hide();
		BCEPGP_context_popup_header:SetText("Add to Standby");
		BCEPGP_context_popup_title:Hide();
		BCEPGP_context_popup_desc:SetText("Add a guild member to the standby list");
		BCEPGP_context_amount:SetText("");
		BCEPGP_context_popup_confirm:SetScript('OnClick', function()
															PlaySound("gsTitleOptionExit");
															HideUIPanel(BCEPGP_context_popup);
															BCEPGP_addToStandby(BCEPGP_context_amount:GetText());
														end);
	elseif strfind(obj, "BCEPGP_StandbyButton") then
		local name = getglobal(getglobal(this:GetName()):GetParent():GetName() .. "Info"):GetText();
		for i = 1, BCEPGP_ntgetn(BCEPGP_standbyRoster) do
			if BCEPGP_standbyRoster[i] == name then
				table.remove(BCEPGP_standbyRoster, i);
			end
		end
		BCEPGP_UpdateStandbyScrollBar();
	else
		--BCEPGP_print(obj);
	end
end

function BCEPGP_setOverrideLink(arg1, arg2)
	local name = arg1;
	local event = arg2;
	if event == "enter" then
		local _, item = GetItemInfo(getglobal(arg1):GetText());
		GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT");
		GameTooltip:SetHyperlink(item);
		GameTooltip:Show()
	else
		GameTooltip:Hide();
	end
end

function BCEPGP_distribute_popup_give()
	for i = 1, 40 do
		if GetMasterLootCandidate(i) == BCEPGP_distPlayer then
			GiveMasterLoot(BCEPGP_lootSlot, i);
			return;
		end
	end
	BCEPGP_print(BCEPGP_distPlayer .. " is not on the candidate list for loot", true);
end

function BCEPGP_distribute_popup_OnEvent(event)
	if event == "CHAT_MSG_LOOT" then
		BCEPGP_distPlayer = string.sub(arg1, 0, string.find(arg1, " ")-1);
		if BCEPGP_distPlayer == "You" then
			BCEPGP_distPlayer = UnitName("player");
		end
	end
	if BCEPGP_distributing then
		if event == "UI_ERROR_MESSAGE" and arg1 == "Inventory is full." and BCEPGP_distPlayer ~= "" then
			BCEPGP_print(BCEPGP_distPlayer .. "'s inventory is full", 1);
			BCEPGP_distribute_popup:Hide();
		elseif event == "UI_ERROR_MESSAGE" and arg1 == "You can't carry any more of those items." and BCEPGP_distPlayer ~= "" then
			BCEPGP_print(BCEPGP_distPlayer .. " can't carry any more of this unique item", 1);
			BCEPGP_distribute_popup:Hide();
		end
	end
end

function BCEPGP_initRestoreDropdown(level, menuList, search)
	for k, _ in pairs(RECORDS) do
		local entry = UIDropDownMenu_CreateInfo();
		entry.text = k;
		entry.func = BCEPGP_restoreDropdownOnClick;
		UIDropDownMenu_AddButton(entry);
	end
end

function BCEPGP_restoreDropdownOnClick()
	if (not checked) then
		UIDropDownMenu_SetSelectedName(BCEPGP_restoreDropdown, this:GetText());
	end
end