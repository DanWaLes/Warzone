require('tblprint');
require('version');

local debug = false;

function Server_Created(game, settings)
	if not debug and not settings.MapTestingGame then
		return;
	end

	if not serverCanRunMod(game) then
		return;
	end

	settings.RankedGame = false;
	settings.BootedPlayersTurnIntoAIs = true;
	settings.SurrenderedPlayersTurnIntoAIs = true;
	settings.TimesCanComeBackFromAI = 0;

	settings.AIsSurrenderWhenOneHumanRemains = false;
	settings.AtStartDivideIntoTeamsOf = 1;
	settings.FogLevel = WL.GameFogLevel.NoFog;

	settings.AutomaticTerritoryDistribution = true;
	settings.LimitDistributionTerritories = 1;
	settings.InitialPlayerArmiesPerTerritory = 0;
	settings.InitialNeutralsInDistribution = 0;
	settings.InitialNonDistributionArmies = 0;
	settings.NumberOfWastelands = 0;

	settings.MinimumArmyBonus = 0;
	settings.BonusArmyPer = 0;
	settings.ArmyCap = nil;
	settings.LocalDeployments = false;
	settings.Cards = nil;
	settings.CommerceArmyCostMultiplier = nil;
	settings.CommerceCityBaseCost = nil;

	settings.NoSplit = false;
	settings.MultiAttack = false;
	settings.Commanders = false;

	-- easier to calculate
	settings.OneArmyStandsGuard = false;
	settings.LuckModifier = 0;
	settings.OffenseKillRate = 1;-- means 100%
	settings.DefenseKillRate = 1;
	settings.RoundingMode = WL.RoundingModeEnum.StraightRound;

	listTerritoryNamesAlphabetically(game);
end

function listTerritoryNamesAlphabetically(game)
	local names = {};

	for _, terr in pairs(game.Map.Territories) do
		table.insert(names, {id = terr.ID, name = terr.Name});
	end

	-- a to z
	-- https://stackoverflow.com/questions/71084051/how-do-i-sort-a-simple-lua-table-alphabetically#answer-71084344
	table.sort(names, function(a, b)
		return a.name < b.name;
	end);

	Mod.PublicGameData = {terrNames = names};
end
