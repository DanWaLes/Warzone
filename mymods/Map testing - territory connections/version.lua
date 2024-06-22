-- https://www.warzone.com/wiki/Mod_API_Reference#Newer_API_features

function canRunMod()
	local version = '5.17';
	local name = '"Map testing - territory connection"';

	if (not WL.IsVersionOrHigher or not WL.IsVersionOrHigher(version)) then
		if UI and UI.Alert then
			UI.Alert('You must be running app version ' .. version .. ' at the minimum to use mod ' .. name .. '. Check for updates');
		end

		return false;
	end

	return true;
end

function serverCanRunMod(game)
	if game.Settings.SinglePlayer and not canRunMod() then
		return false;
	end

	return true;
end
