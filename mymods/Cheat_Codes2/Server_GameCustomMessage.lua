require 'util';
require 'teams';

function Server_GameCustomMessage(game, playerId, payload, setReturn)
	if not payload then
		return;
	end

	local ret = {};

	if payload.useCode ~= nil then
		ret = useCode(playerId, payload.useCode);
	elseif payload.unuseCode ~= nil then
		ret = unuseCode(playerId, payload.unuseCode);
	elseif payload.getTeamSolvedCodes ~= nil then
		ret = getTeamSolvedCodes(playerId);
	end

	setReturn(ret);
end

function useCode(playerId, code)
	local playerGameData = Mod.PlayerGameData;
	local codeNo = tbllen(playerGameData[playerId].cheatCodesToUse);

	if codeNo >= Mod.Settings.MaxCheatCodesUsedPerTurn then
		return playerGameData[playerId].cheatCodesToUse;
	end

	if teamHasSolvedCode(playerId, code) then
		playerGameData[playerId].cheatCodesToUse[code] = true;-- makes finding a code faster
	end

	Mod.PlayerGameData = playerGameData;

	return Mod.PlayerGameData[playerId].cheatCodesToUse;
end

function unuseCode(playerId, code)
	local playerGameData = Mod.PlayerGameData;
	playerGameData[playerId].cheatCodesToUse[code] = nil;
	Mod.PlayerGameData = playerGameData;

	return Mod.PlayerGameData[playerId].cheatCodesToUse;
end