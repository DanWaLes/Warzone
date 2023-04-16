require '_version'
require 'z_settings'
-- require 'z_util'

local isMegaRaffle;
local reward;
local playersInRaffle = {};

function Server_AdvanceTurn_Start(game, addNewOrder)
	if not game.Settings.MultiPlayer and not canRunMod() then
		-- client is server in SP games
		-- if cant run, dont apply the mod, turn proceeds as normal
		return;
	end;

	if (100 - math.random(1, 100)) < getSetting('RaffleChance') then
		return;
	end

	local rand = getSetting('RaffleRewardRand');
	reward = math.random(-rand, rand) + getSetting('RaffleReward');
	if reward < 0 then
		reward = 1;
	end

	if getSetting('MegaRaffleEnabled') then
		if (100 - math.random(1, 100)) < getSetting('MegaRaffleChance') then
			isMegaRaffle = true;
			reward = round(reward * getSetting('MegaRaffleMulti'));
		end
	end

	local raffStartingMsg = reward .. ' ';
	if game.Settings.CommerceGame then
		raffStartingMsg = raffStartingMsg .. 'gold';
	else
		raffStartingMsg = raffStartingMsg .. 'army';
	end
	if isMegaRaffle then
		raffStartingMsg = raffStartingMsg .. ' mega';
	end
	raffStartingMsg = raffStartingMsg .. ' raffle starting!';

	addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, raffStartingMsg, nil));

	for playerId, player in pairs(game.ServerGame.Game.PlayingPlayers) do
		addNewOrder(WL.GameOrderCustom.Create(playerId, '!raffle', 'Raffles_enterraffle', nil, 1));
	end
end

local done = false;

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if done or not reward then
		return;
	end

	if order.proxyType == 'GameOrderCustom' then
		if order.Payload == 'Raffles_enterraffle' then
			-- like this allows rigged raffles, useful for cheat codes
			if not playersInRaffle[order.PlayerID] then
				playersInRaffle[order.PlayerID] = 0;
			end
			playersInRaffle[order.PlayerID] = playersInRaffle[order.PlayerID] + 1;

			-- GameOrderCustom doesnt have a visibleToOpt and GameOrderEvent doesnt have a payload
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
			addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, '!raffle', nil));
		end
	end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	done = true;

	if not reward then
		return;
	end

	local playersActuallyInRaffle = {};
	local numPlayersInRaffle = 0;
	-- print('playersInRaffle');
	-- tblprint(playersInRaffle);

	for playerId, n in pairs(playersInRaffle) do
		local player = game.ServerGame.Game.Players[playerId];
		local isPlaying = player.State == WL.GamePlayerState.Playing;

		while isPlaying and n > 0 do
			numPlayersInRaffle = numPlayersInRaffle + 1;
			playersActuallyInRaffle[numPlayersInRaffle] = playerId;
			n = n - 1;
		end
	end

	if numPlayersInRaffle < 1 then
		-- for if a mod skipped the raffle orders
		return;
	end

	-- print('numPlayersInRaffle = ' .. numPlayersInRaffle);
	-- print('playersActuallyInRaffle');
	-- tblprint(playersActuallyInRaffle);

	local winner = playersActuallyInRaffle[math.random(1, numPlayersInRaffle)];
	local winnerName = game.ServerGame.Game.Players[winner].DisplayName(nil, false);
	local msg =  'Raffle over: congratulations to ' .. winnerName .. ' for winning ' .. reward .. ' ';
	if game.Settings.CommerceGame then
		msg = msg .. 'gold';
	else
		if reward > 1 then
			msg = msg .. 'armies';
		else
			msg = msg .. 'army';
		end
	end
	msg = msg .. '!';

	addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, msg, nil, nil, nil, {WL.IncomeMod.Create(winner, reward, '')}));
end