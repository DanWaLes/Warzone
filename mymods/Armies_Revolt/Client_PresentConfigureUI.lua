require 'settings'

GLOBALS = {};

function Client_PresentConfigureUI(rootParent)
	cpc(rootParent, getSettings());
end

function cpc(rootParent, settings)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	for settingName, setting in pairs(settings) do
		local initialSettingValue = Mod.Settings[settingName];

		if initialSettingValue == nil then
			initialSettingValue = setting.defaultValue;
		end

		if setting.inputType == 'bool' then
			local vert2 = UI.CreateVerticalLayoutGroup(vert);

			GLOBALS[settingName] = UI.CreateCheckBox(vert2)
				.SetText(setting.label)
				.SetIsChecked(initialSettingValue);

			if setting.subsettings then
				local vert3 = nil;
				local subsettingEnabledOrDisabled = function()
					if GLOBALS[settingName].GetIsChecked() then
						vert3 = UI.CreateVerticalLayoutGroup(vert2);
						cpc(vert3, setting.subsettings);
					elseif not UI.IsDestroyed(vert3) then
						UI.Destroy(vert3);
					end
				end

				GLOBALS[settingName].SetOnValueChanged(subsettingEnabledOrDisabled);
				subsettingEnabledOrDisabled();
			end
		else
			local horz = UI.CreateHorizontalLayoutGroup(rootParent);

			UI.CreateLabel(horz).SetText(setting.label);

			GLOBALS[settingName] = UI.CreateNumberInputField(horz)
				.SetSliderMinValue(setting.minValue)
				.SetSliderMaxValue(setting.maxValue)
				.SetValue(initialSettingValue);

			if setting.inputType == 'float' then
				GLOBALS[settingName].SetWholeNumbers(false);
			end
		end
	end
end