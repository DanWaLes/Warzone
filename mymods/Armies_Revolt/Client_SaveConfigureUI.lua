require 'settings'

function Client_SaveConfigureUI(alert)
	local errMsg;
	local settingValues = {};

	for key, value in pairs(getSettings()) do
		local isNumber = value.inputType == 'int' or value.inputType == 'number';
		local settingVal;

		if value.inputType == 'bool' then
			settingVal = GLOBALS[key].GetIsChecked();
		else
			settingVal = GLOBALS[key].GetValue();

			if settingVal < value.minValue or settingVal > value.maxValue then
				if errMsg == nil then
					errMsg = '';
				end

				if errMsg ~= '' then
					errMsg = errMsg .. '\n';
				end

				errMsg = errMsg .. value.label .. ' must be between ' .. tostring(value.minValue) .. ' and ' .. tostring(value.maxValue);
			end
		end

		settingValues[key] = settingVal;
	end

	if errMsg then
		return alert(errMsg);
	end

	for key, value in pairs(settingValues) do
		Mod.Settings[key] = value;
	end
end