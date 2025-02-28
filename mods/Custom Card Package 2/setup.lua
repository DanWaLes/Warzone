require('settings');
require('tblprint');
require('cards');

function setup(game)
	local cardNames = getCardNames();
	local cardsThatCanBeActive = getCardsThatCanBeActive();
	local teams = {};

	for playerId, player in pairs(game.ServerGame.Game.Players) do
		if player.Team > -1 then
			if not teams[player.Team] then
				teams[player.Team] = {members = {}};
			end

			table.insert(teams[player.Team].members, playerId);
		end
	end

	for cardName in pairs(cardsThatCanBeActive) do
		cardsThatCanBeActive[cardName] = getSetting('Enable' .. cardName);
	end

	local terrsArray = nil;

	if (getSetting('EnableReconnaissance+') and getSetting('Reconnaissance+RandomAutoplay')) or getSetting('AIsPlayCards') then
		terrsArray = {};

		for terrId in pairs(game.Map.Territories) do
			table.insert(terrsArray, terrId);
		end
	end

	local pgd = Mod.PublicGameData;

	pgd.teams = teams;
	pgd.cardNames = cardNames;
	pgd.cardsThatCanBeActive = cardsThatCanBeActive;
	pgd.activeCards = nil;
	pgd.terrsArray = terrsArray;
	Mod.PublicGameData = pgd;
end
