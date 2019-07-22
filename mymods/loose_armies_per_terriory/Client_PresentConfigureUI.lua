require "LoseArmiesPerTerritory"
require "Util"

function Client_PresentConfigureUI(rootParent)
	-- adapted from https://github.com/FizzerWL/ExampleMods/blob/master/RandomizedBonusesMod/Client_PresentConfigureUI.lua
	local initialGold = Mod.Settings.Gold;
	local initialTerritories = Mod.Settings.Territories;
	if initialGold == nil then initialGold = GetDefaults("Gold"); end
	if initialTerritories == nil then initialTerritories = GetDefaults("Territories"); end

	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	local horz = UI.CreateHorizontalLayoutGroup(vert);

	UI.CreateLabel(horz).SetText('Gold cost per group of X territories held:');
    goldInputField = UI.CreateNumberInputField(horz)
		.SetSliderMinValue(GetDefaults("GoldMinVal"))
		.SetSliderMaxValue(GetDefaults("GoldMaxVal"))
		.SetValue(initialGold);

	UI.CreateLabel(horz).SetText('X Gold is removed for holding this many groups of territories:');
    territoriesInputField = UI.CreateNumberInputField(horz)
		.SetSliderMinValue(GetDefaults("TerritoriesMinVal"))
		.SetSliderMaxValue(GetDefaults("TerritoriesMaxVal"))
		.SetValue(initialTerritories);
end