require "Util"

-- say to the server that we're ready to apply changes in gold for this player
-- only called on human players

function Client_GameRefresh(game)
	print("init Client_GameRefresh");
	-- if we're in the game
	if game == nil then
		print("game was nil in Client_GameRefresh");
		return;
	end
	if game.Us == nil then
		return;
	end

	local playerGameData = Mod.PlayerGameData;

	if playerGameData[game.Us.ID].HasReduceGold then
		return;
	end

	local waitText = "Removing 1 Gold per territory...";
	local doneText = "Done";
	local payload = {};

	payload.Msg = "Remove Gold";

	local callback = function(returnValue)
		UI.Alert(doneText);
	end

	print("about to send SendGameCustomMessage");
	game.SendGameCustomMessage(waitText, payload, callback);
	print("sent SendGameCustomMessage");
end