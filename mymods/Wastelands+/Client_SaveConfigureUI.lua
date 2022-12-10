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
		local settingName = setting.name;
		local settingVal;

		if setting.inputType == 'bool' then
			settingVal = GLOBALS[settingName].GetIsChecked();
		else
			settingVal = GLOBALS[settingName].GetValue();

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

		settingValues[settingName] = settingVal;

		if settingVal and setting.inputType == 'bool' and setting.subsettings then
			csc(setting.subsettings);
		end
	end
end

function round(n, dp)
	-- http://lua-users.org/wiki/SimpleRound
	local multi = 10 ^ (dp or 0);

	return math.floor((n * multi + 0.5)) / multi;
end