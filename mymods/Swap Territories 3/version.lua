-- https://www.warzone.com/wiki/Mod_API_Reference:CustomSpecialUnit

function canRunMod()
	local version = '5.24.1';
	local name = '"Swap Territories 3"';

	if (not WL.IsVersionOrHigher or not WL.IsVersionOrHigher(version)) then
		UI.Alert('You must be running app version ' + version + ' at the minimum to use mod ' + name + '. Check for updates');
		return;
	end

	return true;
end