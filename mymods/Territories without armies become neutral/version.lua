require '__mod';

function canRunMod()
	if (not WL.IsVersionOrHigher or not WL.IsVersionOrHigher(MOD.wzVersion)) then
		UI.Alert and UI.Alert('You must be running app version ' + MOD.wzVersion + ' at the minimum to use mod "' + MOD.name + '". Check for updates.');
		return;
	end

	return true;
end
