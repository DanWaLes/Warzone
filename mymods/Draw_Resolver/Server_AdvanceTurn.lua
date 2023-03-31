require 'eliminate'
require 'version'

function Server_AdvanceTurn_Start(game, addNewOrder)
	if game.Settings.SinglePlayer and not canRunMod() then
		return;
	end

	local votes = checkVotes(game)

	if votes.numPlaying ~= votes.numVotes then
		return;
	end

	local winner = math.random(1, votes.numPlaying);
	local winnerId = votes.players[winner];

	votes.players[winner] = nil;

	addNewOrder(WL.GameOrderEvent.Create(winnerId, 'Decided random winner', {}, eliminate(votes.players, game.ServerGame.LatestTurnStanding.Territories)));
end

function checkVotes(game)
	local publicGameData = Mod.PublicGameData;
	local numPlaying = 0;
	local numVotes = 0;
	local players = {};

	for playerId, player in pairs(game.ServerGame.Game.Players) do
		local playing = player.State == WL.GamePlayerState.Playing;

		if playing then
			numPlaying = numPlaying + 1;
			players[numPlaying] = playerId;

			if publicGameData.votes[playerId] or player.IsAIOrHumanTurnedIntoAI then
				numVotes = numVotes + 1;
			end
		else
			publicGameData.votes[playerId] = false;
		end
	end

	Mod.PublicGameData = publicGameData;

	return {players = players, numPlaying = numPlaying, numVotes = numVotes};
end