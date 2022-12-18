require 'settings'

local errMsg;
local settingValues;

function Client_SaveConfigureUI(alert)
	errMsg = nil;
	settingValues = {};

	csc(getSettings());

	if errMsg then
		return alert(errMsg);
	end

	for settingName, settingValue in pairs(settingValues) do
		Mod.Settings[settingName] = settingValue;
	end
end

function csc(settings)
	for _, setting in ipairs(settings) do
		if setting.isTemplate then
			Mod.Settings[setting.name] = GLOBALS[setting.name];
			local n = 1;

			while n < (Mod.Settings[setting.name] + 1) do
				local toAdd = setting.get(n);
				cscDoSetting(toAdd);
				n = n + 1;
			end
		else
			cscDoSetting(setting);
		end
	end
end

function cscDoSetting(setting)
	local settingVal;

	if setting.inputType == 'bool' then
		settingVal = GLOBALS[setting.name].GetIsChecked();
	else
		settingVal = GLOBALS[setting.name].GetValue();

		if setting.inputType == 'float' then
			settingVal = round(settingVal, setting.dp);
		end

		local absoluteMax = setting.absoluteMax or setting.maxValue;
		local usingMax = type(setting.absoluteMax) == 'number' or setting.absoluteMax == nil;
		local isTooLow = settingVal < setting.minValue;
		local isTooHigh = settingVal > absoluteMax;

		if isTooLow or (usingMax and isTooHigh) then
			if errMsg == nil then
				errMsg = '';
			end

			if errMsg ~= '' then
				errMsg = errMsg .. '\n';
			end

			errMsg = errMsg .. setting.label .. ' must be ';

			if isTooLow and not usingMax then
				errMsg = errMsg .. 'at least ' .. tostring(setting.minValue);
			elseif isTooLow or isTooHigh then
				errMsg = errMsg .. 'between ' .. tostring(setting.minValue) .. ' and ' .. tostring(absoluteMax);
			end
		end
	end

	settingValues[setting.name] = settingVal;

	if settingVal and setting.inputType == 'bool' and setting.subsettings then
		csc(setting.subsettings);
	end
end