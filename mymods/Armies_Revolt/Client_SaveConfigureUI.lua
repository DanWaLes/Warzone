require 'settings'

function Client_SaveConfigureUI(alert)
	local errMsg;
	local settingValues = {};

	local ret = csc(errMsg, settingValues, getSettings());
	errMsg = ret.errMsg;
	settingValues = ret.settingValues;

	if errMsg then
		return alert(errMsg);
	end

	for settingName, settingValue in pairs(settingValues) do
		Mod.Settings[settingName] = settingValue;
	end
end

function csc(errMsg, settingValues, settings)
	for settingName, setting in pairs(settings) do
		local settingVal;

		if setting.inputType == 'bool' then
			settingVal = GLOBALS[settingName].GetIsChecked();
		else
			settingVal = GLOBALS[settingName].GetValue();

			if setting.inputType == 'float' then
				settingVal = round(settingVal, setting.dp);
			end

			if settingVal < setting.minValue or settingVal > setting.maxValue then
				if errMsg == nil then
					errMsg = '';
				end

				if errMsg ~= '' then
					errMsg = errMsg .. '\n';
				end

				errMsg = errMsg .. setting.label .. ' must be between ' .. tostring(setting.minValue) .. ' and ' .. tostring(setting.maxValue);
			end
		end

		settingValues[settingName] = settingVal;

		if setting.subsettings then
			csc(errMsg, settingValues, setting.subsettings);
		end
	end

	return {
		errMsg = errMsg,
		settingValues = settingValues
	};
end

function round(n, dp)
	-- http://lua-users.org/wiki/SimpleRound
	local multi = 10 ^ (dp or 0);

	return math.floor((n * multi + 0.5)) / multi;
end