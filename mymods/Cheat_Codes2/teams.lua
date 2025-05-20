function getTeamId(playerId)
	return Mod.PublicGameData.teams.teamed.playerTeam[playerId];
end

function teamIdToTeamName(teamId)
	local lettersInAlphabet = 26;
	local name = '';

	while teamId > -1 do
		name = name .. string.char(teamId + 65);
		teamId = teamId - lettersInAlphabet;
	end

	return name;
end

function getTeamSolvedCodes(playerId)
	local teamId = getTeamId(playerId);

	if teamId then
		return Mod.PrivateGameData.cheatCodeProgress[teamId].solvedCheatCodes;
	else
		return Mod.PlayerGameData[playerId].solvedCheatCodes;
	end
end

function teamHasSolvedCode(playerId, code)
	return getTeamSolvedCodes(playerId)[code];
end