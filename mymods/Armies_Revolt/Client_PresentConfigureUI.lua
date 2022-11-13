require 'settings'

GLOBALS = {};

function Client_PresentConfigureUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	for key, value in pairs(getSettings()) do
		local initialSettingValue = Mod.Settings[key];

		if initialSettingValue == nil then
			initialSettingValue = value.defaultValue;
		end

		if value.inputType == 'bool' then
			GLOBALS[key] = UI.CreateCheckBox(vert)
				.SetText(value.label)
				.SetIsChecked(initialSettingValue);
		else
			local horz = UI.CreateHorizontalLayoutGroup(rootParent);

			UI.CreateLabel(horz).SetText(value.label);

			GLOBALS[key] = UI.CreateNumberInputField(horz)
				.SetSliderMinValue(value.minValue)
				.SetSliderMaxValue(value.maxValue)
				.SetValue(initialSettingValue);

			if value.inputType == 'float' then
				GLOBALS[key].SetWholeNumbers(false);
			end
		end
	end
end
