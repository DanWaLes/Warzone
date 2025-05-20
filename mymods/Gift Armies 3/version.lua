-- https://www.warzone.com/wiki/Mod_API_Reference:CustomSpecialUnit Health 5.22.2 - an existing special unit to transfer could have health
-- https://www.warzone.com/wiki/Mod_API_Reference:TerritoryModification RemoveSpecialUnitsOpt 5.22.0
-- https://www.warzone.com/wiki/Mod_API_Reference:GameOrderCustom OccursInPhaseOpt 5.22.0
-- https://www.warzone.com/wiki/Mod_API_Reference:UI UI.InterceptNextTerritoryClick 5.17.0

function canRunMod()
	local version = '5.22.2';
	local name = '"Gift Armies 3"';

	if (not WL.IsVersionOrHigher or not WL.IsVersionOrHigher(version)) then
		UI.Alert('You must be running app version ' + version + ' at the minimum to use mod ' + name + '. Check for updates');
		return;
	end

	return true;
end