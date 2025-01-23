-- copied from https://github.com/DanWaLes/Warzone/tree/master/mods/libs/AutoSettingsFiles

require('__settings');

GLOBALS = {};

local modDevMadeError = false;
local settingHelpAreas = {};
local canUseUIElementIsDestroyed = false;
local save = nil;

function Client_PresentConfigureUI(rootParent)
	canUseUIElementIsDestroyed = WL and WL.IsVersionOrHigher and WL.IsVersionOrHigher('5.21');
	save = function()
		-- save because destroying otherwise goes back to default setting values
		-- returns true if there isnt a error, false if there is an error

		return Client_SaveConfigureUI(UI.Alert);
	end

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

	if canUseUIElementIsDestroyed then
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
	if setting.isCustomCard then
		if setting.usesSettings then
			cpc(setting.settings, vert);
		end

		return;
	end

	local horz = UI.CreateHorizontalLayoutGroup(vert);
	local vert2 = UI.CreateVerticalLayoutGroup(vert);
	local initialSettingValue = Mod.Settings[setting.name];

	if initialSettingValue == nil then
		initialSettingValue = setting.defaultValue;
	end

	if setting.inputType == 'radio' then
		local vert3 = UI.CreateVerticalLayoutGroup(vert2);
		local vert4 = UI.CreateVerticalLayoutGroup(vert3);
		local vert5 = nil;
		local selectedCheckbox = nil;
		local selectedRadioButtonLabel = nil;
		local selectedRadioButtonHelp = nil;
		local selectedRadioButtonHelpHelpParentParent = nil;
		local selectedRadioButtonHelpHelpParent = nil;

		function getLabelFromOption(option)
			return (type(option) == 'string' and option) or option.label;
		end

		function getLabelColorFromOption(option)
			return (type(option) == 'table' and option.labelColor) or nil;
		end

		function updateLabelWithOption(option)
			local text = getLabelFromOption(option);
			local color = getLabelColorFromOption(option);

			selectedRadioButtonLabel.SetText(text);

			if color then
				selectedRadioButtonLabel.SetColor(color);
			end

			if not selectedRadioButtonHelp then
				return;
			end

			UI.Destroy(selectedRadioButtonHelp);
			UI.Destroy(selectedRadioButtonHelpHelpParent);
			settingHelpAreas[setting.name .. tostring(-1)] = nil;
			selectedRadioButtonHelpHelpParent = UI.CreateVerticalLayoutGroup(selectedRadioButtonHelpHelpParentParent);
			selectedRadioButtonHelp = makeLabelHelpFromOption(horz, selectedRadioButtonHelpHelpParent, option, -1);
		end

		function makeLabelFromOption(parent, option)
			return createLabel(parent, {
				label = getLabelFromOption(option),
				labelColor = getLabelColorFromOption(option)
			});
		end

		function makeLabelHelpFromOption(btnParent, helpParent, option, fakeSettingNameSuffix)
			local hasHelp = type('option') == 'table' and option.help;

			if not hasHelp then
				return;
			end

			-- make a fake setting so that createHelpBtn can be reused using option

			local fakeSetting = {
				name = setting.name .. tostring(fakeSettingNameSuffix),
				help = option.help
			};

			return createHelpBtn(btnParent, helpParent, fakeSetting);
		end

		function listAllOptions()
			if not vert5 then
				vert5 = UI.CreateVerticalLayoutGroup(vert4);
			end

			for a, option in ipairs(setting.controls) do
				local horz2 = UI.CreateHorizontalLayoutGroup(UI.CreateVerticalLayoutGroup(vert5));
				local i = a;
				local isSelectedCheckbox = i == initialSettingValue;
				local checkbox = UI.CreateCheckBox(horz2)
					.SetText('')
					.SetIsChecked(isSelectedCheckbox);

				makeLabelFromOption(horz2, option);
				makeLabelHelpFromOption(horz2, UI.CreateVerticalLayoutGroup(horz2), option, a);

				if isSelectedCheckbox then
					Mod.Settings[setting.name] = i;
					selectedCheckbox = checkbox;

					if selectedRadioButtonLabel then
						updateLabelWithOption(option);
					end
				end

				checkbox.SetOnClick(function()
					Mod.Settings[setting.name] = i;

					if selectedCheckbox then
						selectedCheckbox.SetIsChecked(false);
					end

					checkbox.SetIsChecked(true);
					selectedCheckbox = checkbox;

					if selectedRadioButtonLabel then
						updateLabelWithOption(option);
					end
				end);
			end
		end

		createLabel(horz, setting);
		createHelpBtn(horz, UI.CreateVerticalLayoutGroup(vert3), setting);

		if canUseUIElementIsDestroyed then
			local initialSelectedOption = setting.controls[initialSettingValue];

			selectedRadioButtonLabel = makeLabelFromOption(horz, initialSelectedOption);

			selectedRadioButtonHelpHelpParentParent = UI.CreateVerticalLayoutGroup(horz);
			selectedRadioButtonHelpHelpParent = UI.CreateVerticalLayoutGroup(selectedRadioButtonHelpHelpParentParent);
			selectedRadioButtonHelp = makeLabelHelpFromOption(horz, selectedRadioButtonHelpHelpParent, initialSelectedOption, -1);

			createExpandCollaseBtn(
				horz,
				true,
				function()
					-- if theres an error dont allow options to collapse

					return save();
				end,
				function()
					if not UI.IsDestroyed(vert5) then
						UI.Destroy(vert5);
						vert5 = nil;
					end
				end,
				listAllOptions
			);
		else
			listAllOptions();
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
			makeTextInput(setting, horz, initialSettingValue);
		elseif setting.inputType == 'int' or setting.inputType == 'float' then
			makeNumberInput(setting, horz, initialSettingValue);
		end
	end
end

function createLabel(parent, options)
	local label = UI.CreateLabel(parent).SetText(options.label);

	if options.labelColor then
		label.SetColor(options.labelColor);
	end

	return label;
end

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

	return UI.CreateButton(btnParent)
		.SetText('?')
		.SetColor('#23A0FF')
		.SetOnClick(
			function()
				if not canUseUIElementIsDestroyed then
					if not settingHelpAreas[setting.name] then
						showHelp();
					end
				elseif UI.IsDestroyed(settingHelpAreas[setting.name]) then
					showHelp();
				else
					hideHelp();
				end
			end
		);
end

function createExpandCollaseBtn(parent, startCollapsed, onBeforeExpandOrCollapse, onCollapse, onExpand)
	local expandCollapseBtn = UI.CreateButton(parent);
	local startText = (startCollapsed and getExpandBtnLabelTxt()) or getCollapseBtnLabelTxt();

	expandCollapseBtn.SetColor('#23A0FF')
	expandCollapseBtn.SetText(startText);
	expandCollapseBtn.SetOnClick(function()
		if not onBeforeExpandOrCollapse() then
			return;
		end

		if expandCollapseBtn.GetText() == getExpandBtnLabelTxt() then
			expandCollapseBtn.SetText(getCollapseBtnLabelTxt());
		else
			expandCollapseBtn.SetText(getExpandBtnLabelTxt());
		end

		if canUseUIElementIsDestroyed then
			onCollapse();
		end

		if expandCollapseBtn.GetText() == getCollapseBtnLabelTxt() then
			onExpand();
		end
	end);

	return expandCollapseBtn;
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
			false,
			function()
				-- if theres an error dont allow settings to collapse

				return save();
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
		if not canUseUIElementIsDestroyed then
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

function makeTextInput(setting, horz, initialSettingValue)
	GLOBALS[setting.name] = UI.CreateTextInputField(horz).SetText(initialSettingValue);

	if setting.placeholder then
		GLOBALS[setting.name].SetPlaceholderText(setting.placeholder);
	end

	if setting.charLimit then
		GLOBALS[setting.name].SetCharacterLimit(setting.charLimit);
	end
end

function makeNumberInput(setting, horz, initialSettingValue)
	GLOBALS[setting.name] = UI.CreateNumberInputField(horz);

	if setting.inputType == 'float' then
		GLOBALS[setting.name].SetWholeNumbers(false);
	end

	GLOBALS[setting.name]
		.SetSliderMinValue(setting.minValue)
		.SetSliderMaxValue(setting.maxValue)
		.SetValue(initialSettingValue);
end
