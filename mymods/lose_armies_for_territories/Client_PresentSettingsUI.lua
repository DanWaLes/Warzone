function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	
	UI.CreateLabel(vert).SetText('Gold to remove: ' .. tostring(Mod.Settings.Gold));
	UI.CreateLabel(vert).SetText('For each lot of this many territories owned: ' .. tostring(Mod.Settings.Territories));
	UI.CreateLabel(vert).SetText('Enable bonus overrider: ' .. tostring(Mod.Settings.EnableBonusOverrider));
end
