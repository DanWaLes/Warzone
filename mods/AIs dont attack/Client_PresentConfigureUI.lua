-- copied from https://github.com/DanWaLes/Warzone/tree/master/mods/libs/AutoSettingsFiles

require('__settings');

local modDevMadeError = false;

GLOBALS = {};

function Client_PresentConfigureUI(rootParent)
	if type(getSettings) ~= 'function' then
		getSettings = function()
			return nil;
		end;
	end

	local root = UI.CreateVerticalLayoutGroup(rootParent);

	cpc(root, getSettings());

	if not modDevMadeError then
		return;
	end

	GLOBALS = {};

	if (WL and WL.IsVersionOrHigher and WL.IsVersionOrHigher('5.21')) then
		UI.Destroy(root);
	end

	UI.CreateLabel(rootParent).SetText('The mod developer made an error while trying to add settings');
end

function cpc(parent, settings)
	if type(settings) ~= 'table' then
		modDevMadeError = true;
	end

	if modDevMadeError then
		return;
	end

	local vert = UI.CreateVerticalLayoutGroup(parent);

	for _, setting in ipairs(settings) do
		if type(setting) ~= 'table' then
			modDevMadeError = true;

			return;
		end

		if setting.isTemplate then
			GLOBALS[setting.name] = Mod.Settings[setting.name] or 0;

			local vert2 = UI.CreateVerticalLayoutGroup(vert);
			local i = 1;

			while i < (GLOBALS[setting.name] + 1) do
				cpcDoSetting(vert2, setting.get(i));
				i = i + 1;
			end

			local btn = UI.CreateButton(vert).SetColor(setting.btnColor or '#00FF05').SetText(setting.btnText);

			if setting.btnTextColor then
				btn.SetTextColor(setting.btnTextColor);
			end

			btn.SetOnClick(function()
				GLOBALS[setting.name] = GLOBALS[setting.name] + 1;
				cpcDoSetting(vert2, setting.get(GLOBALS[setting.name]));
			end);
		else
			cpcDoSetting(vert, setting);
		end
	end
end

function cpcDoSetting(vert, setting)
	local horz = UI.CreateHorizontalLayoutGroup(vert);
	local vert2 = UI.CreateVerticalLayoutGroup(vert);

	if setting.isGroup then
		local btn = UI.CreateButton(horz).SetText(setting.btnText);

		if setting.btnColor then
			btn.SetColor(setting.btnColor);
		end

		if setting.btnTextColor then
			btn.SetTextColor(setting.btnTextColor);
		end

		local vert3 = nil;

		btn.SetOnClick(function()
			if not vert3 then
				vert3 = UI.CreateVerticalLayoutGroup(vert2);
				setting.onExpand(btn, UI.CreateVerticalLayoutGroup(vert3));
				cpc(vert3, setting.subsettings);
			else
				if not Client_SaveConfigureUI(UI.Alert) then
					-- if theres an error dont allow settings to collapse
					return;
				end

				if (WL and WL.IsVersionOrHigher and WL.IsVersionOrHigher('5.21')) then
					UI.Destroy(vert3);
					vert3 = nil;
				end
			end
		end);

		return;
	end

	local initialSettingValue = Mod.Settings[setting.name];

	if initialSettingValue == nil then
		initialSettingValue = setting.defaultValue;
	end

	if setting.inputType == 'radio' then
		local label = UI.CreateLabel(horz).SetText(setting.label);

		if setting.labelColor then
			label.SetColor(setting.labelColor);
		end

		local vert3 = UI.CreateVerticalLayoutGroup(vert2);

		createHelpBtn(horz, UI.CreateVerticalLayoutGroup(vert3), setting);

		local horz2 = UI.CreateHorizontalLayoutGroup(vert2);
		local selectedCheckbox = nil;

		for a, option in ipairs(setting.controls) do
			local i = a;
			local isSelectedCheckbox = i == initialSettingValue;
			local checkbox = UI.CreateCheckBox(horz2).SetText('').SetIsChecked(isSelectedCheckbox);
			local checkboxLabel = UI.CreateLabel(horz2).SetText((type(option) == 'string' and option) or option.label);

			if option.labelColor then
				checkboxLabel.SetColor(option.labelColor);
			end

			if isSelectedCheckbox then
				Mod.Settings[setting.name] = i;
				selectedCheckbox = checkbox;
			end

			checkbox.SetOnClick(function()
				Mod.Settings[setting.name] = i;

				if selectedCheckbox then
					selectedCheckbox.SetIsChecked(false);
				end

				checkbox.SetIsChecked(true);
				selectedCheckbox = checkbox;
			end);
		end
	elseif setting.inputType == 'bool' then
		GLOBALS[setting.name] = UI.CreateCheckBox(horz)
			.SetText('')
			.SetIsChecked(initialSettingValue);

		-- colors dont take affect on checkbox labels so make an actual label
		local label = UI.CreateLabel(horz).SetText(setting.label);

		if setting.labelColor then
			label.SetColor(setting.labelColor);
		end

		local vert3 = UI.CreateVerticalLayoutGroup(vert2);

		createHelpBtn(horz, UI.CreateVerticalLayoutGroup(vert3), setting);

		if setting.subsettings then
			local expandCollapseBtn = nil;
			local expandCollapseBtnClicked;
			local subsettingEnabledOrDisabled;
			local vert4 = nil;

			expandCollapseBtnClicked = function()
				-- save - destroying otherwise goes back to default setting values

				if not Client_SaveConfigureUI(UI.Alert) then
					-- if theres an error dont allow settings to collapse
					return;
				end

				if expandCollapseBtn.GetText() == getExpandBtnLabelTxt() then
					expandCollapseBtn.SetText(getCollapseBtnLabelTxt());
				else
					expandCollapseBtn.SetText(getExpandBtnLabelTxt());
				end

				if (WL and WL.IsVersionOrHigher and WL.IsVersionOrHigher('5.21')) then
					if not UI.IsDestroyed(vert4) then
						UI.Destroy(vert4);
						vert4 = nil;
					end
				end

				if expandCollapseBtn.GetText() == getCollapseBtnLabelTxt() then
					subsettingEnabledOrDisabled();
				end
			end

			subsettingEnabledOrDisabled = function()
				if not (WL and WL.IsVersionOrHigher and WL.IsVersionOrHigher('5.21')) then
					if not expandCollapseBtn then
						expandCollapseBtn = UI.CreateButton(horz);
						expandCollapseBtn.SetColor('#23A0FF')
						expandCollapseBtn.SetText(getCollapseBtnLabelTxt());
						expandCollapseBtn.SetOnClick(expandCollapseBtnClicked);
					end

					if not vert4 then
						vert4 = UI.CreateVerticalLayoutGroup(vert3);
						cpc(vert4, setting.subsettings);
					end
				elseif GLOBALS[setting.name].GetIsChecked() then
					if UI.IsDestroyed(expandCollapseBtn) then
						expandCollapseBtn = UI.CreateButton(horz);
						expandCollapseBtn.SetColor('#23A0FF')
						expandCollapseBtn.SetText(getCollapseBtnLabelTxt());
						expandCollapseBtn.SetOnClick(expandCollapseBtnClicked);
					end

					vert4 = UI.CreateVerticalLayoutGroup(vert3);
					cpc(vert4, setting.subsettings);
				elseif not UI.IsDestroyed(vert4) then
					UI.Destroy(expandCollapseBtn);
					UI.Destroy(vert4);
				end
			end

			GLOBALS[setting.name].SetOnValueChanged(subsettingEnabledOrDisabled);
			subsettingEnabledOrDisabled();
		end
	else
		local label = UI.CreateLabel(horz).SetText(setting.label);

		if setting.labelColor then
			label.SetColor(setting.labelColor);
		end

		createHelpBtn(horz, vert2, setting);

		if setting.inputType == 'text' then
			GLOBALS[setting.name] = UI.CreateTextInputField(horz).SetText(initialSettingValue);

			if setting.placeholder then
				GLOBALS[setting.name].SetPlaceholderText(setting.placeholder);
			end

			if setting.charLimit then
				GLOBALS[setting.name].SetCharacterLimit(setting.charLimit);
			end
		elseif setting.inputType == 'int' or setting.inputType == 'float' then
			GLOBALS[setting.name] = UI.CreateNumberInputField(horz);

			if setting.inputType == 'float' then
				GLOBALS[setting.name].SetWholeNumbers(false);
			end

			GLOBALS[setting.name]
				.SetSliderMinValue(setting.minValue)
				.SetSliderMaxValue(setting.maxValue)
				.SetValue(initialSettingValue);
		end
	end
end

local settingHelpAreas = {};

function createHelpBtn(btnParent, helpParent, setting)
	if not setting.help then
		return;
	end

	UI.CreateButton(btnParent).SetText('?').SetColor('#23A0FF').SetOnClick(function()
		if not (WL and WL.IsVersionOrHigher and WL.IsVersionOrHigher('5.21')) then
			if not settingHelpAreas[setting.name] then
				settingHelpAreas[setting.name] = UI.CreateVerticalLayoutGroup(helpParent);
				setting.help(settingHelpAreas[setting.name]);
			end
		elseif UI.IsDestroyed(settingHelpAreas[setting.name]) then
			settingHelpAreas[setting.name] = UI.CreateVerticalLayoutGroup(helpParent);
			setting.help(settingHelpAreas[setting.name]);
		else
			UI.Destroy(settingHelpAreas[setting.name]);
			settingHelpAreas[setting.name] = nil;
		end
	end);
end