require 'distwastelands';

function Server_StartGame(game, standing)
	if game.Settings.AutomaticTerritoryDistribution then
		makeDistributionWastelands(game, standing);
	end
end