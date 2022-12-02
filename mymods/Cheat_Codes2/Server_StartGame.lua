require 'util'

function Server_StartGame(game)
	local cheatCodes = generateCheatCodes(game);
	local teams = getTeams(game);
	local hackersData = calcHackersData();

	local publicGameData = Mod.PublicGameData;
	publicGameData.teams = teams;
	publicGameData.hackerTypes = hackersData;

	Mod.PublicGameData = publicGameData;

	local playerGameData = Mod.PlayerGameData;
	for playerId, _ in pairs(game.ServerGame.Game.Players) do
		playerGameData[playerId] = {
			hackers = {
				list = {},
				length = 0,
				lastBoughtOnTurn = -1
			},
			numOffices = 0,
			cheatCodesToUse = {}
		};
	end

	for _, playerId in pairs(teams.noTeam) do
		playerGameData[playerId].lastGuessed = -1;
		playerGameData[playerId].solvedCheatCodes = {};
	end

	Mod.PlayerGameData = playerGameData;

	local privateGameData = Mod.PrivateGameData;

	privateGameData.cheatCodes = cheatCodes;

	privateGameData.cheatCodeProgress = {};
	for teamId, _ in pairs(teams.teamed.byTeamId) do
		privateGameData.cheatCodeProgress[teamId] = {
			lastGuessed = -1,
			solvedCheatCodes = {}
		};
	end

	Mod.PrivateGameData = privateGameData;
end

function generateCheatCodes(game)
	local cheatCodes = {};

	for id, _ in pairs(game.Settings.Cards) do
		local code = generateCheatCode();

		if not cheatCodes[code] then
			cheatCodes[code] = {};
		end

		table.insert(cheatCodes[code], id);
	end

	return cheatCodes;
end

function generateCheatCode()
	-- codes dont have to be unique
	local code = '';
	local i = 0;

	while true do
		if i == Mod.Settings.CheatCodeLength then
			break;
		end

		code = code .. math.random(0, 9);
		i = i + 1;
	end

	return code;
end

function getTeams(game)
	local teams = {
		noTeam = {},
		teamed = {
			byTeamId = {},
			playerTeam = {}
		}
	};

	for playerId, player in pairs(game.ServerGame.Game.Players) do
		if player.Team == -1 then
			table.insert(teams.noTeam, playerId);
		else
			if not teams.teamed.byTeamId[player.Team] then
				teams.teamed.byTeamId[player.Team] = {};
			end
			table.insert(teams.teamed.byTeamId[player.Team], playerId);

			teams.teamed.playerTeam[playerId] = player.Team;
		end
	end

	return teams;
end

function calcHackersData()
	local hackersData = {};
	local increase = 0.25;
	local multiplier = 1;
	local i = 1;
	local names = {'Trainee', 'Junior', 'Mid-level', 'Senior', 'Lead'};

	while true do
		if i > 5 then
			break;
		end

		local data = {
			name = names[i],
			cost = round(Mod.Settings.HackerBaseCost * multiplier),
			guessesPerTurn = round(((10 ^ Mod.Settings.CheatCodeLength) / Mod.Settings.SpeedH1) * multiplier, 2)
		};
		table.insert(hackersData, data);

		multiplier = multiplier + increase;
		i = i + 1;
	end

	return hackersData;
end