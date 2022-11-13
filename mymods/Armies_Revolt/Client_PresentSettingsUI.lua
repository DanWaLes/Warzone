require 'settings'

function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	for key, value in pairs(getSettings()) do
		UI.CreateLabel(vert).SetText(value.label .. ': '.. tostring(Mod.Settings[key]));
	end
end