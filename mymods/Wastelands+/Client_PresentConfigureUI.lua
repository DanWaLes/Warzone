require 'settings'

GLOBALS = {};

function Client_PresentConfigureUI(rootParent)
	cpc(rootParent, getSettings());
end

function cpc(rootParent, settings)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	for _, setting in ipairs(settings) do
		local settingName = setting.name;
		local initialSettingValue = Mod.Settings[settingName];

		if initialSettingValue == nil then
			initialSettingValue = setting.defaultValue;
		end

		local horz = UI.CreateHorizontalLayoutGroup(vert);
		local vert2 = UI.CreateVerticalLayoutGroup(vert);

		if setting.inputType == 'bool' then
			GLOBALS[settingName] = UI.CreateCheckBox(horz)
				.SetText(setting.label)
				.SetIsChecked(initialSettingValue);

			local vert3 = UI.CreateVerticalLayoutGroup(vert2);
			createHelpBtn(horz, UI.CreateVerticalLayoutGroup(vert3), setting);

			if setting.subsettings then
				local vert4 = nil;
				local subsettingEnabledOrDisabled = function()
					if GLOBALS[settingName].GetIsChecked() then
						vert4 = UI.CreateVerticalLayoutGroup(vert3);
						cpc(vert4, setting.subsettings);
					elseif not UI.IsDestroyed(vert4) then
						UI.Destroy(vert4);
					end
				end

				GLOBALS[settingName].SetOnValueChanged(subsettingEnabledOrDisabled);
				subsettingEnabledOrDisabled();
			end
		else
			UI.CreateLabel(horz).SetText(setting.label);

			GLOBALS[settingName] = UI.CreateNumberInputField(horz)
				.SetSliderMinValue(setting.minValue)
				.SetSliderMaxValue(setting.maxValue)
				.SetValue(initialSettingValue);

			if setting.inputType == 'float' then
				GLOBALS[settingName].SetWholeNumbers(false);
			end

			createHelpBtn(horz, vert2, setting);
		end
	end
end

local settingHelpAreas = {};

function createHelpBtn(btnParent, helpParent, setting)
	if not setting.help then
		return;
	end

	UI.CreateButton(btnParent).SetText('?').SetColor('#23A0FF').SetOnClick(function()
		if UI.IsDestroyed(settingHelpAreas[setting.name]) then
			settingHelpAreas[setting.name] = UI.CreateVerticalLayoutGroup(helpParent);
			setting.help(settingHelpAreas[setting.name]);
		else
			UI.Destroy(settingHelpAreas[setting.name]);
		end
	end);
end