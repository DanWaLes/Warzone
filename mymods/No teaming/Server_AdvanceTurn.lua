require '_util';
require 'version';
require 'eliminate';

function Server_AdvanceTurn_Start(Game, AddNewOrder)
	if not canRunMod() then
		return;
	end

	game = Game;
	addNewOrder = AddNewOrder;
	host = game.Settings.StartedBy;

	eliminatePlayers();
	spyOnEveryone();

	local playerGD = Mod.PlayerGameData;
	playerGD[host].eliminating = {};
	Mod.PlayerGameData = playerGD;
end

function eliminatePlayers()
	local terrs = game.ServerGame.LatestTurnStanding.Territories;

	if not Mod.PlayerGameData[host].eliminating then
		return;
	end

	local eliminating = {};
	local msg = 'Eliminate ';
	eliminatedPlayers = {};

	for playerId in pairs(Mod.PlayerGameData[host].eliminating) do
		local player = game.ServerGame.Game.Players[playerId];

		if player and player.State == WL.GamePlayerState.Playing then
			msg = msg .. player.DisplayName(nil, false) .. ', ';
			table.insert(eliminating, playerId);
			eliminatedPlayers[playerId] = true;
		end
	end

	msg = string.gsub(msg, ', $', '');

	if #eliminating > 0 then
		addNewOrder(WL.GameOrderEvent.Create(host, msg, nil, eliminate(eliminating, terrs)));
	end
end

function spyOnEveryone()
	for playerId, player in pairs(game.ServerGame.Game.PlayingPlayers) do
		if not eliminatedPlayers[playerId] then
			spyOn(playerId);
		end
	end

	if game.ServerGame.Settings.Cards[WL.CardID.Spy].CanSpyOnNeutral then
		spyOn(WL.PlayerID.Neutral);
	end
end

function spyOn(playerId)
	local cardInstance = WL.NoParameterCardInstance.Create(WL.CardID.Spy);
	local order = WL.GameOrderPlayCardSpy.Create(cardInstance.ID, host, playerId);

	addNewOrder(order);
end