require('settings');
require('number_util');
require('tblprint');

function Server_Created(game, settings)
	settings.AllowAttackOnly = randomBool();
	settings.AllowPercentageAttacks = randomBool();
	settings.AllowTransferOnly = randomBool();

	if randomBool() then
		settings.ArmyCap = math.random(1, 40);
	else
		settings.ArmyCap = nil;
	end

	if randomBool() then
		settings.BonusArmyPer = math.random(1, 15);
	else
		settings.BonusArmyPer = 0;
	end

	settings.Commanders = randomBool();

	if getSetting('UseRandomCommerce') then
		settings.CommerceArmyCostMultiplier = math.random(0, 15);
		settings.CommerceCityBaseCost = randomBool() and math.random(1, 10) or nil;
	end

	if not settings.CustomScenario then
		settings.AutomaticTerritoryDistribution = randomBool();

		if getSetting('UseRandomDistMode') then
			-- 0 full dist; -1 random warlords; -2 random cities
			-- >0 ones the map maker made, no way to know how much teams/players are supposed to be in which one

			settings.DistributionModeID = -math.random(0, 2);
		end

		settings.InitialNeutralsInDistribution = math.random(0, 15);
		settings.InitialNonDistributionArmies = math.random(0, 15);
		settings.InitialPlayerArmiesPerTerritory = math.random(settings.OneArmyMustStandGuardOneOrZero, 15);
		settings.LimitDistributionTerritories = math.random(0, 15);-- 0 means no limit

		if randomBool() then
			settings.NumberOfWastelands = math.random(1, 15);
			settings.WastelandSize = math.random(0, 100);
		else
			settings.NumberOfWastelands = 0;
		end
	end

	-- no higher than normal fog otherwise gets messy with random settings
	local fogLevels = {
		'NoFog',
		'LightFog',
		'Foggy'
	};

	if getSetting('AllowHeavierFogs') then
		table.insert(fogLevels, 'ModerateFog');
		table.insert(fogLevels, 'VeryFoggy');
		table.insert(fogLevels, 'ExtremeFog');
	end

	settings.FogLevel = WL.GameFogLevel[fogLevels[math.random(1, #fogLevels)]];

	settings.RoundingMode = WL.RoundingModeEnum[(math.random(1, 2) == 1 and 'StraightRound' or 'WeightedRandom')];
	settings.LocalDeployments = randomBool();

	if getSetting('UseRandomLuckMod') then
		local randLuckMod = nil;

		if getSetting('LuckStrat') then
			randLuckMod = math.random(1, 2) == 1 and 0 or 0.16;
		else
			randLuckMod = randomFloat(0, 1);
		end

		settings.LuckModifier = randLuckMod;
	end

	settings.MinimumArmyBonus = math.random(1, 15);-- 1 to be on the safe side
	settings.MoveOrder = WL.MoveOrderEnum[(math.random(1, 2) == 1 and 'Cycle' or 'Random')];
	settings.MultiAttack = randomBool();
	settings.NoSplit = randomBool();

	if getSetting('RandomiseArmiesStandGuard') then
		settings.OneArmyStandsGuard = randomBool();
	end

	if getSetting('UseRandomKillRates') then
		settings.OffenseKillRate = math.random(5, 100);
		settings.DefenseKillRate  = math.random(0, 100);
	end

	randomiseCards(settings);
end

function randomBool()
	return math.random(2) % 2 == 1;
end

function randomFloat(lower, greater)
	-- https://stackoverflow.com/questions/11548062/how-to-generate-random-float-in-lua#answer-18209644

	return round(lower + math.random()  * (greater - lower), 2);
end

function randomiseCards(settings)
	local cardParams = {
		[WL.CardID.EmergencyBlockade] = {
			-- isnt Abandon in WL.CardID
			randomFloat(1, 8)
		},
		[WL.CardID.Blockade] = {
			randomFloat(1, 8)
		},
		[WL.CardID.Diplomacy] = {
			math.random(1, 10)
		},
		[WL.CardID.Reconnaissance] = {
			math.random(1, 10)
		},
		[WL.CardID.Sanctions] = {
			math.random(1, 10),
			randomFloat(0.01, 1)
		},
		[WL.CardID.Spy] = {
			math.random(1, 10),
			randomBool()
		},
		[WL.CardID.Surveillance] = {
			math.random(1, 10)
		},
		[WL.CardID.Reinforcement] = {
			WL.ReinforcementCardMode.Fixed,
			0,
			math.random(1, 15)
		}
	};

	function getCardParam(cardId, paramNo)
		local cardParam = cardParams[cardId];

		if not cardParam then
			return nil;
		end

		return cardParam[paramNo];
	end

	local mustForceEnabelAtleastOneOf = {
		forcing = false,
		atLeast1Enabeled = false
	};

	if (
		getSetting('AllowHeavierFogs') and
		getSetting('ForceHeavierFogCards') and
		(
			settings.FogLevel == WL.GameFogLevel.ModerateFog or
			settings.FogLevel == WL.GameFogLevel.VeryFoggy or
			settings.FogLevel == WL.GameFogLevel.ExtremeFog
		)
	) then
		mustForceEnabelAtleastOneOf.forcing = true;
		mustForceEnabelAtleastOneOf.Reconnaissance = true;
		mustForceEnabelAtleastOneOf.Surveillance = true;
		mustForceEnabelAtleastOneOf.Spy = true;
	end

	local cards = {};
	local numCardsInGame = 0;

	for cardName, cardId in pairs(WL.CardID) do
		if cardName == 'EmergencyBlockade' then
			cardName = 'Abandon';
		end

		if (
			randomBool() or
			(
				mustForceEnabelAtleastOneOf.forcing and
				not mustForceEnabelAtleastOneOf.atLeast1Enabeled
			)
		) then
			local pieces = math.random(1, 10);
			local minPerTurn = 1;
			local weight = 1;
			local initialPieces = 0;

			cards[cardId] = (
				WL['CardGame' .. cardName]
					.Create(
						pieces,
						minPerTurn,
						weight,
						initialPieces,
						getCardParam(cardId, 1),
						getCardParam(cardId, 2),
						getCardParam(cardId, 3)
					)
			);

			numCardsInGame = numCardsInGame + 1;

			if mustForceEnabelAtleastOneOf[cardName] then
				mustForceEnabelAtleastOneOf.atLeast1Enabeled = true;
			end
		end
	end

	if numCardsInGame > 0 then
		settings.Cards = cards;
		settings.MaxCardsHold = math.random(0, 15);
		settings.NumberOfCardsToReceiveEachTurn = numCardsInGame;

		if getSetting('RandomiseCardsHeldVisibility') then
			settings.CardHoldingsAndReceivesFogged = randomBool();
		end

		if getSetting('RandomiseCardsPlayedVisibility') then
			settings.CardPlayingsFogged = randomBool();
		end
	else
		settings.Cards = nil;
		settings.MaxCardsHold = 0;
		settings.NumberOfCardsToReceiveEachTurn = 0;
	end
end
