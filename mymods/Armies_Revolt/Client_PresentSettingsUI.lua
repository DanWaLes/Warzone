require 'settings'
require 'ui'

function Client_PresentSettingsUI(rootParent)
	cps(rootParent, getSettings());
end

function cps(rootParent, settings)
	local vert = Vert(rootParent);

	for settingName, setting in pairs(settings) do
		local settingValue = Mod.Settings[settingName];

		if settingValue == nil then
			settingValue = false;
			-- for settings added while mod is public
			-- new settings must be a setting with subsettings that is by default not enabled
		end

		UI.CreateLabel(vert).SetText(setting.label .. ': ' .. settingValue);

		if setting.subsettings and settingValue then
			cps(vert, setting.subsettings);
		end
	end
end