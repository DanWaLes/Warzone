require '_util';
require '_settings';

function Server_StartGame(game)
	local teams = {};
	local cardPieces = {
		noTeam = {},
		teammed = {}
	};
	local playerGD = Mod.PlayerGameData;
	local teamsNeedingShownReceivedCardsMsg = {};

	function addStartingPieces(player)
		local team = player.Team == -1 and player.ID or player.Team;
		local cards = {'Reconnaissance+'};

		for _, cardName in pairs(cards) do
			if getSetting('Enable' .. cardName) then
				local startingPieces = getSetting(cardName .. 'StartPieces');
				local piecesInCard = getSetting(cardName .. 'PiecesInCard');

				if player.Team == -1 then
					cardPieces.noTeam[team].currentPieces[cardName] = startingPieces;

					if startingPieces > 0 and not cardPieces.noTeam[team].receivedPieces then
						cardPieces.noTeam[team].receivedPieces = {};
					end
					cardPieces.noTeam[team].receivedPieces[cardName] = startingPieces;

					if cardPieces.noTeam[team].currentPieces[cardName] >= piecesInCard then
						playerGD[team].shownReceivedCardsMsg = false;
						print('need to show received cards msg for player ' .. team);
					end
				else
					if not cardPieces.teammed[team].currentPieces[cardName] then
						cardPieces.teammed[team].currentPieces[cardName] = 0;
					end

					cardPieces.teammed[team].currentPieces[cardName] = cardPieces.teammed[team].currentPieces[cardName] + startingPieces;

					if cardPieces.teammed[team].currentPieces[cardName] >= piecesInCard then
						table.insert(teamsNeedingShownReceivedCardsMsg, team);
					end

					if startingPieces > 0 and not cardPieces.teammed[team].receivedPieces then
						cardPieces.noTeam[team].receivedPieces = {};
					end
					cardPieces.noTeam[team].receivedPieces[cardName] = cardPieces.teammed[team].currentPieces[cardName];
				end
			end
		end
	end

	for playerId, player in pairs(game.ServerGame.Game.Players) do
		if player.Team == -1 then
			cardPieces.noTeam[playerId] = {
				currentPieces = {},
				receivedPieces = nil
			};
		else
			if not teams[player.Team] then
				teams[player.Team] = {
					members = {}
				};

				cardPieces[player.Team] = {
					currentPieces = {},
					receivedPieces = nil
				};
			end

			table.insert(teams[player.Team].members, playerId);
		end

		playerGD[playerId] = {
			prefShowReceivedCardsMsg = true,
			shownReceivedCardsMsg = true
		};

		addStartingPieces(player);
	end

	for _, teamId in pairs(teamsNeedingShownReceivedCardsMsg) do
		for _, playerId in pairs(teams[teamId].members) do
			playerGD[playerId].shownReceivedCardsMsg = false;
			print('need to show received cards msg for player ' .. playerId);
		end
	end

	Mod.PublicGameData = {
		teams = teams,
		cardPieces = cardPieces
	};

	Mod.PlayerGameData = playerGD;
end