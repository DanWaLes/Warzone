-- https://www.warzone.com/wiki/Mod_API_Reference:TerritoryModification RemoveSpecialUnitsOpt 5.22.0

function canRunMod()
	local version = '5.22';
	local name = '"Host spies on and can eliminate players"';

	if (not WL.IsVersionOrHigher or not WL.IsVersionOrHigher(version)) then
		UI.Alert('You must be running app version ' + version + ' at the minimum to use mod ' + name + '. Check for updates');
		return;
	end

	return true;
end