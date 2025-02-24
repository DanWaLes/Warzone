-- copied from https://github.com/DanWaLes/Warzone/tree/main/mods/libs/AutoSettingsFiles

require('__settings');

local errMsg;
local settingValues;
local modDevMadeError = false;
local customCardSettings;

function Client_SaveConfigureUI(alert, addCard)
	errMsg = nil;
	settingValues = {};
	customCardSettings = {};

	if type(getSettings) ~= 'function' then
		getSettings = function()
			return nil;
		end;
	end

	local settings = getSettings();

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

	for _, setting in ipairs(customCardSettings) do
		local numPieces = setting.cardGameSettingsMap.NumPieces;
		local minPiecesPerTurn = setting.CustomCardSettingsMap.MinimumPiecesPerTurn;
		local initialPieces = setting.CustomCardSettingsMap.InitialPieces;
		local weight = setting.CustomCardSettingsMap.Weight;
		local activeOrderDuration = setting.CustomCardSettingsMap.ActiveOrderDuration;

		if type(numPieces) == 'string' then
			minPiecesPerTurn = Mod.Settings[numPieces];
		end

		if type(minPiecesPerTurn) == 'string' then
			minPiecesPerTurn = Mod.Settings[minPiecesPerTurn];
		end

		if type(initialPieces) == 'string' then
			minPiecesPerTurn = Mod.Settings[initialPieces];
		end

		if type(weight) == 'string' then
			minPiecesPerTurn = Mod.Settings[weight];
		end

		if type(activeOrderDuration) == 'string' then
			minPiecesPerTurn = Mod.Settings[activeOrderDuration];
		end

		local cardId = addCard(
			setting.customCardName,
			setting.customCardDescription,
			setting.customCardImageFilename,
			numPieces,
			minPiecesPerTurn,
			initialPieces,
			weight,
			activeOrderDuration
		);

		Mod.Settings[setting.name] = cardId;
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
	if setting.isCustomCard then
		if not (WL and WL.IsVersionOrHigher and WL.IsVersionOrHigher('5.32.0.1')) then
			return;
		end

		if setting.usesSettings then
			csc(setting.settings);
		end

		table.insert(customCardSettings, settings);
		return;
	end

	if setting.inputType == 'radio' then
		-- explicitly written to in Client_PresentConfigureUI if the value has ever been changed from the default

		if not Mod.Settings[setting.name] then
			Mod.Settings[setting.name] = setting.defaultValue;
		end

		return;
	end

	local settingVal;

	if setting.inputType == 'bool' then
		settingVal = access(setting, 'GetIsChecked');
	elseif setting.inputType == 'text' then
		settingVal = access(setting, 'GetText');

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
		settingVal = access(setting, 'GetValue');

		if setting.inputType == 'float' then
			settingVal = round(settingVal, setting.dp);
		end

		local absoluteMax = setting.absoluteMax or setting.maxValue;
		local absoluteMin = setting.absoluteMin or setting.minValue;
		local usingMax = type(setting.absoluteMax) == 'number' and settingVal > setting.maxValue;
		local usingMin = type(setting.absoluteMin) == 'number' and settingVal < setting.minValue;
		local isTooHigh = settingVal > absoluteMax;
		local isTooLow = settingVal < absoluteMin;

		if isTooLow or isTooHigh then
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
	end

	settingValues[setting.name] = settingVal;

	if settingVal and setting.inputType == 'bool' and setting.subsettings then
		csc(setting.subsettings);
	end
end

function access(setting, fn)
	-- check if the element for the setting is destroyed before trying to access any of its functions

	-- if destroyed might not be able to access the value
	-- so use the defaultValue fallback

	local value = Mod.Settings[setting.name];

	if value == nil then
		value = setting.defaultValue;
	end

	local el = GLOBALS[setting.name];

	if WL and WL.IsVersionOrHigher and WL.IsVersionOrHigher('5.21') then
		if not UI.IsDestroyed(el) then
			value = el[fn]();
		end	
	else
		-- no ui elements are destroyed if checking for destroyed is not an option
		-- so safe to set the value

		value = el[fn]();
	end

	if value == nil then
		print('access(setting, fn) result is nil');
		print('setting.name = ' .. setting.name);
		print('fn = ' .. fn);
	end

	return value;
end

function round(n, dp)
	-- http://lua-users.org/wiki/SimpleRound
	local multi = 10 ^ (dp or 0);

	return math.floor((n * multi + 0.5)) / multi;
end