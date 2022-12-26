require 'eliminate'

function Server_AdvanceTurn_Start(game, addNewOrder)
	if (not WL.IsVersionOrHigher or not WL.IsVersionOrHigher('5.22')) then
		UI.Alert('You must update your app to the latest version to use this mod');
		return;
	end

	local players = {};
	local numPlaying = 0;
	local numVoted = 0;

	for playerId, player in pairs(game.ServerGame.Game.Players) do
		local playing = player.State == WL.GamePlayerState.Playing;

		if playing then
			numPlaying = numPlaying + 1;
			players[numPlaying] = playerId;

			if player.IsAIOrHumanTurnedIntoAI then
				numVoted = numVoted + 1;
			else
				if Mod.PublicGameData.votes[playerId] then
					numVoted = numVoted + 1;
				end
			end
		end
	end

	if numVoted ~= numPlaying then
		return;
	end

	local winner = math.random(1, numPlaying);
	local winnerId = players[winner];

	players[winner] = nil;

	addNewOrder(WL.GameOrderEvent.Create(winnerId, 'Random winner decided', {}, eliminate(players, game.ServerGame.LatestTurnStanding.Territories)));
end