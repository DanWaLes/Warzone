require "Util"
-- say to the server that we're ready to apply changes in gold for this player
-- only called on human players

function Client_GameRefresh(game)
	-- if we're in the game
	if game == nil then
		return;
	end
	if game.Us == nil then
		return;
	end

	if not PlayerIsPlaying(game.Us) then
		return;
	end

	local playerGameData = Mod.PlayerGameData;

	-- print("Mod.PlayerGameData =\n" .. tprint(Mod.PlayerGameData));

	if playerGameData.HasReduceGold then return; end

	local waitText = "Removing " .. tostring(Mod.Settings.Gold) .. " Gold for each " .. ternary(Mod.Settings.Territories == 1, "territory", tostring(Mod.Settings.Territories) .. "territories") .. "owned"
	local doneText = "Removed " .. tostring(Mod.Settings.Gold) .. " Gold for each " .. ternary(Mod.Settings.Territories == 1, "territory", tostring(Mod.Settings.Territories) .. "territories") .. "owned"
	local payload = {};
	payload.Msg = "Remove gold for territories";

	local callback = function(returnValue)
		-- prompting user each turn could get in the user's way
		-- UI.Alert(doneText);
	end

	game.SendGameCustomMessage(waitText, payload, callback);
end
