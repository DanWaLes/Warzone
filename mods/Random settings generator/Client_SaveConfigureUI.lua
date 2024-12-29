-- copied from https://github.com/DanWaLes/Warzone/tree/master/mods/libs/AutoSettingsFiles

require('__settings');

local errMsg;
local settingValues;
local modDevMadeError = false;

function Client_SaveConfigureUI(alert)
	errMsg = nil;
	settingValues = {};

	if type(getSettings) ~= 'function' then
		getSettings = function()
			return nil;
		end;
	end

	local settings = getSettings()

	csc(settings);

	if modDevMadeError then
		settingValues = {};
		errMsg = 'The mod developer made an error while adding settings';
	end

	if errMsg then
		alert(errMsg);

		return;
	end

	for settingName, settingValue in pairs(settingValues) do
		Mod.Settings[settingName] = settingValue;
	end

	return true;
end

function csc(settings)
	if type(settings) ~= 'table' then
		modDevMadeError = true;
	end

	if modDevMadeError then
		return;
	end

	for _, setting in ipairs(settings) do
		if type(setting) ~= 'table' then
			modDevMadeError = true;

			return;
		end

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
	if setting.inputType == 'radio' then
		-- explicitly written to in Client_PresentConfigureUI
		return;
	end

	local settingVal;

	if setting.inputType == 'bool' then
		settingVal = GLOBALS[setting.name].GetIsChecked();
	elseif setting.inputType == 'text' then
		settingVal = GLOBALS[setting.name].GetText();

		local length = #settingVal;
		local tooLong = setting.charLimit and (length > setting.charLimit);
		local notEntered = length < 1;

		if tooLong or notEntered then
			if errMsg == nil then
				errMsg = '';
			end

			if errMsg ~= '' then
				errMsg = errMsg .. '\n';
			end

			errMsg = errMsg .. setting.label .. ' must be ';

			if tooLong then
				errMsg = errMsg .. 'less than ' .. setting.charLimit .. ' character';

				if setting.charLimit > 1 then
					errMsg = errMsg + 's';
				end

				errMsg = errMsg .. ' long';
			else
				errMsg = errMsg .. ' entered';
			end
		end
	else
		settingVal = GLOBALS[setting.name].GetValue();

		if setting.inputType == 'float' then
			settingVal = round(settingVal, setting.dp);
		end

		local absoluteMax = setting.absoluteMax or setting.maxValue;
		local absoluteMin = setting.absoluteMin or setting.minValue;
		local usingMax = type(setting.absoluteMax) == 'number' and settingVal > setting.maxValue;
		local usingMin = type(setting.absoluteMin) == 'number' and settingVal < setting.minValue;
		local isTooHigh = settingVal > absoluteMax;
		local isTooLow = settingVal < absoluteMin;

		if not (isTooLow or isTooHigh) then
			return;
		end

		if errMsg == nil then
			errMsg = '';
		end

		if errMsg ~= '' then
			errMsg = errMsg .. '\n';
		end

		errMsg = errMsg .. setting.label .. ' must be ';

		if isTooLow and not usingMin then
			errMsg = errMsg .. 'greater than ' .. tostring(setting.minValue);
		elseif isTooHigh and not usingMax then
			errMsg = errMsg .. 'less than ' .. tostring(setting.maxValue);
		else
			errMsg = errMsg .. 'between ' .. tostring(absoluteMin) .. ' and ' .. tostring(absoluteMax);
		end
	end

	settingValues[setting.name] = settingVal;

	if settingVal and setting.inputType == 'bool' and setting.subsettings then
		csc(setting.subsettings);
	end
end

function round(n, dp)
	-- http://lua-users.org/wiki/SimpleRound
	local multi = 10 ^ (dp or 0);

	return math.floor((n * multi + 0.5)) / multi;
end