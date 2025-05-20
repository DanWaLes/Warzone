require 'util'
require 'payloadTypes'
require 'teams'

local bought = {};
local badOrders = {};

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if order.proxyType == 'GameOrderCustom' then
		local isBuyOffice = order.Payload == PAYLOAD_TYPES.office.buy;
		local isBuyHacker = order.Payload == PAYLOAD_TYPES.hacker.buy;
		local isUpgradeHacker = not not string.match(order.Payload, PAYLOAD_TYPES.hacker.upgrade);

		if isBuyOffice or isBuyHacker or isUpgradeHacker then
			if not bought[order.PlayerID] then
				bought[order.PlayerID] = {
					offices = 0,
					hackers = {
						new = 0,
						upgrades = {}
					}
				};
			end

			if not badOrders[order.PlayerID] then
				badOrders[order.PlayerID] = {
					offices = {},
					hackers = {
						new = {},
						upgrades = {}
					}
				};
			end

			if isBuyOffice then
				skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);

				if order.CostOpt == nil or order.CostOpt[WL.ResourceType.Gold] ~= Mod.Settings.OfficeCost then
					local skipMsg = 'Buy office order skipped because the cost does not match with game settings';
					local skipReason = WL.GameOrderEvent.Create(order.PlayerID, skipMsg, {});

					table.insert(badOrders[order.PlayerId].offices, skipReason);
				else
					bought[order.PlayerID].offices = bought[order.PlayerID].offices + 1;
				end
			elseif isBuyHacker then
				skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);

				if order.CostOpt == nil or order.CostOpt[WL.ResourceType.Gold] ~= Mod.Settings.HackerBaseCost then
					local skipMsg = 'Buy hacker order skipped because the cost does not match';
					local skipReason = WL.GameOrderEvent.Create(order.PlayerID, skipMsg, {});

					table.insert(badOrders[order.PlayerID].hackers.new, skipReason);
				else
					bought[order.PlayerID].hackers.new = bought[order.PlayerID].hackers.new + 1;
				end
			elseif isUpgradeHacker then
				skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);

				local hackerNo = tonumber(string.match(order.Payload, '%d+'));
				local skipPrefix = 'Promote hacker #' .. hackerNo .. ' order skipped because ';
				local skipCostOrder = WL.GameOrderEvent.Create(order.PlayerID, skipPrefix .. 'cost does not match', {});

				if hackerNo < 1 or hackerNo > Mod.PlayerGameData[order.PlayerID].hackers.length then
					local skipNoSuchHackerOrder = WL.GameOrderEvent.Create(order.PlayerID, skipPrefix .. 'hacker does not exist', {});

					table.insert(badOrders[order.PlayerID].hackers.upgrades, skipNoSuchHackerOrder);
				elseif order.CostOpt == nil then
					table.insert(badOrders[order.PlayerID].hackers.upgrades, skipCostOrder);
				else
					local hacker = Mod.PlayerGameData[order.PlayerID].hackers.list[hackerNo];
					local hackerType = Mod.PublicGameData.hackerTypes[hacker.upgradeNo + 1];

					if not hackerType then
						local fullyPromotedOrder = WL.GameOrderEvent.Create(order.PlayerID, skipPrefix .. 'that hacker is fully promoted', {});

						table.insert(badOrders[order.PlayerID].hackers.upgrades, fullyPromotedOrder);
					elseif order.CostOpt[WL.ResourceType.Gold] == hackerType.cost then
						if not bought[order.PlayerID].hackers.upgrades[hackerNo] then
							bought[order.PlayerID].hackers.upgrades[hackerNo] = true;
						end

						-- silently ignore repeat orders, they should never happen anyway, is fiddly to display it in the right place
					else
						table.insert(badOrders[order.PlayerID].hackers.upgrades, skipCostOrder);
					end
				end
			end
		end
	end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	local playerGameData = Mod.PlayerGameData;

	makeGuesses(game, addNewOrder);
	validatePurchases(game, addNewOrder);
	useEveryonesCodes(game, addNewOrder);
end

function validatePurchases(game, addNewOrder)
	local playerGameData = Mod.PlayerGameData;

	for playerId, basket in pairs(bought) do
		if basket.hackers.new > 1 then
			local refund = {};
			refund[playerId] = {}
			refund[playerId][WL.ResourceType.Gold] = (basket.hackers.new - 1) * Mod.Settings.HackerBaseCost;

			local event = WL.GameOrderEvent.Create(playerId, 'Only one hacker can be bought at a time, refund given', {});
			event.AddResourceOpt = refund;

			table.insert(badOrders[playerId].hackers.new, event);

			bought[playerId].hackers.new = 1;
		end

		local n = 0;
		if bought[playerId].offices > 0 then
			n = 1;
		end

		local maxHackers = (playerGameData[playerId].numOffices + n) * Mod.Settings.HackersPerOffice;

		local turnNo = game.ServerGame.Game.NumberOfTurns;
		local turnHackerCanBeBought;
		if playerGameData[playerId].hackers.lastBoughtOnTurn == -1 then
			turnHackerCanBeBought = turnNo;
		else
			local numTurnsHackerCanBeBought = round(Mod.Settings.SpeedH1 / Mod.Settings.HackersPerOffice);
			turnHackerCanBeBought = playerGameData[playerId].hackers.lastBoughtOnTurn + numTurnsHackerCanBeBought;
		end

		if bought[playerId].hackers.new > 0 then
			if playerGameData[playerId].hackers.length + bought[playerId].hackers.new > maxHackers then
				local refund = {};
				refund[playerId] = {};
				refund[playerId][WL.ResourceType.Gold] = Mod.Settings.HackerBaseCost;

				local event = WL.GameOrderEvent.Create(playerId, 'Attempt made to buy a hacker when there is not enough offices, refund given', {});
				event.AddResourceOpt = refund;

				table.insert(badOrders[playerId].hackers.new, event);

				bought[playerId].hackers.new = 0;
			elseif playerGameData[playerId].hackers.lastBoughtOnTurn > -1 and turnHackerCanBeBought ~= game.ServerGame.Game.NumberOfTurns then
				local refund = {};
				refund[playerId] = {};
				refund[playerId][WL.ResourceType.Gold] = Mod.Settings.HackerBaseCost;

				local event = WL.GameOrderEvent.Create(playerId, 'Attempt made to buy a hacker when none are available, refund given', {});
				event.AddResourceOpt = refund;

				table.insert(badOrders[playerId].hackers.new, event);

				bought[playerId].hackers.new = 0;
			end
		end

		if bought[playerId].hackers.new > 0 then
			table.insert(playerGameData[playerId].hackers.list, {upgradeNo = 1});
			playerGameData[playerId].hackers.length = playerGameData[playerId].hackers.length + 1;
			playerGameData[playerId].hackers.lastBoughtOnTurn = game.ServerGame.Game.NumberOfTurns;
		end

		if bought[playerId].offices > 0 then
			local numHackers = playerGameData[playerId].hackers.length;
			local numOfficesNeeded = numHackers / Mod.Settings.HackersPerOffice;

			local numOfficesAllowed = math.ceil(numOfficesNeeded);
			if numOfficesAllowed == numOfficesNeeded then
				numOfficesAllowed = numOfficesAllowed + 1;
			end

			local numExtraOffices = playerGameData[playerId].numOffices + bought[playerId].offices - numOfficesAllowed;

			if numExtraOffices > 0 then
				local refund = {};
				refund[playerId] = {};
				refund[playerId][WL.ResourceType.Gold] = Mod.Settings.OfficeCost * numExtraOffices;

				local msg = 'Attempt made to buy ';
				if numExtraOffices == 1 then
					msg = msg .. 'an office';
				else
					msg = msg .. 'offices';
				end
				msg = msg .. ' when there is a sufficient amount, refund given';

				local event = WL.GameOrderEvent.Create(playerId, msg, {});
				event.AddResourceOpt = refund;

				table.insert(badOrders[playerId].offices, event);

				bought[playerId].offices = bought[playerId].offices - numExtraOffices;
			end
		end

		if bought[playerId].offices > 0 then
			playerGameData[playerId].numOffices = playerGameData[playerId].numOffices + 1;

			local event = WL.GameOrderEvent.Create(playerId, 'Buy an office', {});
			local buy = {};
			buy[playerId] = {};
			buy[playerId][WL.ResourceType.Gold] = -Mod.Settings.OfficeCost;

			event.AddResourceOpt = buy;
			addNewOrder(event);
		end

		for _, order in ipairs(badOrders[playerId].offices) do
			addNewOrder(order);
		end

		if bought[playerId].hackers.new > 0 then
			local event = WL.GameOrderEvent.Create(playerId, 'Buy a hacker', {});
			local buy = {};
			buy[playerId] = {};
			buy[playerId][WL.ResourceType.Gold] = -Mod.Settings.HackerBaseCost;

			event.AddResourceOpt = buy;
			addNewOrder(event);
		end

		for _, order in ipairs(badOrders[playerId].hackers.new) do
			addNewOrder(order);
		end

		for hackerNo, _ in pairs(bought[playerId].hackers.upgrades) do
			local upgradeNo = playerGameData[playerId].hackers.list[hackerNo].upgradeNo;

			playerGameData[playerId].hackers.list[hackerNo].upgradeNo = upgradeNo + 1;

			local oldHackerType = Mod.PublicGameData.hackerTypes[upgradeNo];
			local newHackerType = Mod.PublicGameData.hackerTypes[upgradeNo + 1];
			local event = WL.GameOrderEvent.Create(playerId, 'Promote hacker #' .. hackerNo .. ' from ' .. oldHackerType.name .. ' to ' .. newHackerType.name, {});
			local buy = {};
			buy[playerId] = {};
			buy[playerId][WL.ResourceType.Gold] = -newHackerType.cost;

			event.AddResourceOpt = buy;
			addNewOrder(event);
		end

		for _, order in ipairs(badOrders[playerId].hackers.upgrades) do
			addNewOrder(order);
		end
	end

	Mod.PlayerGameData = playerGameData;
end

function makeGuesses(game, addNewOrder)
	local teamGuessesSum = {};

	function getSoloGuessSum(playerId)
		local sum = 0;

		for _, hacker in pairs(Mod.PlayerGameData[playerId].hackers.list) do
			local hackerType = Mod.PublicGameData.hackerTypes[hacker.upgradeNo];

			sum = sum + hackerType.guessesPerTurn;
		end

		return round(sum);
	end
	
	function getLastCheatCodeCombo()
		local code = '';

		while string.len(code) < Mod.Settings.CheatCodeLength do
			code = code .. '9';
		end

		return tonumber(code);
	end

	function doGuessing(start, numNewGuesses, teamId, playerId)
		if numNewGuesses == 0 then
			return;
		end

		local guessedStr;
		local solvedStr;

		function toCode(n)
			local code = '' .. n;

			while string.len(code) < Mod.Settings.CheatCodeLength do
				code = '0' .. code;
			end

			return code;
		end

		start = start + 1;

		local last = getLastCheatCodeCombo();
		local finish = start + numNewGuesses;
		local solvedAll = finish >= last;

		if solvedAll then
			finish = last;
		end

		local privateGameData = Mod.PrivateGameData;
		local playerGameData = Mod.PlayerGameData;

		for codeStr, _ in pairs(Mod.PrivateGameData.cheatCodes) do
			local code = tonumber(codeStr);

			if code >= start and code <= finish then
				if teamId then
					privateGameData.cheatCodeProgress[teamId].solvedCheatCodes[codeStr] = true;

					if not solvedStr then
						solvedStr = 'Team ' .. teamIdToTeamName(teamId) .. ' solved cheat codes:';
					end
				else
					playerGameData[playerId].solvedCheatCodes[codeStr] = true;;

					if not solvedStr then
						solvedStr = 'Solved cheat codes:';
					end
				end

				if string.sub(solvedStr, -1) ~= ':' then
					solvedStr = solvedStr .. ',';
				end

				solvedStr = solvedStr .. ' ' .. codeStr;
			end
		end

		if teamId then
			privateGameData.cheatCodeProgress[teamId].lastGuessed = finish;
			guessedStr = 'Team ' .. teamIdToTeamName(teamId) .. ' guessed';
		else
			playerGameData[playerId].lastGuessed = finish;
			guessedStr = 'Guessed';
		end

		guessedStr = guessedStr .. ' cheat codes ' .. toCode(start) .. ' to ' .. toCode(finish);

		Mod.PrivateGameData = privateGameData;
		Mod.PlayerGameData = playerGameData;

		local assignedPlayer = playerId;
		if teamId then
			assignedPlayer = Mod.PublicGameData.teams.teamed.byTeamId[teamId][1];
		end

		local guessVisibility = nil;
		local solvedVisibility = nil;

		if Mod.Settings.CheatCodeGuessVisibiltyIsTeamOnly then
			guessVisibility = {};
		end
		if Mod.Settings.CheatCodeSolvedVisibiltyIsTeamOnly then
			solvedVisibility = {};
		end

		if guessedStr then
			addNewOrder(WL.GameOrderEvent.Create(assignedPlayer, guessedStr, guessVisibility));

			if solvedStr then
				addNewOrder(WL.GameOrderEvent.Create(assignedPlayer, solvedStr, solvedVisibility));
			end
		end

		return solvedAll;
	end

	for playerId, stored in pairs(Mod.PlayerGameData) do
		local serverPlayer = game.ServerGame.Game.Players[playerId];

		if serverPlayer.State == WL.GamePlayerState.Playing then
			local teamId = getTeamId(playerId);
			local soloSum = getSoloGuessSum(playerId);

			if teamId then
				if not teamGuessesSum[teamId] then
					teamGuessesSum[teamId] = 0;
				end

				teamGuessesSum[teamId] = teamGuessesSum[teamId] + soloSum;
			else
				local solvedAll = doGuessing(stored.lastGuessed, soloSum, nil, playerId);

				if solvedAll then
					addNewOrder(WL.GameOrderEvent.Create(playerId, 'Entered all cheat code combinations', nil));
					addNewOrder(sell({playerId}));
				end
			end
		end
	end

	for teamId, teamSum in pairs(teamGuessesSum) do
		local solvedAll = doGuessing(Mod.PrivateGameData.cheatCodeProgress[teamId].lastGuessed, teamSum, teamId, nil);

		if solvedAll then
			local playersInTeam = Mod.PublicGameData.teams.teamed.byTeamId[teamId];

			addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, 'Team ' .. teamIdToTeamName(teamId) .. ' entered all cheat code combinations', nil));
			addNewOrder(sell(playersInTeam));
		end
	end
end

function sell(playerIds)
	local event = WL.GameOrderEvent.Create(WL.PlayerID.Neutral, 'Sell all hackers and offices @ ' .. Mod.Settings.SellPerCent .. '%', playerIds);
	local s = {};

	for _, playerId in pairs(playerIds) do
		s[playerId] = {};
		s[playerId][WL.ResourceType.Gold] = round(calcOverallCost(playerId) * (Mod.Settings.SellPerCent / 100));
		bought[playerId] = nil;
	end

	event.AddResourceOpt = s;

	return event;
end

function calcOverallCost(playerId)
	local playerGameData = Mod.PlayerGameData;

	local total = playerGameData[playerId].numOffices * Mod.Settings.OfficeCost;
	Mod.PlayerGameData[playerId].numOffices = 0;

	for _, hacker in pairs(playerGameData[playerId].hackers.list) do
		local upgradeNo = hacker.upgradeNo;

		while upgradeNo > 0 do
			local hackerType = Mod.PublicGameData.hackerTypes[upgradeNo];
			total = total + hackerType.cost;
			upgradeNo = upgradeNo - 1;
		end
	end

	playerGameData[playerId].hackers.list = {};
	playerGameData[playerId].hackers.length = 0;

	playerGameData[playerId].doneAllCombos = true;

	Mod.PlayerGameData = playerGameData;
	return total;
end

function decideRCVal(game)
	local rc = game.Settings.Cards[WL.CardID.Reinforcement];

	if rc.Mode == 0 then
		-- fixed armies
		return rc.FixedArmies;
	elseif rc.Mode == 1 then
		-- progressive by territories owned by players
		return rc.ProgressivePercentage * numTerritoriesOwnedByPlayers(game.ServerGame.LatestTurnStanding.Territories);
	else
		-- progressive by turn no
		return rc.ProgressivePercentage * (game.ServerGame.Game.NumberOfTurns + 1);
	end
end

function numTerritoriesOwnedByPlayers(territories)
	local i = 0;

	for _, territory in pairs(territories) do
		if not territory.IsNeutral then
			i = i + 1;
		end
	end

	return i;
end

function useEveryonesCodes(game, addNewOrder)
	local playerGameData = Mod.PlayerGameData;
	local solvedVisibility = nil;

	if Mod.Settings.CheatCodeSolvedVisibiltyIsTeamOnly then
		solvedVisibility = {};
	end

	for playerId, stored in pairs(playerGameData) do
		local serverPlayer = game.ServerGame.Game.Players[playerId];

		if serverPlayer.State == WL.GamePlayerState.Playing then
			useCodes(game, addNewOrder, playerId, playerGameData, solvedVisibility);
		end

		playerGameData[playerId].cheatCodesToUse = {};
	end

	Mod.PlayerGameData = playerGameData;
end

function useCodes(game, addNewOrder, playerId, playerGameData, solvedVisibility)
	if solvedVisibility ~= nil then
		local numCodes = tbllen(playerGameData[playerId].cheatCodesToUse);
		local msg;

		if numCodes > 0 then
			if numCodes == 1 then
				msg = 'A cheat code';
			else
				msg = tostring(numCodes) .. ' cheat codes';
			end

			msg = msg .. ' will be used by someone';

			-- passing player id makes the assigned player see it, even if no said in visibility
			addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, msg, nil));
		end
	end

	for codeUsed, _ in pairs(playerGameData[playerId].cheatCodesToUse) do
		addNewOrder(WL.GameOrderEvent.Create(playerId, 'Used cheat code ' .. codeUsed, solvedVisibility));

		for _, cardId in pairs(Mod.PrivateGameData.cheatCodes[codeUsed]) do
			-- https://www.warzone.com/wiki/Mod_API_Reference:GameOrderReceiveCard
			local cardInstance;

			if cardId == WL.CardID.Reinforcement then
				cardInstance = WL.ReinforcementCardInstance.Create(decideRCVal(game));
			else
				cardInstance = WL.NoParameterCardInstance.Create(cardId);
			end

			addNewOrder(WL.GameOrderReceiveCard.Create(playerId, {cardInstance}));
		end
	end
end