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

	if not Util_PlayerIsPlaying(game.Us) then
		return;
	end

	print("init Client_GameRefresh");

	local isAutoDistAndEnteredServer_StartGame = Util_IsAutoDist(game) and Mod.PublicGameData.enteredServer_StartGame;
	local isManualDistAndEnteredServer_StartDist = Util_IsManualDist(game) and Mod.PublicGameData.enteredServer_StartDist;

	if isAutoDistAndEnteredServer_StartGame then
		print("setting gold in autodist game");
	elseif isManualDistAndEnteredServer_StartDist then
		print("setting gold in manualdist game");
	else
		print("this should never happen");
		return;
	end

	local playerGameData = Mod.PlayerGameData;

	if playerGameData.HasReduceGold then return; end

	local waitText = "Setting gold to " .. Util_GetGold();
	local doneText = "Set gold to " .. Util_GetGold();

	local payload = {};
	payload.Msg = "remove_gold";

	local callback = function()
		if not playerGameData.HasShownIncorrectGoldWarning then
			-- note that when the game starts, the displayed Gold is incorrect, afterwards the displayed amount is correct and removes the correct amount of Gold

			UI.Alert("Your Gold for this turn should be " .. Util_GetGold() .. ". Your displayed Gold will be correct for the rest of this game.");
		end
	end

	game.SendGameCustomMessage(waitText, payload, callback);
end