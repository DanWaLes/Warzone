function canRunMod()
	local version = '5.22';
	local name = '"Raffles"';
	-- https://www.warzone.com/wiki/Mod_API_Reference:GameOrderCustom > OccursInPhaseOpt 5.22
	-- https://www.warzone.com/wiki/Mod_API_Reference:GameOrderEvent > https://www.warzone.com/wiki/Mod_API_Reference:IncomeMod 5.17

	if (not WL.IsVersionOrHigher or not WL.IsVersionOrHigher(version)) then
		UI.Alert('You must be running app version ' + version + ' at the minimum to use mod ' + name + '. Check for updates');
		return;
	end

	return true;
end