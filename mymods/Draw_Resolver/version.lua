function canRunMod()
	local version = '5.22';
	local name = '"Draw Resolver"';

	if (not WL.IsVersionOrHigher or not WL.IsVersionOrHigher(version)) then
		UI.Alert('You must be running app version ' + version + ' at the minimum to use mod ' + name + '. Check for updates');
		return;
	end

	return true;
end