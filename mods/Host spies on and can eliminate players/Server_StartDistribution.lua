require('tblprint');
require('version');
require('setup');

function Server_StartDistribution(game, standing)
	if not serverCanRunMod(game) then
		return;
	end

	setup(game);
end