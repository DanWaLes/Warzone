require 'settings'

function Client_PresentSettingsUI(rootParent)
	cps(rootParent, getSettings());
end

function cps(rootParent, settings)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	for _, setting in ipairs(settings) do
		local settingName = setting.name;
		local settingValue = Mod.Settings[settingName];

		if settingValue == nil then
			settingValue = false;
			-- for settings added while mod is public
			-- new settings must be a setting with subsettings
		end

		UI.CreateLabel(vert).SetText(setting.label .. ': ' .. tostring(settingValue));

		if setting.subsettings and settingValue then
			cps(vert, setting.subsettings);
		end
	end
end