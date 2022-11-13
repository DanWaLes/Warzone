require 'settings'

function Client_PresentSettingsUI(rootParent)
	cps(rootParent, getSettings());
end

function cps(rootParent, settings)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	for settingName, setting in pairs(settings) do
		UI.CreateLabel(vert).SetText(setting.label .. ': '.. tostring(Mod.Settings[settingName]));

		if setting.subsettings and Mod.Settings[settingName] then
			cps(vert, setting.subsettings);
		end
	end
end