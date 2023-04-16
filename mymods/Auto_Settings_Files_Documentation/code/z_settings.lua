function addSetting(name, label, inputType, defaultValue, otherProps)
	local allowedInputTypes = {
		int = 'number',
		float = 'number',
		bool = 'boolean',
		text = 'string'
	};

	if type(name) ~= 'string' then
		print('name in addSetting must be a string\nname is');
		print(name);
		return;
	end

	if type(label) ~= 'string' then
		print('label in addSetting must be a string\nlabel is');
		print(label);
		return;
	end

	if not allowedInputTypes[inputType] then
		print('inputType in addSetting must be one of "int", "float", "bool", "text"\ninputType is');
		print(inputType);
		return;
	end

	if type(defaultValue) ~= allowedInputTypes[inputType] then
		print('defaultValue in addSetting must be ' .. allowedInputTypes[inputType] .. ' for inputType ' .. inputType .. '\ndefaultValue is');
		print(defaultValue);
		return;
	end

	local setting = {name = name, label = label, inputType = inputType, defaultValue = defaultValue};

	if otherProps == nil then
		return setting;
	end

	if type(otherProps) ~= 'table' then
		print('otherProps in addSetting must be a table\notherProps is');
		print(otherProps);
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
	else
		if inputType == 'float' then
			forcedProps.dp = 'number';
		end

		forcedProps.minValue = 'number';
		forcedProps.maxValue = 'number';
		optionalProps.absoluteMax = 'number';
	end

	for prop, tpe in pairs(forcedProps) do
		local val = otherProps[prop];

		if type(val) ~= tpe then
			print(prop .. ' must be a ' + tpe .. ' for inputType ' .. inputType .. ' in addSetting\nis');
			print(val)
			return;
		end

		setting[prop] = val;
	end

	for prop, tpe in pairs(optionalProps) do
		local val = otherProps[prop];

		if val ~= nil then
			if type(val) ~= tpe then
				print(prop .. ' must be a ' + tpe .. ' for inputType ' .. inputType .. ' or non-existent in addSetting\nis');
				print(val);
				return;
			end
		end

		setting[prop] = val;
	end

	return setting;
end

function addSettingTemplate(name, btnText, options, get)
	-- todo add bkwards
	if type(name) ~= 'string' then
		print('name in addSettingTemplate must be a string\nname is');
		print(name);
		return;
	end

	if type(btnText) ~= 'string' then
		print('btnText in addSettingTemplate must be a string\nname is');
		print(btnText);
		return;
	end

	if options == nil then
		options = {};
	else
		if type(options) ~= 'table' then
			print('options in addSettingTemplate must be a table or nil\noptions is');
			print(options);
			return;
		end
	end

	if type(get) ~= 'function' then
		print('get in addSettingTemplate must be a function(n)\nget is');
		print(groupLabel);
		return;
	end

	local setting = {name = name, btnText = btnText, isTemplate = true, btnColor = options.btnColor, btnTextColor = options.btnTextColor, bkwards = options.bkwards};
	setting.get = function(n)
		local tmp = get(n);
		if type(tmp) ~= 'table' then
			print('get(n) must return a table in addSettingTemplate\nis');
			print(tmp);
			return;
		end

		if type(tmp.label) ~= 'string' then
			print('get(n).label must be a string\nis');
			print(tmp.label);
			return;
		end

		-- cant do checkbox label color

		if type(tmp.settings) ~= 'table' then
			print('get(n).settings must be a table in addSettingTemplate\nis');
			print(tmp.settings);
			return;
		end

		for i, ss in ipairs(tmp.settings) do
			local name = tmp.settings[i].name;
			if type(name) ~= 'string' then
				print('get(n).settings[' + i + '].name must be a string\nis');
				print(ss.name);
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

function getSetting(name, template)
	if type(name) ~= 'string' then
		print('name in getSetting must be a string\nis');
		print(name);
		return;
	end

	if template ~= nil then
		if type(template) ~= 'table' then
			print('template in getSetting must be a table or non-existent\nis');
			print(template);
			return;
		end

		if type(template.n) ~= 'number' then
			print('template.n must be a number in getSetting\nis');
			print(template.n);
			return;
		end

		if type(template.name) ~= 'string' then
			print('template.name must be a string in getSetting\nis');
			print(template.name);
			return;
		end

		name = name .. '_' .. template.n .. '_' .. template.name;
	end

	if Mod.Settings[name] == nil then
		print('setting ' + name + ' doesnt exist');
		return;
	end

	return Mod.Settings[name];
end