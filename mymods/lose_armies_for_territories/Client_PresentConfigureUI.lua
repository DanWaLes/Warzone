require "LoseArmiesForTerritories"
require "Util"

function Client_PresentConfigureUI(rootParent)
	-- adapted from https://github.com/FizzerWL/ExampleMods/blob/master/RandomizedBonusesMod/Client_PresentConfigureUI.lua
	local initialGold = Mod.Settings.Gold;
	local initialTerritories = Mod.Settings.Territories;
	local initialEnableBonusOverrider = Mod.Settings.EnableBonusOverrider;
	if initialGold == nil then initialGold = GetDefaults("Gold"); end
	if initialTerritories == nil then initialTerritories = GetDefaults("Territories"); end
	if initialEnableBonusOverrider == nil then initialEnableBonusOverrider = GetDefaults("EnableBonusOverrider"); end

	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	local horz = UI.CreateHorizontalLayoutGroup(vert);

	UI.CreateLabel(horz).SetText('Gold to remove (G):');
    goldInputField = UI.CreateNumberInputField(horz)
		.SetSliderMinValue(GetDefaults("GoldMinVal"))
		.SetSliderMaxValue(GetDefaults("GoldMaxVal"))
		.SetValue(initialGold);

	UI.CreateLabel(horz).SetText('For each lot of this many territories owned (T):');
    territoriesInputField = UI.CreateNumberInputField(horz)
		.SetSliderMinValue(GetDefaults("TerritoriesMinVal"))
		.SetSliderMaxValue(GetDefaults("TerritoriesMaxVal"))
		.SetValue(initialTerritories);

	UI.CreateLabel(vert).SetText("It's recommended that bonuses are overridden to prevent the game from being a draw.");
	UI.CreateLabel(vert).SetText("Bonus overrider formula is: default bonus value + round((territories in bonus / T) * G)");
	enableBonusOverriderInputField = UI.CreateCheckBox(vert).SetText('Enable bonus overrider').SetIsChecked(initialEnableBonusOverrider);
end