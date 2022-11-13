require 'settings'

GLOBALS = {};

function Client_PresentConfigureUI(rootParent)
	local inputFieldTypes = {
		int = 'CreateNumberInputField',
		number = 'CreateNumberInputField',
		bool = 'CreateCheckBox'
	};

	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	for key, value in pairs(getSettings()) do
		local initialSettingValue = Mod.Settings[key];

		if initialSettingValue == nil then
			initialSettingValue = value.defaultValue;
		end

		UI.CreateLabel(vert).SetText(value.label);
		GLOBALS[key] = UI[inputFieldTypes[value.inputType]](vert);

		if value.inputType == 'bool' then
			GLOBALS[key].SetIsChecked(initialSettingValue);
		else
			GLOBALS[key]	
				.SetSliderMinValue(value.minValue)
				.SetSliderMaxValue(value.maxValue)
				.SetValue(initialSettingValue)

			if value.inputType == 'number' then
				GLOBALS[key].WholeNumbers = false;
			end
		end
	end
end