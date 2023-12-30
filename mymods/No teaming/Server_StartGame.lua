require 'setup';

function Server_StartGame(game, standing)
	if game.ServerGame.Settings.AutomaticTerritoryDistribution then
		setup(game);
	end
end