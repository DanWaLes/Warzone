-- https://www.warzone.com/wiki/Mod_API_Reference:GameOrderCustom OccursInPhaseOpt 5.22.0
-- https://www.warzone.com/wiki/Mod_API_Reference:UI UI.InterceptNextTerritoryClick 5.17.0
-- https://www.warzone.com/wiki/Mod_Hooks Server_AdvanceTurn_Order addNewOrder arg2 5.17.0

function canRunMod()
	local version = '5.22';
	local name = '"Custom Card Package 2"';

	if (not WL.IsVersionOrHigher or not WL.IsVersionOrHigher(version)) then
		UI.Alert('You must be running app version ' + version + ' at the minimum to use mod ' + name + '. Check for updates');
		return;
	end

	return true;
end
