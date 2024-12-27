-- copied from https://github.com/DanWaLes/Warzone/tree/master/mods/libs/AutoSettingsFiles

require('__settings');

local modDevMadeError = false;

GLOBALS = {};

function Client_PresentConfigureUI(rootParent)
	local root = UI.CreateVerticalLayoutGroup(rootParent);

	if type(getSettings) ~= 'function' then
		getSettings = function()
			return nil;
		end;
	end

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
			cpcDoTemplate(setting, vert);
		else
			cpcDoSetting(setting, vert);
		end
	end
end

function cpcDoTemplate(setting, vert)
	GLOBALS[setting.name] = Mod.Settings[setting.name] or 0;

	local vert2 = UI.CreateVerticalLayoutGroup(vert);
	local i = 1;

	while i < (GLOBALS[setting.name] + 1) do
		cpcDoSetting(setting.get(i), vert2);
		i = i + 1;
	end

	local btn = UI.CreateButton(vert)
		.SetColor(setting.btnColor or '#00FF05')
		.SetText(setting.btnText);

	if setting.btnTextColor then
		btn.SetTextColor(setting.btnTextColor);
	end

	btn.SetOnClick(function()
		GLOBALS[setting.name] = GLOBALS[setting.name] + 1;
		cpcDoSetting(setting.get(GLOBALS[setting.name]), vert2);
	end);
end

function cpcDoSetting(setting, vert)
	local horz = UI.CreateHorizontalLayoutGroup(vert);
	local vert2 = UI.CreateVerticalLayoutGroup(vert);

	if setting.isGroup then
		return cpcDoSettingGroup(setting, horz, vert2);
	end

	local initialSettingValue = Mod.Settings[setting.name];

	if initialSettingValue == nil then
		initialSettingValue = setting.defaultValue;
	end

	if setting.inputType == 'radio' then
		local vert3 = UI.CreateVerticalLayoutGroup(vert2);
		local selectedCheckbox = nil;

		createLabel(horz, setting);
		createHelpBtn(horz, UI.CreateVerticalLayoutGroup(vert3), setting);

		for a, option in ipairs(setting.controls) do
			local vert4 = UI.CreateVerticalLayoutGroup(vert3);
			local horz2 = UI.CreateHorizontalLayoutGroup(vert4);
			local i = a;
			local isSelectedCheckbox = i == initialSettingValue;
			local checkbox = UI.CreateCheckBox(horz2)
				.SetText('')
				.SetIsChecked(isSelectedCheckbox);

			createLabel(horz2, {
				label = (type(option) == 'string' and option) or option.label
				labelColor = (type(option) == 'table' and option.labelColor) or nil
			});

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
		local vert3 = UI.CreateVerticalLayoutGroup(vert2);

		-- colors dont take affect on checkbox labels
		-- so use empty checkbox label and make an actual label

		GLOBALS[setting.name] = UI.CreateCheckBox(horz)
			.SetText('')
			.SetIsChecked(initialSettingValue);

		createLabel(horz, setting);
		createHelpBtn(horz, UI.CreateVerticalLayoutGroup(vert3), setting);
		cpcDoSettingBoolSubsettings(setting, horz, vert3);
	else
		createLabel(horz, setting)
		createHelpBtn(horz, vert2, setting);

		if setting.inputType == 'text' then
			makeTextInput(setting, horz);
		elseif setting.inputType == 'int' or setting.inputType == 'float' then
			makeNumberInput(setting, horz);
		end
	end
end

function createLabel(parent, options)
	local label = UI.CreateLabel(parent).SetText(options.label);

	if options.labelColor then
		label.SetColor(options.labelColor);
	end
end

local settingHelpAreas = {};

function createHelpBtn(btnParent, helpParent, setting)
	if not setting.help then
		return;
	end

	function showHelp()
		settingHelpAreas[setting.name] = UI.CreateVerticalLayoutGroup(helpParent);
		setting.help(settingHelpAreas[setting.name]);
	end

	function hideHelp()
		UI.Destroy(settingHelpAreas[setting.name]);
		settingHelpAreas[setting.name] = nil;
	end

	UI.CreateButton(btnParent).SetText('?').SetColor('#23A0FF').SetOnClick(function()
		if not (WL and WL.IsVersionOrHigher and WL.IsVersionOrHigher('5.21')) then
			if not settingHelpAreas[setting.name] then
				showHelp();
			end
		elseif UI.IsDestroyed(settingHelpAreas[setting.name]) then
			showHelp();
		else
			hideHelp();
		end
	end);
end

function createExpandCollaseBtn(parent, onBeforeExpandOrCollapse, onCollapse, onExpand)
	local expandCollapseBtn = UI.CreateButton(parent);

	expandCollapseBtn.SetColor('#23A0FF')
	expandCollapseBtn.SetText(getCollapseBtnLabelTxt());
	expandCollapseBtn.SetOnClick(function()
		onBeforeExpandOrCollapse();

		if expandCollapseBtn.GetText() == getExpandBtnLabelTxt() then
			expandCollapseBtn.SetText(getCollapseBtnLabelTxt());
		else
			expandCollapseBtn.SetText(getExpandBtnLabelTxt());
		end

		if (WL and WL.IsVersionOrHigher and WL.IsVersionOrHigher('5.21')) then
			onCollapse();
		end

		if expandCollapseBtn.GetText() == getCollapseBtnLabelTxt() then
			onExpand();
		end
	end);

	return expandCollapseBtn;
end

function cpcDoSettingGroup(setting, horz, vert)
	local btn = UI.CreateButton(horz).SetText(setting.btnText);

	if setting.btnColor then
		btn.SetColor(setting.btnColor);
	end

	if setting.btnTextColor then
		btn.SetTextColor(setting.btnTextColor);
	end

	local vert2 = nil;

	btn.SetOnClick(function()
		if not vert2 then
			vert2 = UI.CreateVerticalLayoutGroup(vert);
			setting.onExpand(btn, UI.CreateVerticalLayoutGroup(vert2));
			cpc(vert2, setting.subsettings);
		else
			if not Client_SaveConfigureUI(UI.Alert) then
				-- if theres an error dont allow settings to collapse
				return;
			end

			if (WL and WL.IsVersionOrHigher and WL.IsVersionOrHigher('5.21')) then
				UI.Destroy(vert2);
				vert2 = nil;
			end
		end
	end);
end

function cpcDoSettingBoolSubsettings(setting, horz, vert)
	if not setting.subsettings then
		return;
	end

	local expandCollapseBtn = nil;
	local subsettingEnabledOrDisabled;
	local vert2 = nil;
	local makeExpandCollapseBtn = function()
		expandCollapseBtn = createExpandCollaseBtn(
			horz,
			function()
				-- save because destroying otherwise goes back to default setting values
				-- if theres an error dont allow settings to collapse

				if not Client_SaveConfigureUI(UI.Alert) then
					return;
				end
			end,
			function()
				if not UI.IsDestroyed(vert2) then
					UI.Destroy(vert2);
					vert2 = nil;
				end
			end,
			subsettingEnabledOrDisabled
		);
	end

	subsettingEnabledOrDisabled = function()
		if not (WL and WL.IsVersionOrHigher and WL.IsVersionOrHigher('5.21')) then
			if not expandCollapseBtn then
				makeExpandCollapseBtn();
			end

			if not vert2 then
				vert2 = UI.CreateVerticalLayoutGroup(vert);
				cpc(vert2, setting.subsettings);
			end
		elseif GLOBALS[setting.name].GetIsChecked() then
			if UI.IsDestroyed(expandCollapseBtn) then
				makeExpandCollapseBtn();
			end

			vert2 = UI.CreateVerticalLayoutGroup(vert);
			cpc(vert2, setting.subsettings);
		elseif not UI.IsDestroyed(vert2) then
			UI.Destroy(expandCollapseBtn);
			UI.Destroy(vert2);
		end
	end

	GLOBALS[setting.name].SetOnValueChanged(subsettingEnabledOrDisabled);
	subsettingEnabledOrDisabled();
end

function makeTextInput(setting, horz)
	GLOBALS[setting.name] = UI.CreateTextInputField(horz).SetText(initialSettingValue);

	if setting.placeholder then
		GLOBALS[setting.name].SetPlaceholderText(setting.placeholder);
	end

	if setting.charLimit then
		GLOBALS[setting.name].SetCharacterLimit(setting.charLimit);
	end
end

function makeNumberInput(setting, horz)
	GLOBALS[setting.name] = UI.CreateNumberInputField(horz);

	if setting.inputType == 'float' then
		GLOBALS[setting.name].SetWholeNumbers(false);
	end

	GLOBALS[setting.name]
		.SetSliderMinValue(setting.minValue)
		.SetSliderMaxValue(setting.maxValue)
		.SetValue(initialSettingValue);
end
