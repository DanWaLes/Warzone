require '_util';

function Server_Created(game, settings)
	if not settings.Cards then
		return;
	end

	Mod.PublicGameData = {lastGivenCardPiecesOn = {}};
end