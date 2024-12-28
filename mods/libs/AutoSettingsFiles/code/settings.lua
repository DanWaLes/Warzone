-- copied from https://github.com/DanWaLes/Warzone/tree/master/mods/libs/AutoSettingsFiles

function addSetting(name, label, inputType, defaultValue, otherProps)
	local allowedInputTypes = {
		int = 'number',
		float = 'number',
		bool = 'boolean',
		text = 'string',
		radio = 'number'
	};

	if type(name) ~= 'string' then
		print('addSetting error: name must be a string');
		print('name = ' .. tostring(name));

		return;
	end

	if type(label) ~= 'string' then
		print('addSetting error: label in must be a string');
		print('name = ' .. name);
		print('label = ' .. tostring(label));

		return;
	end

	if not allowedInputTypes[inputType] then
		print('addSetting error: inputType must be one of "int", "float", "bool", "text", "radio"');
		print('name = ' .. name);
		print('inputType = ' .. tostring(inputType));

		return;
	end

	if type(defaultValue) ~= allowedInputTypes[inputType] then
		print('addSetting error: defaultValue for inputType ' .. inputType .. ' must be a ' .. allowedInputTypes[inputType]);
		print('name = ' .. name);
		print('defaultValue = ' .. tostring(defaultValue));

		return;
	end

	local setting = {name = name, label = label, inputType = inputType, defaultValue = defaultValue};

	if inputType ~= 'radio' then
		if otherProps == nil then
			return setting;
		end
	end

	if type(otherProps) ~= 'table' then
		print('addSetting error: otherProps must be a table');
		print('name = ' .. name);
		print('otherProps = ' .. tostring(otherProps));

		return;
	end

	local forcedProps = {};
	local optionalProps = {
		help = 'function',
		labelColor = 'string'
	};

	if otherProps.bkwrds ~= nil then
		if inputType == 'bool' then
			optionalProps.bkwrds = 'boolean';
		elseif inputType == 'text' then
			optionalProps.bkwrds = 'string';
		else
			optionalProps.bkwrds = 'number';
		end
	end

	if inputType == 'bool' then
		optionalProps.subsettings = 'table';
	elseif inputType == 'text' then
		optionalProps.placeholder = 'string';
		optionalProps.charLimit = 'number';
	elseif inputType == 'int' or inputType == 'float' then
		if inputType == 'float' then
			forcedProps.dp = 'number';
		end

		forcedProps.minValue = 'number';
		forcedProps.maxValue = 'number';
		optionalProps.absoluteMax = 'number';
		optionalProps.absoluteMin = 'number';
	elseif inputType == 'radio' then
		forcedProps.controls = 'table';
	end

	for prop, tpe in pairs(forcedProps) do
		local val = otherProps[prop];

		if type(val) ~= tpe then
			print('addSetting error: otherProps[' .. prop .. '] must be a ' .. tpe .. ' for inputType ' .. inputType);
			print('name = ' .. name);
			print('otherProps[' .. prop .. '] = ' .. tostring(val));

			return;
		end

		setting[prop] = val;
	end

	for prop, tpe in pairs(optionalProps) do
		local val = otherProps[prop];

		if val ~= nil then
			if type(val) ~= tpe then
				print('addSetting error: otherProps[' .. prop .. '] must be a ' .. tpe .. ' for inputType ' .. inputType .. ' or non-existent');
				print('name = ' .. name);
				print('otherProps[' .. prop .. '] = ' .. tostring(val));

				return;
			end
		end

		setting[prop] = val;
	end

	if inputType == 'bool' then
		-- no special checks required
	elseif inputType == 'text' then
		if setting.charLimit and setting.charLimit < 1 then
			print('addSetting error: otherProps.charLimit should always be higher than 0 or else user cant enter text');
			print('name = ' .. name);
			print('otherProps.charLimit = ' .. tostring(setting.charLimit));

			return;
		end
	elseif inputType == 'int' or inputType == 'float' then
		if (setting.minValue > setting.maxValue) or (setting.maxValue < setting.minValue) then
			print('addSetting error: otherProps.minValue must be lower than otherProps.maxValue and otherProps.maxValue must be higher than otherProps.minValue');
			print('name = ' .. name);
			print('minValue = ' .. tostring(setting.minValue);
			print('maxValue = ' .. tostring(setting.maxValue));

			return;
		end

		if setting.absoluteMax then
			if setting.absoluteMax < setting.maxValue then
				print('addSetting error: otherProps.absoluteMax must be higher than otherProps.maxValue');
				print('name = ' .. name);
				print('absoluteMax = ' .. tostring(setting.absoluteMax));
				print('maxValue = ' .. tostring(setting.maxValue));

				return;
			end
		end

		if setting.absoluteMin then
			if setting.absoluteMin > setting.minValue then
				print('addSetting error: otherProps.absoluteMin must be lower than otherProps.minValue');
				print('name = ' .. name);
				print('absoluteMin = ' .. tostring(setting.absoluteMin));
				print('minValue = ' .. tostring(setting.minValue));

				return;
			end
		end
	elseif inputType == 'radio' then
		-- defaultValue is the initial selected option
		-- defaultValue must be a whole number in range of #controls
		-- controls is an array
		-- items in the array should a table (label: <string>, labelColor: <color> or nil) or string (maps to table.label)

		if #settings.controls < 2 then
			print('addSetting error: otherProps.controls must have at least 2 controls');
			print('name = ' .. name);

			return;
		end

		if defaultValue < 1 then
			print('addSetting error: defaultValue for inputType ' .. inputType .. ' must be at least 1');
			print('name = ' .. name);
			print('defaultValue = ' .. defaultValue);

			return;
		end

		if defaultValue > #settings.controls then
			print('addSetting error: defaultValue for inputType ' .. inputType .. ' must be no larger than the length of the otherProps.controls array');
			print('name = ' .. name);
			print('defaultValue = ' .. defaultValue);

			return;
		end

		if optionalProps.bkwards and otherProps.bkwards < 1 then
			print('addSetting error: otherProps.bkwards for inputType ' .. inputType .. ' must be at least 1');
			print('name = ' .. name);
			print('otherProps.bkwards = ' .. otherProps.bkwards);

			return;
		end

		if optionalProps.bkwards and otherProps.bkwards > #settings.controls then
			print('addSetting error: otherProps.bkwards for inputType ' .. inputType .. ' must be no larger than the length of the otherProps.controls array');
			print('name = ' .. name);
			print('otherProps.bkwards = ' .. otherProps.bkwards);

			return;
		end

		local foundDefaultSelectedControl = false;
		local foundBkwardsSelectedControl = not setting.bkwards;

		for i, value in ipairs(controls) do
			if i == defaultValue then
				foundDefaultSelectedControl = true;
			end

			if i == setting.bkwards then
				foundBkwardsSelectedControl = true;
			end

			if type(value) == 'string' then
				-- is valid label name
			elseif type(value) == 'table' then
				if not (type(value.label) == 'string') then
					print('addSetting error: otherProps.controls[' .. i .. '].label must be a string');
					print('name = ' .. name);
					print('otherProps.controls[' .. i .. '].label = ' .. tostring(otherProps.controls[i].label));

					return;
				end

				if not (not value.labelColor or type(value.labelColor) == 'string') then
					print('addSetting error: otherProps.controls[' .. i .. '].labelColor must falsey or a color');
					print('name = ' .. name);
					print('otherProps.controls[' .. i .. '].labelColor = ' .. tostring(otherProps.controls[i].labelColor));

					return;
				end

				if not (not value.labelHelp or type(value.labelHelp) == 'function') then
					print('addSetting error: otherProps.controls[' .. i .. '].labelHelp must be falsey or a function(parent)');
					print('name = ' .. name);
					print('otherProps.controls[' .. i .. '].labelHelp = ' .. tostring(otherProps.controls[i].labelHelp));

					return;
				end
			end
		end

		if not foundDefaultSelectedControl then
			print('addSetting error: defaultValue for inputType ' .. inputType .. ' does not exist as a key on the otherProps.controls array');
			print('name = ' .. name);
			print('defaultValue = ' .. defaultValue);

			return;
		end

		if not foundBkwardsSelectedControl then
			print('addSetting error: otherProps.bkwards for inputType ' .. inputType .. ' does not exist as a key on the otherProps.controls array');
			print('name = ' .. name);
			print('otherProps.bkwards' .. otherProps.bkwards);

			return;
		end
	end

	return setting;
end

function addSettingTemplate(name, btnText, options, get)
	if type(name) ~= 'string' then
		print('addSettingTemplate error: name must be a string');
		print('name = ' .. tostring(name));

		return;
	end

	if type(btnText) ~= 'string' then
		print('addSettingTemplate error: btnText must be a string');
		print('name = ' .. name);
		print('btnText = ' .. tostring(btnText));

		return;
	end

	if options == nil then
		options = {};
	else
		if type(options) ~= 'table' then
			print('addSettingTemplate error: options must be a table or nil');
			print('name = ' .. name);
			print('options = ' .. tostring(options));

			return;
		end
	end

	if type(get) ~= 'function' then
		print('addSettingTemplate error: get must be a function(n)');
		print('name = ' .. name);
		print('get = ' .. tostring(get));

		return;
	end

	local setting = {
		name = name,
		btnText = btnText,
		isTemplate = true,
		btnColor = options.btnColor,
		btnTextColor = options.btnTextColor,
		bkwards = options.bkwards
	};

	setting.get = function(n)
		local tmp = get(n);

		if type(tmp) ~= 'table' then
			print('addSettingTemplate error: get(n) must return a table');
			print('name = ' .. name);
			print('get(n) = ' .. tostring(tmp));

			return;
		end

		if type(tmp.label) ~= 'string' then
			print('addSettingTemplate error: get(n).label must be a string');
			print('name = ' .. name);
			print('get(n).label = ' .. tostring(tmp.label));

			return;
		end

		-- cant do checkbox label color

		if type(tmp.settings) ~= 'table' then
			print('addSettingTemplate error: get(n).settings must be a table');
			print('name = ' .. name);
			print('get(n).settings = ' .. tostring(tmp.settings));

			return;
		end

		for i, ss in ipairs(tmp.settings) do
			local name = tmp.settings[i].name;

			if type(name) ~= 'string' then
				print('addSettingTemplate error: get(n).settings[i].name must be a string');
				print('name = ' .. name);
				print('get(n).settings[i].name = ' .. tostring(ss.name));

				return;
			end

			tmp.settings[i].name = setting.name .. '_' .. n .. '_' .. name;
		end

		return {
			name = setting.name .. '_' .. n,
			inputType = 'bool',
			defaultValue = true,
			label = tmp.label,
			subsettings = tmp.settings
		};
	end

	return setting;
end

-- used to keep track of which areas exist in Client_PresentSettingsUI
local numsSettingGroups = 0;

function addSettingGroup(btnTxt, options, settings)
	numsSettingGroups = numsSettingGroups + 1;

	if type(btnText) ~= 'string' then
		print('addSettingGroup error: btnText must be a string');
		print('btnText = ' .. tostring(btnText));

		return;
	end

	if options == nil then
		options = {};
	end

	if type(options) ~= 'table' then
		print('addSettingGroup error: options must be a table or nil');
		print('btnText = ' .. btnText);
		print('options = ' .. tostring(options));

		return;
	end

	if options.onExpand == nil then
		options.onExpand = function() end;
	end

	if type(options.onExpand) ~= 'function' then
		print('addSettingGroup error: options.onExpand must be a function(vert) or nil');
		print('btnText = ' .. btnText);
		print('options.onExpand = ' .. tostring(options.onExpand));

		return;
	end

	-- this doesnt need to use options.bkwards
	return {
		isGroup = true,
		btnText = btnText,
		btnColor = options.btnColor,
		btnTextColor = options.btnTextColor,
		onExpand = options.onExpand,
		subsettings: settings,
		ID = numsSettingGroups
	};
end

function getSetting(name, template)
	if type(name) ~= 'string' then
		print('getSetting error: name must be a string');
		print('name = ' .. tostring(name));

		return;
	end

	if template ~= nil then
		if type(template) ~= 'table' then
			print('getSetting error: template must be a table or non-existent');
			print('template = ' .. tostring(template));

			return;
		end

		if type(template.n) ~= 'number' then
			print('getSetting error: template.n must be a number');
			print('template.n = ' .. tostring(template.n));

			return;
		end

		if type(template.name) ~= 'string' then
			print('getSetting error: template.name must be a string');
			print('template.name = ' .. tostring(template.name));

			return;
		end

		name = name .. '_' .. template.n .. '_' .. template.name;
	end

	if Mod.Settings[name] == nil then
		print('getSetting warning: setting ' .. name .. ' doesnt exist');

		return;
	end

	return Mod.Settings[name];
end

function getCollapseBtnLabelTxt()
	-- https://www.amp-what.com &#9650;

	return '▲';
end

function getExpandBtnLabelTxt()
	-- https://www.amp-what.com &#9660;

	return '▼';
end
