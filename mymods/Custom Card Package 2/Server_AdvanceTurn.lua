require 'version';
require '_settings';
require '_util';

function Server_AdvanceTurn_Start(game)
	local publicGD = Mod.PublicGameData;

	for teamType in pairs(publicGD.teams) do
		for teamId in pairs(publicGD.teams[teamType]) do
			publicGD.teams[teamType].receivedPieces = nil;
		end
	end

	Mod.PublicGameData = publicGD;
end

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	processGameOrderCustom(game, order);
end

function processGameOrderCustom(game, order)
	if not (order.proxyType == 'GameOrderCustom' and startsWith(order.Payload, 'CCP2_')) then
		return;
	end

	if game.Settings.SinglePlayer and not canRunMod() then
		return;
	end

	parsePayload(game, order.Payload);
end

function parsePayload(game, payload)
	-- 'CCP2_addCardPieces_1000_<Reconnaissance+=[1],Reconnaissance+=[1]>',
	-- 'CCP2_useCard_1000_<Reconnaissance+=[100],Reconnaissance+=[]>',

	local commands = {
		addCardPieces = addCardPieces,
		useCard = useCard
	};
	local cardNames = {
		'Reconnaissance+' = true
	};

	for _, str in pairs(strs) do
		local _, _, command, playerId, cards = string.find(str, '^CCP2_([^_]+)_(%d+)_<([^>]+)>$');
		playerId = tonumber(playerId);

		if playerId and game.ServerGame.Game.PlayingPlayers[playerId] and command and cards and commands[command] then
			local player = game.ServerGame.Game.PlayingPlayers[playerId];
			local commaSplit = split(cards, ',');

			for _, str2 in pairs(commaSplit) do
				local _, _, cardName, param = string.find(str2, '^([^=]+)=%[([^%]]*)%]$');

				if cardName and param and cardNames[cardName] then
					commands[command](game, player, cardName, param);
				end
			end
		end
	end
end

function addCardPieces(game, player, cardName, param)
	local numPieces = tonumber(param);
	-- todo
	-- this has to decide if any new pieces have been earned
end

function useCard(game, player, cardName, param)
	local use = {
		'Reconnaissance+' = useCardReconnaissancePlus
	};

	-- need to check if enough pieces to play card

	local success = use[cardName](game, player, cardName, param);
	if not success then
		return;
	end

	-- reduce number of current pieces
end

function useCardReconnaissancePlus(game, player, cardName, param)
	local terrId = tonumber(param);
	-- todo
	-- https://www.warzone.com/wiki/Mod_API_Reference:GameOrderPlayCardReconnaissance
	-- https://www.warzone.com/wiki/Mod_API_Reference:NoParameterCardInstance
	return true;
end