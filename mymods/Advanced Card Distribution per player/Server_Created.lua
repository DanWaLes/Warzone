require '_util';
require '_settings';

function Server_Created(game, settings)
	if not settings.Cards then
		return;
	end

	for id, cardGame in pairs(settings.Cards) do
		local cardName = string.sub(cardGame.proxyType, #'CardGame' + 1);

		if getSetting('Enable' .. cardName) then
			settings.Cards[id].Weight = 1;
			settings.Cards[id].MinimumPiecesPerTurn = 0;
		end
	end

	Mod.PublicGameData = {lastGivenCardPiecesOn = {}};
end